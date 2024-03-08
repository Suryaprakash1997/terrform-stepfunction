#! /bin/bash
terraform init
terraform destroy -auto-approve
if [ $? -eq 0 ]; then
    echo "success" > script-status.txt
else
    echo "failure" > script-status.txt
fi
aws s3 cp script-status.txt s3://terrafornstatus/script-status.txt
