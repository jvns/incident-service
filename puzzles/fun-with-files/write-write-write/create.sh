if [ -n "$1" ]
then
    SUFFIX=$1
else
    SUFFIX=`cat /dev/urandom | tr -dc 'a-z' | fold -w 5 | head -n 1`
fi
set -eux
cloud-init devel  schema  --config-file cloud-init.yaml
gcloud compute instances create disk-writing-$SUFFIX  \
    --machine-type https://www.googleapis.com/compute/v1/projects/wizard-debugging-school/zones/us-east1-c/machineTypes/f1-micro \
    --image projects/ubuntu-os-cloud/global/images/ubuntu-1804-bionic-v20190514\
    --metadata-from-file user-data=cloud-init.yaml \
    --metadata cos-update-strategy=update_disabled
