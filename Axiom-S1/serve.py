#!/usr/bin/env python3
# Axiom-S1 serve - V2 优先，R1 兜底

import json
import os
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer

V2_BRAIN = os.path.expanduser("~/.axiom/Axiom-V2/brain")
R1_BRAIN = os.path.expanduser("~/.axiom/Axiom-R1/brain")
TOKEN_FILE = os.path.expanduser("~/.axiom/token.tnt")
LOGS_DIR = os.path.expanduser("~/.axiom/logs")
DEBUG_FLAG = os.path.expanduser("~/.axiom/debug")
DEFAULT_PORT = 8712

def load_tokens():
    tokens = []
    if os.path.isfile(TOKEN_FILE):
        with open(TOKEN_FILE, "r") as f:
            for line in f:
                t = line.strip()
                if t:
                    tokens.append(t)
    return tokens

def log(msg):
    if not os.path.isfile(DEBUG_FLAG):
        return
    if not os.path.isdir(LOGS_DIR):
        return
    try:
        from datetime import datetime
        run = os.environ.get("AXIOM_RUN_NUM", "0")
        y = datetime.now().strftime("%y")
        md = datetime.now().strftime("%m.%d")
        fname = "%s-%s-%s_S1.log" % (y, md, run)
        ts = datetime.now().strftime("%H:%M:%S")
        with open(os.path.join(LOGS_DIR, fname), "a") as f:
            f.write("[%s] %s\n" % (ts, msg))
    except Exception:
        pass

def lookup_in(brain_dir, user_msg):
    if not os.path.isdir(brain_dir):
        return None
    msg = user_msg.strip()
    for name in [msg.lower(), msg]:
        path = os.path.join(brain_dir, name)
        if os.path.isfile(path):
            try:
                with open(path, "r") as f:
                    return f.read()
            except Exception:
                pass
    return None

def lookup(user_msg):
    r = lookup_in(V2_BRAIN, user_msg)
    if r is not None:
        return r
    r = lookup_in(R1_BRAIN, user_msg)
    if r is not None:
        return r
    return "未训练"

class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        pass

    def do_POST(self):
        tokens = load_tokens()

        auth = self.headers.get("Authorization", "")
        if auth.startswith("Bearer "):
            got = auth[7:].strip()
        else:
            got = ""

        if not tokens:
            self.send_response(500)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"error": "no token configured"}).encode())
            return

        if got not in tokens:
            log("unauthorized: %s" % got)
            self.send_response(401)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"error": "unauthorized"}).encode())
            return

        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length).decode("utf-8", "ignore")

        try:
            data = json.loads(body)
        except Exception:
            self.send_response(400)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"error": "bad json"}).encode())
            return

        user_msg = ""
        msgs = data.get("messages", [])
        if msgs:
            user_msg = msgs[-1].get("content", "")

        reply = lookup(user_msg)
        log("req: %s -> %s" % (user_msg, reply))

        resp = {
            "id": "axiom-s1",
            "object": "chat.completion",
            "model": data.get("model", "axiom"),
            "choices": [{
                "index": 0,
                "message": {"role": "assistant", "content": reply},
                "finish_reason": "stop"
            }]
        }

        out = json.dumps(resp).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(out)))
        self.end_headers()
        self.wfile.write(out)

def main():
    port = DEFAULT_PORT
    if len(sys.argv) > 1:
        try:
            port = int(sys.argv[1])
        except ValueError:
            pass

    print("Axiom-S1 启动，端口 %d" % port)
    print("V2 语料: %s" % V2_BRAIN)
    print("R1 语料: %s" % R1_BRAIN)
    print("token 文件: %s" % TOKEN_FILE)
    print("Ctrl+C 停止")

    server = HTTPServer(("127.0.0.1", port), Handler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nAxiom-S1 已停止")

if __name__ == "__main__":
    main()
