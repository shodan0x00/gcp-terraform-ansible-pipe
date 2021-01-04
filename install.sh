#/bin/bash

id=$(tr -dc a-z0-9 </dev/urandom | head -c 24 ; echo ''); id=asg$id

gcloud projects create $id

gcloud config set project $id

gcloud iam service-accounts create acg-sg \
    --description="GCloud Service Account" \
    --display-name="ServiceAccount"

gcloud projects add-iam-policy-binding $id \
    --member="serviceAccount:acg-sg@$id.iam.gserviceaccount.com" \
    --role="roles/owner"

gcloud iam service-accounts keys create ~/bootstrap/credentials.json \
  --iam-account acg-sg@$id.iam.gserviceaccount.com

b=$(gcloud alpha billing accounts list --uri)

gcloud alpha billing accounts projects link $id --account-id $b

gcloud services enable compute.googleapis.com

apt-get update && apt-get install ansible -y

wget https://releases.hashicorp.com/terraform/0.14.3/terraform_0.14.3_linux_amd64.zip

unzip -o terraform_0.14.3_linux_amd64.zip

mv -f terraform /usr/bin

cd bootstrap

bucket=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1)

export GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/credentials.json

sed -i -e "s/@project-name/\"$id\"/g" gcp.tfvars

sed -i -e "s/@bucket-name/\"$bucket\"/g" gcp.tfvars

sed -i -e "s/@bucket-name/\"$bucket\"/g" compute/create-instances.tf

sed -i -e "s/@bucket-name/\"$bucket\"/g" template/ansible_template.tf

cd $HOME/bootstrap/remote-state && terraform init && terraform apply -var-file='/home/asborisov/gcp/gcp.tfvars' -auto-approve

cd $HOME/bootstrap/compute && terraform init && terraform apply -var-file='/home/asborisov/gcp/gcp.tfvars' -auto-approve

cd $HOME/bootstrap/template && terraform init && terraform apply -var-file='/home/asborisov/gcp/gcp.tfvars' -auto-approve

echo "INSTALLATION DONE"

pwd
