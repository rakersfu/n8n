ARG N8N_VERSION=stable
FROM docker.n8n.io/n8nio/n8n:$N8N_VERSION

LABEL maintainer="rakersfu <mail@graker.eu.org>"

ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true \
    N8N_RUNNERS_ENABLED=true \
    N8N_PROXY_HOPS=1
    JKYD_USER=app
    JKYD_PASSWORD=app123

USER root

# 安装 Python3 和 curl
RUN apk add --no-cache python3 py3-pip curl

# 使用 get-pip.py 安装 pip 并绕过 PEP 668
COPY requirements.txt /home/node/requirements.txt

RUN curl -sS https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3 get-pip.py --break-system-packages && \
    rm get-pip.py && \
    pip3 install --no-cache-dir -r /home/node/requirements.txt --break-system-packages && \
    pip3 cache purge

# 安装 jkyd
COPY jkyd.x86_64 /usr/local/bin/jkyd
#RUN curl -L -o /usr/local/bin/jkyd https://gitee.com/rakerose/gist/raw/master/jkyd.x86_64 && \
    chmod +x /usr/local/bin/jkyd

USER node

VOLUME ["$HOME/.n8n"]

EXPOSE 5678 7681
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
