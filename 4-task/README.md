# Task 4. Create and deploy your own service.

## CONTENT
* hello.py - module says "Hello" to the world or someone
* savefile.py - module lets user upload txt file on server, then display content of that file
* jsonproc.py - module accept POST request with word and count value, then display word with emoji


## DESCRIPTION
### jsonproc.py

* Run module and try from commad line (any "word" string value and "count" integer  accepted):
```sh
curl -XPOST -H 'Content-Type: application/json' -d'{"word":"just", "count": 5}' http://example.site
```
Output will like: 👍just👍just👍just👍just👍just👍


* To get help just try:
```sh
curl http://example.site
```
on local testing use http://127.0.0.1:5000


### Known shortcomings
* no input checks
