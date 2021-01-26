FROM golang:1.13 AS go

WORKDIR /go/src/app
COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .

RUN go build

FROM ubuntu:20.04
RUN apt-get update && apt-get install -y wget iproute2
RUN wget https://github.com/firecracker-microvm/firecracker/releases/download/v0.23.2/Firecracker-v0.23.2-x86_64.tgz 
RUN tar -xf Firecracker-v0.23.2-x86_64.tgz
RUN cp release-v0.23.2/firecracker-v0.23.2-x86_64 /usr/bin/firecracker
RUN cp release-v0.23.2/jailer-v0.23.2-x86_64 /usr/bin/jailer
RUN apt-get install -y dmsetup
COPY --from=go /go/src/app/firecracker-manager  /usr/bin/firecracker-manager
WORKDIR /app


