const { initializeApp } = require('firebase/app');
const { getFirestore, collection, addDoc } = require('firebase/firestore');

// Since we are running a raw JS script, we use hardcoded config from .env to test
const firebaseConfig = {
  apiKey: "AIzaSyBe18VdJHjdvF8SM5SU8tWRWoJkRdE41x0",
  authDomain: "rudram-4b896.firebaseapp.com",
  projectId: "rudram-4b896",
  storageBucket: "rudram-4b896.firebasestorage.app",
  messagingSenderId: "357831414448",
  appId: "1:357831414448:web:c42afc9dfeb58387442175",
  measurementId: "G-Y60GVTY6WN"
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

async function testWrite() {
  console.log("Attempting to write to Firestore...");
  try {
    const docRef = await addDoc(collection(db, "products"), {
      title: "Test Product from Node",
      currentPrice: 100,
      timestamp: new Date()
    });
    console.log("Document written with ID: ", docRef.id);
  } catch (e) {
    console.error("Error adding document: ", e);
  }
}

testWrite();
