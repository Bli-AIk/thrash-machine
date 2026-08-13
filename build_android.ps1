# build_android.ps1 - Windows one-click Android build launcher.
#
#   build_android.cmd            -> interactive menu (wrap / compile)
#   build_android.cmd wrap       -> quick wrapper APK  (official LÖVE shell + game.love)
#   build_android.cmd compile    -> full APK from source (needs Android SDK + NDK)
#
# The launcher installs whatever is missing into .tools\ (PortableGit, JDK 17,
# LÖVE 11.5, and for compile mode the Android cmdline-tools/SDK/NDK), then runs
# the matching bash script through Git Bash.

param(
    [ValidateSet('menu', 'wrap', 'compile')]
    [string]$Mode = 'menu'
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Tools = Join-Path $Root '.tools'

# --- tiny helpers -------------------------------------------------------------

function Invoke-Download([string]$Url, [string]$OutFile) {
    Write-Host "正在下载 $(Split-Path -Leaf $OutFile) ..."
    $dir = Split-Path -Parent $OutFile
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $Url -OutFile $OutFile
    if (-not (Test-Path $OutFile) -or (Get-Item $OutFile).Length -eq 0) {
        throw "下载失败: $Url"
    }
}

function Expand-Zip([string]$Zip, [string]$Dest) {
    if (-not (Test-Path $Dest)) { New-Item -ItemType Directory -Path $Dest -Force | Out-Null }
    Expand-Archive -LiteralPath $Zip -DestinationPath $Dest -Force
}

# --- tool detection / installation --------------------------------------------

function Get-GitBash {
    $candidates = @(
        (Join-Path $env:ProgramFiles 'Git\bin\bash.exe'),
        (Join-Path ${env:ProgramFiles(x86)} 'Git\bin\bash.exe'),
        (Join-Path $env:LOCALAPPDATA 'Programs\Git\bin\bash.exe'),
        (Join-Path $env:USERPROFILE 'AppData\Local\Programs\Git\bin\bash.exe')
    )
    foreach ($c in $candidates) {
        if ($c -and (Test-Path $c)) { return $c }
    }
    $cmd = Get-Command bash.exe -ErrorAction SilentlyContinue
    if ($cmd -and $cmd.Source -and $cmd.Source -notmatch '\\System32\\bash\.exe$') {
        return $cmd.Source
    }

    $ver = if ($env:THRASH_MACHINE_GIT_VERSION) { $env:THRASH_MACHINE_GIT_VERSION } else { '2.55.0.3' }
    $tag = 'v' + $ver.Substring(0, $ver.LastIndexOf('.')) + '.windows.' + $ver.Substring($ver.LastIndexOf('.') + 1)
    $sfxName = "PortableGit-$ver-64-bit.7z.exe"
    $sfx = Join-Path $Tools $sfxName
    $url = "https://github.com/git-for-windows/git/releases/download/$tag/$sfxName"
    if (-not (Test-Path $sfx)) { Invoke-Download $url $sfx }
    $gitDir = Join-Path $Tools 'git'
    Write-Host "解压 PortableGit 到 .tools\git ..."
    & $sfx "-o$gitDir" -y | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'PortableGit 解压失败' }
    $bash = Join-Path $gitDir 'bin\bash.exe'
    if (-not (Test-Path $bash)) { throw "未找到 bash: $bash" }
    return $bash
}

function Test-Java17([string]$JavaExe) {
    if (-not $JavaExe -or -not (Test-Path $JavaExe)) { return $false }
    $v = (& $JavaExe -version 2>&1 | Select-Object -First 1)
    return ($v -match 'version "17')
}

function Get-JavaHome {
    # Explicit user override wins, whatever its version.
    if ($env:THRASH_MACHINE_ANDROID_JAVA_HOME -and
        (Test-Path (Join-Path $env:THRASH_MACHINE_ANDROID_JAVA_HOME 'bin\java.exe'))) {
        return $env:THRASH_MACHINE_ANDROID_JAVA_HOME
    }
    # Compile mode requires exactly JDK 17, so a 17 on PATH/JAVA_HOME avoids
    # the ~190 MB download; other JDKs are ignored and a fresh 17 is installed.
    $java = Get-Command java.exe -ErrorAction SilentlyContinue
    if ($java -and $java.Source -and (Test-Java17 $java.Source)) {
        return Split-Path (Split-Path $java.Source -Parent) -Parent
    }
    if ($env:JAVA_HOME -and (Test-Java17 (Join-Path $env:JAVA_HOME 'bin\java.exe'))) {
        return $env:JAVA_HOME
    }
    $jdkDir = Join-Path $Tools 'jdk-17'
    $sub = Get-ChildItem $jdkDir -Directory -ErrorAction SilentlyContinue |
        Where-Object { Test-Path (Join-Path $_.FullName 'bin\java.exe') } | Select-Object -First 1
    if ($sub) { return $sub.FullName }

    $zip = Join-Path $Tools 'jdk-17.zip'
    $url = 'https://api.adoptium.net/v3/binary/latest/17/ga/windows/x64/jdk/hotspot/normal/eclipse?project=jdk'
    if (-not (Test-Path $zip)) { Invoke-Download $url $zip }
    Write-Host '解压 JDK 17 到 .tools\jdk-17 ...'
    Expand-Zip $zip $jdkDir
    $sub = Get-ChildItem $jdkDir -Directory -ErrorAction SilentlyContinue |
        Where-Object { Test-Path (Join-Path $_.FullName 'bin\java.exe') } | Select-Object -First 1
    if (-not $sub) { throw 'JDK 17 解压后未找到 bin\java.exe' }
    return $sub.FullName
}

function Get-Love {
    if ($env:LOVE -and (Test-Path $env:LOVE)) { return $env:LOVE }
    $cmd = Get-Command love.exe -ErrorAction SilentlyContinue
    if ($cmd -and $cmd.Source) { return $cmd.Source }
    foreach ($c in @((Join-Path $env:ProgramFiles 'LOVE\love.exe'), (Join-Path $env:LOCALAPPDATA 'Programs\LOVE\love.exe'))) {
        if ($c -and (Test-Path $c)) { return $c }
    }

    $zip = Join-Path $Tools 'love-11.5-win64.zip'
    $url = 'https://github.com/love2d/love/releases/download/11.5/love-11.5-win64.zip'
    if (-not (Test-Path $zip)) { Invoke-Download $url $zip }
    $loveDir = Join-Path $Tools 'love'
    Write-Host '解压 LÖVE 11.5 到 .tools\love ...'
    Expand-Zip $zip $loveDir
    $exe = Get-ChildItem $loveDir -Recurse -Filter love.exe -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if (-not $exe) { throw 'LÖVE 解压后未找到 love.exe' }
    return $exe.FullName
}

function Get-AndroidSdk([string]$JavaHome) {
    foreach ($s in @($env:ANDROID_SDK_ROOT, $env:ANDROID_HOME)) {
        if ($s -and (Test-Path (Join-Path $s 'platforms\android-34')) -and
            (Test-Path (Join-Path $s 'build-tools\34.0.0')) -and
            (Test-Path (Join-Path $s 'ndk\25.2.9519653'))) { return $s }
    }
    $sdkDir = Join-Path $Tools 'android-sdk'
    $sdkManager = Join-Path $sdkDir 'cmdline-tools\latest\bin\sdkmanager.bat'
    if (-not (Test-Path $sdkManager)) {
        $zip = Join-Path $Tools 'commandlinetools-win-latest.zip'
        $url = 'https://dl.google.com/android/repository/commandlinetools-win-9862592_latest.zip'
        if (-not (Test-Path $zip)) { Invoke-Download $url $zip }
        $tmp = Join-Path $sdkDir 'cmdline-tools-tmp'
        Write-Host '解压 Android cmdline-tools ...'
        Expand-Zip $zip $tmp
        $inner = Join-Path $tmp 'cmdline-tools'
        if (-not (Test-Path $inner)) { throw 'cmdline-tools 压缩包结构异常' }
        $latest = Join-Path $sdkDir 'cmdline-tools\latest'
        if (Test-Path $latest) { Remove-Item $latest -Recurse -Force }
        New-Item -ItemType Directory -Path (Split-Path -Parent $latest) -Force | Out-Null
        Move-Item $inner $latest
        Remove-Item $tmp -Recurse -Force
    }
    if (-not (Test-Path (Join-Path $sdkDir 'platforms\android-34')) -or
        -not (Test-Path (Join-Path $sdkDir 'build-tools\34.0.0')) -or
        -not (Test-Path (Join-Path $sdkDir 'ndk\25.2.9519653'))) {
        Write-Host '安装 Android SDK 组件（platforms;android-34 / build-tools;34.0.0 / ndk;25.2.9519653，首次约 1.5 GB）...'
        $sdkManager = Join-Path $sdkDir 'cmdline-tools\latest\bin\sdkmanager.bat'
        $env:JAVA_HOME = $JavaHome
        (1..60 | ForEach-Object { 'y' }) | & $sdkManager --sdk_root="$sdkDir" --licenses | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'sdkmanager --licenses 失败' }
        & $sdkManager --sdk_root="$sdkDir" 'platforms;android-34' 'build-tools;34.0.0' 'ndk;25.2.9519653'
        if ($LASTEXITCODE -ne 0) { throw 'sdkmanager 安装组件失败' }
    }
    return $sdkDir
}

# --- main ----------------------------------------------------------------------

if ($Mode -eq 'menu') {
    Write-Host ''
    Write-Host 'Thrash Machine - Android 打包'
    Write-Host '  1) 快速套包构建（推荐）：官方 LÖVE 壳 + 游戏 .love，自动下载工具，约 5 分钟'
    Write-Host '  2) 完整编译构建：从源码编译原生 APK（首次需下载约 1.5 GB Android SDK/NDK）'
    Write-Host ''
    $choice = Read-Host '请选择 (1/2)'
    if ($choice -eq '2') { $Mode = 'compile' } else { $Mode = 'wrap' }
}

$bash = Get-GitBash
$javaHome = Get-JavaHome
$loveExe = Get-Love
if ($Mode -eq 'compile') { $sdkDir = Get-AndroidSdk $javaHome }

# Export what the bash scripts expect. Use forward slashes for LÖVE so Git Bash
# can resolve it, and keep the interactive Kristal prompt off.
$env:THRASH_MACHINE_ANDROID_JAVA_HOME = $javaHome
$env:LOVE = $loveExe.Replace('\', '/')
$loveDir = Split-Path -Parent $loveExe
if (-not $env:PATH.Contains($loveDir)) { $env:PATH = "$loveDir;$env:PATH" }
$env:THRASH_MACHINE_KRISTAL_SOURCE = 'tag'
$env:THRASH_MACHINE_KRISTAL_REF = 'v0.10.0'
if ($Mode -eq 'compile') {
    $env:ANDROID_SDK_ROOT = $sdkDir
}

$script = if ($Mode -eq 'compile') { './build_android.sh' } else { './build_android_wrap.sh' }
Write-Host "启动 Git Bash: $script"
$rootFwd = $Root.Replace('\', '/')
& $bash -lc "cd `"$rootFwd`" && $script"
$code = $LASTEXITCODE
if ($code -ne 0) {
    Write-Host "构建失败（退出码 $code），请查看上方日志。" -ForegroundColor Red
    exit $code
}

$dist = Join-Path $Root 'dist'
if (Test-Path $dist) { Start-Process explorer.exe -ArgumentList $dist }
Write-Host '构建完成！APK 在 dist 目录。'
exit 0
