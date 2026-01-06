// Firebase config - Currently not used in development mode
// Uncomment and configure when needed for production

const admin = require("firebase-admin");

let firebaseInitialized = false;

const initializeFirebase = () => {
  if (!firebaseInitialized) {
    try {
      const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;

      if (serviceAccountPath) {
        const serviceAccount = require(serviceAccountPath);
        admin.initializeApp({
          credential: admin.credential.cert(serviceAccount),
        });
        firebaseInitialized = true;
        console.log("✅ Firebase Admin initialized successfully");
      } else {
        console.log("⚠️  Firebase credentials not configured.");
      }
    } catch (error) {
      console.error("❌ Error initializing Firebase Admin:", error.message);
    }
  }
};

module.exports = {
  admin,
  initializeFirebase,
  firebaseInitialized: () => firebaseInitialized,
};
