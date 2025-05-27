# AI-Powered Early Plant Disease Detection App

This project is an AI-powered system that automatically detects plant diseases by analyzing leaf images inserted into a MongoDB database every 6 hours. When a new image is added, it is processed using Google Gemini API. If any disease is detected, the farmer receives a push notification on the Flutter mobile app, which includes detailed diagnosis such as:

Disease name
Severity level
Causes
Symptoms
Treatments
Preventions
The app also provides a history, treatment library, and notification archive to help farmers track and manage their crops effectively.

# Key Features
🖼️ Image Analysis
Every 6 hours, a new plant image is inserted into the database.
The backend detects this and sends it to Google Gemini API for disease detection.

1. Push Notifications
If disease is found, a notification is sent instantly to the farmer’s mobile app.

📊 Plant Diagnosis Dashboard
View disease name, severity, causes, symptoms, treatments, and preventions.

🕘 History
Stores all previously analyzed plant images.
Farmers can revisit any missed diagnosis.
Automatically generates a report for each analysis.

💊 Treatment Library
A collection of general treatments used to prevent and cure plant diseases.
Useful even if no disease is currently detected.

🔔 Notification Log
Keeps a record of all notifications, including timestamps and disease names.

# Tech Stack
1. For Mobile App: Flutter 
2. Backend: Flask (Python)
3. AI Integration: Google Gemini API
4. Database: MongoDB
5. Notification:OneSignal

