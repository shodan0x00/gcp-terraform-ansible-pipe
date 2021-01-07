# How to launch (restart the console for reruns)

Open cloud shell (top right corner) and execute this commands

```bash
sudo -s
cd ~
git clone https://github.com/RT-Data-Engineer/gcp-terraform-ansible-pipe.git /opt/bootstrap
bash /opt/bootstrap/install.sh
```
# How to ssh manually 
copy remote_user from /opt/bootstrap/ansible.cfg<br>
copy key file /opt/bootstrap/ssh-key<br>
```bash
ssh -i ansible_key sa_remote_account@public_ip
```
