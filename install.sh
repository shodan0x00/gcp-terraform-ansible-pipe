#/bin/bash

#generate random project and activate billing with creation of service account and compute API
id=$(tr -dc a-z0-9 </dev/urandom | head -c 24 ; echo ''); id=asg$id

gcloud projects create $id

gcloud config set project $id

gcloud compute project-info add-metadata \
    --metadata enable-oslogin=TRUE

gcloud iam service-accounts create acg-sg \
    --description="GCloud Service Account" \
    --display-name="ServiceAccount"

gcloud projects add-iam-policy-binding $id \
    --member="serviceAccount:acg-sg@$id.iam.gserviceaccount.com" \
    --role="roles/owner"
    
gcloud iam service-accounts keys create /opt/bootstrap/credentials.json \
  --iam-account acg-sg@$id.iam.gserviceaccount.com

b=$(gcloud alpha billing accounts list --uri)

gcloud alpha billing accounts projects link $id --account-id $b

gcloud services enable compute.googleapis.com

#install ansible and terraform
apt-get update && apt-get install ansible -y

wget https://releases.hashicorp.com/terraform/0.14.3/terraform_0.14.3_linux_amd64.zip

unzip -o terraform_0.14.3_linux_amd64.zip

mv -f terraform /usr/bin

#morphing project and bucket name into placeholders
cd /opt/bootstrap

sed -i -e "s/@project-name/\"$id\"/g" gcp.tfvars

sed -i -e "s/@bucket-name/\"$id\"/g" gcp.tfvars

sed -i -e "s/@bucket-name/\"$id\"/g" compute/create-instances.tf

sed -i -e "s/@bucket-name/\"$id\"/g" template/ansible_template.tf

#activating terraform auth
export GOOGLE_APPLICATION_CREDENTIALS=/opt/bootstrap/credentials.json

#preparing SSH keys
ssh-keygen -b 2048 -t rsa -f /opt/bootstrap/ssh-key-ansible -q -N ""

gcloud auth activate-service-account --key-file /opt/bootstrap/credentials.json

$ansible_sa=$(gcloud compute os-login ssh-keys add --key-file=/opt/bootstrap/ssh-key-ansible.pub | grep 'username:' | awk '{print $2}')

#executing terraform inits
sleep 15
cd /opt/bootstrap/remote-state && terraform init && terraform apply -var-file='/opt/bootstrap/gcp.tfvars' -auto-approve
sleep 15
cd /opt/bootstrap/compute && terraform init && terraform apply -var-file='/opt/bootstrap/gcp.tfvars' -auto-approve
sleep 15
cd /opt/bootstrap/template && terraform init && terraform apply -var-file='/opt/bootstrap/gcp.tfvars' -auto-approve

echo "INSTALLATION DONE"
