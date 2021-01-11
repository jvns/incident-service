#!/bin/bash
set -e
cd /app
docker-compose -f docker-compose-prod.yml exec rails rails cleanup_old_vms.rb

