#!/bin/sh
# Axiom 安装脚本

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/bin"
TARGET="$BIN_DIR/Axiom"

echo "Axiom 安装"
echo "源目录: $SRC_DIR"
echo "目标:   $TARGET"
echo ""

mkdir -p "$BIN_DIR"
cp "$SRC_DIR/Axiom" "$TARGET"
chmod +x "$TARGET"
echo "[ok] 已安装 Axiom 到 $TARGET"

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

echo ""
echo "检查依赖："
command -v curl >/dev/null 2>&1 && echo "[ok] curl" || echo "[!] 缺少 curl，走 API 会失败：apt install curl"
command -v tar  >/dev/null 2>&1 && echo "[ok] tar"  || echo "[!] 缺少 tar，导入导出会失败：apt install tar"
command -v jq   >/dev/null 2>&1 && echo "[ok] jq"   || echo "[!] 缺少 jq，走 API 会失败：apt install jq"

echo ""
echo "安装完成。运行：Axiom help"
