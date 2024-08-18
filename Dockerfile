#FROM alpine:latest
#RUN apk add --no-cache bash
FROM ubuntu:latest
RUN apt-get update && apt-get install -y \
    zip

WORKDIR /input

COPY bin/ /usr/local/bin/
RUN chmod +x /usr/local/bin/*

COPY exclude.rfa /root/exclude.rfa

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]