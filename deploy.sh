#!/bin/bash
# 注册 systemd 服务
set -e

echo "=== 部署 Contacts App ==="

# 1. 停止当前进程
echo "[1/5] 停止旧进程..."
pkill -f contacts-app-1.0.0.jar 2>/dev/null || true
sleep 2

# 2. 创建 systemd 服务文件
echo "[2/5] 安装 systemd 服务文件..."
cat > /etc/systemd/system/contacts-app.service <<'SERVICE'
[Unit]
Description=Contacts App - Spring Boot Contacts Application
After=network.target mariadb.service
Requires=mariadb.service

[Service]
Type=simple
WorkingDirectory=/opt/contacts-app
ExecStart=/usr/bin/java -jar contacts-app-1.0.0.jar --spring.datasource.url='jdbc:mariadb://localhost:3306/contactdb?useSSL=false' --server.port=8080
Restart=on-failure
RestartSec=5
StandardOutput=append:/opt/contacts-app/app.log
StandardError=append:/opt/contacts-app/app.log

[Install]
WantedBy=multi-user.target
SERVICE

# 3. 重载 systemd
echo "[3/5] 重载 systemd 配置..."
systemctl daemon-reload

# 4. 启用开机自启
echo "[4/5] 启用开机自启..."
systemctl enable contacts-app.service

# 5. 启动服务
echo "[5/5] 启动服务..."
systemctl start contacts-app.service
sleep 3

# 状态检查
echo ""
systemctl status contacts-app.service --no-pager
echo ""
echo "=== 完成 ==="
