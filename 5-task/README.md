# Task 5. Create an ansible playbook that deploys the service to the VM.


## Running
```sh
ansible-playbook --vault-password-file passfile site.yml
```
* passfile - placed in root directory for education purpose (in real project that file must store in safe place)


## Description
### site.yml
Main deploy file that include two roles: common and web.

### hosts
Inventory file contains list of mananged grouped nodes. For group of hosts applyed setting to use Python3.

### passfile
Used to encrypt some files in project.

### Vagrantfile
Example of vagrantfile to setup test nodes on localhost.

### roles/common/tasks/main.yml
Contains tasks applyed to all nodes.

### roles/common/files/iptables
Setted on all nodes.

### roles/common/vars/common-vars.yml
Encrypted file with values of varaibles. Use command bellow to view file content:
```sh
ansible-vault view --vault-password-file passfile roles/common/vars/common-vars.yml
```

### roles/web/tasks/
* main.yml - Tasks applyed to group of nodes "webservers" splits onto two stages:
* venv.yml - installing virtual environment and project service, 
* nginx.yml - installing and configuration nginx.

### roles/web/files/
* project/ - conteins project files.
* nginx.crt and nginx.key - self-signed certificate.

### roles/web/templates/pyproject.j2
Template of available sites in nginx to deploy project roles/web/files/project/

### roles/web/vars/
Encrypted files with values of varaibles. Use command above to view file content.
