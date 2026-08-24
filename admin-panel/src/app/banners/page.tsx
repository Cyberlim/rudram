"use client";
import { Search, Filter, Plus, MoreHorizontal, Download, Trash2, Edit2, Image as ImageIcon } from "lucide-react";
import { useState, useEffect } from "react";
import { db } from "@/lib/firebase";
import { collection, query, orderBy, onSnapshot, doc, setDoc, deleteDoc, updateDoc, serverTimestamp } from "firebase/firestore";

interface Banner {
  id: string;
  title: string;
  subtitle?: string;
  imageUrl: string;
  placement: string;
  status: string;
  color1: string;
  color2: string;
  createdAt?: any;
}

export default function BannersPage() {
  const [banners, setBanners] = useState<Banner[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  
  // Form State
  const [formData, setFormData] = useState({
    title: "",
    subtitle: "",
    imageUrl: "",
    placement: "Hero",
    status: "Active",
    color1: "#FFE0D1",
    color2: "#FFF0E5",
  });

  useEffect(() => {
    const q = query(collection(db, "banners"), orderBy("createdAt", "desc"));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const fetchedBanners = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      })) as Banner[];
      setBanners(fetchedBanners);
      setLoading(false);
      setError(null);
    }, (err) => {
      console.error("Firebase error:", err);
      setError(err.message);
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  const handleAddBanner = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.title || !formData.imageUrl) return;

    try {
      const newRef = doc(collection(db, "banners"));
      await setDoc(newRef, {
        ...formData,
        createdAt: serverTimestamp(),
      });
      setIsModalOpen(false);
      setFormData({ title: "", subtitle: "", imageUrl: "", placement: "Hero", status: "Active", color1: "#FFE0D1", color2: "#FFF0E5" });
    } catch (error) {
      console.error("Error adding banner:", error);
      alert("Failed to add banner");
    }
  };

  const handleDelete = async (id: string) => {
    if (confirm("Are you sure you want to delete this banner?")) {
      await deleteDoc(doc(db, "banners", id));
    }
  };

  const toggleStatus = async (id: string, currentStatus: string) => {
    const newStatus = currentStatus === "Active" ? "Inactive" : "Active";
    await updateDoc(doc(db, "banners", id), { status: newStatus });
  };

  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-1000 ease-out pb-10">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black text-gray-900 dark:text-gray-100">Banners Management</h1>
          <p className="text-gray-500 mt-1">Manage and view all your banners in one place.</p>
        </div>
        <div className="flex items-center gap-3">
          <button 
            onClick={() => setIsModalOpen(true)}
            className="flex items-center gap-2 bg-amber-600 hover:bg-amber-700 text-white px-4 py-2 rounded-lg font-medium transition-colors shadow-sm"
          >
            <Plus className="w-4 h-4" />
            <span>Add Banner</span>
          </button>
        </div>
      </div>

      {/* Table Container */}
      <div className="bg-white dark:bg-[#14142B] rounded-2xl shadow-sm border border-gray-100 dark:border-[#2A2A42] flex flex-col overflow-hidden">
        {/* Table */}
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm whitespace-nowrap">
            <thead className="bg-gray-50 dark:bg-[#0B0B1A]/50">
              <tr className="text-gray-500 font-semibold border-b border-gray-100 dark:border-[#2A2A42]">
                <th className="py-4 px-6">Image</th>
                <th className="py-4 px-6">Title</th>
                <th className="py-4 px-6">Placement</th>
                <th className="py-4 px-6">Colors</th>
                <th className="py-4 px-6">Status</th>
                <th className="py-4 px-6 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {error ? (
                <tr><td colSpan={6} className="text-center py-8 text-red-500">Error: {error}</td></tr>
              ) : loading ? (
                <tr><td colSpan={6} className="text-center py-8">Loading banners...</td></tr>
              ) : banners.length === 0 ? (
                <tr><td colSpan={6} className="text-center py-8 text-gray-500">No banners found. Click "Add Banner" to create one.</td></tr>
              ) : (
                banners.map((banner) => (
                  <tr key={banner.id} className="hover:bg-gray-50 dark:bg-[#0B0B1A]/50 transition-colors group">
                    <td className="py-4 px-6">
                      <div className="w-16 h-10 bg-gray-100 rounded overflow-hidden">
                        <img src={banner.imageUrl} alt={banner.title} className="w-full h-full object-cover" />
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="font-medium text-gray-900 dark:text-gray-100">{banner.title}</div>
                      {banner.subtitle && <div className="text-sm text-gray-500">{banner.subtitle}</div>}
                    </td>
                    <td className="py-4 px-6 text-gray-600">{banner.placement}</td>
                    <td className="py-4 px-6 text-gray-600">
                      <div className="flex gap-1">
                        <div className="w-4 h-4 rounded-full border border-gray-200 dark:border-[#2A2A42]" style={{backgroundColor: banner.color1}}></div>
                        <div className="w-4 h-4 rounded-full border border-gray-200 dark:border-[#2A2A42]" style={{backgroundColor: banner.color2}}></div>
                      </div>
                    </td>
                    <td className="py-4 px-6">
                      <button 
                        onClick={() => toggleStatus(banner.id, banner.status)}
                        className={`px-2.5 py-1 rounded-full text-xs font-semibold ${banner.status === 'Active' ? 'bg-emerald-100 text-emerald-700 hover:bg-emerald-200' : 'bg-gray-100 text-gray-700 dark:text-gray-300 hover:bg-gray-200'}`}
                      >
                        {banner.status}
                      </button>
                    </td>
                    <td className="py-4 px-6 text-right">
                      <button onClick={() => handleDelete(banner.id)} className="text-red-400 hover:text-red-600 p-1 rounded-md hover:bg-red-50 transition-colors">
                        <Trash2 className="w-5 h-5" />
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Add Banner Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white dark:bg-[#14142B] rounded-2xl w-full max-w-md p-6 shadow-xl">
            <h2 className="text-xl font-bold mb-4">Add New Banner</h2>
            <form onSubmit={handleAddBanner} className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Title</label>
                  <input
                    type="text"
                    className="w-full px-3 py-2 border border-gray-200 dark:border-[#2A2A42] rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-amber-500 outline-none transition-all"
                    placeholder="e.g. Diwali Special"
                    value={formData.title}
                    onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Subtitle (Optional)</label>
                  <input
                    type="text"
                    className="w-full px-3 py-2 border border-gray-200 dark:border-[#2A2A42] rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-amber-500 outline-none transition-all"
                    placeholder="e.g. Upto 50% OFF"
                    value={formData.subtitle}
                    onChange={(e) => setFormData({ ...formData, subtitle: e.target.value })}
                  />
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Image URL</label>
                <input 
                  type="url" 
                  required
                  value={formData.imageUrl}
                  onChange={(e) => setFormData({...formData, imageUrl: e.target.value})}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-amber-500 focus:border-amber-500"
                  placeholder="https://example.com/image.jpg"
                />
                <p className="text-xs text-gray-500 mt-1">Provide a direct URL to the banner image.</p>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Placement</label>
                  <select
                    className="w-full px-3 py-2 border border-gray-200 dark:border-[#2A2A42] rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-amber-500 outline-none transition-all bg-white dark:bg-[#14142B]"
                    value={formData.placement}
                    onChange={(e) => setFormData({ ...formData, placement: e.target.value })}
                  >
                    <option value="Hero">Hero (Top Carousel)</option>
                    <option value="Offer">Offer (Exclusive Offers)</option>
                  </select>
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Gradient Color 1</label>
                  <input 
                    type="color" 
                    value={formData.color1}
                    onChange={(e) => setFormData({...formData, color1: e.target.value})}
                    className="w-full h-10 cursor-pointer"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Gradient Color 2</label>
                  <input 
                    type="color" 
                    value={formData.color2}
                    onChange={(e) => setFormData({...formData, color2: e.target.value})}
                    className="w-full h-10 cursor-pointer"
                  />
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Placement</label>
                <select 
                  value={formData.placement}
                  onChange={(e) => setFormData({...formData, placement: e.target.value})}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-amber-500 focus:border-amber-500"
                >
                  <option value="Hero">Hero Slider (Home)</option>
                  <option value="Exclusive Offers">Exclusive Offers</option>
                  <option value="Category">Category Header</option>
                </select>
              </div>
              
              <div className="flex justify-end gap-3 pt-4 border-t border-gray-100 dark:border-[#2A2A42]">
                <button 
                  type="button" 
                  onClick={() => setIsModalOpen(false)}
                  className="px-4 py-2 text-gray-700 dark:text-gray-300 bg-gray-100 hover:bg-gray-200 rounded-lg font-medium transition-colors"
                >
                  Cancel
                </button>
                <button 
                  type="submit" 
                  className="px-4 py-2 text-white bg-amber-600 hover:bg-amber-700 rounded-lg font-medium transition-colors"
                >
                  Save Banner
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}