---
# Cloudflare IP 优选工具

这是一个全自动的 **Cloudflare CDN 节点优选工具**。它通过 **TCP 延迟筛选** + **IP 可用性二次检测** + **真实带宽测速** 三重机制，从海量公开节点中筛选出当前网络环境下速度最快、可用性最高的 Cloudflare IP，并将结果自动推送到 GitHub 仓库，同时支持微信实时通知。

> [!IMPORTANT]
> **跨平台支持**：本工具同时兼容 **Windows** 和 **Linux** 操作系统。
> - Windows 自动推送依赖 PowerShell 脚本 `git_sync.ps1`
> - Linux 自动推送依赖 Bash 脚本 `git_sync.sh`

---

## ✨ 功能特性

| 模块 | 说明 |
| :--- | :--- |
| 🌐 **多模式筛选** | 支持 **全局最优 TopN** 与 **分国家最优 TopN** 两种筛选模式，灵活适配不同使用场景。 |
| ⚡ **TCP 连接测试** | 多线程并发测试 TCP 握手延迟，可自定义测试次数与成功率阈值，淘汰不稳定节点。 |
| 🔍 **IP 可用性二次检测** | 调用专用 API 验证节点是否可正常代理请求，过滤“假通”节点。检测 API 失效时自动降级，不影响流程。 |
| 📶 **真实带宽测速** | 基于 `curl` 下载 Cloudflare 测速文件，实测节点吞吐量（Mbps），确保最终节点拥有最优带宽表现。 |
| 🌍 **国家过滤** | 支持仅保留指定国家/地区的节点（如 HK、US、JP），精准匹配需求。 |
| 📬 **微信实时通知** | 集成 **WxPusher**，任务启动、异常告警、结果摘要均可推送至微信，随时掌握运行状态。 |
| 🔄 **定时自动运行** | 通过 Windows 计划任务或 Linux cron 实现无人值守定时执行，持续保持节点列表新鲜度。 |
| 🚀 **一键部署** | 提供 `setup.ps1` (Windows) 与 `setup.sh` (Linux) 自动化部署脚本，自动安装依赖、配置定时任务并生成 `.gitignore`。 |
| 📤 **GitHub 自动同步** | 每次运行后自动将筛选结果 `ip.txt` 推送至指定 GitHub 仓库，方便通过 Raw 链接直接对接各类代理工具。 |
| 🔒 **隐私保护** | `.gitignore` 自动忽略 `config.json` 及推送脚本，避免敏感 Token 泄露。 |
| 🖥️ **跨平台兼容** | 完美支持 Windows (PowerShell) 与 Linux (Bash)，核心逻辑均由 Python 统一实现。 |

---

## 📦 文件清单

| 文件 | 说明 |
| :--- | :--- |
| `main.py` | **核心程序**：负责抓取节点、TCP 测试、可用性检测、带宽测速及保存结果 |
| `config.json` | **配置文件**：所有运行参数均在此修改（含详细注释） |
| `git_sync.ps1` | **Windows 推送脚本**：用于将 `ip.txt` 强制推送到 GitHub |
| `git_sync.sh` | **Linux 推送脚本**：用于将 `ip.txt` 强制推送到 GitHub |
| `setup.ps1` | **Windows 一键部署脚本**：自动安装依赖、配置计划任务（需管理员权限） |
| `setup.sh` | **Linux 一键部署脚本**：自动安装依赖、配置 cron 定时任务（需 root 权限） |
| `ip.txt` | **输出结果**：程序运行后生成的优选节点列表（每次运行会覆盖） |

---

## 🖥️ 系统要求

- **操作系统**：Windows 10+ / Windows Server 2016+ 或 Linux（Ubuntu/Debian/CentOS 等）
- **必备软件**：
  - **Python 3.7+**
  - **Git**
  - **curl**（需在系统 PATH 中可用）
- **Python 依赖**：`requests` 库

---

## 🚀 部署步骤

### 通用前置步骤

1. **获取项目文件**  
   通过 Git 克隆或直接下载 ZIP 压缩包并解压：
   ```bash
   git clone https://github.com/你的用户名/仓库名.git
   cd 仓库名
   ```

2. **配置微信通知（可选）**  
   编辑 `config.json`，填写 WxPusher 的 `WXPUSHER_APP_TOKEN` 和 `WXPUSHER_UIDS`。  
   若不需要通知，可将 `ENABLE_WXPUSHER` 设为 `false`。

3. **配置 GitHub 自动推送**  
   根据你的操作系统，编辑对应的推送脚本：
   - **Windows**：编辑 `git_sync.ps1`
   - **Linux**：编辑 `git_sync.sh`
   
   修改以下三项为你的真实信息：
   ```text
   github_token="你的 GitHub Personal Access Token"
   github_username="你的 GitHub 用户名"
   repo_name="仓库名"
   ```

---

### Windows 部署

#### 自动部署（推荐）

右键点击 **`setup.ps1`**，选择 **“使用 PowerShell 运行”**（请以管理员身份运行）。  
脚本会自动完成以下操作：
- 检测并安装 Python、Git、curl
- 安装 Python 依赖 `requests`
- 创建 `.gitignore` 保护敏感文件
- 创建 Windows 计划任务，每 15 分钟运行一次 `main.py`

#### 手动部署

1. 安装 [Python 3](https://www.python.org/downloads/)（勾选 “Add Python to PATH”）、[Git](https://git-scm.com/download/win) 和 [curl](https://curl.se/windows/)。
2. 在项目目录打开命令提示符，执行：
   ```cmd
   pip install requests
   ```
3. （可选）手动创建计划任务：参考 `setup.ps1` 中的任务配置。

#### 运行测试

在项目目录地址栏输入 `cmd` 并回车，执行：
```cmd
python main.py
```

---

### Linux 部署

#### 自动部署（推荐）

在终端中执行以下命令：
```bash
chmod +x setup.sh
sudo ./setup.sh
```

脚本会自动完成：
- 检测包管理器（apt/yum/dnf/pacman）并安装 Python3、pip、Git、curl
- 安装 Python 依赖 `requests`
- 创建 `.gitignore` 保护敏感文件
- 添加 cron 定时任务，每 15 分钟运行一次 `main.py`

#### 手动部署

1. 安装依赖（以 Debian/Ubuntu 为例）：
   ```bash
   sudo apt update
   sudo apt install -y python3 python3-pip git curl
   ```
2. 安装 Python 依赖：
   ```bash
   pip3 install requests
   ```
3. 赋予推送脚本执行权限：
   ```bash
   chmod +x git_sync.sh
   ```
4. （可选）手动添加 cron 任务：
   ```bash
   (crontab -l 2>/dev/null; echo "*/15 * * * * cd $(pwd) && /usr/bin/python3 $(pwd)/main.py >> $(pwd)/cron.log 2>&1") | crontab -
   ```

#### 运行测试

在项目目录下执行：
```bash
python3 main.py
```

---

## 🕒 定时自动运行说明

| 平台 | 方式 | 默认频率 |
| :--- | :--- | :--- |
| Windows | 任务计划程序（任务名：`Cloudflare IP 优选`） | 每 15 分钟 |
| Linux | cron 定时任务 | 每 15 分钟 |

**日志查看**：
- Windows：可在任务计划程序中查看历史运行状态。
- Linux：日志输出至项目目录下的 `cron.log`，使用 `tail -f cron.log` 实时查看。

---

## ⚙️ 配置说明

所有运行参数均集中在 `config.json` 文件中，文件内已包含详细注释。主要配置项如下：

| 参数 | 说明 |
| :--- | :--- |
| `USE_GLOBAL_MODE` | `true` = 全局最优 N 个；`false` = 每个国家最优 N 个 |
| `TCP_PROBES` | 每个节点 TCP 连接测试次数 |
| `MIN_SUCCESS_RATE` | TCP 最低成功率阈值（0.0~1.0） |
| `BANDWIDTH_CANDIDATES` | 进入带宽测速的候选节点数 |
| `GLOBAL_TOP_N` / `PER_COUNTRY_TOP_N` | 最终保留的节点数量 |
| `FILTER_COUNTRIES_ENABLED` | 是否启用国家过滤 |
| `ALLOWED_COUNTRIES` | 允许的国家代码列表（如 `["HK","US"]`） |
| `ENABLE_WXPUSHER` | 是否启用微信通知 |
| `WXPUSHER_APP_TOKEN` / `WXPUSHER_UIDS` | WxPusher 认证信息 |
| `OUTPUT_FILE` | 结果保存文件名（默认 `ip.txt`） |

> 💡 其余并发数、超时时间、API 地址等高级参数可根据网络环境微调，一般保持默认即可。

---

## 📊 结果输出说明

程序运行完成后，会在本地生成 `ip.txt` 并在同步后更新至 GitHub 链接：
`https://raw.githubusercontent.com/你的用户名/仓库名/refs/heads/main/ip.txt`

### 文件格式
`ip.txt` 采用标准格式，每一行代表一个最优节点，具体格式为：
`IP地址:端口#国家代码`

> **示例：**
> `104.16.x.x:443#US`
> `162.159.x.x:443#HK`

---

## 🚀 对接 EdgeTunnel (2.0+) 指南

**EdgeTunnel** (EDTunnel) 是基于 Cloudflare Workers 的隧道工具。使用本项目筛选出的 `ip.txt` 可以显著提升连接速度和稳定性。

### 方法一：优选订阅模式（推荐）

1. 复制你的 GitHub Raw 链接：
   `https://raw.githubusercontent.com/你的用户名/仓库名/refs/heads/main/ip.txt`
2. 打开 EdgeTunnel 控制面板，进入 **“优选订阅模式”**。
3. 在 **“自定义订阅”** 处填入上述 GitHub Raw 链接。
4. 保存配置，程序将根据你筛选出的最优 IP 自动构建隧道节点。

### 方法二：手动替换 EdgeTunnel 节点配置

1. 打开 `ip.txt`，从列表中选择排在正序（带宽最高）的 **IP 地址** 和 **端口**。
2. 打开 EdgeTunnel 控制面板，进入 **“优选订阅模式”**。
3. 在 **“自定义订阅”** 处填入上述 **IP 地址** 和 **端口**。
4. 保存配置。

### 💡 为什么这样对接更有效？
- **低延迟**：`main.py` 已经通过 TCP 握手筛选出了延迟最低的节点。
- **高带宽**：结果经过真实 `curl` 下载测试，排在前面的节点具有更强的并发吞吐能力。
- **高可用**：通过 `AVAILABILITY_CHECK_API` 过滤了那些能 Ping 通但无法正常通过代理请求的无效 IP。

---

### 注意事项
- **GitHub 缓存**：GitHub Raw 链接有一定的 CDN 缓存时间（通常为 5 分钟左右）。如果刚运行完脚本发现链接内容没变，请稍等片刻。
- **网络环境**：建议在你的主运行环境（如家庭软路由或主力 PC）运行此脚本，因为不同网络环境下筛选出的最优 IP 可能不同。

---

## ❓ 常见问题

1. **提示 `ModuleNotFoundError: No module named 'requests'`**  
   请执行 `pip install requests` (Windows) 或 `pip3 install requests` (Linux)。

2. **带宽测速被跳过**  
   请确保系统已安装 `curl` 且位于 PATH 环境变量中。

3. **可用性检测全部失败**  
   若 API 接口异常，程序会自动跳过此步骤并回退到 TCP 筛选结果，同时发送微信提醒（如已配置）。

4. **GitHub 推送失败**  
   - 检查 `git_sync.ps1` / `git_sync.sh` 中的 Token、用户名、仓库名是否正确。
   - 确保 Token 具备 `repo` 权限。
   - 确认本地 Git 已正确配置用户信息（`git config --global user.name/email`）。

5. **Linux 下 `git_sync.sh` 权限被拒绝**  
   执行 `chmod +x git_sync.sh` 赋予执行权限。

6. **隐私保护**  
   自动生成的 `.gitignore` 文件会忽略 `config.json`、`git_sync.ps1` 和 `git_sync.sh`，防止敏感信息被提交到公开仓库。

---

## 🙏 致谢

- 节点数据源 & 检测 API：[cmliussss](https://github.com/cmliussss)
- 微信通知服务：[WxPusher](https://wxpusher.zjiecode.com/)

---

**许可证**：本项目采用 [MIT License](https://opensource.org/licenses/MIT) 开源。
