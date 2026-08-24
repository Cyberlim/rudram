"use client";
import { Search, Download, Users, ShoppingBag, LayoutGrid, ChevronRight, Loader2 } from "lucide-react";
import { useState, useEffect } from "react";
import { db } from "@/lib/firebase";
import { collection, query, orderBy, onSnapshot, getDocs, where } from "firebase/firestore";
import Fuse from "fuse.js";
import { useRouter } from "next/navigation";

interface Customer {
  id: string;
  name: string;
  email: string;
  phone?: string;
  photoUrl?: string;
  photoURL?: string;
  createdAt?: any;
  totalOrders?: number;
  address?: string;
}

export default function CustomersPage() {
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [roomCounts, setRoomCounts] = useState<Record<string, number>>({});
  const router = useRouter();

  useEffect(() => {
    const q = query(collection(db, "users"), orderBy("createdAt", "desc"));
    const unsub = onSnapshot(q, async (snap) => {
      const users = snap.docs.map((d) => ({ id: d.id, ...d.data() })) as Customer[];
      setCustomers(users);
      setLoading(false);

      // Fetch room counts for each user
      const counts: Record<string, number> = {};
      await Promise.all(
        users.map(async (user) => {
          try {
            const roomSnap = await getDocs(
              query(collection(db, "user_rooms"), where("userId", "==", user.id))
            );
            counts[user.id] = roomSnap.size;
          } catch { counts[user.id] = 0; }
        })
      );
      setRoomCounts(counts);
    }, () => setLoading(false));
    return () => unsub();
  }, []);

  const fuse = new Fuse(customers, {
    keys: ["name", "email", "phone"],
    threshold: 0.3,
  });

  const filtered = search ? fuse.search(search).map(r => r.item) : customers;

  const formatDate = (ts: any) => {
    if (!ts?.toDate) return "—";
    return ts.toDate().toLocaleDateString("en-IN", { day: "2-digit", month: "short", year: "numeric" });
  };

  const getAvatar = (c: Customer) =>
    c.photoUrl || c.photoURL || null;

  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-1000 ease-out pb-10">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-[#2A2A42] pb-6">
        <div>
          <h1 className="text-2xl font-black text-white">Customers</h1>
          <p className="text-gray-400 mt-1">
            {loading ? "Loading..." : `${customers.length} registered customers`}
          </p>
        </div>
        <button className="flex items-center gap-2 bg-[#1C1C2E] border border-[#2A2A42] hover:border-amber-500/40 text-gray-300 px-4 py-2 rounded-lg font-medium transition-colors">
          <Download className="w-4 h-4" />
          <span>Export</span>
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-3 gap-4">
        {[
          { label: "Total Users", value: customers.length, icon: Users, color: "text-amber-400" },
          { label: "With Rooms", value: Object.values(roomCounts).filter(c => c > 0).length, icon: LayoutGrid, color: "text-purple-400" },
          { label: "Total Rooms", value: Object.values(roomCounts).reduce((a, b) => a + b, 0), icon: LayoutGrid, color: "text-blue-400" },
        ].map(stat => (
          <div key={stat.label} className="bg-[#1C1C2E] border border-[#2A2A42] rounded-xl p-4">
            <p className="text-gray-400 text-xs mb-1">{stat.label}</p>
            <p className={`text-2xl font-black ${stat.color}`}>{stat.value}</p>
          </div>
        ))}
      </div>

      {/* Table */}
      <div className="bg-[#1C1C2E] rounded-2xl border border-[#2A2A42] overflow-hidden">
        {/* Search */}
        <div className="p-4 border-b border-[#2A2A42] flex gap-4 bg-[#14142B]/50">
          <div className="relative w-full max-w-sm">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-500" />
            <input
              type="text"
              placeholder="Search by name or email..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full pl-10 pr-4 py-2 bg-[#14142B] border border-[#2A2A42] text-white rounded-lg text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none transition-all"
            />
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm whitespace-nowrap">
            <thead>
              <tr className="text-gray-500 font-semibold border-b border-[#2A2A42] bg-[#14142B]/30">
                <th className="py-4 px-6">#</th>
                <th className="py-4 px-6">Customer</th>
                <th className="py-4 px-6">Email</th>
                <th className="py-4 px-6">Phone</th>
                <th className="py-4 px-6 text-center">Rooms</th>
                <th className="py-4 px-6">Joined</th>
                <th className="py-4 px-6"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#2A2A42]/50">
              {loading ? (
                <tr><td colSpan={7} className="text-center py-16">
                  <Loader2 className="w-8 h-8 animate-spin text-amber-500 mx-auto" />
                </td></tr>
              ) : filtered.length === 0 ? (
                <tr><td colSpan={7} className="text-center py-16 text-gray-500">No customers found</td></tr>
              ) : (
                filtered.map((c, i) => (
                  <tr
                    key={c.id}
                    onClick={() => router.push(`/customers/${c.id}`)}
                    className="hover:bg-[#2A2A42]/30 transition-colors cursor-pointer group"
                  >
                    <td className="py-4 px-6 text-gray-500 text-xs font-mono">{i + 1}</td>
                    <td className="py-4 px-6">
                      <div className="flex items-center gap-3">
                        {getAvatar(c) ? (
                          <img src={getAvatar(c)!} alt={c.name} className="w-9 h-9 rounded-full object-cover border-2 border-[#2A2A42]" onError={(e) => { e.currentTarget.style.display = 'none'; }} />
                        ) : (
                          <div className="w-9 h-9 rounded-full bg-amber-500/20 text-amber-400 flex items-center justify-center text-sm font-bold uppercase flex-shrink-0">
                            {(c.name || "?")[0]}
                          </div>
                        )}
                        <div>
                          <span className="font-semibold text-white">{c.name || "—"}</span>
                          {c.address && <p className="text-xs text-gray-500 mt-0.5 truncate max-w-[150px]">{c.address}</p>}
                        </div>
                      </div>
                    </td>
                    <td className="py-4 px-6 text-gray-400">{c.email || "—"}</td>
                    <td className="py-4 px-6 text-gray-400">{c.phone || "—"}</td>
                    <td className="py-4 px-6 text-center">
                      <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold ${(roomCounts[c.id] ?? 0) > 0 ? 'bg-purple-600/20 text-purple-300' : 'bg-[#2A2A42] text-gray-500'}`}>
                        <LayoutGrid className="w-3 h-3" />
                        {roomCounts[c.id] ?? 0}
                      </span>
                    </td>
                    <td className="py-4 px-6 text-gray-500 text-xs">{formatDate(c.createdAt)}</td>
                    <td className="py-4 px-6">
                      <ChevronRight className="w-4 h-4 text-gray-600 group-hover:text-amber-400 transition-colors" />
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        <div className="p-4 border-t border-[#2A2A42] bg-[#14142B]/50 text-sm text-gray-500">
          Showing {filtered.length} of {customers.length} customers
        </div>
      </div>
    </div>
  );
}