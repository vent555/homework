# Task 1. Turn one-liner into a script.
Based on the instructor's assignment, a one-line script displays no more than five organizations with the resources of which network connections are established by firefox process.
```sh
sudo netstat -tunapl | awk '/firefox/ {print $5}' | cut -d: -f1 \
  | sort | uniq -c | sort | tail -n5 | grep -oP '(\d+\.){3}\d+' \
  | while read IP ; do whois $IP | awk -F':' '/^Organization/ {print $2}' ; done
```


## RUNING
```sh
	./task.sh [argument]
```
* argument - process's name or ID, if no argument specified script will run for "firefox" process's name.


## WORKFLOW
* On first stage script will read and check argument. Script will try to recognize either entered PID or name. If no argument specified, then $_pid variable will assigned "firefox" value.
* Next, unique IP addresses will extracted from netstat command output for the eteblished connections of specified proccess. The result will wrote to t1.tmp file.
If no conections are esteblished, script will notify the user. 
* Finally, for every IP address will executed whois request. Organization's name will extracted from whois respones. Name will wrote in t2.tmp file. File content will sorted and counted by unique value.
* Final table will displayed.


## Dependencies
You should have `netstat` and `whois` utils installed.
```sh
sudo apt-get install net-tools whois -y
```
