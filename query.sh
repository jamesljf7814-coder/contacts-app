#!/bin/bash
# MariaDB 远程数据库命令行查询工具
# 用法: ./query.sh "SELECT * FROM contacts"
#       ./query.sh "SHOW TABLES"

DIR="$(cd "$(dirname "$0")" && pwd)"
TOOLS_DIR="$(cd "$DIR/.." && pwd)/tools"
JAVA_BIN="$TOOLS_DIR/jdk-17.0.20.1+1/Contents/Home/bin/java"
MARIADB_JAR=$(find "$HOME/.m2/repository/org/mariadb/jdbc" -name "mariadb-java-client-*.jar" 2>/dev/null | sort -V | tail -1)

if [ -z "$MARIADB_JAR" ]; then
  echo "未找到 mariadb-java-client jar，请先执行 ./start.sh 编译"
  exit 1
fi

DB_HOST="120.24.74.222"
DB_PORT="3306"
DB_NAME="contactdb"
DB_USER="app"
DB_PASS="app123"

SQL="${1:-SHOW TABLES}"

# 使用 JDK 单文件源码执行 JDBC 查询
TMP_SRC="/tmp/MariaQuery.java"
cat > "$TMP_SRC" <<'EOF'
import java.sql.*;
import java.util.*;

public class MariaQuery {
    public static void main(String[] args) throws Exception {
        String url = args[0], user = args[1], pass = args[2], sql = args[3];
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             Statement st = conn.createStatement()) {
            boolean hasRs = st.execute(sql);
            if (!hasRs) {
                System.out.println("更新成功，影响行数: " + st.getUpdateCount());
                return;
            }
            try (ResultSet rs = st.getResultSet()) {
                ResultSetMetaData md = rs.getMetaData();
                int n = md.getColumnCount();
                List<String[]> rows = new ArrayList<>();
                String[] header = new String[n];
                int[] width = new int[n];
                for (int i = 0; i < n; i++) {
                    header[i] = md.getColumnLabel(i + 1);
                    width[i] = header[i].length();
                }
                while (rs.next()) {
                    String[] row = new String[n];
                    for (int i = 0; i < n; i++) {
                        Object v = rs.getObject(i + 1);
                        row[i] = v == null ? "NULL" : v.toString();
                        width[i] = Math.max(width[i], row[i].length());
                    }
                    rows.add(row);
                }
                StringBuilder fmt = new StringBuilder();
                for (int i = 0; i < n; i++) fmt.append("%-" + width[i] + "s  ");
                String f = fmt.toString().trim();
                System.out.println(String.format(f, (Object[]) header));
                for (int i = 0; i < n; i++) System.out.print("-".repeat(width[i]) + (i < n - 1 ? "  " : ""));
                System.out.println();
                for (String[] row : rows) System.out.println(String.format(f, (Object[]) row));
                System.out.println(rows.size() + " 行");
            }
        }
    }
}
EOF

echo "执行: $SQL"
echo "-----------------------------------"
"$JAVA_BIN" -cp "$MARIADB_JAR" "$TMP_SRC" \
  "jdbc:mariadb://$DB_HOST:$DB_PORT/$DB_NAME" "$DB_USER" "$DB_PASS" "$SQL"
