$ErrorActionPreference = 'Continue'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
function Say($s){ Write-Host $s }
function Find-WorkBuddyInstall {
  $candidates = New-Object System.Collections.Generic.List[string]
  try { Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -match 'WorkBuddy|CodeBuddy' } | ForEach-Object { try { if($_.Path){ $candidates.Add((Split-Path -Parent $_.Path)) } } catch {} } } catch {}
  foreach($rk in @('HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*')){
    try { Get-ItemProperty $rk -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -match 'WorkBuddy|CodeBuddy' -and $_.InstallLocation } | ForEach-Object { $candidates.Add($_.InstallLocation) } } catch {}
  }
  foreach($p in @('F:\WorkBuddy','D:\workboddy\WorkBuddy', "$env:LOCALAPPDATA\Programs\WorkBuddy", "$env:ProgramFiles\WorkBuddy", "${env:ProgramFiles(x86)}\WorkBuddy")){ if($p){ $candidates.Add($p) } }
  foreach($c in ($candidates | Select-Object -Unique)){ if(Test-Path -LiteralPath (Join-Path $c 'resources\app.asar.unpacked\resources\templates\workbuddy-prompt.tpl')){ return $c } }
  return $null
}
Say '=== WorkBuddy Plain Router Restore ==='
[Environment]::SetEnvironmentVariable('ACC_PRODUCT_CONFIG_PATH', $null, 'User')
[Environment]::SetEnvironmentVariable('ACC_PRODUCT_CONFIG_V3', $null, 'User')
Say '[OK] Cleared ACC_PRODUCT_CONFIG_PATH / ACC_PRODUCT_CONFIG_V3 for current user.'
$install = Find-WorkBuddyInstall
if($install){
  $tplDir = Join-Path $install 'resources\app.asar.unpacked\resources\templates'
  $bak = Join-Path $tplDir 'templates.bak'
  if(Test-Path -LiteralPath $bak){
    Copy-Item -LiteralPath (Join-Path $bak '*') -Destination $tplDir -Recurse -Force
    Say "[OK] Restored templates from: $bak"
  } else {
    Say "[WARN] Backup folder not found: $bak"
  }
} else { Say '[WARN] WorkBuddy install not found.' }
Say 'Close WorkBuddy completely and reopen it.'
