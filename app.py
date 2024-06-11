from flask import Flask, request, jsonify, make_response, Response
from prometheus_client import Counter, Gauge, start_http_server, generate_latest
import random
from flask_sqlalchemy import SQLAlchemy
from os import environ

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = environ.get('DB_URL')
db = SQLAlchemy(app)

class User(db.Model):
    __tablename__ = 'users'

    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)

    def json(self):
        return {'id': self.id,'username': self.username, 'email': self.email}

with app.app_context():
    db.create_all()

CONTENT_TYPE_LATEST = str('text/plain; version=0.0.4; charset=utf-8')

number_of_requests = Counter(
    'number_of_requests',
    'The number of requests, its a counter so the value can increase or reset to zero.'
)

number_of_errors = Counter(
    'number_of_errors',
    'The number of errors, its a counter so the value can increase or reset to zero.'
)


#create a test route
@app.route('/test', methods=['GET'])
def test():
  return make_response(jsonify({'message': 'test route ...'}), 200)


# create a user
@app.route('/users', methods=['POST'])
def create_user():
    try:
        if request.headers['Content-Type'] != 'application/json':
            return make_response(jsonify({'message': 'Content-Type must be application/json'}), 400)
        data = request.get_json()
        print("Received data:", data)

        if "username" not in data or "email" not in data:
            return make_response(jsonify({'message': 'Missing username or email in request'}), 400)

        new_user = User(username=data["username"], email=data["email"])
        db.session.add(new_user)
        db.session.commit()

        return make_response(jsonify({'message': 'user created'}), 201)
    except Exception as e:
        db.session.rollback()
        number_of_errors.inc()
        return make_response(jsonify({'message': f'error creating user: {str(e)}'}), 500)
    finally:
        db.session.close()

# get all users
@app.route('/users', methods=['GET'])
def get_users():
  try:
    users = User.query.all()
    return make_response(jsonify([user.json() for user in users]), 200)
  except:
    number_of_errors.inc()
    return make_response(jsonify({'message': 'error getting users'}), 500)

# get a user by id
@app.route('/users/<int:id>', methods=['GET'])
def get_user(id):
  try:
    user = User.query.filter_by(id=id).first()
    if user:
      return make_response(jsonify({'user': user.json()}), 200)
    return make_response(jsonify({'message': 'user not found'}), 404)
  except:
    number_of_errors.inc()
    return make_response(jsonify({'message': 'error getting user'}), 500)

# update a user
@app.route('/users/<int:id>', methods=['PUT'])
def update_user(id):
  try:
    user = User.query.filter_by(id=id).first()
    if user:
      data = request.get_json()
      user.username = data['username']
      user.email = data['email']
      db.session.commit()
      return make_response(jsonify({'message': 'user updated'}), 200)
    return make_response(jsonify({'message': 'user not found'}), 404)
  except:
    number_of_errors.inc()
    return make_response(jsonify({'message': 'error updating user'}), 500)

# delete a user
@app.route('/users/<int:id>', methods=['DELETE'])
def delete_user(id):
  try:
    user = User.query.filter_by(id=id).first()
    if user:
      db.session.delete(user)
      db.session.commit()
      return make_response(jsonify({'message': 'user deleted'}), 200)
    return make_response(jsonify({'message': 'user not found'}), 404)
  except:
    number_of_errors.inc()
    return make_response(jsonify({'message': 'error deleting user'}), 500)
  
# get metrics
@app.route('/metrics', methods=['GET'])
def get_data():
    number_of_requests.inc()
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)
    
if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True)