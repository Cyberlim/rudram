import { initializeApp } from 'firebase/app';
import { getFirestore, collection, addDoc, getDocs, deleteDoc } from 'firebase/firestore';

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

const slides = [
  {
    image: 'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/6_mu5hap.jpg',
    headline: 'ROYAL HERITAGE',
    description: 'Discover the unmatched craftsmanship of ancient royal jewelers.',
    features: [
      { icon: 'diamond', text: 'Master Artisan Crafted' },
      { icon: 'verified', text: 'Lifetime Authenticity' }
    ],
    order: 0,
    active: true,
  },
  {
    image: 'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/5_lf1dgq.jpg',
    headline: 'CELESTIAL BEAUTY',
    description: 'Diamonds sourced from the most pristine mines around the world.',
    features: [
      { icon: 'star', text: 'GIA Certified' },
      { icon: 'eco', text: 'Sustainable Sourcing' }
    ],
    order: 1,
    active: true,
  },
  {
    image: 'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/7_i3yykt.jpg',
    headline: 'VINTAGE GLAMOUR',
    description: 'Bespoke designs reminiscent of the golden era of high jewelry.',
    features: [
      { icon: 'diamond', text: 'Rare Jewels' },
      { icon: 'verified', text: 'Award Winning' }
    ],
    order: 2,
    active: true,
  }
];

async function seed() {
  const collectionRef = collection(db, 'luxury_slides');
  
  // Clear existing first
  const snapshot = await getDocs(collectionRef);
  let deletedCount = 0;
  for (const doc of snapshot.docs) {
    await deleteDoc(doc.ref);
    deletedCount++;
  }
  console.log(`Deleted ${deletedCount} existing luxury slides.`);

  let count = 0;
  for (const slide of slides) {
    await addDoc(collectionRef, {
      ...slide,
      createdAt: new Date() // Not using FieldValue.serverTimestamp() in client SDK easily without import
    });
    count++;
  }
  console.log(`Seeded ${count} luxury slides successfully.`);
  process.exit(0);
}

seed().catch(console.error);
