# Task 5+. Create docker container with your own app inside.

## Requirements
Docker and docker-compose must be installed.

## Build container
```sh
sudo docker-compose build --no-cache
```
## Run container
```sh
sudo docker-compose up
```

## DESCRIPTION
### docker-compose.yml
Creates service "pyproj" with params:
* build - describes context and Dockerfile location
* volumes - defines mount host path
* ports - makes port forward from 8080 host port to 5000 container port
* environment - transfers run arguments for launch app

### Dockerfile
Contains the commands to assemble the image.

### requirements.txt
Contains list of the packeges required for app.

### jsonproc.py
is app for deploy. The docker-compose.yml file instructes Dockerfile to get it from project location ../../4-task/pyproject/


## Checking
```sh
curl -XPOST -H 'Content-Type: application/json' -d'{"word":"just", "count": 5}' http://127.0.0.1:8080
```
Output will like: 👍just👍just👍just👍just👍just👍


* To get help just try:
```sh
curl http://127.0.0.1:8080
```
