Andersen courses homework.

TASK 1
	Turn this one-liner into a nice script:
sudo netstat -tunapl | awk '/firefox/ {print $5}' | cut -d: -f1 | sort | uniq -c | sort | tail -n5 | grep -oP '(\d+\.){3}\d+' | while read IP ; do whois $IP | awk -F':' '/^Organization/ {print $2}' ; done


TASK 2
	Download the database:
curl -s https://yandex.ru/news/quotes/graph_2000.json > ./quotes.json

	Analize database and tell which March the price was the least volatile since 2015?
