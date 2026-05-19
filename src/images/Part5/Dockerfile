FROM ubuntu:latest
RUN apt-get -y update && apt -y install curl libfcgi-dev spawn-fcgi nginx build-essential &&  rm -rf /var/lib/apt/lists
RUN rm -f /etc/nginx/sites-enabled/default
COPY ./server/nginx/nginx.conf /etc/nginx/nginx.conf
WORKDIR /usr/src
COPY ./server/start.sh .
COPY ./server/server.c .
RUN gcc -o server server.c -lfcgi
RUN chmod +x start.sh
EXPOSE 81
RUN useradd -m -s /bin/bash appuser && \
    chown -R appuser:appuser /usr/src

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:81/ || exit 1

USER appuser
CMD ["./start.sh"]