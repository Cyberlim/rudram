const { initializeApp } = require("firebase/app");
const { getFirestore, collection, doc, setDoc, serverTimestamp } = require("firebase/firestore");

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

const globalShopProducts = [
  {
    id: 'prod_001',
    title: "Royal Emerald Diamond Set",
    currentPrice: 85000.00,
    oldPrice: 125000.00,
    discount: "-32%",
    image: "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/6a/55/96/6a55960bc89259fa0cc11bf784e1d28c.jpg",
    category: "Sets",
    bgColor: 4293848814
  },
  {
    id: 'prod_002',
    title: "Sapphire Drop Earrings",
    currentPrice: 42000.00,
    oldPrice: 55000.00,
    discount: "-25%",
    image: "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/f4/05/41/f4054166dccbf42baf55d8501074b012.jpg",
    category: "Earrings",
    bgColor: 4293848814
  },
  {
    id: 'prod_003',
    title: "Infinity Gold Bracelet",
    currentPrice: 35000.00,
    oldPrice: 45000.00,
    discount: "-22%",
    image: "https://images.weserv.nl/?url=https://i.pinimg.com/736x/c3/8e/3e/c38e3e93d6d993c115314b20274943fa.jpg",
    category: "Bracelets",
    bgColor: 4293848814
  },
  {
    id: 'prod_004',
    title: "Classic Solitaire Ring",
    currentPrice: 95000.00,
    oldPrice: 110000.00,
    discount: "-15%",
    image: "https://images.weserv.nl/?url=https://i.pinimg.com/736x/0f/5f/1a/0f5f1a0cc6a898a8b23e72fb2b1a087f.jpg",
    category: "Rings",
    bgColor: 4293848814
  },
  {
    id: 'prod_005',
    title: "Rose Gold Pendant",
    currentPrice: 28000.00,
    oldPrice: 35000.00,
    discount: "-20%",
    image: "https://images.weserv.nl/?url=https://i.pinimg.com/736x/36/dc/71/36dc71af1ca7f5c4a8fdfe73bbb688b1.jpg",
    category: "Necklaces",
    bgColor: 4293848814
  },
  {
    id: 'prod_006',
    title: "Bridal Meenakari Set",
    currentPrice: 125000.00,
    oldPrice: 155000.00,
    discount: "-19%",
    image: "https://images.weserv.nl/?url=https://i.pinimg.com/736x/54/26/f3/5426f37ee3738c45aa2e07091c6ea709.jpg",
    category: "Sets",
    bgColor: 4293848814
  },
  {
    id: 'prod_007',
    title: "Diamond Stud Earrings",
    currentPrice: 15000.00,
    oldPrice: 25000.00,
    discount: "-40%",
    image: "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/a2/d1/53/a2d153c12d7c1216c406500543686ceb.jpg",
    category: "Earrings",
    bgColor: 4293848814
  },
  {
    id: 'prod_008',
    title: "Gold Choker Necklace",
    currentPrice: 45000.00,
    oldPrice: 60000.00,
    discount: "-25%",
    image: "https://images.weserv.nl/?url=https://i.pinimg.com/1200x/55/5f/81/555f8192d281f652159bbf59a2bb673c.jpg",
    category: "Necklaces",
    bgColor: 4293848814
  },
  {
    id: 'prod_009',
    title: "Pearl Drop Necklace",
    currentPrice: 22000.00,
    oldPrice: 30000.00,
    discount: "-26%",
    image: "https://images.weserv.nl/?url=https://i.pinimg.com/736x/22/86/e4/2286e4e7c09d91ebc9a9169e1bcd069d.jpg",
    category: "Necklaces",
    bgColor: 4293848814
  }
];

const _productImages = [
    "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/6_mu5hap.jpg",
    "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/5_lf1dgq.jpg",
    "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/7_i3yykt.jpg",
    "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/4_a7e9t3.jpg",
    "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/3_i5pjnq.jpg",
    "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/1_x3dvkl.jpg",
];

const allProducts = [];
for (let i = 0; i < 12; i++) {
    const image = _productImages[i % _productImages.length];
    if (i % 4 == 0) {
        allProducts.push({
            id: `prod_all_${i}`,
            title: `Gold Necklace Design ${i}`,
            currentPrice: 45000 + (i * 1000),
            oldPrice: 50000 + (i * 1000),
            discount: "10% Off",
            image: image,
            bgColor: 4294956800, // 0xFFFFD700
            category: "Necklaces",
        });
    } else if (i % 4 == 1) {
        allProducts.push({
            id: `prod_all_${i}`,
            title: `Diamond Ring ${i}`,
            currentPrice: 85000 + (i * 2000),
            oldPrice: 95000 + (i * 2000),
            discount: "12% Off",
            image: image,
            bgColor: 4290822336, // 0xFFC0C0C0
            category: "Rings",
        });
    } else if (i % 4 == 2) {
        allProducts.push({
            id: `prod_all_${i}`,
            title: `Pearl Earrings ${i}`,
            currentPrice: 25000 + (i * 500),
            oldPrice: 30000 + (i * 500),
            discount: "15% Off",
            image: image,
            bgColor: 4294965468, // 0xFFFFF8DC
            category: "Earrings",
        });
    } else {
        allProducts.push({
            id: `prod_all_${i}`,
            title: `Bracelet ${i}`,
            currentPrice: 65000 + (i * 1500),
            oldPrice: 75000 + (i * 1500),
            discount: "8% Off",
            image: image,
            bgColor: 4292519194, // 0xFFDAA520
            category: "Bracelets",
        });
    }
}

async function seed() {
    console.log("Seeding globalShopProducts (9 items)...");
    for (const p of globalShopProducts) {
        await setDoc(doc(db, "products", p.id), {
            ...p,
            mainCategory: "Jewellery",
            createdAt: serverTimestamp()
        }, { merge: true });
        console.log(`Saved ${p.id}`);
    }

    console.log("Seeding allProducts generated list (12 items)...");
    for (const p of allProducts) {
        await setDoc(doc(db, "products", p.id), {
            ...p,
            mainCategory: "Jewellery",
            createdAt: serverTimestamp()
        }, { merge: true });
        console.log(`Saved ${p.id}`);
    }

    const otherProducts = [
        { id: "prod_other_1", title: "Men's Casual Shirt", currentPrice: 1500, oldPrice: 2000, discount: "-25%", category: "Men", mainCategory: "Fashion", image: "https://images.unsplash.com/photo-1596755094514-f87e32f85f2c?w=400", bgColor: 4293848814 },
        { id: "prod_other_2", title: "Women's Designer Dress", currentPrice: 3500, oldPrice: 5000, discount: "-30%", category: "Women", mainCategory: "Fashion", image: "https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400", bgColor: 4293848814 },
        { id: "prod_other_3", title: "Gaming Laptop Pro", currentPrice: 85000, oldPrice: 100000, discount: "-15%", category: "Laptops", mainCategory: "Electronics", image: "https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=400", bgColor: 4293848814 },
        { id: "prod_other_4", title: "4K Gaming Monitor", currentPrice: 25000, oldPrice: 30000, discount: "-16%", category: "Monitors", mainCategory: "Electronics", image: "https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=400", bgColor: 4293848814 },
        { id: "prod_other_5", title: "Premium Chef Knife", currentPrice: 2500, oldPrice: 3500, discount: "-28%", category: "Kitchen", mainCategory: "Home & Lifestyle", image: "https://images.unsplash.com/photo-1593618998160-e34014e67546?w=400", bgColor: 4293848814 },
        { id: "prod_other_6", title: "Vitamin C Serum", currentPrice: 800, oldPrice: 1200, discount: "-33%", category: "Beauty", mainCategory: "Health & Beauty", image: "https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400", bgColor: 4293848814 },
        { id: "prod_other_7", title: "Organic Green Tea", currentPrice: 400, oldPrice: 500, discount: "-20%", category: "Drinks", mainCategory: "Food & Beverage", image: "https://images.unsplash.com/photo-1627492276025-b4618e4bcfa5?w=400", bgColor: 4293848814 }
    ];

    console.log("Seeding remaining category products (7 items)...");
    for (const p of otherProducts) {
        await setDoc(doc(db, "products", p.id), {
            ...p,
            createdAt: serverTimestamp()
        }, { merge: true });
        console.log(`Saved ${p.id}`);
    }

    console.log("Done seeding!");
    process.exit(0);
}

seed().catch(console.error);
