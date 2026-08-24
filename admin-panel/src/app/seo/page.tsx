"use client";
import { useState, useEffect } from "react";
import { doc, getDoc, setDoc } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { Save, Loader2, Globe } from "lucide-react";
import toast from "react-hot-toast";

export default function SeoSettingsPage() {
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [seo, setSeo] = useState({
    metaTitle: "",
    metaDescription: "",
    keywords: "",
    ogImage: "",
  });

  useEffect(() => {
    fetchSeo();
  }, []);

  const fetchSeo = async () => {
    try {
      const docRef = doc(db, "web_settings", "seo");
      const docSnap = await getDoc(docRef);
      if (docSnap.exists()) {
        setSeo({ ...seo, ...docSnap.data() });
      }
    } catch (error) {
      console.error("Error fetching SEO settings:", error);
      toast.error("Failed to load SEO settings.");
    } finally {
      setIsLoading(false);
    }
  };

  const handleSave = async () => {
    setIsSaving(true);
    try {
      await setDoc(doc(db, "web_settings", "seo"), seo, { merge: true });
      toast.success("SEO settings updated successfully!");
    } catch (error) {
      console.error("Error saving SEO settings:", error);
      toast.error("Failed to save changes.");
    } finally {
      setIsSaving(false);
    }
  };

  if (isLoading) {
    return (
      <div className="flex h-64 items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-amber-500" />
      </div>
    );
  }

  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-1000 ease-out max-w-4xl pb-20">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-[#2A2A42] pb-6">
        <div>
          <h1 className="text-2xl font-black text-white">SEO Settings</h1>
          <p className="text-gray-400 mt-1">Manage meta tags to improve your search engine rankings.</p>
        </div>
        <button 
          onClick={handleSave}
          disabled={isSaving}
          className="flex items-center gap-2 bg-amber-500 hover:bg-amber-600 disabled:opacity-50 text-white px-6 py-2.5 rounded-lg font-bold transition-colors shadow-sm"
        >
          {isSaving ? <Loader2 className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />}
          <span>{isSaving ? "Saving..." : "Save Changes"}</span>
        </button>
      </div>

      <div className="space-y-8">
        <section className="bg-[#1C1C2E] rounded-2xl border border-[#2A2A42] overflow-hidden">
          <div className="px-6 py-4 border-b border-[#2A2A42] bg-[#14142B]/50 flex items-center gap-3">
            <Globe className="w-5 h-5 text-amber-500" />
            <div>
              <h2 className="text-lg font-bold text-white">Global Meta Tags</h2>
              <p className="text-xs text-gray-400 mt-0.5">These will be used as default for pages that don't have specific tags.</p>
            </div>
          </div>
          <div className="p-6 space-y-6">
            <div>
              <label className="block text-sm font-semibold text-gray-300 mb-2">Meta Title</label>
              <input 
                type="text" 
                value={seo.metaTitle}
                onChange={(e) => setSeo({...seo, metaTitle: e.target.value})}
                placeholder="E.g., JewelCraft | Timeless Luxury Jewelry"
                className="w-full bg-[#14142B] border border-[#2A2A42] text-white rounded-lg px-4 py-2.5 text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none transition-all" 
              />
              <p className="text-xs text-gray-500 mt-1">Recommended length: 50-60 characters.</p>
            </div>

            <div>
              <label className="block text-sm font-semibold text-gray-300 mb-2">Meta Description</label>
              <textarea 
                rows={3}
                value={seo.metaDescription}
                onChange={(e) => setSeo({...seo, metaDescription: e.target.value})}
                placeholder="E.g., Discover our exclusive collection of hallmarked diamond and gold jewelry..."
                className="w-full bg-[#14142B] border border-[#2A2A42] text-white rounded-lg px-4 py-2.5 text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none transition-all" 
              />
              <p className="text-xs text-gray-500 mt-1">Recommended length: 150-160 characters.</p>
            </div>

            <div>
              <label className="block text-sm font-semibold text-gray-300 mb-2">Keywords (Comma separated)</label>
              <input 
                type="text" 
                value={seo.keywords}
                onChange={(e) => setSeo({...seo, keywords: e.target.value})}
                placeholder="jewelry, diamond, gold, luxury, shop online"
                className="w-full bg-[#14142B] border border-[#2A2A42] text-white rounded-lg px-4 py-2.5 text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none transition-all" 
              />
            </div>
          </div>
        </section>

        <section className="bg-[#1C1C2E] rounded-2xl border border-[#2A2A42] overflow-hidden">
          <div className="px-6 py-4 border-b border-[#2A2A42] bg-[#14142B]/50">
            <h2 className="text-lg font-bold text-white">Social Sharing (Open Graph)</h2>
            <p className="text-xs text-gray-400 mt-0.5">How your website looks when shared on WhatsApp, Facebook, or Twitter.</p>
          </div>
          <div className="p-6">
            <label className="block text-sm font-semibold text-gray-300 mb-2">Open Graph Image URL</label>
            <input 
              type="text" 
              value={seo.ogImage}
              onChange={(e) => setSeo({...seo, ogImage: e.target.value})}
              placeholder="https://yourwebsite.com/og-image.jpg"
              className="w-full bg-[#14142B] border border-[#2A2A42] text-white rounded-lg px-4 py-2.5 text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none transition-all" 
            />
            {seo.ogImage && (
              <div className="mt-4 p-4 bg-[#14142B] border border-[#2A2A42] rounded-lg inline-block">
                <img src={seo.ogImage} alt="OG Preview" className="max-w-xs h-32 object-cover rounded shadow-md" onError={(e) => (e.currentTarget.style.display = 'none')} />
                <p className="text-xs text-gray-500 mt-2">Preview Image</p>
              </div>
            )}
          </div>
        </section>

      </div>
    </div>
  );
}
