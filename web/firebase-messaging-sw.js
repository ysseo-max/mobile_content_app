importScripts("https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyC_QwviH3iHJkmYalRjJx7vYgclNdUYOhc",
  authDomain: "rebeauty-photos.firebaseapp.com",
  projectId: "rebeauty-photos",
  storageBucket: "rebeauty-photos.firebasestorage.app",
  messagingSenderId: "924939408824",
  appId: "1:924939408824:web:cb5b146571ee7cd2ac6b4d",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((message) => {
  const notification = message.notification;
  if (!notification) return;

  return self.registration.showNotification(notification.title, {
    body: notification.body,
    icon: "/icons/Icon-192.png",
  });
});
