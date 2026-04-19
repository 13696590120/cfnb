#!/bin/bash
# git_sync.sh - Linux 下将 ip.txt 推送到 GitHub

# ==================== GitHub 认证信息（请修改为你的信息） ====================
github_token="your_github_personal_access_token_here"
github_username="your_github_username"
repo_name="your_repo_name"
branch="your_branch"

# 切换到脚本所在目录
cd "$(dirname "$0")" || exit 1

# 拉取远程最新更新
git pull origin "$branch"

# 暂存并提交 ip.txt
git add ip.txt
commit_msg="Update ip.txt on $(date '+%Y-%m-%d %H:%M:%S')"
git commit -m "$commit_msg"

# 强制推送到 GitHub
git push "https://${github_token}@github.com/${github_username}/${repo_name}.git" "$branch" --force

echo "✅ ip.txt 已推送到 GitHub"