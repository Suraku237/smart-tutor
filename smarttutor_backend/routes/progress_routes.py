from flask import Blueprint, jsonify
import mysql.connector

progress_bp = Blueprint('progress', __name__)

# connect to the database
db = mysql.connector.Connect(
    host = "localhost",
    user = "root",
    password = "121Emma@99",
    database = "smarttutor_db"

)
cursor = db.cursor(dictionary=True)
# GET USER progress and mood trend
@progress_bp.route('/progress/<int:user_id>', methods = ['GET'])
def get_progress(user_id):
    try:
        #get average quiz score 
        cursor.execute(""" SELECT AVG(percentage) AS avg_score FROM quiz_results WHERE user_id = %s """, (user_id))
        score_result = cursor.fetchone()
        
        #get mood trend (based on last 5 feedbacks)

        cursor.execute("""SELECT sentiment FROM feedback WHERE user_id = %s ORDER BY created_at DESC LIMIT 5 """, (user_id)) 
        feedbacks = cursor.fetchall()

        # calculate mood trend 
        positive = sum(1 for f in feedbacks if  f['sentiment'] == 'Positive')

        negative = sum(1 for f in feedbacks if  f['sentiment'] == 'Negative')

        neutral = sum (1 for f in feedbacks if  f['sentiment'] == 'Neutral')

        if  positive > negative:
            mood_trend = "You're enjoying your lessons more lately!"

        elif negative > positive:
            mood_trend = "You seem to find some lessons challenging. Keep going!" 

        else:
            mood_trend = "Your learning mood is steady!"

            return jsonify({
                "average_score":
                round(score_result['avg_score'], 2)
                if score_result['avg_score'] else 0,
                "mood_trend": mood_trend,
                "recent_feedbacks": feedbacks
            }) 

    except Exception as e:
        return jsonify({"error": str(e)}) , 500     