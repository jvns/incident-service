#!/bin/bash
scp scripts/post-receive root@dockerbox:/git/incident-service.git/hooks/post-receive
scp secrets_prod.sh wizard.key wizard.key.pub root@dockerbox:/app/
scp scripts/master.key root@dockerbox:/app/config/master.key
