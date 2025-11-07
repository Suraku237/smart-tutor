# routes/feedback_routes.py
from flask import Blueprint, request, jsonify
from textblob import TextBlob

feedback_bp = Blueprint('feedback_bp', __name__)

@feedback_bp.route('/feedback', methods=['POST'])
def analyze_feedback():
    data = request.get_json()
    feedback_text = data.get('feedback', '')

    if not feedback_text:
        return jsonify({'error': 'Feedback is required'}), 400

    # Analyze sentiment
    blob = TextBlob(feedback_text)
    polarity = blob.sentiment.polarity  # -1 (negative) to 1 (positive)

    if polarity > 0.1:
        sentiment = 'positive'
        message = "Great! Keep it up!"
    elif polarity < -0.1:
        sentiment = 'negative'
        message = "We understand this topic is difficult. Keep trying!"
    else:
        sentiment = 'neutral'
        message = "Thanks for your feedback!"

    return jsonify({
        'feedback': feedback_text,
        'sentiment': sentiment,
        'message': message
    })
