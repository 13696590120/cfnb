---

# Cloudflare IP 优选工具

这是一个全自动的 **Cloudflare CDN 节点优选工具**。它通过 **TCP 延迟筛选** + **IP 可用性二次检测** + **真实带宽测速** 三重机制，筛选出当前环境下速度最快的节点，并将结果自动推送到 GitHub 仓库，同时支持微信实时通知。

> [!CAUTION]
> **重要提示：** 本工具 **仅支持 Windows 操作系统**。
> 自动推送功能依赖 PowerShell 脚本 `git_sync.ps1`，Linux / macOS 无法直接使用（除非自行实现等效 Shell 脚本）。

---

## 🛠 工作流程
程序启动后将按以下顺序自动化执行：
**抓取节点数据** → **TCP 延迟初筛** → **API 可用性复筛** → **真实带宽测速 (curl)** → **生成 `ip.txt`** → **同步至 GitHub** → **微信推送通知**

---

## 📦 文件清单

| 文件 | 说明 |
| :--- | :--- |
| `main.py` | **核心程序**：负责抓取节点、TCP 测试、可用性检测、带宽测速及保存结果 |
| `config.json` | **配置文件**：所有运行参数均在此修改 |
| `git_sync.ps1` | **PowerShell 脚本**：用于将 `ip.txt` 强制推送到 GitHub |
| `setup.ps1` | **一键安装环境脚本**：自动安装所需依赖、配置隐私保护及计划任务（需管理员权限） |
| `ip.txt` | **输出结果**：程序运行后生成的优选节点列表 |

---

## 🚀 快速上手

### 1. 环境准备
* **操作系统**：Windows 10 (1803+) 或 Windows 11（系统自带 `curl`）。
* **Python**：建议安装 Python 3.8 或更高版本。

### 2. 一键部署（推荐）
右键点击 `setup.ps1`，选择 **“使用 PowerShell 运行”**。脚本会自动：
* 检查并安装 `requests` 库。
* 自动生成 `.gitignore` 防止隐私泄露。
* **创建 Windows 计划任务**：默认每 15 分钟后台自动运行一次，无需人工干预。

### 3. 配置参数
编辑 `config.json`，根据注释修改参数。主要关注：

| 字段 | 说明 | 默认值 |
| :--- | :--- | :--- |
| `USE_GLOBAL_MODE` | `true`: 全局最优 IP；`false`: 每个国家最优 IP | `true` |
| `BANDWIDTH_CANDIDATES` | 参与带宽测速的候选 IP 数量 | `32` |
| `GLOBAL_TOP_N` | 最终保留在 `ip.txt` 中的节点数 | `16` |
| `JSON_URL` | Cloudflare IP 节点数据源地址 | `https://zip.cm.edu.kg/all.txt` |
| `WXPUSHER_APP_TOKEN` | [WxPusher 应用 Token](https://wxpusher.zjiecode.com/admin/) | `AT_xxx...` |
| `WXPUSHER_UIDS` | 接收通知的微信 UID 列表 | `["UID_xxx"]` |

### 4. 配置 GitHub 自动推送（可选）

若需自动更新仓库中的 `ip.txt`，请编辑 `git_sync.ps1`。
> [!TIP]
> **Token 申请**：前往 [GitHub Tokens (Classic)](https://github.com/settings/tokens) 创建，需勾选 `repo` 权限。

```powershell
$github_token = "ghp_xxxxxxxx"   # 填入你的 Token
$github_username = "你的 GitHub 用户名"
$repo_name = "仓库名"
```

> [!WARNING]
> **安全提醒**：切勿将包含真实 Token 的脚本提交到公开仓库！
> **初始化提醒**：确保你的项目目录已关联远程库：`git remote add origin https://github.com/用户/仓库.git`

### 5. 运行程序
若不使用计划任务，也可在项目文件夹地址栏输入 `cmd` 并回车，手动执行：
```cmd
python main.py
```

---

## 🕒 设置定时自动运行

* **使用 `setup.ps1` 自动设置**：脚本会自动创建名为 `Cloudflare IP 优选` 的任务，每 15 分钟运行一次。
* **手动调整频率**：
    1.  按下 `Win + R`，输入 `taskschd.msc` 并回车。
    2.  在“任务计划程序库”中找到 `Cloudflare IP 优选`。
    3.  右键“属性” -> “触发器” -> “编辑”，即可修改重复间隔（如改为每 1 小时运行一次）。

---

## ❓ 常见问题 (FAQ)

**Q: 为什么带宽测速结果全是 0.00 Mbps？**
A: 请确保你的系统可以调用 `curl` 命令。在 CMD 输入 `curl --version` 检查。如果是精简版系统，请自行安装 curl 并添加环境变量。

**Q: 如何停止自动运行的任务？**
A: 在“任务计划程序”中找到该任务，右键选择“禁用”或“删除”即可。

---
