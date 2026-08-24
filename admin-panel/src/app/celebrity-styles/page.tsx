"use client";
import { Search, Plus, Trash2, X, Package } from "lucide-react";
import { useState, useEffect } from "react";
import { db } from "@/lib/firebase";
import {
  collection, query, orderBy, onSnapshot, doc, setDoc,
  deleteDoc, updateDoc, serverTimestamp, arrayUnion, arrayRemove, getDoc
} from "firebase/firestore";

interface CelebrityStyle {
  id: string;
  title: string;
  image: string;
  status: string;
  productIds?: string[];
  createdAt?: any;
}

interface Product {
  id: string;
  title: string;
  image: string;
  currentPrice: number;
}

export default function CelebrityStylesPage() {
  const [styles, setStyles] = useState<CelebrityStyle[]>([]);
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [isAddStyleOpen, setIsAddStyleOpen] = useState(false);
  const [managingStyle, setManagingStyle] = useState<CelebrityStyle | null>(null);
  const [productSearch, setProductSearch] = useState("");

  const [formData, setFormData] = useState({ title: "", image: "", status: "Active" });

  // Fetch celebrity styles
  useEffect(() => {
    const q = query(collection(db, "celebrityStyles"), orderBy("createdAt", "desc"));
    const unsub = onSnapshot(q, (snap) => {
      setStyles(snap.docs.map((d) => ({ id: d.id, ...d.data() })) as CelebrityStyle[]);
      setLoading(false);
    }, (err) => { setError(err.message); setLoading(false); });
    return () => unsub();
  }, []);

  // Fetch all products for selector
  useEffect(() => {
    const q = query(collection(db, "products"));
    const unsub = onSnapshot(q, (snap) => {
      setProducts(snap.docs.map((d) => ({ id: d.id, ...d.data() })) as Product[]);
    });
    return () => unsub();
  }, []);

  const handleAddStyle = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.title || !formData.image) return;
    try {
      const newRef = doc(collection(db, "celebrityStyles"));
      await setDoc(newRef, { ...formData, productIds: [], createdAt: serverTimestamp() });
      setIsAddStyleOpen(false);
      setFormData({ title: "", image: "", status: "Active" });
    } catch (err) {
      alert("Failed to add celebrity style");
    }
  };

  const handleDelete = async (id: string) => {
    if (confirm("Delete this celebrity style?")) {
      await deleteDoc(doc(db, "celebrityStyles", id));
    }
  };

  const toggleStatus = async (id: string, current: string) => {
    await updateDoc(doc(db, "celebrityStyles", id), {
      status: current === "Active" ? "Inactive" : "Active",
    });
  };

  const toggleProduct = async (productId: string) => {
    if (!managingStyle) return;
    const styleRef = doc(db, "celebrityStyles", managingStyle.id);
    const isLinked = (managingStyle.productIds ?? []).includes(productId);
    await updateDoc(styleRef, {
      productIds: isLinked ? arrayRemove(productId) : arrayUnion(productId),
    });
    // Update local state for instant UI feedback
    setManagingStyle((prev) =>
      prev
        ? {
            ...prev,
            productIds: isLinked
              ? prev.productIds?.filter((id) => id !== productId)
              : [...(prev.productIds ?? []), productId],
          }
        : null
    );
  };

  const filteredProducts = products.filter((p) =>
    p.title?.toLowerCase().includes(productSearch.toLowerCase())
  );

  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-1000 ease-out pb-10">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black text-gray-900 dark:text-gray-100">Celebrity Styles</h1>
          <p className="text-gray-500 mt-1">Manage celebrity styles and assign products to each style.</p>
        </div>
        <button
          onClick={() => setIsAddStyleOpen(true)}
          className="flex items-center gap-2 bg-amber-600 hover:bg-amber-700 text-white px-4 py-2 rounded-lg font-medium transition-colors shadow-sm"
        >
          <Plus className="w-4 h-4" />
          <span>Add Style</span>
        </button>
      </div>

      {/* Table */}
      <div className="bg-white dark:bg-[#14142B] rounded-2xl shadow-sm border border-gray-100 dark:border-[#2A2A42] overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm whitespace-nowrap">
            <thead className="bg-gray-50 dark:bg-[#0B0B1A]/50">
              <tr className="text-gray-500 font-semibold border-b border-gray-100 dark:border-[#2A2A42]">
                <th className="py-4 px-6">Image</th>
                <th className="py-4 px-6">Title</th>
                <th className="py-4 px-6">Products Linked</th>
                <th className="py-4 px-6">Status</th>
                <th className="py-4 px-6 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {error ? (
                <tr><td colSpan={5} className="text-center py-8 text-red-500">Error: {error}</td></tr>
              ) : loading ? (
                <tr><td colSpan={5} className="text-center py-8">Loading...</td></tr>
              ) : styles.length === 0 ? (
                <tr><td colSpan={5} className="text-center py-8 text-gray-500">No styles found. Click "Add Style" to create one.</td></tr>
              ) : (
                styles.map((style) => (
                  <tr key={style.id} className="hover:bg-gray-50 dark:bg-[#0B0B1A]/50 transition-colors">
                    <td className="py-4 px-6">
                      <div className="w-12 h-16 bg-gray-100 rounded overflow-hidden">
                        <img src={style.image} alt={style.title} className="w-full h-full object-cover" />
                      </div>
                    </td>
                    <td className="py-4 px-6 font-medium text-gray-900 dark:text-gray-100">{style.title}</td>
                    <td className="py-4 px-6">
                      <span className="text-gray-600 text-sm">
                        {(style.productIds ?? []).length} product{(style.productIds ?? []).length !== 1 ? "s" : ""}
                      </span>
                    </td>
                    <td className="py-4 px-6">
                      <button
                        onClick={() => toggleStatus(style.id, style.status)}
                        className={`px-2.5 py-1 rounded-full text-xs font-semibold ${style.status === "Active" ? "bg-emerald-100 text-emerald-700 hover:bg-emerald-200" : "bg-gray-100 text-gray-700 dark:text-gray-300 hover:bg-gray-200"}`}
                      >
                        {style.status}
                      </button>
                    </td>
                    <td className="py-4 px-6 text-right">
                      <div className="flex items-center justify-end gap-2">
                        <button
                          onClick={() => setManagingStyle(style)}
                          className="flex items-center gap-1 text-amber-600 hover:text-amber-800 px-2 py-1 rounded-md hover:bg-amber-50 text-xs font-medium transition-colors"
                        >
                          <Package className="w-4 h-4" />
                          Manage Products
                        </button>
                        <button
                          onClick={() => handleDelete(style.id)}
                          className="text-red-400 hover:text-red-600 p-1 rounded-md hover:bg-red-50 transition-colors"
                        >
                          <Trash2 className="w-5 h-5" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Add Style Modal */}
      {isAddStyleOpen && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white dark:bg-[#14142B] rounded-2xl w-full max-w-md p-6 shadow-xl">
            <h2 className="text-xl font-bold mb-4">Add Celebrity Style</h2>
            <form onSubmit={handleAddStyle} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Title (e.g. Red Carpet, Bollywood)</label>
                <input type="text" required value={formData.title}
                  onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-amber-500 focus:border-amber-500"
                  placeholder="E.g., Red Carpet"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Image URL</label>
                <input type="url" required value={formData.image}
                  onChange={(e) => setFormData({ ...formData, image: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-amber-500 focus:border-amber-500"
                  placeholder="https://example.com/image.jpg"
                />
                <p className="text-xs text-gray-500 mt-1">Provide a direct URL to the image.</p>
              </div>
              <div className="flex justify-end gap-3 pt-4 border-t border-gray-100 dark:border-[#2A2A42]">
                <button type="button" onClick={() => setIsAddStyleOpen(false)}
                  className="px-4 py-2 text-gray-700 dark:text-gray-300 bg-gray-100 hover:bg-gray-200 rounded-lg font-medium transition-colors">
                  Cancel
                </button>
                <button type="submit"
                  className="px-4 py-2 text-white bg-amber-600 hover:bg-amber-700 rounded-lg font-medium transition-colors">
                  Save Style
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Manage Products Modal */}
      {managingStyle && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
        <div className="bg-white dark:bg-[#14142B] rounded-2xl w-full max-w-3xl p-6 shadow-xl max-h-[90vh] flex flex-col">
            <div className="flex items-center justify-between mb-4">
              <div>
                <h2 className="text-xl font-bold">Manage Products</h2>
                <p className="text-sm text-gray-500">Style: <span className="font-semibold text-amber-700">{managingStyle.title}</span></p>
              </div>
              <button onClick={() => setManagingStyle(null)} className="p-2 hover:bg-gray-100 rounded-full">
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Search */}
            <div className="relative mb-4">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4" />
              <input
                type="text"
                placeholder="Search products..."
                value={productSearch}
                onChange={(e) => setProductSearch(e.target.value)}
                className="w-full pl-9 pr-4 py-2 border border-gray-200 dark:border-[#2A2A42] rounded-lg text-sm focus:ring-amber-500 focus:border-amber-500"
              />
            </div>

            <p className="text-xs text-gray-400 mb-3">
              {(managingStyle.productIds ?? []).length} product(s) linked — click to add/remove
            </p>

            {/* Product List */}
            <div className="overflow-y-auto flex-1 space-y-2 pr-1">
              {filteredProducts.length === 0 ? (
                <div className="text-center py-10 text-gray-400">No products found</div>
              ) : (
                filteredProducts.map((product) => {
                  const isLinked = (managingStyle.productIds ?? []).includes(product.id);
                  return (
                    <div
                      key={product.id}
                      onClick={() => toggleProduct(product.id)}
                      className={`flex items-center gap-3 cursor-pointer rounded-xl border-2 p-3 transition-all ${
                        isLinked
                          ? "border-amber-500 bg-amber-50 shadow-sm"
                          : "border-gray-200 dark:border-[#2A2A42] hover:border-amber-300 hover:bg-gray-50 dark:bg-[#0B0B1A]"
                      }`}
                    >
                      {/* Product Image */}
                      <div className="w-14 h-14 rounded-lg bg-gray-100 overflow-hidden flex-shrink-0">
                        <img
                          src={product.image}
                          alt={product.title}
                          className="w-full h-full object-cover"
                          onError={(e) => (e.currentTarget.style.display = "none")}
                        />
                      </div>

                      {/* Product Info */}
                      <div className="flex-1 min-w-0">
                        <p className="text-sm font-semibold text-gray-900 dark:text-gray-100 truncate">{product.title}</p>
                        <p className="text-xs text-amber-700 font-bold mt-0.5">₹{product.currentPrice?.toLocaleString()}</p>
                      </div>

                      {/* Check indicator */}
                      <div className={`w-6 h-6 rounded-full flex items-center justify-center flex-shrink-0 border-2 transition-all ${
                        isLinked ? "bg-amber-500 border-amber-500 text-white" : "border-gray-300"
                      }`}>
                        {isLinked && (
                          <svg className="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={3}>
                            <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                          </svg>
                        )}
                      </div>
                    </div>
                  );
                })
              )}
            </div>

            <div className="mt-4 pt-4 border-t border-gray-100 dark:border-[#2A2A42] flex justify-end">
              <button
                onClick={() => setManagingStyle(null)}
                className="px-5 py-2 bg-amber-600 hover:bg-amber-700 text-white rounded-lg font-medium transition-colors"
              >
                Done
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
