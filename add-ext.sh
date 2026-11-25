#!/bin/sh
# 用法: ./add-ext.sh 作者/仓库名   例: ./add-ext.sh N0VI028/JS-Slash-Runner
REPO="$1"
if [ -z "$REPO" ]; then
  echo "用法: ./add-ext.sh 作者/仓库名"
  exit 1
fi
NAME=$(echo "$REPO" | cut -d/ -f2)
cd /var/mobile/st || exit 1

for BR in main master; do
  node -e '
const z = require("zlib"), f = require("fs");
const u = "https://cdn.gh-proxy.org/https://codeload.github.com/" + process.argv[1] + "/tar.gz/refs/heads/" + process.argv[2];
fetch(u).then(r => { if (!r.ok) throw new Error("HTTP " + r.status); return r.arrayBuffer(); })
  .then(b => {
    f.writeFileSync("ext.tgz", Buffer.from(b));
    f.writeFileSync("ext.tar", z.gunzipSync(f.readFileSync("ext.tgz")));
    console.log("下载完成", process.argv[2]);
  })
  .catch(e => { console.log("失败:", e.message); process.exit(1); });
' "$REPO" "$BR"
  if [ $? -ne 0 ]; then
    echo "分支 $BR 不可用"
    continue
  fi
  tar -xf ext.tar || exit 1
  rm -rf "SillyTavern-release/data/default-user/extensions/$NAME"
  mv "$NAME-$BR" "SillyTavern-release/data/default-user/extensions/$NAME" || exit 1
  rm -f ext.tgz ext.tar
  echo "已安装 $NAME"
  exit 0
done
echo "安装失败：请确认仓库名是否正确"
exit 1
