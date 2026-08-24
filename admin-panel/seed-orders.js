const { initializeApp } = require("firebase/app");
const { getFirestore, collection, getDocs, doc, setDoc, updateDoc, serverTimestamp } = require("firebase/firestore");

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

const customers = [
    "Neha Sharma", "Rahul Verma", "Aarti Singh", "Pooja Patel", "Ankit Joshi",
    "Vikram Malhotra", "Sunita Rao", "Karan Johar", "Meera Rajput", "Rohan Das"
];

const statuses = ["Pending", "Processing", "Shipped", "Delivered", "Cancelled"];

function randomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

async function seed() {
    console.log("Fetching existing products...");
    const snapshot = await getDocs(collection(db, "products"));
    const products = [];
    
    // 1. Update existing products with stock and soldCount
    for (const d of snapshot.docs) {
        const data = d.data();
        const stock = randomInt(1, 50);
        const soldCount = randomInt(10, 200);
        
        await updateDoc(d.ref, {
            stock: stock,
            soldCount: soldCount
        });
        
        products.push({
            id: d.id,
            title: data.title || "Unknown Product",
            image: data.image || "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/6a/55/96/6a55960bc89259fa0cc11bf784e1d28c.jpg",
            price: data.currentPrice || 50000
        });
        console.log(`Updated product ${d.id} - Stock: ${stock}, Sold: ${soldCount}`);
    }

    if (products.length === 0) {
        console.log("No products found to create orders for.");
        process.exit(1);
    }

    console.log("\nGenerating 25 random orders...");
    
    for (let i = 0; i < 25; i++) {
        const orderId = `ORD-${2000 + i}`;
        const p = products[randomInt(0, products.length - 1)];
        const qty = randomInt(1, 3);
        const status = statuses[randomInt(0, statuses.length - 1)];
        const customer = customers[randomInt(0, customers.length - 1)];
        
        // Random date within the last 30 days
        const pastDays = randomInt(0, 30);
        const date = new Date();
        date.setDate(date.getDate() - pastDays);
        
        const orderData = {
            id: orderId,
            customerName: customer,
            productName: p.title,
            productImage: p.image,
            productId: p.id,
            quantity: qty,
            amount: p.price * qty,
            status: status,
            createdAt: date // We use JS Date so it maps to Firestore Timestamp
        };
        
        await setDoc(doc(db, "orders", orderId), orderData);
        console.log(`Created order ${orderId} - ${status} - ₹${orderData.amount}`);
    }

    console.log("Done seeding orders!");
    process.exit(0);
}

seed().catch(console.error);
