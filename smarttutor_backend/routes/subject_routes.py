from flask import Blueprint, jsonify
import mysql.connector

subject_bp = Blueprint('subject_bp', __name__)

# Database connection
db = mysql.connector.connect(
    host="localhost",
    user="root",       # Your MySQL username
    password="121Emma@99",       # Your MySQL password
    database="smarttutor_db"
)
cursor = db.cursor(dictionary=True)

# 🧩 Get all subjects
@subject_bp.route('/subjects', methods=['GET'])
def get_subjects():
    cursor.execute("SELECT * FROM subjects")
    subjects = cursor.fetchall()
    return jsonify(subjects)
