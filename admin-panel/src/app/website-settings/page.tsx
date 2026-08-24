"use client";
import { useState, useEffect } from "react";
import { doc, getDoc, setDoc } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { Save, Loader2, Settings, Palette, Image as ImageIcon } from "lucide-react";
import toast from "react-hot-toast";

export default function WebsiteSettingsPage() {
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [settings, setSettings] = useState({
    primaryColor: "#C69C6D",
    fontFamily: "Inter",
    enableAdvancedFeatures: false,
    maintenanceMode: false,
    logoUrl: "",
    faviconUrl: "",
  });

  useEffect(() => {
    fetchSettings();
  }, []);

  const fetchSettings = async () => {
    try {
      const docRef = doc(db, "web_settings", "general");
      const docSnap = await getDoc(docRef);
      if (docSnap.exists()) {
        setSettings({ ...settings, ...docSnap.data() });
      }
    } catch (error) {
      console.error("Error fetching website settings:", error);
      toast.error("Failed to load settings.");
    } finally {
      setIsLoading(false);
    }
  };

  const handleSave = async () => {
    setIsSaving(true);
    try {
      await setDoc(doc(db, "web_settings", "general"), settings, { merge: true });
      toast.success("Website settings updated successfully!");
    } catch (error) {
      console.error("Error saving website settings:", error);
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
          <h1 className="text-2xl font-black text-white">Website Settings</h1>
          <p className="text-gray-400 mt-1">Configure global parameters and preferences.</p>
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
        
        {/* Theme Settings */}
        <section className="bg-[#1C1C2E] rounded-2xl border border-[#2A2A42] overflow-hidden">
          <div className="px-6 py-4 border-b border-[#2A2A42] bg-[#14142B]/50 flex items-center gap-3">
            <Palette className="w-5 h-5 text-amber-500" />
            <div>
              <h2 className="text-lg font-bold text-white">Theme & Typography</h2>
              <p className="text-xs text-gray-400 mt-0.5">Update the visual identity of your store.</p>
            </div>
          </div>
          <div className="p-6 space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-semibold text-gray-300 mb-2">Primary Theme Color (HEX)</label>
                <div className="flex gap-3">
                  <div 
                    className="w-10 h-10 rounded-lg border border-[#2A2A42]" 
                    style={{ backgroundColor: settings.primaryColor }}
                  />
                  <input 
                    type="text" 
                    value={settings.primaryColor}
                    onChange={(e) => setSettings({...settings, primaryColor: e.target.value})}
                    className="flex-1 bg-[#14142B] border border-[#2A2A42] text-white rounded-lg px-4 py-2.5 text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none transition-all" 
                  />
                </div>
              </div>
              <div>
                <label className="block text-sm font-semibold text-gray-300 mb-2">Primary Font Family</label>
                <select 
                  value={settings.fontFamily}
                  onChange={(e) => setSettings({...settings, fontFamily: e.target.value})}
                  className="w-full bg-[#14142B] border border-[#2A2A42] text-white rounded-lg px-4 py-2.5 text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none transition-all cursor-pointer"
                >
                  <option value="Inter">Inter (Modern Sans)</option>
                  <option value="Cormorant Garamond">Cormorant Garamond (Elegant Serif)</option>
                  <option value="Roboto">Roboto</option>
                  <option value="Playfair Display">Playfair Display (Luxury Serif)</option>
                </select>
              </div>
            </div>
          </div>
        </section>

        {/* Media */}
        <section className="bg-[#1C1C2E] rounded-2xl border border-[#2A2A42] overflow-hidden">
          <div className="px-6 py-4 border-b border-[#2A2A42] bg-[#14142B]/50 flex items-center gap-3">
            <ImageIcon className="w-5 h-5 text-amber-500" />
            <div>
              <h2 className="text-lg font-bold text-white">Logo & Favicon</h2>
              <p className="text-xs text-gray-400 mt-0.5">Brand images used across the site.</p>
            </div>
          </div>
          <div className="p-6 space-y-6">
            <div>
              <label className="block text-sm font-semibold text-gray-300 mb-2">Logo URL (Transparent PNG recommended)</label>
              <input 
                type="text" 
                value={settings.logoUrl}
                onChange={(e) => setSettings({...settings, logoUrl: e.target.value})}
                placeholder="https://..."
                className="w-full bg-[#14142B] border border-[#2A2A42] text-white rounded-lg px-4 py-2.5 text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none transition-all" 
              />
            </div>
            <div>
              <label className="block text-sm font-semibold text-gray-300 mb-2">Favicon URL (Square format)</label>
              <input 
                type="text" 
                value={settings.faviconUrl}
                onChange={(e) => setSettings({...settings, faviconUrl: e.target.value})}
                placeholder="https://..."
                className="w-full bg-[#14142B] border border-[#2A2A42] text-white rounded-lg px-4 py-2.5 text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none transition-all" 
              />
            </div>
          </div>
        </section>

        {/* Global Toggles */}
        <section className="bg-[#1C1C2E] rounded-2xl border border-[#2A2A42] overflow-hidden">
          <div className="px-6 py-4 border-b border-[#2A2A42] bg-[#14142B]/50 flex items-center gap-3">
            <Settings className="w-5 h-5 text-amber-500" />
            <div>
              <h2 className="text-lg font-bold text-white">System Controls</h2>
              <p className="text-xs text-gray-400 mt-0.5">Toggle global website behaviors.</p>
            </div>
          </div>
          <div className="p-6 space-y-6">
            
            <div className="flex items-center justify-between pb-4 border-b border-[#2A2A42]">
              <div>
                <h4 className="font-semibold text-white text-sm">Enable advanced features</h4>
                <p className="text-xs text-gray-400 mt-1">Turn on to test beta features on the frontend.</p>
              </div>
              <div 
                onClick={() => setSettings({...settings, enableAdvancedFeatures: !settings.enableAdvancedFeatures})}
                className={`relative inline-block w-12 h-6 cursor-pointer rounded-full transition-colors duration-300 ${settings.enableAdvancedFeatures ? 'bg-amber-500' : 'bg-[#2A2A42]'}`}
              >
                <span className={`absolute top-1 w-4 h-4 bg-white dark:bg-[#14142B] rounded-full transition-all duration-300 ${settings.enableAdvancedFeatures ? 'left-7' : 'left-1'}`}></span>
              </div>
            </div>

            <div className="flex items-center justify-between pt-2">
              <div>
                <h4 className="font-semibold text-red-400 text-sm">Maintenance Mode</h4>
                <p className="text-xs text-gray-400 mt-1">If active, customers will see a "Under Maintenance" screen.</p>
              </div>
              <div 
                onClick={() => setSettings({...settings, maintenanceMode: !settings.maintenanceMode})}
                className={`relative inline-block w-12 h-6 cursor-pointer rounded-full transition-colors duration-300 ${settings.maintenanceMode ? 'bg-red-500' : 'bg-[#2A2A42]'}`}
              >
                <span className={`absolute top-1 w-4 h-4 bg-white dark:bg-[#14142B] rounded-full transition-all duration-300 ${settings.maintenanceMode ? 'left-7' : 'left-1'}`}></span>
              </div>
            </div>

          </div>
        </section>

      </div>
    </div>
  );
}