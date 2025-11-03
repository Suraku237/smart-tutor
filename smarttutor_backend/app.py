from flask import Flask, jsonify
from routes.auth_routes import auth_bp
from routes.subject_routes import subject_bp
from routes.lesson_routes import lesson_bp
from routes.quiz_routes import quiz_bp


app = Flask(__name__)

# Register the blueprint
app.register_blueprint(auth_bp, url_prefix='/auth')

app.register_blueprint(subject_bp, url_prefix='/api')

app.register_blueprint(lesson_bp, url_prefix='/api')

app.register_blueprint(quiz_bp, url_prefix = '/api')



@app.route('/')
def home():
    return jsonify({"message": "Welcome to SmartTutor Backend!"})

if __name__ == '__main__':
    app.run(debug=True)
