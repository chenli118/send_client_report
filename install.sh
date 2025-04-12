#!/bin/bash

# 配置变量
SCRIPT_REPO_URL="https://github.com/chenli118/send_client_report.git"
SCRIPT_DIR="/root/script"
EMAIL_SCRIPT="send_traffic_report.py"
CRON_SCHEDULE="0 23 * * * /usr/bin/python3 ${SCRIPT_DIR}/${EMAIL_SCRIPT} >> /var/log/traffic_report.log 2>&1"
CRON_FILE="/var/spool/cron/crontabs/root"

# 1. 克隆或更新脚本仓库
if [ ! -d "${SCRIPT_DIR}" ]; then
    echo "脚本目录不存在，正在克隆仓库..."
    git clone "${SCRIPT_REPO_URL}" "${SCRIPT_DIR}"
else
    echo "脚本目录已存在，正在拉取最新代码..."
    cd "${SCRIPT_DIR}"
    git pull origin main
fi

# 2. 确保发送流量报告的 Python 脚本存在且最新
echo "正在确保 Python 脚本文件存在..."
cp -f "${SCRIPT_DIR}/${EMAIL_SCRIPT}" "${SCRIPT_DIR}/${EMAIL_SCRIPT}"  # 覆盖旧脚本

# 3. 设置定时任务
echo "正在检查和设置定时任务..."
CRON_EXIST=$(grep -F "${EMAIL_SCRIPT}" "${CRON_FILE}")

if [ -z "${CRON_EXIST}" ]; then
    # 如果没有找到相同的定时任务，则添加
    echo "没有找到现有的定时任务，正在添加新的定时任务..."
    echo "${CRON_SCHEDULE}" >> "${CRON_FILE}"
else
    # 如果找到了相同的定时任务，则先删除旧的定时任务
    echo "找到现有的定时任务，正在删除..."
    sed -i "/${EMAIL_SCRIPT}/d" "${CRON_FILE}"
    echo "删除完成，重新添加定时任务..."
    echo "${CRON_SCHEDULE}" >> "${CRON_FILE}"
fi

# 4. 检查 Python3 路径
if ! command -v python3 &> /dev/null; then
    echo "错误: 未找到 Python3，请确保 Python3 已安装并在 PATH 中。"
    exit 1
fi

# 5. 重启 cron 服务以应用新的定时任务
echo "重启 cron 服务以应用新的定时任务..."
systemctl restart cron

echo "脚本已成功更新并配置！"
