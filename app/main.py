
"""
  Simple Page to demostrate the trio of 
  ECR, CIRCLE and DOCKER using PYTHON
"""
from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
@app.route('/index')
def index():
  return render_template('index.html')

if __name__=="__main__":
  app.run(host='0.0.0.0', debug=True, port=80)