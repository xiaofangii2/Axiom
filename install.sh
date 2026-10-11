#!/bin/sh
# Axiom 安装脚本

REPO="xiaofangii2/Axiom"
AXIOM_DIR="$HOME/.axiom"
BIN_DIR="$HOME/bin"

echo "Axiom 安装"
echo ""

if [ ! -f "$(dirname "$0")/Axiom-V2/Axiom" ]; then
  echo "选择下载源："
  echo "  1 GitHub"
  echo "  2 Gitee"
  printf "> "
  read choice

  case "$choice" in
    1|"")
      TAR_URL="https://github.com/$REPO/archive/refs/heads/main.tar.gz"
      SRC_NAME="GitHub"
      ;;
    2)
      TAR_URL="https://gitee.com/$REPO/repository/archive/main.tar.gz"
      SRC_NAME="Gitee"
      ;;
    *)
      echo "Axiom: 无效选择"
      exit 1
      ;;
  esac

  echo "从 $SRC_NAME 下载..."

  TMP=$(mktemp -d)
  cd "$TMP" || exit 1

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

  SRC_DIR=""
  for d in "$TMP"/*/; do
    [ -d "$d" ] || continue
    SRC_DIR="$d"
    break
  done

  if [ -z "$SRC_DIR" ]; then
    echo "Axiom: 包结构不对"
    cd ~ && rm -rf "$TMP"
    exit 1
  fi
else
  SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
fi

mkdir -p "$AXIOM_DIR/Axiom-V2/brain"
mkdir -p "$AXIOM_DIR/Axiom-V2/conv"
mkdir -p "$AXIOM_DIR/Axiom-R1/brain"
mkdir -p "$AXIOM_DIR/Axiom-S1"
mkdir -p "$AXIOM_DIR/logs"
mkdir -p "$BIN_DIR"

cp "$SRC_DIR/Axiom-V2/Axiom" "$AXIOM_DIR/Axiom-V2/Axiom"
chmod +x "$AXIOM_DIR/Axiom-V2/Axiom"
echo "[ok] Axiom-V2 → $AXIOM_DIR/Axiom-V2/Axiom"

cp "$SRC_DIR/Axiom-R1/Axiom" "$AXIOM_DIR/Axiom-R1/Axiom"
chmod +x "$AXIOM_DIR/Axiom-R1/Axiom"
echo "[ok] Axiom-R1 → $AXIOM_DIR/Axiom-R1/Axiom"

cp "$SRC_DIR/Axiom-S1/Axiom" "$AXIOM_DIR/Axiom-S1/Axiom"
chmod +x "$AXIOM_DIR/Axiom-S1/Axiom"
echo "[ok] Axiom-S1 → $AXIOM_DIR/Axiom-S1/Axiom"

cp "$SRC_DIR/Axiom-S1/serve.py" "$AXIOM_DIR/Axiom-S1/serve.py"
chmod +x "$AXIOM_DIR/Axiom-S1/serve.py"
echo "[ok] serve.py → $AXIOM_DIR/Axiom-S1/serve.py"

cp "$SRC_DIR/launcher" "$BIN_DIR/Axiom"
chmod +x "$BIN_DIR/Axiom"
echo "[ok] launcher → $BIN_DIR/Axiom"

if [ ! -f "$AXIOM_DIR/config.yml" ]; then
  cat > "$AXIOM_DIR/config.yml" <<'CFG'
# Axiom 配置
# can_think: 是否默认开启思考（true / false）
can_think: false
CFG
  echo "[ok] 生成 $AXIOM_DIR/config.yml"
fi

if [ ! -f "$AXIOM_DIR/Axiom-V2/Online-AI.ini" ]; then
  touch "$AXIOM_DIR/Axiom-V2/Online-AI.ini"
fi

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
      fi
    else
      echo "[!] 找不到 $SHELL_RC，请手动把 \$HOME/bin 加入 PATH"
    fi
    ;;
esac

echo ""
echo "检查依赖："
command -v curl >/dev/null 2>&1 && echo "[ok] curl" || echo "[!] 缺少 curl：apt install curl"
command -v tar  >/dev/null 2>&1 && echo "[ok] tar"  || echo "[!] 缺少 tar：apt install tar"
command -v jq   >/dev/null 2>&1 && echo "[ok] jq"   || echo "[!] 缺少 jq：apt install jq"
command -v bc   >/dev/null 2>&1 && echo "[ok] bc"   || echo "[!] 缺少 bc：apt install bc"
command -v python >/dev/null 2>&1 && echo "[ok] python" || echo "[!] 缺少 python（S1 服务需要）：apt install python"

[ -n "$TMP" ] && cd ~ && rm -rf "$TMP"

echo ""
echo "安装完成。运行：Axiom help"
