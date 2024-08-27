from flask import Flask, request, jsonify
from flask_cors import CORS
from models.face_recognition_model import FaceRecognitionModel

app = Flask(__name__)
CORS(app)

face_model = FaceRecognitionModel()

@app.route('/register', methods=['POST'])
def register_face():
    if 'image' not in request.files:
        return jsonify({"status": "error", "message": "No image provided"}), 400
    
    image_file = request.files['image']
    result, status_code = face_model.register_face(image_file)
    return jsonify(result), status_code

@app.route('/verify', methods=['POST'])
def verify_face():
    if 'image' not in request.files:
        return jsonify({"status": "error", "message": "No image provided"}), 400
    
    image_file = request.files['image']
    result, status_code = face_model.verify_face(image_file)
    return jsonify(result), status_code

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
