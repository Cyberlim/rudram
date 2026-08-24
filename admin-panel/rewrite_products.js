const fs = require('fs');
const file = 'src/app/products/page.tsx';

const images = [
  'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/6_mu5hap.jpg',
  'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/5_lf1dgq.jpg',
  'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/7_i3yykt.jpg',
  'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/4_a7e9t3.jpg',
  'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/3_i5pjnq.jpg',
  'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/1_x3dvkl.jpg'
];

const jewelryProducts = [
  { title: "18k Gold Plated Minimalist Necklace", price: 1299, cat: "Necklaces" },
  { title: "Diamond Solitaire Engagement Ring", price: 15499, cat: "Rings" },
  { title: "Kundan Temple Bridal Set", price: 24500, cat: "Temple Jewellery" },
  { title: "Sterling Silver Hoop Earrings", price: 899, cat: "Earrings" },
  { title: "22k Gold Antique Bangle Set", price: 45000, cat: "Bangles & Bracelets" },
  { title: "Diamond Heart Pendant Chain", price: 12500, cat: "Pendants & Chains" },
  { title: "Traditional Gold Mangalsutra", price: 35000, cat: "Mangalsutra" },
  { title: "Diamond Floral Nose Pin", price: 4500, cat: "Nose Rings" },
  { title: "Silver Payal Anklet Pair", price: 2500, cat: "Anklets" },
  { title: "Kundan Maang Tikka", price: 3200, cat: "Maang Tikka" },
  { title: "Complete Diamond Bridal Set", price: 150000, cat: "Bridal Sets" },
  { title: "Men's Platinum Cuban Chain", price: 85000, cat: "Men's Jewellery" },
  { title: "Kundan Choker Necklace", price: 8500, cat: "Necklaces" },
  { title: "Ruby Emerald Gold Ring", price: 12500, cat: "Rings" },
  { title: "Antique Gold Jhumkas", price: 3500, cat: "Earrings" },
  { title: "Bridal Chooda Bangle Set", price: 4500, cat: "Bangles & Bracelets" },
  { title: "Gold Plated Temple Mangalsutra", price: 12000, cat: "Mangalsutra" },
  { title: "Silver Oxidised Choker", price: 1500, cat: "Necklaces" },
  { title: "Platinum Couple Rings", price: 45000, cat: "Rings" },
  { title: "Polki Diamond Studs", price: 85000, cat: "Earrings" }
];

let generatedProductsStr = "[\n";
jewelryProducts.forEach((p, index) => {
    generatedProductsStr += `  {
    title: "${p.title}",
    currentPrice: ${p.price},
    oldPrice: ${Math.floor(p.price * 1.2)},
    discount: "20% OFF",
    category: "${p.cat}",
    stock: 20,
    vendorName: "Rudram Jewelry",
    image: "${images[index % images.length]}",
    bgColor: "#FFF8F0",
  },\n`;
});
generatedProductsStr += "]";

let content = fs.readFileSync(file, 'utf8');

// Replace the REAL_PRODUCTS array. It starts at `const REAL_PRODUCTS = [` and ends at the first `];` that follows it.
content = content.replace(/const REAL_PRODUCTS = \[[\s\S]*?\];/, `const REAL_PRODUCTS = ${generatedProductsStr};`);

fs.writeFileSync(file, content);
