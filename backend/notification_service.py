import os
import requests
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

class NotificationService:
    def __init__(self):
        self.app_id = os.getenv("ONESIGNAL_APP_ID")
        self.api_key = os.getenv("ONESIGNAL_API_KEY")
        self.base_url = "https://onesignal.com/api/v1"
        
        # Verify credentials are loaded
        if not self.app_id or not self.api_key:
            raise ValueError("OneSignal credentials not found in environment variables")
        
        # Remove 'Basic ' prefix if it's already in the API key
        if self.api_key.startswith("Basic "):
            self.api_key = self.api_key[6:]

    def send_notification(self, title, message, severity):
        """
        Send a push notification to all users
        """
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Basic {self.api_key}"
        }

        payload = {
            "app_id": self.app_id,
            "included_segments": ["All"],
            "contents": {"en": message},
            "headings": {"en": title},
            "data": {
                "severity": severity,
                "type": "disease_detection"
            },
            "android_channel_id": "f9149f46-0749-4ed5-a1bb-7f31ba220239"  # This must match the channel ID in OneSignal dashboard
        }

        try:
            print(f"Sending notification with app_id: {self.app_id}")
            print(f"Using API key: {self.api_key[:10]}...")  # Only print first 10 chars for security
            
            response = requests.post(
                f"{self.base_url}/notifications",
                headers=headers,
                json=payload
            )
            
            if response.status_code == 403:
                print("❌ Authentication failed. Please check your OneSignal REST API key")
                print("Response:", response.text)
                return False
                
            response.raise_for_status()
            print(f"✅ Notification sent successfully: {title}")
            return True
        except Exception as e:
            print(f"❌ Error sending notification: {e}")
            if hasattr(e, 'response') and e.response is not None:
                print(f"Response status: {e.response.status_code}")
                print(f"Response body: {e.response.text}")
            return False

# Create a singleton instance
notification_service = NotificationService() 