import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { readFileSync } from 'fs';
import { resolve } from 'path';

// Provide path to your service account key here.
const serviceAccount = JSON.parse(readFileSync(resolve('./serviceAccountKey.json'), 'utf8'));

initializeApp({
  credential: cert(serviceAccount)
});

const db = getFirestore();

const slides = [
  {
    image: 'https://images.unsplash.com/photo-1599643478518-17488fbbcd75?q=80&w=1200&auto=format&fit=crop',
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
    image: 'https://images.unsplash.com/photo-1626177196020-f13110de832a?q=80&w=1200&auto=format&fit=crop',
    headline: 'CELESTIAL BEAUTY',
    description: 'Diamonds sourced from the most pristine mines around the world.',
    features: [
      { icon: 'star', text: 'GIA Certified' },
      { icon: 'eco', text: 'Sustainable Sourcing' }
    ],
    order: 1,
    active: true,
  }
];

async function seed() {
  const collectionRef = db.collection('luxury_slides');
  let count = 0;
  for (const slide of slides) {
    await collectionRef.add({
      ...slide,
      createdAt: FieldValue.serverTimestamp()
    });
    count++;
  }
  console.log(`Seeded ${count} luxury slides.`);
}

seed().catch(console.error);
