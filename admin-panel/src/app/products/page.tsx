"use client";
import { Search, Filter, Plus, Trash2, Download, Image as ImageIcon } from "lucide-react";
import { useState, useEffect } from "react";
import { db } from "@/lib/firebase";
import { collection, query, orderBy, onSnapshot, doc, deleteDoc, updateDoc, setDoc, serverTimestamp } from "firebase/firestore";
import Fuse from "fuse.js";

interface Product {
  id: string;
  title: string;
  currentPrice: number;
  oldPrice?: number;
  discount?: string;
  category: string;
  stock?: number;
  status?: string;
  image?: string;
  bgColor?: string;
  vendorName?: string;
  createdAt?: any;
}

const REAL_PRODUCTS = [
  {
    title: "18k Gold Plated Minimalist Necklace",
    currentPrice: 1299,
    oldPrice: 1558,
    discount: "20% OFF",
    category: "Necklaces",
    stock: 20,
    vendorName: "Rudram Jewelry",
    image: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/6_mu5hap.jpg",
    bgColor: "#FFF8F0",
  },
  {
    title: "Diamond Solitaire Engagement Ring",
    currentPrice: 15499,
    oldPrice: 18598,
    discount: "20% OFF",
    category: "Rings",
    stock: 20,
    vendorName: "Rudram Jewelry",
    image: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/5_lf1dgq.jpg",
    bgColor: "#FFF8F0",
  },
  {
    title: "Kundan Temple Bridal Set",
    currentPrice: 24500,
    oldPrice: 29400,
    discount: "20% OFF",
    category: "Temple Jewellery",
    stock: 20,
    vendorName: "Rudram Jewelry",
    image: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/7_i3yykt.jpg",
    bgColor: "#FFF8F0",
  },
  {
    title: "Sterling Silver Hoop Earrings",
    currentPrice: 899,
    oldPrice: 1078,
    discount: "20% OFF",
    category: "Earrings",
    stock: 20,
    vendorName: "Rudram Jewelry",
    image: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/4_a7e9t3.jpg",
    bgColor: "#FFF8F0",
  },
  {
    title: "22k Gold Antique Bangle Set",
    currentPrice: 45000,
    oldPrice: 54000,
    discount: "20% OFF",
    category: "Bangles & Bracelets",
    stock: 20,
    vendorName: "Rudram Jewelry",
    image: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/3_i5pjnq.jpg",
    bgColor: "#FFF8F0",
  },
  {
    title: "Diamond Heart Pendant Chain",
    currentPrice: 12500,
    oldPrice: 15000,
    discount: "20% OFF",
    category: "Pendants & Chains",
    stock: 20,
    vendorName: "Rudram Jewelry",
    image: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/1_x3dvkl.jpg",
    bgColor: "#FFF8F0",
  },
  {
    title: "Traditional Gold Mangalsutra",
    currentPrice: 35000,
    oldPrice: 42000,
    discount: "20% OFF",
    category: "Mangalsutra",
    stock: 20,
    vendorName: "Rudram Jewelry",
    image: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/6_mu5hap.jpg",
    bgColor: "#FFF8F0",
  },
  {
    title: "Diamond Floral Nose Pin",
    currentPrice: 4500,
    oldPrice: 5400,
    discount: "20% OFF",
    category: "Nose Rings",
    stock: 20,
    vendorName: "Rudram Jewelry",
    image: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/5_lf1dgq.jpg",
    bgColor: "#FFF8F0",
  },
  {
    title: "Silver Payal Anklet Pair",
    currentPrice: 2500,
    oldPrice: 3000,
    discount: "20% OFF",
    category: "Anklets",
    stock: 20,
    vendorName: "Rudram Jewelry",
    image: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/7_i3yykt.jpg",
    bgColor: "#FFF8F0",
  },
  {
    title: "Kundan Maang Tikka",
    currentPrice: 3200,
    oldPrice: 3840,
    discount: "20% OFF",
    category: "Maang Tikka",
    stock: 20,
    vendorName: "Rudram Jewelry",
    image: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/4_a7e9t3.jpg",
    bgColor: "#FFF8F0",
  },
  {
    title: "Complete Diamond Bridal Set",
    currentPrice: 150000,
    oldPrice: 180000,
    discount: "20% OFF",
    category: "Bridal Sets",
    stock: 20,
    vendorName: "Rudram Jewelry",
    image: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/3_i5pjnq.jpg",
    bgColor: "#FFF8F0",
  },
  {
    title: "Men's Platinum Cuban Chain",
    currentPrice: 85000,
    oldPrice: 102000,
    discount: "20% OFF",
    category: "Men's Jewellery",
    stock: 20,
    vendorName: "Rudram Jewelry",
    image: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/1_x3dvkl.jpg",
    bgColor: "#FFF8F0",
  },
  {
    title: "Kundan Choker Necklace",
    currentPrice: 8500,
    oldPrice: 10200,
    discount: "20% OFF",
    category: "Necklaces",
    stock: 20,
    vendorName: "Rudram Jewelry",
    image: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/6_mu5hap.jpg",
    bgColor: "#FFF8F0",
  },
  {
    title: "Ruby Emerald Gold Ring",
    currentPrice: 12500,
    oldPrice: 15000,
    discount: "20% OFF",
    category: "Rings",
    stock: 20,
    vendorName: "Rudram Jewelry",
    image: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/5_lf1dgq.jpg",
    bgColor: "#FFF8F0",
  },
  {
    title: "Antique Gold Jhumkas",
    currentPrice: 3500,
    oldPrice: 4200,
    discount: "20% OFF",
    category: "Earrings",
    stock: 20,
    vendorName: "Rudram Jewelry",
    image: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/7_i3yykt.jpg",
    bgColor: "#FFF8F0",
  },
  {
    title: "Bridal Chooda Bangle Set",
    currentPrice: 4500,
    oldPrice: 5400,
    discount: "20% OFF",
    category: "Bangles & Bracelets",
    stock: 20,
    vendorName: "Rudram Jewelry",
    image: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/4_a7e9t3.jpg",
    bgColor: "#FFF8F0",
  },
  {
    title: "Gold Plated Temple Mangalsutra",
    currentPrice: 12000,
    oldPrice: 14400,
    discount: "20% OFF",
    category: "Mangalsutra",
    stock: 20,
    vendorName: "Rudram Jewelry",
    image: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/3_i5pjnq.jpg",
    bgColor: "#FFF8F0",
  },
  {
    title: "Silver Oxidised Choker",
    currentPrice: 1500,
    oldPrice: 1800,
    discount: "20% OFF",
    category: "Necklaces",
    stock: 20,
    vendorName: "Rudram Jewelry",
    image: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/1_x3dvkl.jpg",
    bgColor: "#FFF8F0",
  },
  {
    title: "Platinum Couple Rings",
    currentPrice: 45000,
    oldPrice: 54000,
    discount: "20% OFF",
    category: "Rings",
    stock: 20,
    vendorName: "Rudram Jewelry",
    image: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/6_mu5hap.jpg",
    bgColor: "#FFF8F0",
  },
  {
    title: "Polki Diamond Studs",
    currentPrice: 85000,
    oldPrice: 102000,
    discount: "20% OFF",
    category: "Earrings",
    stock: 20,
    vendorName: "Rudram Jewelry",
    image: "https://res.cloudinary.com/ds1wiqrdb/image/upload/v1765716358/5_lf1dgq.jpg",
    bgColor: "#FFF8F0",
  },
];

export default function ProductsPage() {
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [seeding, setSeeding] = useState(false);
  const [search, setSearch] = useState("");

  useEffect(() => {
    const q = query(collection(db, "products"), orderBy("createdAt", "desc"));
    const unsub = onSnapshot(q, (snap) => {
      setProducts(snap.docs.map((d) => ({ id: d.id, ...d.data() })) as Product[]);
      setLoading(false);
    }, () => setLoading(false));
    return () => unsub();
  }, []);

  const handleDelete = async (id: string) => {
    if (confirm("Delete this product?")) await deleteDoc(doc(db, "products", id));
  };

  const toggleStatus = async (id: string, current: string) => {
    await updateDoc(doc(db, "products", id), { status: current === "Active" ? "Inactive" : "Active" });
  };

  const clearAllProducts = async () => {
    if (!confirm("Are you sure you want to delete ALL products? This cannot be undone.")) return;
    setSeeding(true);
    for (const p of products) {
      await deleteDoc(doc(db, "products", p.id));
    }
    setSeeding(false);
  };

  const seedRealProducts = async () => {
    if (!confirm("Seed realistic products into the database?")) return;
    setSeeding(true);
    try {
      for (const p of REAL_PRODUCTS) {
        await setDoc(doc(collection(db, "products")), {
          ...p,
          status: "Active",
          createdAt: serverTimestamp()
        });
      }
      alert("✅ Realistic Products Seeded!");
    } catch (e) {
      console.error(e);
      alert("Failed to seed");
    }
    setSeeding(false);
  };

  const fuse = new Fuse(products, {
    keys: ["title", "category", "vendorName", "id"],
    threshold: 0.3,
  });

  const filtered = search ? fuse.search(search).map(r => r.item) : products;

  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-1000 ease-out pb-10">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black text-gray-900 dark:text-gray-100">Products Management</h1>
          <p className="text-gray-500 mt-1">{loading ? "Loading..." : `${products.length} products found`}</p>
        </div>
        <div className="flex items-center gap-3">
          <button onClick={clearAllProducts} disabled={seeding || products.length === 0}
            className="flex items-center gap-2 bg-red-50 hover:bg-red-100 text-red-600 px-4 py-2 rounded-lg font-medium transition-colors border border-red-200">
            <Trash2 className="w-4 h-4" />
            <span>{seeding ? "Clearing..." : "Clear All"}</span>
          </button>
          
          <button onClick={seedRealProducts} disabled={seeding}
            className="flex items-center gap-2 bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-lg font-medium transition-colors shadow-sm">
            <Plus className="w-4 h-4" />
            <span>{seeding ? "Seeding..." : "Seed Realistic Products"}</span>
          </button>
        </div>
      </div>

      <div className="bg-white dark:bg-[#14142B] rounded-2xl shadow-sm border border-gray-100 dark:border-[#2A2A42] flex flex-col overflow-hidden">
        <div className="p-4 border-b border-gray-100 dark:border-[#2A2A42] flex flex-col md:flex-row md:items-center justify-between gap-4 bg-gray-50 dark:bg-[#0B0B1A]/50">
          <div className="relative w-full md:w-96">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input 
              type="text" 
              placeholder="Search by name or category..." 
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full pl-10 pr-4 py-2 bg-white dark:bg-[#14142B] border border-gray-200 dark:border-[#2A2A42] rounded-lg text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none transition-all"
            />
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm whitespace-nowrap">
            <thead className="bg-gray-50 dark:bg-[#0B0B1A]/50">
              <tr className="text-gray-500 font-semibold border-b border-gray-100 dark:border-[#2A2A42]">
                <th className="py-4 px-6">Product</th>
                <th className="py-4 px-6">Category</th>
                <th className="py-4 px-6">Vendor</th>
                <th className="py-4 px-6">Price</th>
                <th className="py-4 px-6">Stock</th>
                <th className="py-4 px-6">Status</th>
                <th className="py-4 px-6 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {loading ? (
                <tr><td colSpan={7} className="py-10 text-center text-gray-400">Loading products...</td></tr>
              ) : filtered.length === 0 ? (
                <tr><td colSpan={7} className="py-12 text-center">
                  <p className="text-gray-400 mb-3">No products found.</p>
                  <button onClick={seedRealProducts} className="bg-indigo-600 text-white px-4 py-2 rounded-lg text-sm font-medium">Seed Realistic Products</button>
                </td></tr>
              ) : (
                filtered.map((item) => (
                  <tr key={item.id} className="hover:bg-gray-50 dark:bg-[#0B0B1A]/50 transition-colors group">
                    <td className="py-4 px-6">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-lg bg-gray-100 flex items-center justify-center overflow-hidden border border-gray-200 dark:border-[#2A2A42]">
                          {item.image ? (
                            <img src={item.image} alt="" className="w-full h-full object-cover" />
                          ) : (
                            <ImageIcon className="w-5 h-5 text-gray-400" />
                          )}
                        </div>
                        <div>
                          <p className="font-bold text-gray-900 dark:text-gray-100 truncate max-w-[200px]">{item.title}</p>
                          <p className="text-xs text-gray-500 font-mono">#{item.id.slice(0, 8)}</p>
                        </div>
                      </div>
                    </td>
                    <td className="py-4 px-6">
                      <span className="bg-amber-50 text-amber-700 px-2 py-1 rounded text-xs font-semibold">{item.category || "Uncategorized"}</span>
                    </td>
                    <td className="py-4 px-6 text-gray-600 font-medium">{item.vendorName || "—"}</td>
                    <td className="py-4 px-6 font-bold text-gray-900 dark:text-gray-100">₹{(item.currentPrice || 0).toLocaleString()}</td>
                    <td className="py-4 px-6">
                      <span className={`px-2 py-1 rounded text-xs font-bold ${item.stock && item.stock > 10 ? 'text-green-700 bg-green-50' : 'text-red-700 bg-red-50'}`}>
                        {item.stock ?? 0} in stock
                      </span>
                    </td>
                    <td className="py-4 px-6">
                      <button onClick={() => toggleStatus(item.id, item.status || "Active")}
                        className={`px-2.5 py-1 rounded-full text-xs font-semibold ${item.status === "Active" || !item.status ? "bg-emerald-100 text-emerald-700" : "bg-gray-100 text-gray-600"}`}>
                        {item.status || "Active"}
                      </button>
                    </td>
                    <td className="py-4 px-6 text-right">
                      <button onClick={() => handleDelete(item.id)} className="text-red-400 hover:text-red-600 p-1 rounded-md hover:bg-red-50 transition-colors">
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}