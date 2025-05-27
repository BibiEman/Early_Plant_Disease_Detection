from flask import Flask, jsonify, request
from pymongo import MongoClient
from bson import ObjectId
import base64

app = Flask(__name__)

# MongoDB setup
client = MongoClient("mongodb://localhost:27017/")
db = client["PlantHealthDB"]
collection = db["crop_images"]

# In-memory flag to store auto-monitor toggle state
auto_monitor_state = {"enabled": True}

# Function to parse Gemini-style analysis text into key-value format
def parse_analysis(analysis_text):
    lines = analysis_text.strip().split('\n')
    parsed = {}
    for line in lines:
        if ':' in line:
            key, value = line.split(':', 1)
            parsed[key.strip().lower()] = value.strip()
    return parsed

# Home route
@app.route("/", methods=["GET"])
def home():
    return "Welcome to the Plant Disease Detection API"

# ✅ Auto Monitor: Set toggle state
@app.route("/auto_monitor", methods=["POST"])
def set_auto_monitor():
    data = request.get_json()
    if "enabled" in data:
        auto_monitor_state["enabled"] = data["enabled"]
        return jsonify({"status": "success", "enabled": auto_monitor_state["enabled"]}), 200
    else:
        return jsonify({"status": "error", "message": "Missing 'enabled' key"}), 400

# ✅ Auto Monitor: Get toggle state
@app.route("/auto_monitor", methods=["GET"])
def get_auto_monitor():
    return jsonify({"enabled": auto_monitor_state["enabled"]})

# ✅ Latest analyzed plant data with timestamp
@app.route("/latest", methods=["GET"])
def get_latest():
    doc = collection.find_one({"status": "analyzed"}, sort=[("analyzed_at", -1)])
    if not doc:
        return jsonify({"message": "No analysis found"}), 404

    analysis = parse_analysis(doc["analysis_text"])

    return jsonify({
        "image_url": f"http://10.0.2.2:5000/image/{doc['_id']}",
        "disease": analysis.get("disease", "Unknown"),
        "severity": analysis.get("severity", "Unknown"),
        "causes": analysis.get("causes", "Not provided"),
        "symptoms": analysis.get("symptoms", "Not provided"),
        "treatments": analysis.get("treatment", "Not provided"),
        "prevention": analysis.get("prevention", "Not provided"),
        "description": doc["analysis_text"],
        "timestamp": str(doc.get("analyzed_at", "Unknown"))  # ✅ Return timestamp
    })

# ✅ History of all analyzed images
@app.route("/history", methods=["GET"])
def get_history():
    results = []
    for doc in collection.find({"status": "analyzed"}).sort("analyzed_at", -1):
        analysis = parse_analysis(doc["analysis_text"])
        results.append({
            "image_url": f"http://10.0.2.2:5000/image/{doc['_id']}",
            "disease": analysis.get("disease", "Unknown"),
            "severity": analysis.get("severity", "Unknown"),
            "causes": analysis.get("causes", "Not Available"),
            "symptoms": analysis.get("symptoms", "Not Available"),
            "treatment": analysis.get("treatment", "Not Available"),
            "prevention": analysis.get("prevention", "Not Available"),
            "timestamp": doc.get("analyzed_at", None)
        })
    return jsonify(results)

# ✅ Notifications for high/moderate severity
@app.route("/notifications", methods=["GET"])
def get_notifications():
    results = []
    for doc in collection.find({"status": "analyzed"}):
        analysis = parse_analysis(doc["analysis_text"])
        if analysis.get("severity", "").lower() in ["high", "moderate"]:
            results.append({
                "disease": analysis.get("disease", "Unknown"),
                "severity": analysis.get("severity", "Unknown")
            })
    return jsonify(results)

# ✅ Image retrieval endpoint
@app.route("/image/<id>", methods=["GET"])
def get_image(id):
    doc = collection.find_one({"_id": ObjectId(id)})
    if not doc:
        return "Image not found", 404
    img_bytes = base64.b64decode(doc["image"])
    return app.response_class(img_bytes, mimetype="image/jpeg")

# ✅ Run the app
if __name__ == "__main__":
    app.run(debug=True, port=5000)
