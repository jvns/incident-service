FROM ruby:2.7.2
RUN apt-get update -qq && apt-get install -y npm postgresql-client
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install --with development test
# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
