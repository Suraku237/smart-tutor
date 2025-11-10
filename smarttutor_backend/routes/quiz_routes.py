from flask import Blueprint, jsonify, request
import mysql.connector

quiz_bp = Blueprint('quiz_bp', __name__)

# Database connection
db = mysql.connector.connect(
    host="localhost",
    user="root",       # Your MySQL username
    password="121Emma@99",       # Your MySQL password
    database="smarttutor_db"
)
cursor = db.cursor(dictionary=True)

# 🧩 Get quiz questions by lesson ID
@quiz_bp.route('/quiz/<int:lesson_id>', methods=['GET'])
def get_quiz(lesson_id):
    cursor.execute("SELECT * FROM quiz WHERE lesson_id = %s", (lesson_id,))
    questions = cursor.fetchall()
    return jsonify(questions)
