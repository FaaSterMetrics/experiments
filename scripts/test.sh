#!/bin/bash

set -euo pipefail

expname="webservice"

cd infrastructure
terraform workspace select $expname
tfoutput=$(terraform output -json)
cd -
aws_url=$(echo $tfoutput | jq -r '.aws_invoke_url.value')
google_url=$(echo $tfoutput | jq -r '.google_invoke_url.value')


for fn in $(cat experiments/$expname/experiment.json | jq -r '.program.aws | keys[]'); do
  echo "Testing function: ${fn}"
  curl -s $aws_url/${fn}
done

for fn in $(cat experiments/$expname/experiment.json | jq -r '.program.google | keys[]'); do
  echo "Testing function: ${fn}"
  curl -s $google_url/${fn}
done
