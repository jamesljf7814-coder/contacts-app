#!/bin/bash
# 个人通讯录应用 - 启动脚本

# JDK 和 Maven 路径（安装在项目 tools 目录下）
TOOLS_DIR="$(cd "$(dirname "$0")/.." && pwd)/tools"
JDK_HOME="$TOOLS_DIR/jdk-17.0.20.1+1/Contents/Home"
MVN="$TOOLS_DIR/apache-maven-3.9.16/bin/mvn"
MVN_SETTINGS="$TOOLS_DIR/mvn-settings.xml"
APP_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== 个人通讯录应用 ==="
echo ""

# 1. 停止旧进程
echo "[1/3] 停止旧应用..."
PID=$(lsof -ti:8080 2>/dev/null)
if [ -n "$PID" ]; then
    kill -9 $PID 2>/dev/null
    echo "  已停止进程 $PID"
else
    echo "  无运行中的进程"
fi
sleep 1

# 2. 编译打包
echo "[2/3] 编译打包..."
cd "$APP_DIR"
JAVA_HOME="$JDK_HOME" "$MVN" -s "$MVN_SETTINGS" clean package -q
if [ $? -ne 0 ]; then
    echo "  编译失败！"
    exit 1
fi
echo "  编译成功"

# 3. 启动应用（支持 ./start.sh debug 开启远程调试端口 5005）
DEBUG_OPTS=""
if [ "$1" == "debug" ]; then
    DEBUG_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"
    echo "  调试模式: 监听端口 5005"
fi
echo "[3/3] 启动应用..."
nohup "$JDK_HOME/bin/java" $DEBUG_OPTS -jar "$APP_DIR/target/contacts-app-1.0.0.jar" > /tmp/app.log 2>&1 &

# 等待启动
echo -n "  等待启动"
for i in $(seq 1 10); do
    if grep -q "Started ContactsApplication" /tmp/app.log 2>/dev/null; then
        echo ""
        echo ""
        echo "应用已启动！"
        echo "访问地址: http://localhost:8080"
        echo "日志文件: /tmp/app.log"
        exit 0
    fi
    echo -n "."
    sleep 1
done
echo ""
echo "启动超时，请检查日志: cat /tmp/app.log"
