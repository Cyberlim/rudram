const fs = require('fs');
const file = 'src/app/products/page.tsx';
let content = fs.readFileSync(file, 'utf8');
const imgs = [
  'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/6_mu5hap.jpg',
  'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/5_lf1dgq.jpg',
  'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/7_i3yykt.jpg',
  'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/4_a7e9t3.jpg',
  'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/3_i5pjnq.jpg',
  'https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/1_x3dvkl.jpg'
];
let i = 0;
content = content.replace(/image:\s*"https:\/\/images\.unsplash\.com\/[^"]+"/g, () => {
    const res = 'image: "' + imgs[i % imgs.length] + '"';
    i++;
    return res;
});
fs.writeFileSync(file, content);
