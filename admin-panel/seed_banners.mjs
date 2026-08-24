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

// These are the EXACT images used in the desktop web app (desktop_hero_section.dart)
const banners = [
  // Main Carousel Slides (left big slider)
  {
    title: "Timeless Elegance",
    subtitle: "Gilded Luxuries: The Necklace Edit",
    imageUrl: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766772771/Gemini_Generated_Image_fc6eesfc6eesfc6e_p6vjtu.png",
    link: "/shop",
    isActive: true,
    order: 1,
    type: "main_carousel"
  },
  {
    title: "Signature Collection",
    subtitle: "Elevate Your Sparkle",
    imageUrl: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766772766/Gemini_Generated_Image_6v06r16v06r16v06_hky38x.png",
    link: "/collections",
    isActive: true,
    order: 2,
    type: "main_carousel"
  },
  {
    title: "Royal Heritage",
    subtitle: "Crafted for Royalty",
    imageUrl: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766772769/Gemini_Generated_Image_6wnqjh6wnqjh6wnq_prum6f.png",
    link: "/collections/bridal",
    isActive: true,
    order: 3,
    type: "main_carousel"
  },
  // Right Side Cards (small grid)
  {
    title: "25% Off Special",
    subtitle: "Bring Alive Your Dream",
    imageUrl: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766773995/8512716e33d20cac2f4019e1a59ce41f_kuyugk.jpg",
    link: "/shop/offers",
    isActive: true,
    order: 4,
    type: "side_card"
  },
  {
    title: "Exclusive Designs",
    subtitle: "Handcrafted Jewelry",
    imageUrl: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766773994/8f2249c31350c4cb0f69dd74de9f8878_ztxcyd.jpg",
    link: "/shop/exclusive",
    isActive: true,
    order: 5,
    type: "side_card"
  },
  {
    title: "Gold Collection",
    subtitle: "Premium Gold Jewelry",
    imageUrl: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766773994/d9d4b96415c4c99a2cd17c53e1e15fde_efwks7.jpg",
    link: "/shop/gold",
    isActive: true,
    order: 6,
    type: "side_card"
  },
  {
    title: "Singularity",
    subtitle: "Well Defined Beauty",
    imageUrl: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1766773994/97ce300ef56c4bcee8f351a3a037916f_bbqex9.jpg",
    link: "/collections/singularity",
    isActive: true,
    order: 7,
    type: "side_card"
  },
];

async function seed() {
  // 1. Delete all old banners first
  console.log("🗑️  Clearing old banners...");
  const existingSnap = await getDocs(collection(db, 'web_banners'));
  const deletePromises = existingSnap.docs.map(d => deleteDoc(doc(db, 'web_banners', d.id)));
  await Promise.all(deletePromises);
  console.log(`   Deleted ${existingSnap.docs.length} old banners.`);

  // 2. Seed fresh banners
  console.log("\n🌱 Seeding banners...");
  for (const banner of banners) {
    await addDoc(collection(db, 'web_banners'), banner);
    console.log(`   ✅ Added: "${banner.title}" (${banner.type})`);
  }

  console.log("\n🎉 Seeding complete! 7 banners added to Firestore.");
  process.exit(0);
}

seed().catch(err => {
  console.error("❌ Error seeding:", err);
  process.exit(1);
});
