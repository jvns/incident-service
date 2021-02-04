FROM golang:1.13 AS go

WORKDIR /go/src/app
COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .
RUN go build

FROM ubuntu:20.04
RUN apt-get update && apt-get install -y openssh-client mosh
COPY --from=go /go/src/app/multi-gotty  /usr/bin/multi-gotty
WORKDIR /app


