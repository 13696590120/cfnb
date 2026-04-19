# setup.ps1 - Cloudflare IP 优选工具环境一键安装脚本
# 使用方法：右键此文件 -> "使用 PowerShell 运行"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Cloudflare IP 优选工具 - 环境安装" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查是否以管理员身份运行（安装软件需要）
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ 错误：请以管理员身份运行此脚本！" -ForegroundColor Red
    Write-Host "方法：右键点击 setup.ps1 -> 选择 '使用 PowerShell 运行'。" -ForegroundColor Yellow
    pause
    exit 1
}

# 检测 winget 是否可用
$winget = Get-Command winget -ErrorAction SilentlyContinue
if (-not $winget) {
    Write-Host "❌ 未检测到 winget，无法自动安装软件。" -ForegroundColor Red
    Write-Host "请手动下载并安装以下组件：" -ForegroundColor White
    Write-Host "1. Python 3: https://www.python.org/downloads/" -ForegroundColor Yellow
    Write-Host "2. Git: https://git-scm.com/download/win" -ForegroundColor Yellow
    Write-Host "3. curl: https://curl.se/windows/" -ForegroundColor Yellow
    pause
    exit 1
}

# 1. 安装 Python 3
Write-Host "[1/4] 检查 Python..." -ForegroundColor Green
$python = Get-Command python -ErrorAction SilentlyContinue
if ($python) {
    Write-Host "✅ Python 已安装: $($python.Source)" -ForegroundColor Gray
} else {
    Write-Host "正在通过 winget 安装 Python 3..." -ForegroundColor Yellow
    winget install Python.Python.3 --accept-package-agreements --accept-source-agreements
    Write-Host "✅ Python 安装完成，请在脚本结束后重新打开终端以生效。" -ForegroundColor Green
}

# 2. 安装 Git
Write-Host "[2/4] 检查 Git..." -ForegroundColor Green
$git = Get-Command git -ErrorAction SilentlyContinue
if ($git) {
    Write-Host "✅ Git 已安装: $($git.Source)" -ForegroundColor Gray
} else {
    Write-Host "正在通过 winget 安装 Git..." -ForegroundColor Yellow
    winget install Git.Git --accept-package-agreements --accept-source-agreements
    Write-Host "✅ Git 安装完成。" -ForegroundColor Green
}

# 3. 安装 curl
Write-Host "[3/4] 检查 curl..." -ForegroundColor Green
$curl = Get-Command curl -ErrorAction SilentlyContinue
if ($curl) {
    Write-Host "✅ curl 已安装: $($curl.Source)" -ForegroundColor Gray
} else {
    Write-Host "正在通过 winget 安装 curl..." -ForegroundColor Yellow
    winget install cURL.cURL --accept-package-agreements --accept-source-agreements
    Write-Host "✅ curl 安装完成。" -ForegroundColor Green
}

# 4. 安装 Python 依赖 requests
Write-Host "[4/4] 安装 Python 包 requests..." -ForegroundColor Green
# 刷新环境变量（以便在不重启 PowerShell 的情况下尝试调用新安装的 python）
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
python -m pip install --upgrade pip
python -m pip install requests
Write-Host "✅ requests 库安装完成。" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " 🎉 环境安装完毕！" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "👉 接下来请完成以下配置步骤：" -ForegroundColor White
Write-Host "1. 【安全核心】在项目目录创建 .gitignore 文件，填入：config.json 和 git_sync.ps1" -ForegroundColor Yellow
Write-Host "2. 编辑 config.json，填写 WxPusher 的 APP_TOKEN 和 UID" -ForegroundColor White
Write-Host "3. 编辑 git_sync.ps1，填写你的 GitHub Token、用户名及仓库名" -ForegroundColor White
Write-Host "4. 在项目文件夹地址栏输入 cmd 并回车，执行：python main.py" -ForegroundColor Green
Write-Host ""
pause