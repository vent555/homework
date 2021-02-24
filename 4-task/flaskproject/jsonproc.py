from flask import Flask, jsonify, request
from emoji import emojize

app = Flask(__name__)

@app.route('/', methods=['GET'])
def method_get():
     return '''
Hello! Try to use POST request for more fun.
Send me something like this: {"word":"everything", "count": 3}
Don't forget to point content type "application/json".
'''

@app.route('/', methods=['POST'])                                                                                                    
def method_post():
    a = 1
    strout = emojize(":thumbs_up:")                                                                                                                              
    data = request.get_json()
    while a <= data["count"]:
        strout = strout + data["word"] + emojize(":thumbs_up:")
        a += 1

    strout = strout + '\n'

    return strout