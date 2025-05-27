import os
import base64
import pymongo
import datetime
import time
import sys
from dotenv import load_dotenv
import google.generativeai as genai
from notification_service import notification_service

# === Load .env file for Gemini API Key ===
load_dotenv()
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

# === MongoDB Setup ===
client = pymongo.MongoClient("mongodb://localhost:27017/")
db = client["PlantHealthDB"]
collection = db["crop_images"]

# === Gemini Model Setup ===
model = genai.GenerativeModel("gemini-1.5-flash")

def analyze_next_image():
    print("\n🔎 Checking for pending images...")
    sys.stdout.flush()

    # Get the oldest pending image
    document = collection.find_one({"status": "pending"}, sort=[("timestamp", pymongo.ASCENDING)])

    if not document:
        print("✅ No pending images to analyze. Exiting service.")
        sys.stdout.flush()
        return False  # Signal to stop the loop

    image_name = document["image_name"]
    print(f"\n🖼️ Analyzing image: {image_name}")
    sys.stdout.flush()

    try:
        # Verify image data exists
        if "image" not in document or not document["image"]:
            print(f"❌ No image data found for {image_name}")
            # Mark as failed to prevent retrying
            collection.update_one(
                {"_id": document["_id"]},
                {"$set": {"status": "failed", "error": "No image data"}}
            )
            return True

        # Decode base64 image
        try:
            image_data = base64.b64decode(document["image"])
            if not image_data:
                raise ValueError("Decoded image data is empty")
        except Exception as e:
            print(f"❌ Error decoding image data: {e}")
            collection.update_one(
                {"_id": document["_id"]},
                {"$set": {"status": "failed", "error": f"Image decode error: {str(e)}"}}
            )
            return True

        # Determine MIME type based on extension
        ext = os.path.splitext(image_name)[1].lower()
        mime_type = "image/jpeg" if ext in [".jpg", ".jpeg"] else "image/png"

        # Prepare prompt
        prompt = """
You are an expert in plant pathology. Given the image of a plant leaf, analyze it and provide the following details clearly, each on a new line, using the format:

Disease: [Name of disease or "Healthy"]
Severity: [None / Low / Moderate / High]
Causes: [List or description of causes]
Symptoms: [Key symptoms observed]
Treatment: [Suggested treatments]
Prevention: [Prevention techniques to avoid the disease]

Note: Stick to this exact format using `:` for each field.
        """

        # Encode image for Gemini
        try:
            image_base64_str = base64.b64encode(image_data).decode('utf-8')
            parts = [
                {"text": prompt},
                {
                    "mime_type": mime_type,
                    "data": image_base64_str,
                }
            ]
        except Exception as e:
            print(f"❌ Error preparing image for Gemini: {e}")
            collection.update_one(
                {"_id": document["_id"]},
                {"$set": {"status": "failed", "error": f"Image preparation error: {str(e)}"}}
            )
            return True

        # Generate content using Gemini
        try:
            response = model.generate_content({"parts": parts})
            result_text = response.text.strip()
        except Exception as e:
            print(f"❌ Error from Gemini API: {e}")
            collection.update_one(
                {"_id": document["_id"]},
                {"$set": {"status": "failed", "error": f"Gemini API error: {str(e)}"}}
            )
            return True

        if not result_text:
            print("⚠️ No response received from Gemini.")
            collection.update_one(
                {"_id": document["_id"]},
                {"$set": {"status": "failed", "error": "No response from Gemini"}}
            )
            sys.stdout.flush()
            return True

        # Parse the analysis result
        analysis = {}
        for line in result_text.split('\n'):
            if ':' in line:
                key, value = line.split(':', 1)
                analysis[key.strip().lower()] = value.strip()

        # Update MongoDB document
        collection.update_one(
            {"_id": document["_id"]},
            {
                "$set": {
                    "status": "analyzed",
                    "analysis_text": result_text,
                    "analyzed_at": datetime.datetime.utcnow()
                }
            }
        )

        print("📊 Analysis Result:\n", result_text)
        sys.stdout.flush()

        # Send notification if disease is detected and severity is moderate or high
        disease = analysis.get('disease', '').lower()
        severity = analysis.get('severity', '').lower()
        
        if disease != 'healthy' and severity in ['moderate', 'high']:
            title = f"⚠️ Plant Disease Detected: {disease.title()}"
            message = f"Severity: {severity.title()}\nSymptoms: {analysis.get('symptoms', 'Not specified')}"
            notification_service.send_notification(title, message, severity)

    except Exception as e:
        print(f"❌ Error analyzing image: {e}")
        # Update document with error status
        collection.update_one(
            {"_id": document["_id"]},
            {"$set": {"status": "failed", "error": str(e)}}
        )
        sys.stdout.flush()

    return True

# === Initial Delay ===
print("⏳ Waiting 10 seconds to allow image upload to complete...")
sys.stdout.flush()
time.sleep(10)

# === Start Service ===
print("🚀 Gemini analysis service started...")
sys.stdout.flush()

# Continuous loop — break if no more images
while True:
    should_continue = analyze_next_image()
    if not should_continue:
        break
    time.sleep(60)

print("🛑 Gemini image analysis completed. Exiting.")
