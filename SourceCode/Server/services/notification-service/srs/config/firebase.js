const admin = require("firebase-admin");

// Khởi tạo Firebase Admin SDK
const initializeFirebase = () => {
  try {
    if (admin.apps.length === 0) {
      const serviceAccount = {
        type: "service_account",
        project_id: process.env.FIREBASE_PROJECT_ID,
        private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
        private_key: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, "\n"),
        client_email: process.env.FIREBASE_CLIENT_EMAIL,
      };

      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });

      console.log("🔥 Firebase Admin initialized successfully");
    }
  } catch (error) {
    console.error("❌ Firebase initialization error:", error.message);
    throw error;
  }
};

const getMessaging = () => {
  return admin.messaging();
};

const getFirestore = () => {
  return admin.firestore();
};

module.exports = { initializeFirebase, getMessaging, getFirestore };
