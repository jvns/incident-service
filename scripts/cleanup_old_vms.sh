#!/bin/bash
set -e
# docker-compose is in /usr/local/bin which isn't in the path that cron has for some reason
export PATH=$PATH:/usr/local/bin
cd /app
docker-compose -f docker-compose-prod.yml exec rails rails runner cleanup_old_vms.rb

