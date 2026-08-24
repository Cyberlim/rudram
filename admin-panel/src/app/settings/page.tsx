"use client";
import { Save } from 'lucide-react';
import { useState, useEffect } from 'react';
import { doc, getDoc, setDoc } from 'firebase/firestore';
import { db } from '@/lib/firebase';

export default function settingsPage() {
  const [whatsapp, setWhatsapp] = useState('');
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    async function fetchSettings() {
      const docRef = doc(db, 'settings', 'support');
      const docSnap = await getDoc(docRef);
      if (docSnap.exists()) {
        setWhatsapp(docSnap.data().whatsapp || '');
        setEmail(docSnap.data().email || '');
      }
    }
    fetchSettings();
  }, []);

  const handleSave = async () => {
    setLoading(true);
    try {
      await setDoc(doc(db, 'settings', 'support'), {
        whatsapp,
        email
      }, { merge: true });
      alert('Settings saved successfully!');
    } catch (e) {
      console.error(e);
      alert('Error saving settings.');
    } finally {
      setLoading(false);
    }
  };
  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-1000 ease-out max-w-4xl pb-20">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-gray-200 dark:border-[#2A2A42] pb-6">
        <div>
          <h1 className="text-2xl font-black text-gray-900 dark:text-gray-100">General Settings</h1>
          <p className="text-gray-500 mt-1">Configure global parameters and preferences.</p>
        </div>
        <button 
          onClick={handleSave} 
          disabled={loading}
          className="flex items-center gap-2 bg-amber-600 hover:bg-amber-700 disabled:opacity-50 text-white px-6 py-2.5 rounded-lg font-bold transition-colors shadow-sm"
        >
          <Save className="w-4 h-4" />
          <span>{loading ? 'Saving...' : 'Save Changes'}</span>
        </button>
      </div>

      <div className="space-y-8">
        
        <section className="bg-white dark:bg-[#14142B] rounded-2xl shadow-sm border border-gray-100 dark:border-[#2A2A42] overflow-hidden">
          <div className="px-6 py-4 border-b border-gray-100 dark:border-[#2A2A42] bg-gray-50 dark:bg-[#0B0B1A]/50">
            <h2 className="text-lg font-bold text-gray-900 dark:text-gray-100">Support Contact Details</h2>
            <p className="text-xs text-gray-500 mt-0.5">Update the WhatsApp number and Email for the Help & Support page.</p>
          </div>
          <div className="p-6 space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">WhatsApp Number (with country code)</label>
                <input 
                  type="text" 
                  value={whatsapp} 
                  onChange={(e) => setWhatsapp(e.target.value)} 
                  placeholder="e.g. +919876543210" 
                  className="w-full bg-gray-50 dark:bg-[#0B0B1A] border border-gray-200 dark:border-[#2A2A42] rounded-lg px-4 py-2.5 text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none transition-all" 
                />
              </div>
              <div>
                <label className="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">Support Email</label>
                <input 
                  type="email" 
                  value={email} 
                  onChange={(e) => setEmail(e.target.value)} 
                  placeholder="e.g. support@rudram.com" 
                  className="w-full bg-gray-50 dark:bg-[#0B0B1A] border border-gray-200 dark:border-[#2A2A42] rounded-lg px-4 py-2.5 text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none transition-all" 
                />
              </div>
            </div>
          </div>
        </section>

        <section className="bg-white dark:bg-[#14142B] rounded-2xl shadow-sm border border-gray-100 dark:border-[#2A2A42] overflow-hidden">
          <div className="px-6 py-4 border-b border-gray-100 dark:border-[#2A2A42] bg-gray-50 dark:bg-[#0B0B1A]/50">
            <h2 className="text-lg font-bold text-gray-900 dark:text-gray-100">Currency & Locale</h2>
            <p className="text-xs text-gray-500 mt-0.5">Update your currency & locale here.</p>
          </div>
          <div className="p-6 space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">Setting Option 1</label>
                <input type="text" defaultValue="Default Value" className="w-full bg-gray-50 dark:bg-[#0B0B1A] border border-gray-200 dark:border-[#2A2A42] rounded-lg px-4 py-2.5 text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none transition-all" />
              </div>
              <div>
                <label className="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">Setting Option 2</label>
                <select className="w-full bg-gray-50 dark:bg-[#0B0B1A] border border-gray-200 dark:border-[#2A2A42] rounded-lg px-4 py-2.5 text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none transition-all cursor-pointer">
                  <option>Enabled</option>
                  <option>Disabled</option>
                </select>
              </div>
            </div>
            
            <div className="flex items-center justify-between py-3 border-t border-gray-100 dark:border-[#2A2A42] pt-6">
              <div>
                <h4 className="font-semibold text-gray-900 dark:text-gray-100 text-sm">Enable advanced features</h4>
                <p className="text-xs text-gray-500 mt-1">Turn on to enable experimental features for this section.</p>
              </div>
              <div className="relative inline-block w-12 h-6 cursor-pointer rounded-full bg-amber-500 shadow-inner">
                <span className="absolute left-7 top-1 w-4 h-4 bg-white dark:bg-[#14142B] rounded-full transition-all shadow-sm"></span>
              </div>
            </div>
          </div>
        </section>

        <section className="bg-white dark:bg-[#14142B] rounded-2xl shadow-sm border border-gray-100 dark:border-[#2A2A42] overflow-hidden">
          <div className="px-6 py-4 border-b border-gray-100 dark:border-[#2A2A42] bg-gray-50 dark:bg-[#0B0B1A]/50">
            <h2 className="text-lg font-bold text-gray-900 dark:text-gray-100">Notifications</h2>
            <p className="text-xs text-gray-500 mt-0.5">Update your notifications here.</p>
          </div>
          <div className="p-6 space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">Setting Option 1</label>
                <input type="text" defaultValue="Default Value" className="w-full bg-gray-50 dark:bg-[#0B0B1A] border border-gray-200 dark:border-[#2A2A42] rounded-lg px-4 py-2.5 text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none transition-all" />
              </div>
              <div>
                <label className="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">Setting Option 2</label>
                <select className="w-full bg-gray-50 dark:bg-[#0B0B1A] border border-gray-200 dark:border-[#2A2A42] rounded-lg px-4 py-2.5 text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none transition-all cursor-pointer">
                  <option>Enabled</option>
                  <option>Disabled</option>
                </select>
              </div>
            </div>
            
            <div className="flex items-center justify-between py-3 border-t border-gray-100 dark:border-[#2A2A42] pt-6">
              <div>
                <h4 className="font-semibold text-gray-900 dark:text-gray-100 text-sm">Enable advanced features</h4>
                <p className="text-xs text-gray-500 mt-1">Turn on to enable experimental features for this section.</p>
              </div>
              <div className="relative inline-block w-12 h-6 cursor-pointer rounded-full bg-amber-500 shadow-inner">
                <span className="absolute left-7 top-1 w-4 h-4 bg-white dark:bg-[#14142B] rounded-full transition-all shadow-sm"></span>
              </div>
            </div>
          </div>
        </section>
      </div>
    </div>
  );
}