#!/bin/bash
# H2 数据库命令行查询工具
# 用法: ./query.sh "SELECT * FROM CONTACT"
#       ./query.sh "SHOW TABLES"

DIR="$(cd "$(dirname "$0")" && pwd)"
TOOLS_DIR="$(cd "$DIR/.." && pwd)/tools"
H2_JAR=$(find "$HOME/.m2/repository/com/h2database" -name "h2-*.jar" 2>/dev/null | sort -V | tail -1)

if [ -z "$H2_JAR" ]; then
  echo "未找到 h2 jar，请先执行 ./start.sh 编译"
  exit 1
fi

JAVA_BIN="$TOOLS_DIR/jdk-17.0.20.1+1/Contents/Home/bin/java"
DB_URL="jdbc:h2:file:$DIR/data/contactsdb"

SQL="${1:-SHOW TABLES}"

echo "执行: $SQL"
echo "-----------------------------------"
"$JAVA_BIN" -cp "$H2_JAR" org.h2.tools.Shell \
  -url "$DB_URL" \
  -user sa \
  -password "" \
  -sql "$SQL"
