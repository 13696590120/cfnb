-----

# Cloudflare IP 优选工具

这是一个全自动的 **Cloudflare CDN 节点优选工具**。它通过 **TCP 延迟筛选** + **IP 可用性二次检测** + **真实带宽测速** 三重机制，筛选出当前环境下速度最快的节点，并将结果自动推送到 GitHub 仓库，同时支持微信实时通知。

> [\!CAUTION]
> **重要提示：** 本工具 **仅支持 Windows 操作系统**。
> 自动推送功能依赖 PowerShell 脚本 `git_sync.ps1`，Linux / macOS 无法直接使用（除非自行实现等效 Shell 脚本）。

-----

## 📦 文件清单

| 文件 | 说明 |
| :--- | :--- |
| `main.py` | **核心程序**：负责抓取节点、TCP 测试、可用性检测、带宽测速及保存结果 |
| `config.json` | **配置文件**：所有运行参数均在此修改 |
| `git_sync.ps1` | **PowerShell 脚本**：用于将 `ip.txt` 强制推送到 GitHub |
| `setup.ps1` | **一键安装环境脚本**：自动安装所需依赖、配置隐私保护及计划任务（需管理员权限） |
| `ip.txt` | **输出结果**：程序运行后生成的优选节点列表（每次运行会覆盖） |

-----

## 🖥️ 系统要求

  * **操作系统**：Windows 10 / Windows Server 2016 或更高版本
  * **必备软件**：
      * **Python 3.7+**（安装时需勾选 *“Add Python to PATH”*）
      * **Git**
      * **curl**（需将 `curl.exe` 所在目录加入系统 PATH）
  * **Python 依赖**：`requests` 库

-----

## 🚀 部署步骤

### 1\. 获取项目文件

通过 Git 克隆或直接下载 ZIP 压缩包并解压：

```bash
git clone https://github.com/你的用户名/仓库名.git
cd 仓库名
```

### 2\. 安装运行环境

  * **推荐方式（一键部署）**：
    右键点击 **`setup.ps1`**，选择 **“使用 PowerShell 运行”**（请以管理员身份运行）。脚本会自动安装环境，生成 `.gitignore` 保护隐私，并自动创建 Windows 计划任务。
  * **手动方式**：
    若已安装 Python，请在项目目录下执行：
    ```cmd
    pip install requests
    ```

### 3\. 修改配置文件

使用文本编辑器（如 Notepad++）修改`config.json`关键字段，配置文件支持以下所有参数：

| 参数名称 | 说明 | 默认值 |
| :--- | :--- | :--- |
| `USE_GLOBAL_MODE` | `true`: 全局最优 N 个；`false`: 每个国家最优 N 个 | `true` |
| `TCP_PROBES` | 每个节点测试 TCP 连接的次数 | `7` |
| `MIN_SUCCESS_RATE` | TCP 最低成功率阈值（如 1.0 代表 100% 成功） | `1.0` |
| `TEST_AVAILABILITY` | 是否进行 API 可用性二次筛选 | `true` |
| `BANDWIDTH_CANDIDATES`| 进入带宽测速的候选节点数（从 TCP 通过者中选取） | `32` |
| `GLOBAL_TOP_N` | 全局模式下最终保留的节点数量 | `16` |
| `PER_COUNTRY_TOP_N` | 分国家模式下每个国家保留的节点数量 | `1` |
| `MAX_WORKERS` | TCP 并发测试的最大线程数 | `150` |
| `AVAILABILITY_WORKERS`| 可用性检测的并发线程数 | `50` |
| `BANDWIDTH_WORKERS` | 带宽测速的并发线程数 | `6` |
| `TIMEOUT` | 单次 TCP 连接超时时间（秒） | `2.5` |
| `AVAILABILITY_TIMEOUT`| 可用性 API 请求超时时间（秒） | `8` |
| `BANDWIDTH_TIMEOUT` | 单个节点带宽测速超时时间（秒） | `5` |
| `BANDWIDTH_SIZE_MB` | 带宽测速下载文件大小 (MB) | `1` |
| `JSON_URL` | Cloudflare IP 节点数据源地址 | `https://zip.cm.edu.kg/all.txt` |
| `WXPUSHER_APP_TOKEN` | WxPusher 的应用 Token（用于通知） | `AT_xxx...` |
| `WXPUSHER_UIDS` | 接收通知的微信 UID 列表 | `["UID_xxx"]` |

### 4\. 配置 GitHub 自动推送

使用文本编辑器（如 Notepad++）修改`git_sync.ps1`关键字段，配置文件支持以下所有参数：

```powershell
$github_token = "ghp_xxxxxxxxxxxxxxxxxxxx"   # GitHub Personal Access Token
$github_username = "你的GitHub用户名"
$repo_name = "仓库名"
```
### 5\. 运行程序

在项目文件夹地址栏输入 `cmd` 并回车，执行：

```cmd
python main.py
```

程序将自动执行：**抓取节点 → TCP 测试 → 可用性二次检测 → 带宽测速 → GitHub 推送**。

-----

## 🕒 设置定时自动运行

  * **Windows 任务计划程序 (手动设置)**：
    **步骤 1.** 打开“任务计划程序” → “创建基本任务”。
    **步骤 2.** 触发器：设置为每天凌晨或其他时间。
    **步骤 3.** 操作：启动程序。

      * 程序或脚本：`python`
      * 添加参数：`main.py`
      * 起始于：`项目文件夹的绝对路径`

  * **自动化方案**：若使用了 `setup.ps1` 部署，系统已自动创建名为 **“Cloudflare IP 优选”** 的任务，默认每 15 分钟运行一次。

-----

## 📊 结果输出说明

程序运行完成后，会在本地生成 `ip.txt` 并在同步后更新至 GitHub 链接：
`https://raw.githubusercontent.com/你的用户名/仓库名/refs/heads/main/ip.txt`

### 文件格式
`ip.txt` 采用标准格式，每一行代表一个最优节点，具体格式为：
`IP地址:端口#国家代码`

> **示例：**
> `104.16.x.x:443#US`
> `162.159.x.x:443#HK`

-----

## 🚀 对接 EdgeTunnel 指南

**EdgeTunnel** (EDTunnel) 是基于 Cloudflare Workers 的隧道工具。使用本项目筛选出的 `ip.txt` 可以显著提升连接速度和稳定性。

### 方法一：直接作为“优选端点”使用 (推荐)
如果你使用的是支持“外部节点导入”或“自动更新优选 IP”的客户端（如 v2rayN 插件版本或相关手机 App）：

1.  复制你的 GitHub Raw 链接：
    `https://raw.githubusercontent.com/你的用户名/仓库名/refs/heads/main/ip.txt`
2.  在客户端的 **“优选 IP 列表”** 或 **“Endpoint 地址”** 处填入此 URL。
3.  设置 **自动更新频率**（建议 15-60 分钟），确保节点始终保持最优。

### 方法二：手动替换 EdgeTunnel 节点配置
如果你正在手动配置 `vless` 或 `trojan` 节点信息：

1.  打开 `ip.txt`，从列表中选择排在第一位（带宽最高）的 **IP 地址** 和 **端口**。
2.  在你的 EdgeTunnel 客户端配置中，找到 **`地址 (Address)`** 或 **`伪装域名 (SNI)`** 栏目：
    * **地址 (Address)**：填入 `ip.txt` 中的 IP。
    * **端口 (Port)**：填入 `ip.txt` 中的对应端口（通常为 443）。
    * **伪装域名 (SNI) / Host**：填入你部署 EdgeTunnel 时使用的 Worker 域名（例如 `your-worker.workers.dev`）。

### 💡 为什么这样对接更有效？
* **低延迟**：`main.py` 已经通过 TCP 握手筛选出了延迟最低的节点。
* **高带宽**：结果经过真实 `curl` 下载测试，排在前面的节点具有更强的并发吞吐能力。
* **高可用**：通过 `AVAILABILITY_CHECK_API` 过滤了那些能 Ping 通但无法正常通过代理请求的无效 IP。

-----

### 注意事项
* **GitHub 缓存**：GitHub Raw 链接有一定的 CDN 缓存时间（通常为 5 分钟左右）。如果刚运行完脚本发现链接内容没变，请稍等片刻。
* **网络环境**：建议在你的主运行环境（如家庭软路由或主力 PC）运行此脚本，因为不同网络环境下筛选出的最优 IP 可能不同。

-----

## ❓ 常见问题

1.  **提示 `ModuleNotFoundError`**：请执行 `pip install requests`。
2.  **带宽测速跳过**：确保系统已安装 `curl` 并在环境变量中。
3.  **可用性检测全部失败**：若 API 接口异常，程序会自动跳过此步骤并回退到 TCP 筛选结果，同时发送微信提醒。
4.  **隐私保护**：新版脚本会自动生成 `.gitignore` 忽略 `config.json` 和 `git_sync.ps1`，防止私密信息外泄。

-----

## 🙏 致谢

  * 节点数据源 & 检测 API：[cmliussss](https://www.google.com/search?q=https://github.com/cmliussss)
  * 微信通知服务：[WxPusher](https://wxpusher.zjiecode.com/)

-----

**许可证**：本项目采用 [MIT License](https://opensource.org/licenses/MIT) 开源。
