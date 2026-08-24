const { initializeApp } = require("firebase/app");
const { getFirestore, collection, getDocs, query, orderBy, where } = require("firebase/firestore");

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

async function testRead() {
    try {
        console.log("Testing orderBy query...");
        const q1 = query(collection(db, "banners"), orderBy("createdAt", "desc"));
        const snap1 = await getDocs(q1);
        console.log("Banners with orderBy:", snap1.size);
    } catch(e) {
        console.error("Error in q1:", e.message);
    }

    try {
        console.log("Testing where query...");
        const q2 = query(collection(db, "banners"), where("status", "==", "Active"));
        const snap2 = await getDocs(q2);
        console.log("Banners with where:", snap2.size);
    } catch(e) {
        console.error("Error in q2:", e.message);
    }
    
    process.exit(0);
}

testRead().catch(console.error);
