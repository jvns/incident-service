FROM node:11 AS node
WORKDIR /app

COPY tailwind.config.js /app/tailwind.config.js
COPY tailwind.css /app/app/assets/stylesheets/tailwind.css
RUN NODE_ENV=production npx tailwindcss-cli@latest build app/assets/stylesheets/tailwind.css -o public/tailwind.css

FROM nginx
COPY ./rails.conf /etc/nginx/conf.d/default.conf
COPY --from=node /app/public/tailwind.css /app/public/tailwind.css
