FROM debian:12-slim
LABEL authors="Jacobo de Vera"

COPY . /app
WORKDIR /app

RUN apt-get update && apt-get install -y \
    make

ENV TERM=xterm-256color
ENTRYPOINT ["make", "test"]