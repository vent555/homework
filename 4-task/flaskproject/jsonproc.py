from flask import Flask, jsonify, request
from emoji import emojize


app = Flask(__name__)

@app.route('/', methods=['GET', 'POST', 'DELETE', 'PUT'])                                                                                                    
def add():                                                                                                                              
    data = request.get_json()
    strout = emojize(":thumbs_up:") + data["word"] + emojize(":thumbs_up:")
    return strout