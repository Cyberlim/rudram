"use client";
import { Search, Plus, Trash2, FolderHeart, Download } from "lucide-react";
import { useState, useEffect } from "react";
import { db } from "@/lib/firebase";
import { collection, query, orderBy, onSnapshot, doc, setDoc, deleteDoc, updateDoc, serverTimestamp } from "firebase/firestore";
import Fuse from "fuse.js";

interface CollectionData {
  id: string;
  name: string;
  description?: string;
  status: string;
  productCount?: number;
  createdAt?: any;
}

export default function CollectionsPage() {
  const [collectionsList, setCollectionsList] = useState<CollectionData[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [form, setForm] = useState({ name: "", description: "", status: "Active" });

  useEffect(() => {
    const q = query(collection(db, "collections"), orderBy("createdAt", "desc"));
    const unsub = onSnapshot(q, (snap) => {
      setCollectionsList(snap.docs.map((d) => ({ id: d.id, ...d.data() })) as CollectionData[]);
      setLoading(false);
    }, () => setLoading(false));
    return () => unsub();
  }, []);

  const handleAdd = async (e: React.FormEvent) => {
    e.preventDefault();
    const ref = doc(collection(db, "collections"));
    await setDoc(ref, {
      name: form.name,
      description: form.description,
      status: form.status,
      productCount: 0,
      createdAt: serverTimestamp(),
    });
    setIsModalOpen(false);
    setForm({ name: "", description: "", status: "Active" });
  };

  const handleDelete = async (id: string) => {
    if (confirm("Delete this collection?")) await deleteDoc(doc(db, "collections", id));
  };

  const toggleStatus = async (id: string, current: string) => {
    await updateDoc(doc(db, "collections", id), { status: current === "Active" ? "Inactive" : "Active" });
  };

  const fuse = new Fuse(collectionsList, {
    keys: ["name", "description"],
    threshold: 0.3,
  });

  const filtered = search ? fuse.search(search).map(r => r.item) : collectionsList;

  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-1000 ease-out pb-10">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black text-gray-900 dark:text-gray-100">Collections</h1>
          <p className="text-gray-500 mt-1">{loading ? "Loading..." : `${collectionsList.length} collections`}</p>
        </div>
        <div className="flex items-center gap-3">
          <button className="flex items-center gap-2 bg-white dark:bg-[#14142B] border border-gray-200 dark:border-[#2A2A42] hover:bg-gray-50 dark:bg-[#0B0B1A] text-gray-700 dark:text-gray-300 px-4 py-2 rounded-lg font-medium transition-colors">
            <Download className="w-4 h-4" />
            <span>Export</span>
          </button>
          <button onClick={() => setIsModalOpen(true)} className="flex items-center gap-2 bg-amber-600 hover:bg-amber-700 text-white px-4 py-2 rounded-lg font-medium transition-colors shadow-sm">
            <Plus className="w-4 h-4" />
            <span>Add Collection</span>
          </button>
        </div>
      </div>

      <div className="bg-white dark:bg-[#14142B] rounded-2xl shadow-sm border border-gray-100 dark:border-[#2A2A42] flex flex-col overflow-hidden">
        <div className="p-4 border-b border-gray-100 dark:border-[#2A2A42] flex flex-col md:flex-row md:items-center justify-between gap-4 bg-gray-50 dark:bg-[#0B0B1A]/50">
          <div className="relative w-full md:w-96">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input 
              type="text" 
              placeholder="Search collections..." 
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
                <th className="py-4 px-6">Collection Name</th>
                <th className="py-4 px-6">Products Count</th>
                <th className="py-4 px-6">Status</th>
                <th className="py-4 px-6 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {loading ? (
                <tr><td colSpan={4} className="py-10 text-center text-gray-400">Loading collections...</td></tr>
              ) : filtered.length === 0 ? (
                <tr><td colSpan={4} className="py-10 text-center text-gray-400">No collections found.</td></tr>
              ) : (
                filtered.map((item) => (
                  <tr key={item.id} className="hover:bg-gray-50 dark:bg-[#0B0B1A]/50 transition-colors group">
                    <td className="py-4 px-6">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-lg bg-pink-50 flex items-center justify-center border border-pink-100 text-pink-500">
                          <FolderHeart className="w-5 h-5" />
                        </div>
                        <div>
                          <p className="font-bold text-gray-900 dark:text-gray-100">{item.name}</p>
                          <p className="text-xs text-gray-500 font-mono">#{item.id.slice(0, 8)}</p>
                        </div>
                      </div>
                    </td>
                    <td className="py-4 px-6 font-medium text-gray-600">{item.productCount ?? 0} Products</td>
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

      {isModalOpen && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white dark:bg-[#14142B] rounded-2xl w-full max-w-md p-6 shadow-xl">
            <h2 className="text-xl font-bold mb-4">Add Collection</h2>
            <form onSubmit={handleAdd} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Collection Name</label>
                <input type="text" required value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })}
                  placeholder="E.g. Diwali Special" className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm" />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Description (Optional)</label>
                <textarea value={form.description} onChange={(e) => setForm({ ...form, description: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm resize-none" rows={3} />
              </div>
              <div className="flex justify-end gap-3 pt-4 border-t border-gray-100 dark:border-[#2A2A42]">
                <button type="button" onClick={() => setIsModalOpen(false)} className="px-4 py-2 bg-gray-100 text-gray-700 dark:text-gray-300 rounded-lg font-medium">Cancel</button>
                <button type="submit" className="px-4 py-2 bg-amber-600 hover:bg-amber-700 text-white rounded-lg font-medium">Save</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}