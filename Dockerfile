FROM debian:12-slim
LABEL authors="Jacobo de Vera"

RUN apt-get update && apt-get install -y \
    make \
    git \
    ;

WORKDIR /app
ENV TERM=xterm-256color

COPY . /app

ENTRYPOINT ["./test.sh"]