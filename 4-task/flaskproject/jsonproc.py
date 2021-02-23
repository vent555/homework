from flask import Flask, jsonify

people = [{'name': 'Alice', 'birth-year': 1986},
          {'name': 'Bob', 'birth-year': 1985}]

app = Flask(__name__)

@app.route('/api/get-json')
def hello():
    return jsonify(people)