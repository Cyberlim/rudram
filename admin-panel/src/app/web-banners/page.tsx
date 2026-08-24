"use client";
import { useState, useEffect } from "react";
import { collection, getDocs, addDoc, doc, updateDoc, deleteDoc } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { Save, Loader2, Plus, Trash2, Edit2, X, Image as ImageIcon } from "lucide-react";
import toast from "react-hot-toast";

interface Banner {
  id: string;
  title: string;
  imageUrl: string;
  link: string;
  isActive: boolean;
  order: number;
}

export default function WebBannersPage() {
  const [banners, setBanners] = useState<Banner[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  
  const [currentBanner, setCurrentBanner] = useState<Partial<Banner>>({
    title: "",
    imageUrl: "",
    link: "",
    isActive: true,
    order: 0
  });

  useEffect(() => {
    fetchBanners();
  }, []);

  const fetchBanners = async () => {
    try {
      const querySnapshot = await getDocs(collection(db, "web_banners"));
      const loadedBanners: Banner[] = [];
      querySnapshot.forEach((doc) => {
        loadedBanners.push({ id: doc.id, ...doc.data() } as Banner);
      });
      // Sort by order
      loadedBanners.sort((a, b) => a.order - b.order);
      setBanners(loadedBanners);
    } catch (error) {
      console.error("Error fetching banners:", error);
      toast.error("Failed to load banners.");
    } finally {
      setIsLoading(false);
    }
  };

  const handleSave = async () => {
    if (!currentBanner.imageUrl || !currentBanner.title) {
      toast.error("Title and Image URL are required.");
      return;
    }

    setIsSaving(true);
    try {
      if (currentBanner.id) {
        // Update
        const docRef = doc(db, "web_banners", currentBanner.id);
        await updateDoc(docRef, currentBanner);
        toast.success("Banner updated successfully!");
      } else {
        // Add new
        await addDoc(collection(db, "web_banners"), currentBanner);
        toast.success("Banner added successfully!");
      }
      setIsModalOpen(false);
      fetchBanners();
    } catch (error) {
      console.error("Error saving banner:", error);
      toast.error("Failed to save banner.");
    } finally {
      setIsSaving(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Are you sure you want to delete this banner?")) return;
    try {
      await deleteDoc(doc(db, "web_banners", id));
      toast.success("Banner deleted.");
      fetchBanners();
    } catch (error) {
      console.error("Error deleting banner:", error);
      toast.error("Failed to delete banner.");
    }
  };

  const openModal = (banner?: Banner) => {
    if (banner) {
      setCurrentBanner(banner);
    } else {
      setCurrentBanner({
        title: "",
        imageUrl: "",
        link: "",
        isActive: true,
        order: banners.length
      });
    }
    setIsModalOpen(true);
  };

  if (isLoading) {
    return (
      <div className="flex h-64 items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-amber-500" />
      </div>
    );
  }

  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-1000 ease-out max-w-5xl pb-20">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-[#2A2A42] pb-6">
        <div>
          <h1 className="text-2xl font-black text-white">Web Banners</h1>
          <p className="text-gray-400 mt-1">Manage promotional banners on your website.</p>
        </div>
        <button 
          onClick={() => openModal()}
          className="flex items-center gap-2 bg-amber-500 hover:bg-amber-600 text-white px-6 py-2.5 rounded-lg font-bold transition-colors shadow-sm"
        >
          <Plus className="w-4 h-4" />
          <span>Add Banner</span>
        </button>
      </div>

      {banners.length === 0 ? (
        <div className="text-center py-20 bg-[#1C1C2E] border border-[#2A2A42] rounded-2xl">
          <ImageIcon className="w-12 h-12 text-gray-500 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-white">No banners yet</h3>
          <p className="text-gray-400 mt-1">Click the button above to add your first web banner.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {banners.map(banner => (
            <div key={banner.id} className="bg-[#1C1C2E] border border-[#2A2A42] rounded-2xl overflow-hidden group">
              <div className="h-48 relative bg-[#14142B] flex items-center justify-center">
                {banner.imageUrl ? (
                  <img 
                    src={banner.imageUrl} 
                    alt={banner.title} 
                    className="absolute inset-0 w-full h-full object-cover" 
                    onError={(e) => {
                      // Hide the broken image and let the fallback icon below it show
                      e.currentTarget.style.display = 'none';
                    }}
                  />
                ) : null}
                
                {/* Fallback icon behind the image in case it fails or is empty */}
                <div className="text-gray-600 flex flex-col items-center">
                  <ImageIcon className="w-8 h-8 mb-2" />
                  <span className="text-xs">No Image</span>
                </div>

                <div className="absolute top-4 right-4 flex gap-2 z-10">
                  <button 
                    onClick={() => openModal(banner)}
                    className="p-2 bg-black/50 hover:bg-amber-500 text-white rounded-lg backdrop-blur-sm transition-colors"
                  >
                    <Edit2 className="w-4 h-4" />
                  </button>
                  <button 
                    onClick={() => handleDelete(banner.id)}
                    className="p-2 bg-black/50 hover:bg-red-500 text-white rounded-lg backdrop-blur-sm transition-colors"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
                {!banner.isActive && (
                  <div className="absolute top-4 left-4 px-3 py-1 bg-red-500/90 text-white text-xs font-bold rounded-lg backdrop-blur-sm">
                    Inactive
                  </div>
                )}
              </div>
              <div className="p-5">
                <h3 className="font-bold text-white text-lg">{banner.title}</h3>
                <p className="text-gray-400 text-sm mt-1 truncate">Link: {banner.link || "None"}</p>
                <div className="mt-4 flex items-center text-xs font-semibold text-gray-500">
                  <span className="bg-[#2A2A42] px-2 py-1 rounded">Order: {banner.order}</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Add/Edit Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
          <div className="bg-[#1C1C2E] border border-[#2A2A42] rounded-2xl w-full max-w-lg overflow-hidden shadow-2xl animate-in zoom-in-95 duration-200">
            <div className="px-6 py-4 border-b border-[#2A2A42] flex justify-between items-center bg-[#14142B]/50">
              <h2 className="text-lg font-bold text-white">
                {currentBanner.id ? "Edit Banner" : "Add New Banner"}
              </h2>
              <button onClick={() => setIsModalOpen(false)} className="text-gray-400 hover:text-white">
                <X className="w-5 h-5" />
              </button>
            </div>
            
            <div className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-semibold text-gray-300 mb-1">Banner Title</label>
                <input 
                  type="text" 
                  value={currentBanner.title}
                  onChange={(e) => setCurrentBanner({...currentBanner, title: e.target.value})}
                  className="w-full bg-[#14142B] border border-[#2A2A42] text-white rounded-lg px-4 py-2 text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none" 
                />
              </div>
              
              <div>
                <label className="block text-sm font-semibold text-gray-300 mb-1">Image URL</label>
                <input 
                  type="text" 
                  value={currentBanner.imageUrl}
                  onChange={(e) => setCurrentBanner({...currentBanner, imageUrl: e.target.value})}
                  placeholder="https://example.com/image.jpg"
                  className="w-full bg-[#14142B] border border-[#2A2A42] text-white rounded-lg px-4 py-2 text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none" 
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-300 mb-1">Target Link (Optional)</label>
                <input 
                  type="text" 
                  value={currentBanner.link}
                  onChange={(e) => setCurrentBanner({...currentBanner, link: e.target.value})}
                  placeholder="/shop or https://..."
                  className="w-full bg-[#14142B] border border-[#2A2A42] text-white rounded-lg px-4 py-2 text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none" 
                />
              </div>

              <div className="flex gap-4">
                <div className="flex-1">
                  <label className="block text-sm font-semibold text-gray-300 mb-1">Display Order</label>
                  <input 
                    type="number" 
                    value={currentBanner.order}
                    onChange={(e) => setCurrentBanner({...currentBanner, order: parseInt(e.target.value) || 0})}
                    className="w-full bg-[#14142B] border border-[#2A2A42] text-white rounded-lg px-4 py-2 text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none" 
                  />
                </div>
                
                <div className="flex-1 flex items-center pt-6">
                  <label className="flex items-center gap-2 cursor-pointer">
                    <input 
                      type="checkbox"
                      checked={currentBanner.isActive}
                      onChange={(e) => setCurrentBanner({...currentBanner, isActive: e.target.checked})}
                      className="w-4 h-4 rounded text-amber-500 bg-[#14142B] border-[#2A2A42] focus:ring-amber-500/20"
                    />
                    <span className="text-sm font-semibold text-gray-300">Is Active</span>
                  </label>
                </div>
              </div>
            </div>

            <div className="px-6 py-4 border-t border-[#2A2A42] flex justify-end gap-3 bg-[#14142B]/50">
              <button 
                onClick={() => setIsModalOpen(false)}
                className="px-4 py-2 rounded-lg text-sm font-bold text-gray-400 hover:text-white transition-colors"
              >
                Cancel
              </button>
              <button 
                onClick={handleSave}
                disabled={isSaving}
                className="flex items-center gap-2 bg-amber-500 hover:bg-amber-600 disabled:opacity-50 text-white px-6 py-2 rounded-lg text-sm font-bold transition-colors shadow-sm"
              >
                {isSaving ? <Loader2 className="w-4 h-4 animate-spin" /> : null}
                <span>Save Banner</span>
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
