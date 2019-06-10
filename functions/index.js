const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);
// database tree

exports.sendPushNotification = functions.database.ref('/users/{id}/requests/').onWrite(event =>{
    const payload = {
        notification: {
            content_available: 'true',
            title: 'You have a new shoot request!',
            body: 'Click and See!',
            badge: '1',
            sound: 'default',
        }

    };
    return admin.database().ref('fcmToken').once('value').then(allToken => {
        if (allToken.val()){
            const token = Object.keys(allToken.val());
            console.log(`token? ${token}`);
            return admin.messaging().sendToDevice(token, payload).then(response =>{
                return null;
            });
        }

        return null;
    });
});
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

