#!/bin/bash

# 配置变量
SCRIPT_REPO_URL="https://github.com/chenli118/send_client_report.git"
SCRIPT_DIR="/root/script"
EMAIL_SCRIPT="send_client_report.py"
CRON_SCHEDULE="0 23 * * * python3 ${SCRIPT_DIR}/${EMAIL_SCRIPT} >> /var/log/traffic_report.log 2>&1"

# 更新系统
echo "更新系统软件包..."
apt-get update -y
apt-get upgrade -y

# 安装必要的软件包
echo "安装必要的软件包..."
apt-get install -y python3 python3-pip curl vnstat git

# 克隆 GitHub 仓库到目标目录
echo "克隆 GitHub 仓库..."
git clone ${SCRIPT_REPO_URL} ${SCRIPT_DIR}

# 检查脚本文件是否下载成功
if [ ! -f "${SCRIPT_DIR}/${EMAIL_SCRIPT}" ]; then
    echo "下载脚本失败！请检查仓库链接和网络连接。"
    exit 1
fi

# 确保脚本可执行
echo "设置脚本可执行权限..."
chmod +x ${SCRIPT_DIR}/${EMAIL_SCRIPT}

# 设置定时任务
echo "配置定时任务..."
(crontab -l 2>/dev/null; echo "${CRON_SCHEDULE}") | crontab -

# 创建日志文件并设置权限
echo "创建日志文件并设置权限..."
touch /var/log/traffic_report.log
chmod 640 /var/log/traffic_report.log

# 启用 vnstat 服务
echo "启动 vnstat 服务..."
systemctl enable vnstat
systemctl start vnstat

# 完成部署
echo "部署完成！"
echo "定时任务已成功添加到 cron，每晚 23 点执行流量报告脚本。"
echo "查看日志文件: /var/log/traffic_report.log"

