#!/bin/sh
# Axiom 安装脚本 - 从 GitHub 或 Gitee 下载

REPO="xiaofangii2/Axiom"
AXIOM_DIR="$HOME/.axiom"
BIN_DIR="$HOME/bin"

echo "Axiom 安装"
echo ""
echo "选择下载源："
echo "  1 GitHub"
echo "  2 Gitee"
printf "> "
read choice

case "$choice" in
  1|"")
    BASE="https://raw.githubusercontent.com/$REPO/main"
    TAR_URL="https://github.com/$REPO/archive/refs/heads/main.tar.gz"
    SRC_NAME="GitHub"
    ;;
  2)
    BASE="https://gitee.com/$REPO/raw/main"
    TAR_URL="https://gitee.com/$REPO/repository/archive/main.tar.gz"
    SRC_NAME="Gitee"
    ;;
  *)
    echo "Axiom: 无效选择"
    exit 1
    ;;
esac

echo ""
echo "从 $SRC_NAME 下载..."

# 建临时目录
TMP=$(mktemp -d)
cd "$TMP" || exit 1

# 下载整包
if ! curl -fsSL "$TAR_URL" -o axiom.tar.gz; then
  echo "Axiom: 下载失败"
  cd ~ && rm -rf "$TMP"
  exit 1
fi

tar -xzf axiom.tar.gz || {
  echo "Axiom: 解压失败"
  cd ~ && rm -rf "$TMP"
  exit 1
}

# 找到解压出来的目录
SRC_DIR=""
for d in "$TMP"/*/; do
  [ -d "$d" ] || continue
  SRC_DIR="$d"
  break
done

if [ -z "$SRC_DIR" ] || [ ! -f "$SRC_DIR/Axiom-V2/Axiom" ]; then
  echo "Axiom: 包结构不对"
  cd ~ && rm -rf "$TMP"
  exit 1
fi

# 建目录
mkdir -p "$AXIOM_DIR/Axiom-V2/brain"
mkdir -p "$AXIOM_DIR/Axiom-V2/conv"
mkdir -p "$AXIOM_DIR/Axiom-R1/brain"
mkdir -p "$BIN_DIR"

# 拷模型脚本
cp "$SRC_DIR/Axiom-V2/Axiom" "$AXIOM_DIR/Axiom-V2/Axiom"
chmod +x "$AXIOM_DIR/Axiom-V2/Axiom"
echo "[ok] Axiom-V2 → $AXIOM_DIR/Axiom-V2/Axiom"

cp "$SRC_DIR/launcher" "$BIN_DIR/Axiom"
chmod +x "$BIN_DIR/Axiom"
echo "[ok] launcher → $BIN_DIR/Axiom"

# 初始化配置
if [ ! -f "$AXIOM_DIR/config.yml" ]; then
  cat > "$AXIOM_DIR/config.yml" <<'EOF'
# Axiom 配置
# can_think: 是否默认开启思考（true / false）
# 命令行末尾加 think 只当次生效，不写回这里

can_think: false
EOF
  echo "[ok] 生成 $AXIOM_DIR/config.yml"
else
  echo "[i] $AXIOM_DIR/config.yml 已存在，跳过"
fi

# 初始化 Online-AI.ini
if [ ! -f "$AXIOM_DIR/Axiom-V2/Online-AI.ini" ]; then
  touch "$AXIOM_DIR/Axiom-V2/Online-AI.ini"
fi

# 检查 PATH
case ":$PATH:" in
  *":$BIN_DIR:"*)
    echo "[ok] $BIN_DIR 已在 PATH 中"
    ;;
  *)
    echo "[!] $BIN_DIR 不在 PATH 中"
    case "$SHELL" in
      */zsh)  SHELL_RC="$HOME/.zshrc" ;;
      */bash) SHELL_RC="$HOME/.bashrc" ;;
      *)      SHELL_RC="$HOME/.profile" ;;
    esac
    if [ -f "$SHELL_RC" ]; then
      if ! grep -q 'HOME/bin' "$SHELL_RC" 2>/dev/null; then
        echo 'export PATH="$HOME/bin:$PATH"' >> "$SHELL_RC"
        echo "[ok] 已写入 $SHELL_RC，重启终端或 source 一下"
      else
        echo "[i] $SHELL_RC 里已有 HOME/bin 相关配置"
      fi
    else
      echo "[!] 找不到 $SHELL_RC，请手动把 \$HOME/bin 加入 PATH"
    fi
    ;;
esac

# 检查依赖
echo ""
echo "检查依赖："
command -v curl >/dev/null 2>&1 && echo "[ok] curl" || echo "[!] 缺少 curl：apt install curl"
command -v tar  >/dev/null 2>&1 && echo "[ok] tar"  || echo "[!] 缺少 tar：apt install tar"
command -v jq   >/dev/null 2>&1 && echo "[ok] jq"   || echo "[!] 缺少 jq：apt install jq"
command -v bc   >/dev/null 2>&1 && echo "[ok] bc"   || echo "[!] 缺少 bc：apt install bc"

# 清理
cd ~ && rm -rf "$TMP"

echo ""
echo "安装完成。运行：Axiom help"