import os
import base64
import pymongo
import datetime
import time

# === Config Paths ===
IMAGE_DIR = os.path.join(os.path.dirname(__file__), '..', 'database', 'images')

# === MongoDB Setup ===
client = pymongo.MongoClient("mongodb://localhost:27017/")
db = client["PlantHealthDB"]
collection = db["crop_images"]

def get_next_uninserted_image():
    # Get all image names already in the database
    inserted_images = set(doc["image_name"] for doc in collection.find({}, {"image_name": 1}))

    # List all image files in the directory
    all_images = sorted([f for f in os.listdir(IMAGE_DIR) if f.lower().endswith(('.jpg', '.jpeg', '.png'))])

    # Find the first image not yet inserted
    for image_name in all_images:
        if image_name not in inserted_images:
            return os.path.join(IMAGE_DIR, image_name), image_name

    return None, None  # No new images found

def insert_image_to_db():
    image_path, image_name = get_next_uninserted_image()
    if image_path:
        with open(image_path, "rb") as image_file:
            encoded_string = base64.b64encode(image_file.read()).decode("utf-8")
        document = {
            "image_name": image_name,
            "image": encoded_string,
            "timestamp": datetime.datetime.utcnow(),
            "status": "pending"
        }
        collection.insert_one(document)
        print(f"✅ Inserted {image_name} at {datetime.datetime.now()}")
    else:
        print("✅ All images have already been inserted.")

# === Insert One Image Every Minute ===
while True:
    insert_image_to_db()
    time.sleep(60)
