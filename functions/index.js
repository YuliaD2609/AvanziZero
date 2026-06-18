const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Export delle future Cloud Functions
// Esempio: calcolo debiti, predictive shopping, notifiche CRON.

exports.helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  response.send("AvanziZero Backend is running!");
});
