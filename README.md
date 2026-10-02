# Axiom

一个用纯 shell 写的轻量聊天工具，跑在 Termux / Linux 上。

支持本地语料查表，也支持接多个大模型服务商（OpenAI 兼容 / Gemini / Ollama）。
本地优先，命不中就转 API。

## 特性

### 本地语料
- Axiom train <输入> :: <回复> 教它一句话
- 一条语料一个文件，存在 ~/.axiom/brain/
- 文件名大小写不敏感，Hello 和 hello 命中同一条
- Axiom brain 列出所有学过的内容
- Axiom forget <输入> 忘掉某一条
- Axiom chat 进入纯本地聊天，命不中回“未训练”

### 多服务商
- 一份 Online-AI.ini 管多个服务商，互不干扰
- 服务商 ID 唯一，重名直接拒绝，不覆盖
- Axiom api <ID> 添加，Axiom api edit <ID> 编辑，Axiom api rm <ID> 删除
- Axiom model 列出所有服务商和模型，当前选中标 *
- Axiom model <ID> <模型> 切换当前
- Axiom chat api 用选中的服务商聊天

### 三种协议
- type = openai：OpenAI 兼容接口（OpenAI / 智谱 / Ollama 兼容模式 / 各种网关）
- type = gemini：Gemini 原生接口
- type = ollama：Ollama 原生接口
- 每个服务商可单独指定 type

### 分层回答
- 本地语料优先：命中就秒回，不联网、不花钱
- 本地没有才转 API：由选中的服务商回答
- 断网也能用本地那套

### 聊天记录
- 每轮对话自动写入 ~/.axiom/history
- Axiom history 查看
- 纯文本，一行一条，可 cat、可 grep

### 语料导入导出
- Axiom export [文件] 把本地语料打包成 brain.tar.gz
- 包内结构固定：brain/ + META
- META 记录 id / author / version / count / time
- 导出时填写作者、版本、ID（ID 限数字英文）
- Axiom import <brain.tar.gz> 导入
- 导入时校验 META 合法性，打印包信息
- 遇到同名文件依次询问：1 覆盖 / 2 跳过 / 3 全部覆盖 / 4 全部跳过

### 其他
- 纯 sh，无 Python / Node 依赖
- 单文件主脚本，拷贝即用
- 配置和数据都在 ~/.axiom/，干净集中

## 安装

### 一键安装（只用主脚本）

curl -fsSL https://raw.githubusercontent.com/xiaofangii2/Axiom/main/Axiom -o ~/bin/Axiom
chmod +x ~/bin/Axiom

要求 ~/bin 在 PATH 里。不在的话：

echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

### 完整安装（含示例配置）

curl -fsSL https://github.com/xiaofangii2/Axiom/archive/refs/heads/main.tar.gz | tar -xz
cd Axiom-main
sh install.sh

### 开发者

git clone https://github.com/xiaofangii2/Axiom.git
cd Axiom
sh install.sh

install.sh 会：
1. 把 Axiom 拷到 ~/bin/
2. 加执行权限
3. 检查 ~/bin 是否在 PATH，不在就帮你写进 shell 配置
4. 检查依赖 curl / tar / jq

## 依赖

- sh：运行脚本，系统自带
- tar：导入导出语料包，Termux 自带
- curl：调 API，Termux 基本自带
- jq：构造和解析 API 的 JSON，走 API 时需要

纯本地聊天不需要 curl 和 jq。

## 用法

Axiom help                       # 帮助
Axiom chat                       # 本地聊天
Axiom train 你好 :: 你好啊        # 教一句
Axiom brain                      # 看学了啥
Axiom forget 你好                # 忘掉一条
Axiom history                    # 聊天记录

Axiom api ollama                 # 添加服务商
Axiom api edit ollama            # 编辑
Axiom api rm ollama              # 删除
Axiom model                      # 列出服务商和模型
Axiom model ollama qwen2.5:0.5b  # 切换
Axiom chat api                   # 用 API 聊天

Axiom export ~/brain.tar.gz      # 导出语料
Axiom import ~/brain.tar.gz      # 导入语料

## 配置

服务商配置在 ~/.axiom/Online-AI.ini，参考 Online-AI.ini.example：

[ollama]
api_url = http://127.0.0.1:11434/v1/chat/completions
token =
models = qwen2.5:0.5b, llama3.2:1b
type = openai

[glm]
api_url = https://open.bigmodel.cn/api/paas/v4/chat/completions
token = 你的key
models = glm-4.7-flash
type = openai

token 可空（本地 Ollama 不需要）。
服务商 ID 唯一，想用同一服务商不同 token，就起两个 ID。

## 语料包格式

brain.tar.gz
├── brain/      # 一条语料一个文件，文件名=输入，内容=回复
└── META        # id / author / version / count / time

META 示例：

id = abc123
author = xiaofangii2
version = 1.0.0
count = 12
time = 2026-10-02 15:30:00

## 数据目录

~/.axiom/
├── brain/                # 语料
├── Online-AI.ini         # 服务商配置
├── current               # 当前选中的服务商+模型
└── history               # 聊天记录