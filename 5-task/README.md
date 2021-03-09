# Task 5. Create an ansible playbook that deploys the service to the VM.


## Running
```sh
ansible-playbook --vault-password-file passfile site.yml
```
* passfile - placed in root directory for education purpose (in real project that file must store in safe place)


## Vagrantfile
Example of vagrantfile to setup test nodes on localhost.


## Playbook description
### site.yml
Main deploy file that include two roles: common and web.

### hosts
Inventory file contains list of mananged grouped nodes. For group of hosts applyed setting to use Python3.

### roles/common/tasks/
* main.yml - Tasks applyed to all nodes splits onto two stages:
* iptables-cp.yml or iptables-create.yml - apply iptables rules, 
* packages.yml - install all needed packages.

### roles/common/files/iptables
Encrypted file with iptables rules which setted on all nodes.
```sh
ansible-vault view --vault-password-file passfile roles/common/files/iptables
```

### roles/common/vars/
common-vars.yml / iptables.yml - encrypted files with values of varaibles. Use command above to view file content.

### roles/web/tasks/
* main.yml - Tasks applyed to group of nodes "webservers" splits onto two stages:
* venv.yml - install virtual environment and project service, 
* nginx.yml - install and configure nginx.

### roles/web/files/
* pyproject.service - file to start pyproject service.
* nginx.crt and nginx.key - self-signed certificate.

### roles/web/templates/pyproject.j2
Template of available sites in nginx to deploy pyproject.

### roles/web/vars/
Encrypted files with values of varaibles. Use command above to view file content.


## Project verification
To verify deployed project try from localhost (port forwarding configuration must correspond Vagrantfile):
```s
curl https://127.0.0.1:8081
curl -XPOST -H'Content-Type: application/json' -d'{"word":"just", "count": 5}' https://127.0.0.1:8081
```
OR
```s
curl --insecure https://127.0.0.1:4431
curl -XPOST -H'Content-Type: application/json' -d'{"word":"just", "count": 5}' --insecure https://127.0.0.1:4431
```

