# ANDERSEN COURSES HOMEWORK


# Task 1
## Turn this one-liner into a nice script:
```sh
sudo netstat -tunapl | awk '/firefox/ {print $5}' | cut -d: -f1 \
  | sort | uniq -c | sort | tail -n5 | grep -oP '(\d+\.){3}\d+' \
  | while read IP ; do whois $IP | awk -F':' '/^Organization/ {print $2}' ; done
```


#T ask 2
## Analize database and tell which March the price was the least volatile since 2015?
* Download the database https://yandex.ru/news/quotes/graph_2000.json


# Task 3
## Write a script that checks if there are open pull requests for a repository on GitHub. Reports:
* list of the most productive contributors (authors of more than 1 open PR)
* list of users which PRs has created with the labels
* checks of every open PR
