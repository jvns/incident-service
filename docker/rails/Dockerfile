FROM node:11 AS node
WORKDIR /app

COPY tailwind.config.js /app/tailwind.config.js
COPY tailwind.css /app/app/assets/stylesheets/tailwind.css
RUN NODE_ENV=production npx tailwindcss-cli@latest build app/assets/stylesheets/tailwind.css -o public/tailwind.css

FROM ruby:2.7.2
RUN apt-get update -qq && apt-get install -y npm postgresql-client
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install --with development test
COPY ./irbrc /root/.irbrc
COPY --from=node /app/public/tailwind.css /app/public/tailwind.css
# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
