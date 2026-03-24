#!/bin/bash
# 老管家状态上报脚本
# 定时更新 status/laoguanjia.json 到 GitHub

GITHUB_TOKEN_FILE="$HOME/.qclaw/.gh_token"
STATUS_FILE="$HOME/.qclaw/scripts/laoguanjia_status.json"

if [ ! -f "$GITHUB_TOKEN_FILE" ]; then
    echo "Error: GitHub token file not found. Please run setup first."
    exit 1
fi

GITHUB_TOKEN=$(cat "$GITHUB_TOKEN_FILE")
NOW=$(date -u +"%Y-%m-%dT%H:%M:%S+08:00")

cat > "$STATUS_FILE" << EOF
{
  "id": "laoguanjia",
  "status": "在线",
  "lastActive": "${NOW}",
  "uptime": "7×24h",
  "currentTask": "老管家值守中，定时任务执行",
  "capabilities": ["定时任务", "常驻监控", "日志记录", "跨系统同步"],
  "device": "2016款 MacBook（Intel）",
  "note": "性能弱但稳定，常驻"
}
EOF

SHA=$(curl -s "https://api.github.com/repos/namefelix7/openclaw-skill-library/contents/status/laoguanjia.json" \
  -H "Authorization: token $GITHUB_TOKEN" | python3 -c "import sys,json;print(json.load(sys.stdin)['sha'])")

RESPONSE=$(curl -s -X PUT "https://api.github.com/repos/namefelix7/openclaw-skill-library/contents/status/laoguanjia.json" \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"sha\":\"$SHA\",\"message\":\"status: 老管家心跳 $(date '+%Y-%m-%d %H:%M')\",\"content\":\"$(cat $STATUS_FILE | base64)\"}")

if echo "$RESPONSE" | python3 -c "import sys,json; json.load(sys.stdin); print('OK')" 2>/dev/null; then
    echo "$(date): 老管家状态已上报 ✅"
else
    echo "$(date): 上报失败 ❌"
fi
