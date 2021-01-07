# launching the first time 
sudo -s<br>
<br>
rm -rf /opt/bootstrap<br>
<br>
cd ~<br>
<br>
git clone https://github.com/asborsiov/gcp-terraform-ansible-pipe.git /opt/bootstrap<br>
<br>
bash /opt/bootstrap/install.sh<br>

# manual ssh 
copy remote_user from /opt/bootstrap/ansible.cfg
copy key file /opt/bootstrap/ssh-key

ssh -i ansible_key sa_remote_account@public_ip
