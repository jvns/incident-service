FROM node:11 AS node
WORKDIR /app
COPY app /app/app
COPY tailwind.config.js /app/tailwind.config.js
RUN NODE_ENV=production npx tailwindcss-cli@latest build app/assets/stylesheets/tailwind.css -o public/tailwind.css

FROM nginx
COPY ./docker/nginx/rails.conf /etc/nginx/conf.d/default.conf
COPY --from=node /app/public/tailwind.css /tailwind/tailwind.css
