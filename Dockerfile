ARG N8N_VERSION=stable
FROM docker.n8n.io/n8nio/n8n:$N8N_VERSION

LABEL maintainer="rakersfu <mail@graker.eu.org>"

# 设置环境变量（每行用反斜杠续行）
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true \
    N8N_RUNNERS_ENABLED=true \
    N8N_PROXY_HOPS=1 \
    JKYD_USER=app \
    JKYD_PASSWORD=app123

USER root

# 安装 Python3、curl、ttyd 依赖
RUN apk add --no-cache python3 py3-pip curl ttyd

# 安装 pip 并绕过 PEP 668
COPY requirements.txt /home/node/requirements.txt
RUN curl -sS https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3 get-pip.py --break-system-packages && \
    rm get-pip.py && \
    pip3 install --no-cache-dir -r /home/node/requirements.txt --break-system-packages && \
    pip3 cache purge

# 安装 jkyd
COPY jkyd.x86_64 /usr/local/bin/jkyd
RUN chmod +x /usr/local/bin/jkyd

# 安装 cloud
RUN curl -L -C - -o /usr/local/bin/cloud "https://1135-user-app-free-download-cdn.123295.com/123-685/e82d0e6a/1814971086-0/e82d0e6a741d15a519d9f056f07c06ad/c-m104?v=1&t=1762667145&s=5e19c3b169e5727f0e4a2dfb21900386&bzc=1&bzs=1814971086&bzp=0&bi=3349300572&filename=cloudflared&x-mf-biz-cid=28512d3c-7d2b-409c-b384-48140c96760c-584000&ndcp=1&cache_type=1" && \
    chmod +x /usr/local/bin/cloud

# 添加入口脚本
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

USER node

VOLUME ["$HOME/.n8n"]

EXPOSE 5678 7681

ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
