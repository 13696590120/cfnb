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

### 3\. 修改配置文件 `config.json`

使用文本编辑器（如 Notepad++）修改以下关键字段：

| 参数 | 说明 | 默认值 |
| :--- | :--- | :--- |
| `WXPUSHER_APP_TOKEN` | WxPusher 的应用 Token（用于通知） | `AT_xxx...` |
| `WXPUSHER_UIDS` | 接收通知的微信 UID 列表 | `["UID_xxx"]` |
| `USE_GLOBAL_MODE` | `true`: 全局优选；`false`: 分国家优选 | `true` |
| `MIN_SUCCESS_RATE` | **(新)** TCP 最低成功率阈值（如 1.0 代表 100% 成功） | `1.0` |
| `TEST_AVAILABILITY` | **(新)** 是否进行 API 可用性二次筛选 | `true` |
| `MAX_WORKERS` | TCP 并发测试的最大线程数 | `150` |
| `BANDWIDTH_SIZE_MB` | 测速下载文件大小 (MB) | `1` |
| `JSON_URL` | 节点列表源地址 | `https://zip.cm.edu.kg/all.txt` |

### 4\. 配置 GitHub 自动推送（可选）

若需自动更新仓库中的 `ip.txt`，请编辑 `git_sync.ps1`：

```powershell
$github_token = "ghp_xxxxxxxxxxxxxxxxxxxx"   # GitHub Personal Access Token
$github_username = "你的GitHub用户名"
$repo_name = "仓库名"
```

> [\!WARNING]
> **安全提醒**：切勿将包含真实 Token 的脚本提交到公开仓库！建议将其加入 `.gitignore`。
> 同时确保项目目录已与远程仓库关联：`git remote add origin https://github.com/用户/仓库.git`

### 5\. 运行程序

在项目文件夹地址栏输入 `cmd` 并回车，执行：

```cmd
python main.py
```

程序将自动执行：**抓取节点 → TCP 测试 → 可用性二次检测 → 带宽测速 → GitHub 推送 → 微信通知**。

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
