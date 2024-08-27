import face_recognition
import os
from werkzeug.utils import secure_filename

class FaceRecognitionModel:
    def __init__(self, upload_folder='uploads'):
        self.upload_folder = upload_folder
        self.registered_faces = {}

        # Ensure the upload folder exists
        if not os.path.exists(self.upload_folder):
            os.makedirs(self.upload_folder)

    def save_image(self, image_file):
        # Secure the filename to prevent path traversal attacks
        filename = secure_filename(image_file.filename)
        image_path = os.path.join(self.upload_folder, filename)
        image_file.save(image_path)
        return image_path

    def encode_face(self, image_path):
        # Load the image file and get face encodings
        image = face_recognition.load_image_file(image_path)
        face_encodings = face_recognition.face_encodings(image)
        return face_encodings

    def register_face(self, image_file):
        try:
            image_path = self.save_image(image_file)
            face_encodings = self.encode_face(image_path)
            
            if len(face_encodings) > 0:
                # Register the face with the first encoding
                self.registered_faces[os.path.basename(image_path)] = face_encodings[0]
                return {"status": "success", "message": "Face registered successfully"}, 200
            else:
                return {"status": "error", "message": "No face detected"}, 400
        except Exception as e:
            return {"status": "error", "message": str(e)}, 500

    def verify_face(self, image_file):
        try:
            image_path = self.save_image(image_file)
            face_encodings = self.encode_face(image_path)
            
            if len(face_encodings) > 0:
                # Compare the uploaded face with all registered faces
                for registered_face in self.registered_faces.values():
                    matches = face_recognition.compare_faces([registered_face], face_encodings[0])
                    if True in matches:
                        return {"status": "success", "message": "Face verified successfully"}, 200
                
            return {"status": "error", "message": "Face verification failed"}, 400
        except Exception as e:
            return {"status": "error", "message": str(e)}, 500
