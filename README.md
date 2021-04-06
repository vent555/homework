# ANDERSEN COURSES HOMEWORK


# Task 1
## Turn this one-liner into a nice script:
```sh
sudo netstat -tunapl | awk '/firefox/ {print $5}' | cut -d: -f1 \
  | sort | uniq -c | sort | tail -n5 | grep -oP '(\d+\.){3}\d+' \
  | while read IP ; do whois $IP | awk -F':' '/^Organization/ {print $2}' ; done
```


# Task 2
## Analize a database and tell which March the price was the least volatile since 2015?
Download the database https://yandex.ru/news/quotes/graph_2000.json


# Task 3
## Write a script that checks if there are open pull requests for a repository on GitHub. Reports:
* list of the most productive contributors (authors of more than one open PR)
* list of users which PRs has created with the labels
* display checks of every open PR


# Task 4
## Create your own service.
the service should receive `JSON` object and return a string decorated with your favorite emoji in the following manner:
💀evilmartian💀evilmartian💀evilmartian💀


# Task 5
## Create an ansible playbook that deploys the service to the VM.

# Task 5+
## Create docker container with your own app inside.

# Task 6
## Create terraform configuration files to deploy infrastructure in the AWS cloud.
Infrastructure consists of:
* an auto scaling group of web-servers isolated in a private network;
* a data base isolated in a private network;
* a load balancer which receives incoming http requests and forwards its to the web-servers group.
- 
The configuration must provides for any number of infrastructure's copies for a testing purpose.

# Task 7
## Setup two PostgreSQL servers with primary-standby configuration.
* Analize performance with asynchronous and synchronous replication mode;
* Prepare reports with pgbadger.