# Axiom

一个用纯 shell 写的轻量聊天工具，跑在 Termux / Linux 上。

支持本地语料查表，也支持接多个大模型服务商（OpenAI 兼容 / Gemini / Ollama）。
本地优先，命不中就转 API。整个项目零 Python、零 Node，纯 sh 实现。

项目包含两个模型：

- Axiom-V2：正常聊天模型，本地语料 + API 兜底 + 多会话 + 算术
- Axiom-R1：思维版，纯查词，直接把思考过程打出来

## 为什么做这个

- 想在手机上有个能随时调用的聊天工具，不想装一堆运行时
- 想自己维护一份本地语料，常用问题秒回，不联网不花钱
- 想同时管多个模型服务商，随时切换
- 想分享自己的语料包，也导入别人的

## 特性

### 本地语料

- Axiom train <输入> :: <回复> 教它一句话
- 一条语料一个文件，存在 ~/.axiom/Axiom-V2/brain/
- 文件名就是输入，文件内容就是回复
- 文件名大小写不敏感，Hello 和 hello 命中同一条
- Axiom brain 列出所有学过的内容
- Axiom brain --raw 只列文件名，语料多了看着清爽
- Axiom forget <输入> 忘掉某一条
- Axiom chat 进入纯本地聊天，命不中回“未训练”
- 输入结尾的标点自动忽略，你是谁。 等同 你是谁

### 多服务商

- 一份 Online-AI.ini 管多个服务商，互不干扰
- 服务商 ID 唯一，重名直接拒绝，不做覆盖
- Axiom api <ID> 添加服务商
- Axiom api edit <ID> 或 Axiom api set <ID> 编辑
- Axiom api rm <ID> 删除
- Axiom model 列出所有服务商和模型，当前选中标 *
- Axiom model <ID> <模型> 切换当前
- Axiom chat api 一律走 API
- 当前选中存在 ~/.axiom/Axiom-V2/current，两行：服务商 ID、模型名

### 三种协议

- type = openai：OpenAI 兼容接口（OpenAI / 智谱 / Ollama 兼容模式 / 各种网关）
- type = gemini：Gemini 原生接口
- type = ollama：Ollama 原生接口
- 每个服务商可单独指定 type
- token 可空，空则不发送 Authorization 头

### 多会话

- Axiom chat set <名> 新建会话
- Axiom chat say <名> 进入会话聊天，带上下文
- Axiom chat ls 列出所有会话及轮数
- Axiom chat rm <名> 删除会话
- 每个会话一个文件，存在 ~/.axiom/Axiom-V2/conv/<名>
- 会话历史以 user: / assistant: 逐行记录，纯文本可读
- 发 API 时把整个会话历史拼成 messages 一起发
- 会话上限 40 轮，超出自动砍掉最早的对话

### 算术

- 输入纯算式（3+5、12×4、10÷4）直接用 bc 计算
- × 自动转 *，÷ 自动转 /
- 支持小数点、括号、百分号
- 不联网、不走 API，本地秒算

### 输入归一化

- 结尾的逗号、句号、问号、感叹号、分号、空格自动忽略
- 你是谁。 等同 你是谁
- 大小写都尝试匹配，文件名和输入任一命中即可

### 聊天记录

- V2 记录：~/.axiom/Axiom-V2/history
- R1 记录：~/.axiom/Axiom-R1/history
- Axiom history 查看 V2 记录
- Axiom history clear 清空 V2 记录
- Axiom cog history 查看 R1 记录
- Axiom cog history clear 清空 R1 记录
- 两边各自独立，互不干扰

### 语料导入导出

- Axiom export [文件] 把 V2 语料打包成 brain.tar.gz
- 包内结构固定：brain/ + META
- META 记录 id / author / version / description / count / time
- 导出时依次问 id、author、version、description
- id 只允许数字和英文，非法重问
- Axiom import <文件> 导入本地包
- Axiom import <URL> 直接从链接下载并导入
- 导入时打印包信息：ID、作者、版本、说明、条数、导出时间
- 导入时校验 META 合法性，不合法直接中止
- 遇到同名文件依次询问：1 覆盖 / 2 跳过 / 3 全部覆盖 / 4 全部跳过

### 思维版 R1

- Axiom cog 进入 R1 思维模式
- 纯查 R1 自己的语料，不碰 API、不聊天
- 每条输入先输出思考过程，再给结果
- 输出格式：
  [思考] 收到用户输入: xxx
  [思考] 查 R1 语料: xxx → 命中 / 未命中
  [结果] yyy
- Axiom cog train <输入> :: <回复> 训 R1
- Axiom cog brain 看 R1 学了啥
- Axiom cog brain --raw 只列 R1 文件名
- Axiom cog forget <输入> 忘掉 R1 一条
- R1 语料单独存，存在 ~/.axiom/Axiom-R1/brain/

### 配置

- 主配置在 ~/.axiom/config.yml，YAML 格式
- 目前有 can_think 一项，控制是否默认开思考
- 命令行末尾加 think 只当次生效，不写回配置
- 以后要加新配置项，直接往 config.yml 里加行

## 安装

### 一键安装

curl -fsSL https://github.com/xiaofangii2/Axiom/archive/refs/heads/main.tar.gz | tar -xz
cd Axiom-main
sh install.sh

### 开发者

git clone https://github.com/xiaofangii2/Axiom.git
cd Axiom
sh install.sh

install.sh 会做这些事：

1. 建 ~/.axiom/ 下各目录
2. 把 V2 和 R1 脚本拷到 ~/.axiom/
3. 把 launcher 拷到 ~/bin/Axiom
4. 生成 config.yml（已存在则跳过）
5. 检查 PATH，不在就帮你写进 shell 配置
6. 检查依赖 curl / tar / jq / bc

## 依赖

- sh：运行脚本，系统自带
- tar：导入导出语料包，Termux 自带
- curl：调 API，Termux 基本自带
- jq：构造和解析 API 的 JSON，走 API 时需要
- bc：算术计算，输入算式时需要

纯本地聊天不需要 curl 和 jq。

## 用法

Axiom help                       # 帮助
Axiom chat                       # 本地聊天
Axiom chat think                 # 本地聊天，这次开思考
Axiom chat api                   # 走 API
Axiom chat api think             # 走 API，这次开思考
Axiom chat set 工作              # 建会话
Axiom chat say 工作              # 进会话
Axiom chat say 工作 think        # 进会话，这次开思考
Axiom chat ls                    # 列出会话
Axiom chat rm 工作               # 删会话
Axiom train 你好 :: 你好啊        # 教一句
Axiom brain                      # 看学了啥
Axiom brain --raw                # 只列文件名
Axiom forget 你好                # 忘掉一条
Axiom history                    # 聊天记录
Axiom history clear              # 清空记录

Axiom api ollama                 # 添加服务商
Axiom api edit ollama            # 编辑
Axiom api rm ollama              # 删除
Axiom model                      # 列出服务商和模型
Axiom model ollama qwen2.5:0.5b  # 切换
Axiom chat api                   # 用 API 聊天

Axiom export ~/brain.tar.gz      # 导出语料
Axiom import ~/brain.tar.gz      # 导入语料
Axiom import https://.../brain.tar.gz   # 从 URL 导入

Axiom cog                        # 进 R1 思维模式
Axiom cog train 你好 :: 你好啊    # 训 R1
Axiom cog brain                  # 看 R1 学了啥
Axiom cog forget 你好            # 忘掉 R1 一条
Axiom cog history                # 看 R1 记录

## 配置

服务商配置在 ~/.axiom/Axiom-V2/Online-AI.ini，参考 Online-AI.ini.example：

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

字段说明：

- api_url：接口地址
- token：密钥，可空
- models：模型列表，逗号分隔
- type：协议类型，openai / gemini / ollama

token 可空（本地 Ollama 不需要）。
服务商 ID 唯一，想用同一服务商不同 token，就起两个 ID。

主配置在 ~/.axiom/config.yml：

# Axiom 配置
# can_think: 是否默认开启思考（true / false）
# 命令行末尾加 think 只当次生效，不写回这里

can_think: false

## 语料包格式

brain.tar.gz
├── brain/      # 一条语料一个文件，文件名=输入，内容=回复
└── META        # id / author / version / description / count / time

META 示例：

id = abc123
author = xiaofangii2
version = 1.0.0
description = 基础语料
count = 12
time = 2026-10-02 15:30:00

## 数据目录

~/.axiom/
├── config.yml
├── Axiom-V2/
│   ├── brain/            # V2 语料
│   ├── Online-AI.ini     # V2 服务商配置
│   ├── current           # V2 选中的服务商+模型
│   ├── history           # V2 聊天记录
│   └── conv/             # V2 会话
└── Axiom-R1/
    ├── brain/            # R1 语料
    └── history           # R1 聊天记录

## 常见问题

Q: 为什么本地语料命中不了？
A: 检查 ~/.axiom/Axiom-V2/brain/ 里的文件名，跟你输入的是否一致（大小写不敏感）。输入结尾的标点会自动忽略。

Q: 会话太长了会怎样？
A: 超过 40 轮会自动砍掉最早的对话，保留最近 40 轮。

Q: 走 API 时报 jq 错误？
A: 脚本有兜底，jq 失败会自动退回 sed 提取。若仍失败，检查服务商 URL 和模型名是否正确。

Q: Ollama 的 token 要填吗？
A: 不用，直接回车留空。

Q: R1 和 V2 的语料会混吗？
A: 不会，两边语料完全独立，存在不同目录。

## 目录结构（仓库）

Axiom/
├── launcher               # → ~/bin/Axiom
├── install.sh             # 安装脚本
├── README.md              # 本文档
├── Online-AI.ini.example  # 示例配置
├── examples/
│   └── brain.tar.gz       # 示例语料包
├── Axiom-V2/
│   └── Axiom              # V2 主脚本
└── Axiom-R1/
    └── Axiom              # R1 主脚本