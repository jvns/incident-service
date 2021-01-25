FROM golang:1.13 AS go

WORKDIR /go/src/app

COPY fly-api-fun/go.mod .
COPY fly-api-fun/go.sum .
RUN go mod download

COPY fly-api-fun .
RUN go build

FROM ruby:2.7.2
RUN apt-get update -qq && apt-get install -y npm postgresql-client
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install --without development test
RUN apt install -y wget
RUN wget https://github.com/superfly/flyctl/releases/download/v0.0.171/flyctl_0.0.171_Linux_x86_64 -O /usr/bin/flyctl
RUN chmod a+x /usr/bin/flyctl
COPY Rakefile /app/Rakefile
COPY bin /app/bin
COPY config /app/config
COPY db /app/db
COPY lib /app/lib
COPY public /app/public
COPY storage /app/storage
COPY test /app/test
COPY config.ru /app/config.ru
COPY app /app/app
RUN mkdir /app/tmp /app/log
COPY wizard.key /app/wizard.key
COPY --from=go /go/src/app/fly-fun /app/fly-api-fun/fly-fun
# Start the main process.
CMD ["rails", "server", "-b", "[::]"]
