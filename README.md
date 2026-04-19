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
| `setup.ps1` | **一键安装环境脚本**：自动安装所需依赖（需管理员权限） |
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

## 🚀 部署步骤（Windows）

### 1\. 获取项目文件

通过 Git 克隆或直接下载 ZIP 压缩包并解压：

```bash
git clone https://github.com/你的用户名/仓库名.git
cd 仓库名
```

### 2\. 安装运行环境

  * **方式一：一键安装脚本（推荐）**
    右键点击 `setup.ps1`，选择 **“使用 PowerShell 运行”**（请以管理员身份运行）。脚本会自动检测并安装 Python 3、Git、curl (通过 winget) 以及 `requests` 库。
  * **方式二：手动安装**
    安装 Python、Git、curl 后，在命令提示符执行：
    ```cmd
    pip install requests
    ```

### 3\. 修改配置文件 `config.json`

使用文本编辑器（如记事本、VS Code）修改关键字段：

**必填项（微信通知）：**

```json
"WXPUSHER_APP_TOKEN": "你的APP_TOKEN",
"WXPUSHER_UIDS": ["你的UID"]
```

  * **APP\_TOKEN**：在 [WxPusher 管理后台](https://wxpusher.zjiecode.com/admin/) 创建应用获取。
  * **UID**：关注 WxPusher 公众号后，在“我的” → “UID” 中查看。

**可选项（运行参数）：**
| 参数 | 说明 | 默认值 |
| :--- | :--- | :--- |
| `USE_GLOBAL_MODE` | `true` = 全球最优 N 个；`false` = 每个国家最优 N 个 | `true` |
| `GLOBAL_TOP_N` | 全局模式下保留的节点数 | `16` |
| `TCP_PROBES` | 每个节点 TCP 测试次数 | `7` |
| `BANDWIDTH_CANDIDATES` | 进入带宽测速的候选节点数 | `32` |
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

  * **Windows 任务计划程序**：
    1.  打开“任务计划程序” → “创建基本任务”。
    2.  触发器：设置为每天凌晨或其他时间。
    3.  操作：启动程序。
          * 程序或脚本：`python`
          * 添加参数：`main.py`
          * 起始于：`项目文件夹的绝对路径`
  * **其他平台**：若在 Linux 运行，可使用 `cron` 定时执行 `python3 main.py`（需自行处理 Git 推送逻辑）。

-----

## ❓ 常见问题

1.  **提示 `ModuleNotFoundError: No module named 'requests'`**
      * 执行 `pip install requests` 即可。
2.  **带宽测速显示 `⚠️ 未检测到 curl 命令`**
      * 请确保 curl 已正确安装在系统 PATH 中，重启终端后重试。
3.  **可用性检测全部失败？**
      * 程序内置了容错机制，若 API 疑似失效，会自动跳过检测并使用 TCP 筛选列表进行测速，同时发送微信告警。
4.  **GitHub 推送失败？**
      * 请检查 Token 是否拥有 `repo` 权限，并尝试在本地手动执行 `git push` 查看具体报错。

-----

## 🙏 致谢

  * 节点数据源 & 检测 API：[cmliussss](https://www.google.com/search?q=https://github.com/cmliussss)
  * 微信通知服务：[WxPusher](https://wxpusher.zjiecode.com/)

-----

**许可证**：本项目采用 [MIT License](https://www.google.com/search?q=LICENSE) 开源。如果你觉得好用，请点个 ⭐ **Star** 支持一下！
