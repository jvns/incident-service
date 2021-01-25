FROM golang:1.13 AS go

WORKDIR /go/src/app
RUN git clone https://github.com/jvns/multi-gotty
WORKDIR /go/src/app/multi-gotty

RUN go mod download
RUN go build

FROM ubuntu:20.04
RUN apt-get update && apt-get install -y openssh-client
COPY --from=go /go/src/app/multi-gotty/multi-gotty  /usr/bin/multi-gotty
COPY gotty-statics /app/gotty-statics
WORKDIR /app
COPY wizard.key /app/wizard.key

CMD ["/usr/bin/multi-gotty", "--ws-origin", "https://exploding-computers.fly.dev", "--index-dir", "/app/gotty-statics/", "--port", "8080", "--address", "0.0.0.0", "http://exploding-rails.internal:3000/sessions"]
