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

const bannersData = [
  {
    id: "banner_1",
    title: 'Diwali Special',
    imageUrl: 'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1739525624/6_mu5hap.jpg',
    placement: 'Hero',
    status: 'Active',
    color1: '#FFE0D1',
    color2: '#FFF0E5',
  },
  {
    id: "banner_2",
    title: 'New Arrivals',
    imageUrl: 'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1739525624/5_lf1dgq.jpg',
    placement: 'Hero',
    status: 'Active',
    color1: '#E1D5F8',
    color2: '#EEE5FF',
  },
  {
    id: "banner_3",
    title: 'Wedding Collection',
    imageUrl: 'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1739525624/7_i3yykt.jpg',
    placement: 'Hero',
    status: 'Active',
    color1: '#FFE5E5',
    color2: '#FFF5F5',
  },
  {
    id: "banner_offer_1",
    title: "MEGA SALE",
    subtitle: "Upto 50% OFF on Wedding Collection",
    imageUrl: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1739525624/6_mu5hap.jpg",
    placement: 'Offer',
    status: 'Active',
    color1: '#FF6B6B',
    color2: '#FFE66D',
  },
  {
    id: "banner_offer_2",
    title: "BUY 1 GET 1",
    subtitle: "On All Diamond Rings Collection",
    imageUrl: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1739525624/5_lf1dgq.jpg",
    placement: 'Offer',
    status: 'Active',
    color1: '#667EEA',
    color2: '#764BA2',
  },
  {
    id: "banner_offer_3",
    title: "FESTIVE OFFER",
    subtitle: "Flat 30% OFF on All Necklaces",
    imageUrl: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1739525624/4_a7e9t3.jpg",
    placement: 'Offer',
    status: 'Active',
    color1: '#F093FB',
    color2: '#F5576C',
  }
];

const stylesData = [
  {
    id: "style_1",
    title: 'Red Carpet',
    image: 'https://images.weserv.nl/?url=images.unsplash.com/photo-1534528741775-53994a69daeb',
    status: 'Active',
  },
  {
    id: "style_2",
    title: 'Bollywood',
    image: 'https://images.weserv.nl/?url=images.unsplash.com/photo-1531123897727-8f129e1688ce',
    status: 'Active',
  },
  {
    id: "style_3",
    title: 'Met Gala',
    image: 'https://images.weserv.nl/?url=images.unsplash.com/photo-1546167889-0b4d5ff30be0',
    status: 'Active',
  },
  {
    id: "style_4",
    title: 'Cannes',
    image: 'https://images.weserv.nl/?url=images.unsplash.com/photo-1616091216791-a5360b5fc78a',
    status: 'Active',
  },
  {
    id: "style_5",
    title: 'Airport Look',
    image: 'https://images.weserv.nl/?url=images.unsplash.com/photo-1483985988355-763728e1935b',
    status: 'Active',
  },
  {
    id: "style_6",
    title: 'Wedding Guest',
    image: 'https://images.weserv.nl/?url=images.unsplash.com/photo-1595777457583-95e059d581b8',
    status: 'Active',
  }
];

const reelsData = [
  {
    id: "reel_1",
    videoUrl: "https://res.cloudinary.com/ds1wiqrdb/video/upload/v1765563533/LISA_Bulgari_Mediterranea_High_Jewelry_Collection_lnh1ks.mp4",
    productName: "Mediterranea High Jewelry",
    productPrice: "₹1,25,00,000",
    productImage: "https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=200",
    status: 'Active',
  },
  {
    id: "reel_2",
    videoUrl: "https://res.cloudinary.com/ds1wiqrdb/video/upload/v1765563533/Tanishq_Diamonds_Where_Rarity_Meets_Radiance_ruhfu7.mp4",
    productName: "Tanishq Diamond Necklace",
    productPrice: "₹45,00,000",
    productImage: "https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=200",
    status: 'Active',
  },
  {
    id: "reel_3",
    videoUrl: "https://res.cloudinary.com/ds1wiqrdb/video/upload/v1765714763/TOP_TRENDING_GOLD_JEWELLERY_EARRINGS_JHUMKA_DESIGN_goldjewellery_jewelry_gold_jewellery_22k_okoq9c.mp4",
    productName: "Trending Gold Jhumkas",
    productPrice: "₹1,85,000",
    productImage: "https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=200",
    status: 'Active',
  },
  {
    id: "reel_4",
    videoUrl: "https://res.cloudinary.com/ds1wiqrdb/video/upload/v1765714699/The_Timeless_Kasumala_Collection_Rivaah_Wedding_Jewellery_by_Tanishq_ajmdjv.mp4",
    productName: "Timeless Kasumala Set",
    productPrice: "₹8,50,000",
    productImage: "https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=200",
    status: 'Active',
  }
];

async function seedData() {
    try {
        console.log("Seeding Banners...");
        for (const b of bannersData) {
            await setDoc(doc(db, "banners", b.id), {
                title: b.title,
                subtitle: b.subtitle || null,
                imageUrl: b.imageUrl,
                placement: b.placement,
                status: b.status,
                color1: b.color1,
                color2: b.color2,
                createdAt: serverTimestamp()
            }, { merge: true });
            console.log(`Saved ${b.id}`);
        }

        console.log("Seeding Celebrity Styles...");
        for (const s of stylesData) {
            await setDoc(doc(db, "celebrityStyles", s.id), {
                title: s.title,
                image: s.image,
                status: s.status,
                createdAt: serverTimestamp(),
            }, { merge: true });
            console.log(`Saved ${s.id}`);
        }

        console.log("Seeding Reels...");
        for (const r of reelsData) {
            await setDoc(doc(db, "reels", r.id), {
                videoUrl: r.videoUrl,
                productName: r.productName,
                productPrice: r.productPrice,
                productImage: r.productImage,
                status: r.status,
                createdAt: serverTimestamp(),
            }, { merge: true });
            console.log(`Saved ${r.id}`);
        }

        console.log("Done seeding marketing data!");
        process.exit(0);
    } catch (error) {
        console.error(error);
        process.exit(1);
    }
}

seedData();
