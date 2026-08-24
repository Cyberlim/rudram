"use client";
import { useState, useEffect } from "react";
import { doc, getDoc, setDoc } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { Save, Loader2 } from "lucide-react";
import toast from "react-hot-toast";

export default function WebContentPage() {
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [content, setContent] = useState({
    heroTitle: "",
    heroSubtitle: "",
    aboutText: "",
    contactEmail: "",
    contactPhone: "",
  });

  useEffect(() => {
    fetchContent();
  }, []);

  const fetchContent = async () => {
    try {
      const docRef = doc(db, "web_settings", "content");
      const docSnap = await getDoc(docRef);
      if (docSnap.exists()) {
        setContent({ ...content, ...docSnap.data() });
      }
    } catch (error) {
      console.error("Error fetching web content:", error);
      toast.error("Failed to load content.");
    } finally {
      setIsLoading(false);
    }
  };

  const handleSave = async () => {
    setIsSaving(true);
    try {
      await setDoc(doc(db, "web_settings", "content"), content, { merge: true });
      toast.success("Web content updated successfully!");
    } catch (error) {
      console.error("Error saving web content:", error);
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
          <h1 className="text-2xl font-black text-white">Web Content</h1>
          <p className="text-gray-400 mt-1">Manage dynamic text across the website.</p>
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
        {/* Homepage Hero */}
        <section className="bg-[#1C1C2E] rounded-2xl border border-[#2A2A42] overflow-hidden">
          <div className="px-6 py-4 border-b border-[#2A2A42] bg-[#14142B]/50">
            <h2 className="text-lg font-bold text-white">Homepage Hero</h2>
            <p className="text-xs text-gray-400 mt-0.5">The main text shown on the first section of the website.</p>
          </div>
          <div className="p-6 space-y-6">
            <div>
              <label className="block text-sm font-semibold text-gray-300 mb-2">Hero Title</label>
              <input 
                type="text" 
                value={content.heroTitle}
                onChange={(e) => setContent({...content, heroTitle: e.target.value})}
                placeholder="E.g., Timeless Beauty, Always Yours"
                className="w-full bg-[#14142B] border border-[#2A2A42] text-white rounded-lg px-4 py-2.5 text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none transition-all" 
              />
            </div>
            <div>
              <label className="block text-sm font-semibold text-gray-300 mb-2">Hero Subtitle</label>
              <textarea 
                rows={3}
                value={content.heroSubtitle}
                onChange={(e) => setContent({...content, heroSubtitle: e.target.value})}
                placeholder="E.g., Discover exquisite collections, crafted with trust..."
                className="w-full bg-[#14142B] border border-[#2A2A42] text-white rounded-lg px-4 py-2.5 text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none transition-all" 
              />
            </div>
          </div>
        </section>

        {/* About Section */}
        <section className="bg-[#1C1C2E] rounded-2xl border border-[#2A2A42] overflow-hidden">
          <div className="px-6 py-4 border-b border-[#2A2A42] bg-[#14142B]/50">
            <h2 className="text-lg font-bold text-white">About Us</h2>
            <p className="text-xs text-gray-400 mt-0.5">The short about paragraph shown on the footer or about page.</p>
          </div>
          <div className="p-6">
            <label className="block text-sm font-semibold text-gray-300 mb-2">About Text</label>
            <textarea 
              rows={4}
              value={content.aboutText}
              onChange={(e) => setContent({...content, aboutText: e.target.value})}
              placeholder="E.g., JewelCraft has been crafting the finest jewelry since 1990..."
              className="w-full bg-[#14142B] border border-[#2A2A42] text-white rounded-lg px-4 py-2.5 text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none transition-all" 
            />
          </div>
        </section>

        {/* Contact Info */}
        <section className="bg-[#1C1C2E] rounded-2xl border border-[#2A2A42] overflow-hidden">
          <div className="px-6 py-4 border-b border-[#2A2A42] bg-[#14142B]/50">
            <h2 className="text-lg font-bold text-white">Contact Information</h2>
            <p className="text-xs text-gray-400 mt-0.5">Displayed in the footer and contact page.</p>
          </div>
          <div className="p-6 grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-semibold text-gray-300 mb-2">Support Email</label>
              <input 
                type="email" 
                value={content.contactEmail}
                onChange={(e) => setContent({...content, contactEmail: e.target.value})}
                placeholder="support@jewelcraft.com"
                className="w-full bg-[#14142B] border border-[#2A2A42] text-white rounded-lg px-4 py-2.5 text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none transition-all" 
              />
            </div>
            <div>
              <label className="block text-sm font-semibold text-gray-300 mb-2">Phone Number</label>
              <input 
                type="text" 
                value={content.contactPhone}
                onChange={(e) => setContent({...content, contactPhone: e.target.value})}
                placeholder="+1 234 567 8900"
                className="w-full bg-[#14142B] border border-[#2A2A42] text-white rounded-lg px-4 py-2.5 text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none transition-all" 
              />
            </div>
          </div>
        </section>

      </div>
    </div>
  );
}
