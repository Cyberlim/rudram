"use client";
import { Search, Plus, Trash2, Edit2, X, ChevronDown, ChevronRight, Filter } from "lucide-react";
import { useState, useEffect } from "react";
import { db } from "@/lib/firebase";
import { collection, query, orderBy, onSnapshot, doc, setDoc, deleteDoc, updateDoc, serverTimestamp } from "firebase/firestore";
import Fuse from "fuse.js";

// ── Jewellery categories for seeding ─────────────────────
const SEED_CATEGORIES = [
  { name: "Necklaces", icon: "💎", subcategories: ["Gold Necklaces", "Diamond Necklaces", "Silver Necklaces", "Temple Necklaces", "Chokers"] },
  { name: "Rings", icon: "💍", subcategories: ["Gold Rings", "Diamond Rings", "Silver Rings", "Engagement Rings", "Wedding Bands"] },
  { name: "Earrings", icon: "👂", subcategories: ["Studs", "Jhumkas", "Hoops", "Drop Earrings", "Chandbalis"] },
  { name: "Bangles & Bracelets", icon: "✨", subcategories: ["Gold Bangles", "Silver Bangles", "Diamond Bangles", "Kadas", "Charm Bracelets"] },
  { name: "Pendants & Chains", icon: "🔗", subcategories: ["Gold Chains", "Silver Chains", "Diamond Pendants", "God Pendants", "Name Pendants"] },
  { name: "Mangalsutra", icon: "🪡", subcategories: ["Gold Mangalsutra", "Diamond Mangalsutra", "Short Mangalsutra", "Long Mangalsutra"] },
  { name: "Nose Rings", icon: "🌸", subcategories: ["Gold Nose Rings", "Diamond Nose Pins", "Silver Nose Rings"] },
  { name: "Anklets", icon: "🦶", subcategories: ["Gold Anklets", "Silver Anklets", "Beaded Anklets"] },
  { name: "Maang Tikka", icon: "👸", subcategories: ["Gold Maang Tikka", "Diamond Maang Tikka", "Kundan Maang Tikka"] },
  { name: "Temple Jewellery", icon: "🏛️", subcategories: ["Temple Necklaces", "Temple Earrings", "Temple Sets", "Deity Jewellery"] },
  { name: "Bridal Sets", icon: "👰", subcategories: ["Complete Bridal Sets", "Gold Bridal Sets", "Diamond Bridal Sets", "Kundan Sets"] },
  { name: "Men's Jewellery", icon: "👑", subcategories: ["Men's Rings", "Men's Chains", "Men's Bracelets", "Kada"] },
];

const GENERAL_CATEGORIES = [
  { name: "Electronic", icon: "🖥️", subcategories: ["Monitors", "Laptops", "PCs"] },
  { name: "Games", icon: "🎮", subcategories: ["Consoles", "Accessories", "Video Games"] },
  { name: "Fashion", icon: "👗", subcategories: ["Men", "Women", "Kids"] },
  { name: "Pharmacy", icon: "💊", subcategories: ["Medicines", "Supplements", "First Aid"] },
  { name: "Gadgets", icon: "📱", subcategories: ["Smartphones", "Smartwatches", "Tablets"] },
  { name: "Accessories", icon: "🎧", subcategories: ["Headphones", "Cases", "Cables"] },
  { name: "Health", icon: "❤️", subcategories: ["Fitness", "Wellness", "Vitamins"] },
  { name: "Beauty", icon: "🌸", subcategories: ["Makeup", "Skincare", "Haircare"] },
];

interface Category {
  id: string;
  name: string;
  icon?: string;
  subcategories?: string[];
  status: string;
  type?: string;
  productCount?: number;
  createdAt?: any;
}

export default function CategoriesPage() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [activeTab, setActiveTab] = useState("All");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [seeding, setSeeding] = useState(false);
  const [expandedId, setExpandedId] = useState<string | null>(null);
  const [form, setForm] = useState({ name: "", icon: "", subcategories: "", status: "Active", type: "Jewellery" });

  useEffect(() => {
    const q = query(collection(db, "categories"), orderBy("createdAt", "desc"));
    const unsub = onSnapshot(q, (snap) => {
      setCategories(snap.docs.map((d) => ({ id: d.id, ...d.data() })) as Category[]);
      setLoading(false);
    }, () => setLoading(false));
    return () => unsub();
  }, []);

  const seedCategories = async () => {
    if (!confirm(`This will add ${SEED_CATEGORIES.length} jewellery categories to the database. Continue?`)) return;
    setSeeding(true);
    try {
      for (const cat of SEED_CATEGORIES) {
        const ref = doc(collection(db, "categories"));
        await setDoc(ref, {
          name: cat.name,
          icon: cat.icon,
          subcategories: cat.subcategories,
          status: "Active",
          type: "Jewellery",
          productCount: 0,
          createdAt: serverTimestamp(),
        });
      }
      alert("✅ Categories seeded successfully!");
    } catch (e) {
      alert("Failed to seed categories");
    }
    setSeeding(false);
  };

  const handleAdd = async (e: React.FormEvent) => {
    e.preventDefault();
    const ref = doc(collection(db, "categories"));
    await setDoc(ref, {
      name: form.name,
      icon: form.icon || "🏷️",
      subcategories: form.subcategories.split(",").map(s => s.trim()).filter(Boolean),
      status: form.status,
      type: form.type,
      productCount: 0,
      createdAt: serverTimestamp(),
    });
    setIsModalOpen(false);
    setForm({ name: "", icon: "", subcategories: "", status: "Active", type: "Jewellery" });
  };

  const handleDelete = async (id: string) => {
    if (confirm("Delete this category?")) await deleteDoc(doc(db, "categories", id));
  };

  const toggleStatus = async (id: string, current: string) => {
    await updateDoc(doc(db, "categories", id), { status: current === "Active" ? "Inactive" : "Active" });
  };

  // Determine fallback type for legacy data
  const getCategoryType = (c: Category) => {
    if (c.type) return c.type;
    return GENERAL_CATEGORIES.some(g => g.name === c.name) ? "General" : "Jewellery";
  };

  const fuse = new Fuse(categories, {
    keys: ["name", "type", "subcategories"],
    threshold: 0.3,
  });

  const filtered = (search ? fuse.search(search).map(r => r.item) : categories).filter(c => {
    const cType = getCategoryType(c);
    const matchesTab = activeTab === "All" || cType === activeTab;
    return matchesTab;
  });

  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-1000 ease-out pb-10">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black text-gray-900 dark:text-gray-100">Categories</h1>
          <p className="text-gray-500 mt-1">{loading ? "Loading..." : `${categories.length} categories`}</p>
        </div>
        <div className="flex items-center gap-3">
          <button onClick={seedCategories} disabled={seeding}
            className="flex items-center gap-2 bg-purple-600 hover:bg-purple-700 disabled:opacity-60 text-white px-4 py-2 rounded-lg font-medium transition-colors shadow-sm">
            {seeding ? "..." : "🌱 Seed Jewellery"}
          </button>
          
          <button onClick={async () => {
              if (!confirm("Add General categories?")) return;
              setSeeding(true);
              for (const cat of GENERAL_CATEGORIES) {
                await setDoc(doc(collection(db, "categories")), { ...cat, type: "General", status: "Active", productCount: 0, createdAt: serverTimestamp() });
              }
              setSeeding(false);
          }} disabled={seeding}
            className="flex items-center gap-2 bg-indigo-600 hover:bg-indigo-700 disabled:opacity-60 text-white px-4 py-2 rounded-lg font-medium transition-colors shadow-sm">
            {seeding ? "..." : "📦 Seed General"}
          </button>
          <button onClick={() => setIsModalOpen(true)}
            className="flex items-center gap-2 bg-amber-600 hover:bg-amber-700 text-white px-4 py-2 rounded-lg font-medium transition-colors shadow-sm">
            <Plus className="w-4 h-4" /> Add Category
          </button>
        </div>
      </div>

      {/* Tabs */}
      <div className="flex space-x-1 bg-white dark:bg-[#14142B] p-1 rounded-xl shadow-sm border border-gray-100 dark:border-[#2A2A42] w-fit">
        {["All", "Jewellery", "General"].map((tab) => (
          <button
            key={tab}
            onClick={() => setActiveTab(tab)}
            className={`px-6 py-2 rounded-lg text-sm font-medium transition-colors ${
              activeTab === tab
                ? "bg-amber-50 text-amber-700"
                : "text-gray-500 hover:text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:bg-[#0B0B1A]"
            }`}
          >
            {tab}
          </button>
        ))}
      </div>

      <div className="bg-white dark:bg-[#14142B] rounded-2xl shadow-sm border border-gray-100 dark:border-[#2A2A42] overflow-hidden">
        <div className="p-4 border-b border-gray-100 dark:border-[#2A2A42] bg-gray-50 dark:bg-[#0B0B1A]/50">
          <div className="relative w-full md:w-80">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input type="text" placeholder="Search categories..." value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full pl-10 pr-4 py-2 bg-white dark:bg-[#14142B] border border-gray-200 dark:border-[#2A2A42] rounded-lg text-sm focus:ring-amber-500 focus:border-amber-500 outline-none" />
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-gray-50 dark:bg-[#0B0B1A]/50">
              <tr className="text-gray-500 font-semibold border-b border-gray-100 dark:border-[#2A2A42]">
                <th className="py-4 px-6">Icon</th>
                <th className="py-4 px-6">Category Name</th>
                <th className="py-4 px-6">Type</th>
                <th className="py-4 px-6">Subcategories</th>
                <th className="py-4 px-6">Status</th>
                <th className="py-4 px-6 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {loading ? (
                <tr><td colSpan={6} className="py-10 text-center text-gray-400">Loading categories...</td></tr>
              ) : filtered.length === 0 ? (
                <tr>
                  <td colSpan={6} className="py-12 text-center">
                    <p className="text-gray-400 mb-3">No categories found in {activeTab}</p>
                  </td>
                </tr>
              ) : (
                filtered.map((cat) => (
                  <tr key={cat.id} className="hover:bg-gray-50 dark:bg-[#0B0B1A]/50 transition-colors">
                    <td className="py-4 px-6 text-2xl">{cat.icon || "🏷️"}</td>
                    <td className="py-4 px-6 font-semibold text-gray-900 dark:text-gray-100">{cat.name}</td>
                    <td className="py-4 px-6">
                      <span className={`px-2 py-1 rounded text-xs font-medium ${getCategoryType(cat) === 'Jewellery' ? 'bg-purple-50 text-purple-700' : 'bg-indigo-50 text-indigo-700'}`}>
                        {getCategoryType(cat)}
                      </span>
                    </td>
                    <td className="py-4 px-6">
                      <button onClick={() => setExpandedId(expandedId === cat.id ? null : cat.id)}
                        className="flex items-center gap-1 text-amber-600 text-xs font-medium hover:underline">
                        {expandedId === cat.id ? <ChevronDown className="w-3 h-3" /> : <ChevronRight className="w-3 h-3" />}
                        {(cat.subcategories || []).length} subcategories
                      </button>
                      {expandedId === cat.id && (
                        <div className="mt-2 flex flex-wrap gap-1">
                          {(cat.subcategories || []).map((s) => (
                            <span key={s} className="bg-amber-50 text-amber-700 text-xs px-2 py-0.5 rounded-full">{s}</span>
                          ))}
                        </div>
                      )}
                    </td>
                    <td className="py-4 px-6">
                      <button onClick={() => toggleStatus(cat.id, cat.status)}
                        className={`px-2.5 py-1 rounded-full text-xs font-semibold ${cat.status === "Active" ? "bg-emerald-100 text-emerald-700" : "bg-gray-100 text-gray-600"}`}>
                        {cat.status}
                      </button>
                    </td>
                    <td className="py-4 px-6 text-right">
                      <button onClick={() => handleDelete(cat.id)}
                        className="text-red-400 hover:text-red-600 p-1 rounded hover:bg-red-50 transition-colors">
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

      {isModalOpen && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white dark:bg-[#14142B] rounded-2xl w-full max-w-md p-6 shadow-xl">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-xl font-bold">Add Category</h2>
              <button onClick={() => setIsModalOpen(false)} className="p-1 hover:bg-gray-100 rounded-full"><X className="w-5 h-5" /></button>
            </div>
            <form onSubmit={handleAdd} className="space-y-4">
              <div className="grid grid-cols-4 gap-3">
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Icon</label>
                  <input type="text" value={form.icon} onChange={(e) => setForm({ ...form, icon: e.target.value })}
                    placeholder="💎" className="w-full px-3 py-2 border border-gray-300 rounded-lg text-center text-xl" />
                </div>
                <div className="col-span-3">
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Category Name</label>
                  <input type="text" required value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })}
                    placeholder="E.g. Necklaces" className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-amber-500 focus:border-amber-500" />
                </div>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Category Type</label>
                <select value={form.type} onChange={(e) => setForm({ ...form, type: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-amber-500 focus:border-amber-500 outline-none">
                  <option value="Jewellery">Jewellery</option>
                  <option value="General">General</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Subcategories (comma-separated)</label>
                <textarea value={form.subcategories} onChange={(e) => setForm({ ...form, subcategories: e.target.value })}
                  placeholder="Gold Necklaces, Diamond Necklaces, Temple Necklaces"
                  rows={3} className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-amber-500 focus:border-amber-500 resize-none" />
              </div>
              <div className="flex justify-end gap-3 pt-4 border-t border-gray-100 dark:border-[#2A2A42]">
                <button type="button" onClick={() => setIsModalOpen(false)}
                  className="px-4 py-2 bg-gray-100 text-gray-700 dark:text-gray-300 rounded-lg font-medium">Cancel</button>
                <button type="submit" className="px-4 py-2 bg-amber-600 hover:bg-amber-700 text-white rounded-lg font-medium">Save</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}