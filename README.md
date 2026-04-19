Cloudflare IP 优选工具
一个全自动的 Cloudflare CDN 节点优选工具，通过 TCP 延迟筛选 + IP 可用性二次检测 + 真实带宽测速 三重机制筛选出速度最快的节点，并将结果自动推送到 GitHub 仓库，同时支持微信实时通知。

⚠️ 重要提示：本工具 仅支持 Windows 操作系统。自动推送功能依赖 PowerShell 脚本 git_sync.ps1，Linux / macOS 无法直接使用（除非自行实现等效 Shell 脚本）。

📦 文件清单
文件	说明
main.py	核心程序，负责抓取节点、TCP测试、可用性检测、带宽测速、保存结果
config.json	配置文件（已存在），所有运行参数均在此修改
git_sync.ps1	PowerShell 脚本，用于将 ip.txt 强制推送到 GitHub
setup.ps1	一键安装环境脚本（需管理员权限）
ip.txt	程序运行后生成的优选节点列表（每次运行会覆盖）
🖥️ 系统要求
操作系统：Windows 10 / Windows Server 2016 或更高版本

必备软件：

Python 3.7+（需勾选“Add Python to PATH”）

Git

curl（需将 curl.exe 所在目录加入系统 PATH）

Python 依赖：requests 库

🚀 部署步骤（Windows）
1. 获取项目文件
bash

复制

下载
git clone https://github.com/你的用户名/仓库名.git
cd 仓库名
或直接下载 ZIP 并解压到本地文件夹。

2. 安装运行环境
方式一：一键安装脚本（推荐）
右键点击 setup.ps1，选择 “使用 PowerShell 运行”（请以管理员身份运行）。脚本会自动完成：

检测并安装 Python 3、Git、curl（通过 winget）

升级 pip 并安装 requests

方式二：手动安装
安装 Python、Git、curl（见系统要求）。

打开命令提示符，执行：

cmd

复制

下载
pip install requests
3. 修改配置文件 config.json
项目目录下已存在 config.json，请用文本编辑器（如记事本）打开并根据需要修改以下关键字段：

必填项（微信通知）
json

复制

下载
"WXPUSHER_APP_TOKEN": "你的APP_TOKEN",
"WXPUSHER_UIDS": ["你的UID"]
APP_TOKEN：在 WxPusher 管理后台 创建应用获取。

UID：关注 WxPusher 公众号后，点击“我的” → “UID” 获取。

可选项（运行参数）
参数	说明	默认值
USE_GLOBAL_MODE	true = 全球最优 N 个；false = 每个国家最优 N 个	true
GLOBAL_TOP_N	全局模式保留节点数	16
PER_COUNTRY_TOP_N	分国家模式每个国家保留节点数	1
TCP_PROBES	每个节点 TCP 测试次数	7
MIN_SUCCESS_RATE	TCP 最低成功率（0.0~1.0）	1.0
BANDWIDTH_CANDIDATES	进入带宽测速的候选节点数	32
MAX_WORKERS	TCP 并发线程数	150
TIMEOUT	TCP 连接超时（秒）	2.5
BANDWIDTH_SIZE_MB	测速下载文件大小（MB）	1
JSON_URL	节点列表源地址	https://zip.cm.edu.kg/all.txt
OUTPUT_FILE	结果保存文件名	ip.txt
其他参数详见 config.json 中的注释。

4. 配置 GitHub 自动推送（可选）
若需将生成的 ip.txt 自动推送到 GitHub 仓库，请编辑 git_sync.ps1 文件，修改以下三个变量：

powershell

复制

下载
$github_token = "ghp_xxxxxxxxxxxxxxxxxxxx"   # GitHub Personal Access Token
$github_username = "你的GitHub用户名"
$repo_name = "仓库名"
获取 Token 步骤：
GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic) → Generate new token (classic)，勾选 repo 权限，生成后复制。

🔐 安全提醒：切勿将包含真实 Token 的 git_sync.ps1 提交到公开仓库！建议将其加入 .gitignore。

另外，确保项目目录已与远程仓库关联：

bash

复制

下载
git init
git remote add origin https://github.com/你的用户名/仓库名.git
5. 运行程序
在项目文件夹地址栏输入 cmd 回车，执行：

cmd

复制

下载
python main.py
程序将依次输出：

获取节点列表

TCP 连接测试进度

候选节点可用性检测

带宽测速进度

最终优选节点列表

GitHub 推送结果（若已配置）

微信通知发送状态

运行结束后，当前目录下会生成 ip.txt，内容为筛选出的最优节点（每行格式 IP:端口#国家）。

🕒 设置定时自动运行
Windows 任务计划程序
打开“任务计划程序” → “创建基本任务”。

触发器：按需设置（如每天 03:00）。

操作：启动程序 → 程序或脚本：python，添加参数：main.py，起始于：项目文件夹路径。

其他平台
若在 Linux 下运行（需自行处理 GitHub 推送部分），可使用 cron 定时执行 python3 main.py。

❓ 常见问题
1. 运行提示 ModuleNotFoundError: No module named 'requests'
执行 pip install requests 安装依赖。

2. 带宽测速失败，显示 ⚠️ 未检测到 curl 命令
请确保 curl 已安装且所在目录已加入系统 PATH 环境变量。重启终端后再试。

3. 可用性检测全部失败，程序仍继续运行？
程序内置容错机制：若可用性 API 疑似失效（通过率为 0%），将自动跳过二次筛选，并使用原候选列表进行带宽测速，同时发送微信告警。

4. GitHub 推送失败？
检查 git_sync.ps1 中的 Token、用户名、仓库名是否正确。

确保仓库已初始化并关联远程。

在项目目录手动执行 git push 查看具体错误信息。

5. 微信收不到通知？
确认 ENABLE_WXPUSHER 为 true。

检查 WXPUSHER_APP_TOKEN 和 WXPUSHER_UIDS 填写无误。

登录 WxPusher 后台查看消息发送记录。

🙏 致谢
节点数据源由 cmliussss 维护。

可用性检测 API 由同一作者提供。

微信通知服务由 WxPusher 支持。

如果本项目对你有帮助，欢迎给个 ⭐ Star 支持一下！

📜 许可证
本项目采用 MIT License 开源，使用请遵守相关协议。

🤝 贡献
欢迎提交 Issue 或 Pull Request 帮助改进此工具。
