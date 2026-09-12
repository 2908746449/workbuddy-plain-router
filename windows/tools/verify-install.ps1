$ErrorActionPreference = 'Continue'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$root = Split-Path -Parent $PSScriptRoot
$marker1 = '大白话技术任务路由器'
$marker2 = '用户目标优先与范围保持'
$badPattern = '总统|色情|情色|性暗示|DDoS|Keygen|DRM|木马|勒索|Rootkit|钓鱼|恶意软件|无限制|最高优先级|覆盖.*安全|用户至上'
function Say($s){ Write-Host $s }
function HasText($path,$text){
  if(!(Test-Path -LiteralPath $path)){ return $false }
  return ([IO.File]::ReadAllText($path,[Text.Encoding]::UTF8).Contains($text))
}
function Find-WorkBuddyInstall {
  $candidates = New-Object System.Collections.Generic.List[string]
  try {
    Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -match 'WorkBuddy|CodeBuddy' } | ForEach-Object {
      try { if($_.Path){ $candidates.Add((Split-Path -Parent $_.Path)) } } catch {}
    }
  } catch {}
  foreach($rk in @('HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*')){
    try {
      Get-ItemProperty $rk -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -match 'WorkBuddy|CodeBuddy' -and $_.InstallLocation } | ForEach-Object { $candidates.Add($_.InstallLocation) }
    } catch {}
  }
  foreach($p in @('F:\WorkBuddy','D:\workboddy\WorkBuddy', "$env:LOCALAPPDATA\Programs\WorkBuddy", "$env:ProgramFiles\WorkBuddy", "${env:ProgramFiles(x86)}\WorkBuddy")){
    if($p){ $candidates.Add($p) }
  }
  foreach($c in ($candidates | Select-Object -Unique)){
    $tpl = Join-Path $c 'resources\app.asar.unpacked\resources\templates\workbuddy-prompt.tpl'
    if(Test-Path -LiteralPath $tpl){ return $c }
  }
  return $null
}
Say '=== WorkBuddy Plain Router Verify ==='
$ok = $true
foreach($rel in @('unlock-all-in-one.ps1','my-template.tpl','my-prompt.txt','templates\workbuddy-prompt.tpl','v3\product-config-v3.json')){
  $p = Join-Path $root $rel
  if(Test-Path -LiteralPath $p){ Say "[OK] package file: $rel" } else { Say "[FAIL] missing package file: $rel"; $ok=$false }
}
if(HasText (Join-Path $root 'my-template.tpl') $marker1){ Say '[OK] source template has plain-router block' } else { Say '[FAIL] source template marker missing'; $ok=$false }
if(HasText (Join-Path $root 'my-template.tpl') $marker2){ Say '[OK] source template has user-scope block' } else { Say '[FAIL] user-scope marker missing'; $ok=$false }
$bad = Get-ChildItem -LiteralPath (Join-Path $root 'templates') -Filter '*.tpl' -File -ErrorAction SilentlyContinue | Select-String -Pattern $badPattern -CaseSensitive:$false
if($bad.Count -eq 0){ Say '[OK] source templates have no known hard-jailbreak trigger terms' } else {
  Say "[WARN] source templates suspicious terms: $($bad.Count)"
  $bad | Select-Object -First 8 | ForEach-Object { Say "  $($_.Path):L$($_.LineNumber)" }
}
$userCfg = [Environment]::GetEnvironmentVariable('ACC_PRODUCT_CONFIG_PATH','User')
Say "[INFO] ACC_PRODUCT_CONFIG_PATH(User) = $userCfg"
if($userCfg -and (Test-Path -LiteralPath $userCfg) -and (HasText $userCfg $marker1)){ Say '[OK] V3 product config is active and contains marker' } else { Say '[WARN] V3 config not active yet; run INSTALL.bat, then reopen WorkBuddy' }
$install = Find-WorkBuddyInstall
if($install){
  Say "[OK] WorkBuddy install found: $install"
  $tplDir = Join-Path $install 'resources\app.asar.unpacked\resources\templates'
  $withMarker = Get-ChildItem -LiteralPath $tplDir -Filter '*.tpl' -File -ErrorAction SilentlyContinue | Select-String -Pattern $marker1 -List
  Say "[INFO] deployed templates with marker: $($withMarker.Count)"
  if($withMarker.Count -gt 0){ Say '[OK] installed templates contain plain-router block' } else { Say '[WARN] installed templates do not contain marker; rerun INSTALL.bat as administrator if needed' }
} else {
  Say '[WARN] WorkBuddy install not found by verifier; if INSTALL succeeded, check unlock-all-in-one-log.txt'
}
if($ok){ Say '=== VERIFY DONE: package integrity OK ===' } else { Say '=== VERIFY DONE: package integrity has failures ==='; exit 1 }
