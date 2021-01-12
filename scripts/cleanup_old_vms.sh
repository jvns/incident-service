#!/bin/bash
set -e
cd /app
/usr/local/bin/docker-compose -f docker-compose-prod.yml exec rails rails runner cleanup_old_vms.rb

