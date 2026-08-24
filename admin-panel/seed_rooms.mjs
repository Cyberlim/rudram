import { initializeApp } from 'firebase/app';
import { getFirestore, collection, addDoc, getDocs, deleteDoc, doc } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: "AIzaSyBe18VdJHjdvF8SM5SU8tWRWoJkRdE41x0",
  authDomain: "rudram-4b896.firebaseapp.com",
  projectId: "rudram-4b896",
  storageBucket: "rudram-4b896.firebasestorage.app",
  messagingSenderId: "357831414448",
  appId: "1:357831414448:web:c42afc9dfeb58387442175"
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

// Rooms currently hardcoded in rooms_provider.dart
const rooms = [
  {
    name: "The Bridal Lounge",
    image: "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/8e/f7/cb/8ef7cbdf58b59b5183b1456d5d3cc805.jpg",
    description: "Exquisite bridal jewelry collections curated for your special day.",
    isActive: true,
    order: 1,
    productCount: 0,
  },
  {
    name: "Diamond Vault",
    image: "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/a5/c3/c6/a5c3c62788cbdc79c5d4b9f5973962e8.jpg",
    description: "Rare diamonds and precious stones from around the world.",
    isActive: true,
    order: 2,
    productCount: 0,
  },
  {
    name: "Vintage Gallery",
    image: "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/67/4a/24/674a24be75ae9470234c9fbefe1e3246.jpg",
    description: "Heritage pieces with timeless elegance and classic craftsmanship.",
    isActive: true,
    order: 3,
    productCount: 0,
  },
];

async function seed() {
  console.log("🗑️  Clearing old rooms...");
  const existingSnap = await getDocs(collection(db, 'rooms'));
  const deletePromises = existingSnap.docs.map(d => deleteDoc(doc(db, 'rooms', d.id)));
  await Promise.all(deletePromises);
  console.log(`   Deleted ${existingSnap.docs.length} old rooms.`);

  console.log("\n🌱 Seeding rooms...");
  for (const room of rooms) {
    await addDoc(collection(db, 'rooms'), room);
    console.log(`   ✅ Added: "${room.name}"`);
  }

  console.log("\n🎉 Done! 3 virtual rooms seeded to Firestore.");
  process.exit(0);
}

seed().catch(err => {
  console.error("❌ Error:", err);
  process.exit(1);
});
