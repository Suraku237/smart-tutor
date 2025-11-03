from flask import Blueprint, jsonify, request
import mysql.connector

lesson_bp = Blueprint('lesson_bp', __name__)

# Database connection
db = mysql.connector.connect(
    host="localhost",
    user="root",       # Your MySQL username
    password="121Emma@99",       # Your MySQL password
    database="smarttutor_db"
)
cursor = db.cursor(dictionary=True)

# 🧩 Get lessons by subject ID
@lesson_bp.route('/lessons/<int:subject_id>', methods=['GET'])
def get_lessons(subject_id):
    cursor.execute("SELECT * FROM lessons WHERE subject_id = %s", (subject_id,))
    lessons = cursor.fetchall()
    return jsonify(lessons)
