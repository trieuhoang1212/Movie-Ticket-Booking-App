// Firebase config - Currently not used in development mode
// Uncomment and configure when needed for production

const admin = require("firebase-admin");

let firebaseInitialized = false;

const initializeFirebase = () => {
  if (!firebaseInitialized) {
    try {
      // Try to load from environment variables first (for Docker)
      const projectId = process.env.FIREBASE_PROJECT_ID;
      const privateKey = process.env.FIREBASE_PRIVATE_KEY;
      const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;

      if (projectId && privateKey && clientEmail) {
        admin.initializeApp({
          credential: admin.credential.cert({
            projectId: projectId,
            privateKey: privateKey.replace(/\\n/g, "\n"),
            clientEmail: clientEmail,
          }),
        });
        firebaseInitialized = true;
        console.log("✅ Firebase Admin initialized successfully");
      } else {
        // Fallback to service account file path
        const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
        if (serviceAccountPath) {
          const serviceAccount = require(serviceAccountPath);
          admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
          });
          firebaseInitialized = true;
          console.log("✅ Firebase Admin initialized successfully (from file)");
        } else {
          console.log("⚠️  Firebase credentials not configured.");
        }
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
