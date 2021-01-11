#!/bin/bash
set -e
cd /app
docker-compose -f docker-compose-prod.yaml exec rails rails cleanup_all_vms.rb

