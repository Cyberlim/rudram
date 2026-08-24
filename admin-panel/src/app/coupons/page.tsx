"use client";
import { Search, Plus, Trash2, Edit2, Copy, Check } from "lucide-react";
import { useState, useEffect } from "react";
import { db } from "@/lib/firebase";
import {
  collection, query, orderBy, onSnapshot, doc, setDoc,
  deleteDoc, updateDoc, serverTimestamp,
} from "firebase/firestore";
import Fuse from "fuse.js";

interface Coupon {
  id: string;
  code: string;
  discountType: "percent" | "flat";
  discountValue: number;
  minOrder?: number;
  maxUses?: number;
  usedCount?: number;
  expiry?: string;
  status: "Active" | "Inactive";
  createdAt?: any;
}

export default function CouponsPage() {
  const [coupons, setCoupons] = useState<Coupon[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [copied, setCopied] = useState<string | null>(null);
  const [form, setForm] = useState({
    code: "",
    discountType: "percent" as "percent" | "flat",
    discountValue: "",
    minOrder: "",
    maxUses: "",
    expiry: "",
    status: "Active" as "Active" | "Inactive",
  });

  useEffect(() => {
    const q = query(collection(db, "coupons"), orderBy("createdAt", "desc"));
    const unsub = onSnapshot(q, (snap) => {
      setCoupons(snap.docs.map((d) => ({ id: d.id, ...d.data() })) as Coupon[]);
      setLoading(false);
    }, () => setLoading(false));
    return () => unsub();
  }, []);

  const handleAdd = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const ref = doc(collection(db, "coupons"));
      await setDoc(ref, {
        code: form.code.toUpperCase().trim(),
        discountType: form.discountType,
        discountValue: Number(form.discountValue),
        minOrder: form.minOrder ? Number(form.minOrder) : null,
        maxUses: form.maxUses ? Number(form.maxUses) : null,
        usedCount: 0,
        expiry: form.expiry || null,
        status: form.status,
        createdAt: serverTimestamp(),
      });
      setIsModalOpen(false);
      setForm({ code: "", discountType: "percent", discountValue: "", minOrder: "", maxUses: "", expiry: "", status: "Active" });
    } catch {
      alert("Failed to add coupon");
    }
  };

  const handleDelete = async (id: string) => {
    if (confirm("Delete this coupon?")) await deleteDoc(doc(db, "coupons", id));
  };

  const toggleStatus = async (id: string, current: string) => {
    await updateDoc(doc(db, "coupons", id), { status: current === "Active" ? "Inactive" : "Active" });
  };

  const copyCode = (code: string) => {
    navigator.clipboard.writeText(code);
    setCopied(code);
    setTimeout(() => setCopied(null), 2000);
  };

  const fuse = new Fuse(coupons, {
    keys: ["code"],
    threshold: 0.3,
  });

  const filtered = search ? fuse.search(search).map(r => r.item) : coupons;

  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-1000 ease-out pb-10">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black text-gray-900 dark:text-gray-100">Coupons</h1>
          <p className="text-gray-500 mt-1">{loading ? "Loading..." : `${coupons.length} coupons`}</p>
        </div>
        <button
          onClick={() => setIsModalOpen(true)}
          className="flex items-center gap-2 bg-amber-600 hover:bg-amber-700 text-white px-4 py-2 rounded-lg font-medium transition-colors shadow-sm"
        >
          <Plus className="w-4 h-4" />
          Add Coupon
        </button>
      </div>

      <div className="bg-white dark:bg-[#14142B] rounded-2xl shadow-sm border border-gray-100 dark:border-[#2A2A42] overflow-hidden">
        <div className="p-4 border-b border-gray-100 dark:border-[#2A2A42] bg-gray-50 dark:bg-[#0B0B1A]/50">
          <div className="relative w-full md:w-80">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input
              type="text" placeholder="Search coupons..."
              value={search} onChange={(e) => setSearch(e.target.value)}
              className="w-full pl-10 pr-4 py-2 bg-white dark:bg-[#14142B] border border-gray-200 dark:border-[#2A2A42] rounded-lg text-sm focus:ring-amber-500 focus:border-amber-500 outline-none"
            />
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm whitespace-nowrap">
            <thead className="bg-gray-50 dark:bg-[#0B0B1A]/50">
              <tr className="text-gray-500 font-semibold border-b border-gray-100 dark:border-[#2A2A42]">
                <th className="py-4 px-6">Code</th>
                <th className="py-4 px-6">Discount</th>
                <th className="py-4 px-6">Min. Order</th>
                <th className="py-4 px-6">Used / Max</th>
                <th className="py-4 px-6">Expiry</th>
                <th className="py-4 px-6">Status</th>
                <th className="py-4 px-6 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {loading ? (
                <tr><td colSpan={7} className="py-10 text-center text-gray-400">Loading...</td></tr>
              ) : filtered.length === 0 ? (
                <tr><td colSpan={7} className="py-10 text-center text-gray-400">No coupons found. Click "Add Coupon" to create one.</td></tr>
              ) : (
                filtered.map((c) => (
                  <tr key={c.id} className="hover:bg-gray-50 dark:bg-[#0B0B1A]/50 transition-colors">
                    <td className="py-4 px-6">
                      <div className="flex items-center gap-2">
                        <span className="font-mono font-bold text-gray-900 dark:text-gray-100 bg-amber-50 text-amber-700 px-2 py-0.5 rounded text-xs tracking-widest">
                          {c.code}
                        </span>
                        <button onClick={() => copyCode(c.code)} className="text-gray-400 hover:text-amber-600 transition-colors">
                          {copied === c.code ? <Check className="w-3.5 h-3.5 text-green-500" /> : <Copy className="w-3.5 h-3.5" />}
                        </button>
                      </div>
                    </td>
                    <td className="py-4 px-6 font-semibold text-gray-900 dark:text-gray-100">
                      {c.discountType === "percent" ? `${c.discountValue}%` : `₹${c.discountValue}`} off
                    </td>
                    <td className="py-4 px-6 text-gray-600">{c.minOrder ? `₹${c.minOrder}` : "—"}</td>
                    <td className="py-4 px-6 text-gray-600">{c.usedCount ?? 0} / {c.maxUses ?? "∞"}</td>
                    <td className="py-4 px-6 text-gray-600">{c.expiry || "No expiry"}</td>
                    <td className="py-4 px-6">
                      <button
                        onClick={() => toggleStatus(c.id, c.status)}
                        className={`px-2.5 py-1 rounded-full text-xs font-semibold ${c.status === "Active" ? "bg-emerald-100 text-emerald-700" : "bg-gray-100 text-gray-600"}`}
                      >
                        {c.status}
                      </button>
                    </td>
                    <td className="py-4 px-6 text-right">
                      <button onClick={() => handleDelete(c.id)} className="text-red-400 hover:text-red-600 p-1 rounded hover:bg-red-50 transition-colors">
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

      {/* Add Coupon Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white dark:bg-[#14142B] rounded-2xl w-full max-w-md p-6 shadow-xl">
            <h2 className="text-xl font-bold mb-4">Add Coupon</h2>
            <form onSubmit={handleAdd} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Coupon Code</label>
                <input type="text" required value={form.code}
                  onChange={(e) => setForm({ ...form, code: e.target.value.toUpperCase() })}
                  placeholder="E.g. SAVE20"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg font-mono uppercase text-sm focus:ring-amber-500 focus:border-amber-500"
                />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Discount Type</label>
                  <select value={form.discountType} onChange={(e) => setForm({ ...form, discountType: e.target.value as any })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-amber-500 focus:border-amber-500">
                    <option value="percent">Percentage (%)</option>
                    <option value="flat">Flat (₹)</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                    {form.discountType === "percent" ? "Discount %" : "Discount ₹"}
                  </label>
                  <input type="number" required value={form.discountValue}
                    onChange={(e) => setForm({ ...form, discountValue: e.target.value })}
                    placeholder={form.discountType === "percent" ? "20" : "500"}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-amber-500 focus:border-amber-500"
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Min. Order (₹)</label>
                  <input type="number" value={form.minOrder}
                    onChange={(e) => setForm({ ...form, minOrder: e.target.value })}
                    placeholder="Optional"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-amber-500 focus:border-amber-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Max Uses</label>
                  <input type="number" value={form.maxUses}
                    onChange={(e) => setForm({ ...form, maxUses: e.target.value })}
                    placeholder="Unlimited"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-amber-500 focus:border-amber-500"
                  />
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Expiry Date</label>
                <input type="date" value={form.expiry}
                  onChange={(e) => setForm({ ...form, expiry: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-amber-500 focus:border-amber-500"
                />
              </div>
              <div className="flex justify-end gap-3 pt-4 border-t border-gray-100 dark:border-[#2A2A42]">
                <button type="button" onClick={() => setIsModalOpen(false)}
                  className="px-4 py-2 bg-gray-100 text-gray-700 dark:text-gray-300 hover:bg-gray-200 rounded-lg font-medium transition-colors">
                  Cancel
                </button>
                <button type="submit"
                  className="px-4 py-2 bg-amber-600 hover:bg-amber-700 text-white rounded-lg font-medium transition-colors">
                  Save Coupon
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}