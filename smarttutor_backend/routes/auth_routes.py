from flask import Blueprint, request, jsonify
import mysql.connector

# Create a Blueprint for authentication routes
auth_bp = Blueprint('auth_bp', __name__)

# Database connection setup
db = mysql.connector.connect(
    host="localhost",
    user="root",        # your MySQL username
    password="121Emma@99",        # your MySQL password (if any)
    database="smarttutor_db"

)
cursor = db.cursor(dictionary=True)

# 🧩 Register user route
@auth_bp.route('/register', methods=['POST'])
def register_user():
    data = request.get_json()
    print("Reecieved Data:", data)
    name = data.get('name')
    email = data.get('email')
    password = data.get('password')

    if not all([name, email, password]):
        return jsonify({"error": "All fields are required"}), 400

    cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
    existing = cursor.fetchone()
    if existing:
        return jsonify({"error": "Email already exists"}), 400

    cursor.execute("INSERT INTO users (name, email, password) VALUES (%s, %s, %s)", (name, email, password))
    db.commit()

    return jsonify({"message": "User registered successfully"}), 201

# 🧩 Login user route
@auth_bp.route('/auth/login', methods=['POST'])
def login_user():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    if not all([email, password]):
        return jsonify({"error": "Email and password are required"}), 400

    cursor.execute("SELECT * FROM users WHERE email = %s AND password = %s", (email, password))
    user = cursor.fetchone()

    if user:
        return jsonify({
            "message": "Login successful",
            "user": {
                "id": user["id"],
                "name": user["name"],
                "email": user["email"]
            }
        })
    else:
        return jsonify({"error": "Invalid email or password"}), 401

