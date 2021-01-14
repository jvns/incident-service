FROM golang:1.13 AS go

WORKDIR /go/src/app
COPY . .

RUN go get -d -v ./...
RUN go build

FROM ubuntu:20.04
RUN apt-get update
RUN apt-get install -y openssh-client
COPY --from=go /go/src/app/multi-gotty  /usr/bin/multi-gotty
WORKDIR /app


