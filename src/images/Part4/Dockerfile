FROM ubuntu:latest
RUN apt-get -y update && apt -y install libfcgi-dev spawn-fcgi nginx build-essential
RUN rm -f /etc/nginx/sites-enabled/default
# COPY ./server/nginx.conf /etc/nginx/nginx.conf
WORKDIR /usr/src
COPY ./server/start.sh .
COPY ./server/server.c .
RUN gcc -o server server.c -lfcgi
RUN chmod +x start.sh
EXPOSE 81
CMD ["./start.sh"]