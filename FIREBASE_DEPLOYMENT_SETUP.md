# Firebase Hosting Deployment - API Configuration Guide

Your Flutter web app is now live at:
🌐 **https://pinky-shop-f5ad6.web.app**

## ⚙️ Next Steps: Configure Your Backend API

Your app is deployed, but it needs a **backend API** to handle products, orders, users, and chat.

---

## 🎯 Option 1: Firebase Cloud Functions (Recommended for Firebase projects)

### Benefits:
✅ Integrates with Firebase  
✅ Auto-scales  
✅ Pay only for usage  
✅ No server management  

### Setup:

1. **Initialize Firebase Functions**
```bash
cd ChatBot
firebase init functions
# Choose: TypeScript or Python
# Choose: Use existing Firebase project
```

2. **Create API endpoints** in `functions/src/index.ts`:
```typescript
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

// Products endpoint
export const getProducts = functions.https.onRequest((req, res) => {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Methods", "GET, POST");
  
  const db = admin.firestore();
  db.collection('products').get()
    .then(snapshot => {
      const products = [];
      snapshot.forEach(doc => {
        products.push({ id: doc.id, ...doc.data() });
      });
      res.json({ data: products });
    });
});

// Create order endpoint
export const createOrder = functions.https.onRequest((req, res) => {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Methods", "GET, POST");
  
  if (req.method === "POST") {
    const db = admin.firestore();
    db.collection('orders').add(req.body)
      .then(doc => {
        res.json({ success: true, id: doc.id });
      })
      .catch(err => {
        res.status(500).json({ error: err.message });
      });
  }
});
```

3. **Deploy functions**
```bash
firebase deploy --only functions
```

4. **Update your app config** in `lib/config/app_config.dart`:
```dart
case Environment.production:
  return 'https://us-central1-chatbot-flutter-7b34f.cloudfunctions.net/api';
```

---

## 🎯 Option 2: Heroku or AWS (Traditional Backend)

### Heroku Setup:

1. **Create account** at heroku.com
2. **Create Node.js/Python backend** with Express/Flask
3. **Deploy**
```bash
heroku create your-app-name
git push heroku main
```

4. **Update app config**:
```dart
case Environment.production:
  return 'https://your-app-name.herokuapp.com/api';
```

---

## 🎯 Option 3: Render, Railway, or Vercel

### Render.com Example:

1. Push code to GitHub
2. Connect GitHub to Render
3. Deploy
4. Get URL: `https://your-api.onrender.com`

### Update config:
```dart
case Environment.production:
  return 'https://your-api.onrender.com/api';
```

---

## 📝 Quick Configuration Change

Update your production API URL in **`lib/config/app_config.dart`**:

```dart
case Environment.production:
  // Replace with your actual backend API URL
  return 'https://your-backend-api.com/api';
```

Then redeploy to Firebase:

```bash
flutter build web
firebase deploy --only hosting
```

---

## ✅ Deploying Web App Updates

Every time you update code:

```bash
# Build the web app
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

---

## 🔍 Common Backend API Endpoints

Your API should provide these endpoints:

```
GET    /api/products
GET    /api/products/:id
POST   /api/orders
GET    /api/orders?userId=xxx
POST   /api/cart/add
GET    /api/users/:userId
PUT    /api/users/:userId
POST   /api/chat/send
GET    /api/chat/messages
```

---

## 🚀 Recommended Setup for You

Since you're already using Firebase:

1. **Use Firebase Cloud Functions** for API
2. **Keep Firestore** for database
3. **Firebase Hosting** for web app (already done ✅)
4. **Firebase Storage** for images
5. **Firebase Auth** for authentication (already done ✅)

This is the simplest all-in-one solution!

---

## 🚨 Important: CORS Configuration

If your API is on a different domain, add CORS headers:

```javascript
// Node.js/Express
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  next();
});
```

---

## 📊 Your Infrastructure

```
┌─────────────────────────────────────┐
│  Flutter Web App (Firebase Hosting) │
│  https://chatbot-flutter-7b34f...   │
└──────────────────┬──────────────────┘
                   │
                   ↓
        ┌──────────────────────┐
        │   Backend API        │
        │  (Firebase Functions)│
        │  or Heroku/Render    │
        └──────┬───────────────┘
               │
        ┌──────┴──────────┐
        ↓                 ↓
   ┌─────────┐    ┌────────────┐
   │Firestore│    │Firebase    │
   │(Database)   │Storage(Img) │
   └─────────┘    └────────────┘
```

---

## ❓ Need Help?

1. **Firebase Functions** - https://firebase.google.com/docs/functions
2. **Heroku Deployment** - https://devcenter.heroku.com/
3. **Render** - https://render.com/docs
4. **CORS Issues** - Check browser console for errors

Update the API URL → Rebuild → Redeploy = Done! 🎉
