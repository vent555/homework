from flask import Flask, jsonify, request
from emoji import emojize

app = Flask(__name__)

@app.route('/', methods=['GET', 'POST', 'DELETE', 'PUT'])                                                                                                    
def add():
    a = 1
    strout = emojize(":thumbs_up:")                                                                                                                              
    data = request.get_json()
    while a <= data["count"]:
        strout = strout + data["word"] + emojize(":thumbs_up:")
        a += 1

    strout = strout + '\n'

    return strout