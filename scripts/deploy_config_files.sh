#!/bin/bash
#scp scripts/nginx_rails root@rails-box:/etc/nginx/sites-enabled/rails
#scp scripts/post-receive root@rails-box:/home/wizard-debugging-school/hooks/
#scp wizard.key root@rails-box:/home/wizard-debugging-school-deployed/
scp scripts/post-receive root@dockerbox:/git/incident-service.git/hooks/post-receive
scp secrets_prod.sh root@dockerbox:/app/
scp scripts/master.key root@dockerbox:/app/config/master.key
