"use client";
import { Search, Filter, Plus, MoreHorizontal, Download } from "lucide-react";
import { useEffect, useState } from "react";
import { db } from "@/lib/firebase";
import { collection, query, orderBy, onSnapshot, doc, updateDoc } from "firebase/firestore";
import Fuse from "fuse.js";

interface OrderProduct {
  title: string;
  price: number;
  quantity: number;
  totalPrice: number;
}

interface Order {
  id: string;
  orderNumber: string;
  uid: string;
  date: string;
  status: string;
  items: OrderProduct[];
  totalAmount: number;
  paymentMethod: string;
  deliveryDetails: any;
  createdAt: any;
  isLuxury?: boolean;
}

export default function LuxuryOrdersPage() {
  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");

  useEffect(() => {
    const q = query(collection(db, "orders"), orderBy("createdAt", "desc"));
    const unsubscribe = onSnapshot(q, (querySnapshot) => {
      const ordersList: Order[] = [];
      querySnapshot.forEach((doc) => {
        const data = doc.data() as Order;
        // Client-side filtering for luxury orders to avoid needing an index
        if (data.isLuxury) {
          ordersList.push({ ...data, id: doc.id });
        }
      });
      setOrders(ordersList);
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  const handleStatusChange = async (orderId: string, newStatus: string) => {
    try {
      const orderRef = doc(db, "orders", orderId);
      await updateDoc(orderRef, { status: newStatus });
    } catch (error) {
      console.error("Error updating order status: ", error);
      alert("Failed to update order status.");
    }
  };

  const fuse = new Fuse(orders, {
    keys: ["orderNumber", "deliveryDetails.name", "status"],
    threshold: 0.3,
  });

  const filtered = search ? fuse.search(search).map(r => r.item) : orders;

  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-1000 ease-out pb-10">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black text-gray-900 dark:text-gray-100">Luxury Orders</h1>
          <p className="text-gray-500 mt-1">Manage and view high-end luxury product orders.</p>
        </div>
        <div className="flex items-center gap-3">
          <button className="flex items-center gap-2 bg-white dark:bg-[#14142B] border border-gray-200 dark:border-[#2A2A42] hover:bg-gray-50 dark:bg-[#0B0B1A] text-gray-700 dark:text-gray-300 px-4 py-2 rounded-lg font-medium transition-colors">
            <Download className="w-4 h-4" />
            <span>Export VIP List</span>
          </button>
        </div>
      </div>

      {/* Table Container */}
      <div className="bg-white dark:bg-[#14142B] rounded-2xl shadow-sm border border-gray-100 dark:border-[#2A2A42] flex flex-col overflow-hidden">
        {/* Toolbar */}
        <div className="p-4 border-b border-gray-100 dark:border-[#2A2A42] flex flex-col md:flex-row md:items-center justify-between gap-4 bg-gray-50 dark:bg-[#0B0B1A]/50">
          <div className="relative w-full md:w-96">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input 
              type="text" 
              placeholder="Search luxury orders..." 
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full pl-10 pr-4 py-2 bg-white dark:bg-[#14142B] border border-gray-200 dark:border-[#2A2A42] rounded-lg text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none transition-all"
            />
          </div>
          <button className="flex items-center gap-2 bg-white dark:bg-[#14142B] border border-gray-200 dark:border-[#2A2A42] hover:bg-gray-50 dark:bg-[#0B0B1A] text-gray-700 dark:text-gray-300 px-4 py-2 rounded-lg text-sm font-medium transition-colors w-full md:w-auto justify-center">
            <Filter className="w-4 h-4" />
            <span>Filters</span>
          </button>
        </div>

        {/* Table */}
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm whitespace-nowrap">
            <thead className="bg-gray-50 dark:bg-[#0B0B1A]/50">
              <tr className="text-gray-500 font-semibold border-b border-gray-100 dark:border-[#2A2A42]">
                <th className="py-4 px-6 w-12"><input type="checkbox" className="rounded border-gray-300 text-amber-600 focus:ring-amber-500" /></th>
                <th className="py-4 px-6">Order ID</th>
                <th className="py-4 px-6">VIP Customer</th>
                <th className="py-4 px-6">Date</th>
                <th className="py-4 px-6">Amount</th>
                <th className="py-4 px-6">Status</th>
                <th className="py-4 px-6 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {loading ? (
                <tr>
                  <td colSpan={7} className="py-8 text-center text-gray-500">
                    Loading luxury orders...
                  </td>
                </tr>
              ) : filtered.length === 0 ? (
                <tr>
                  <td colSpan={7} className="py-8 text-center text-gray-500">
                    No luxury orders found yet.
                  </td>
                </tr>
              ) : (
                filtered.map((item) => (
                  <tr key={item.id} className="hover:bg-amber-50/30 transition-colors group">
                    <td className="py-4 px-6"><input type="checkbox" className="rounded border-gray-300 text-amber-600 focus:ring-amber-500" /></td>
                    <td className="py-4 px-6 font-medium text-gray-900 dark:text-gray-100">#LUX-{item.orderNumber}</td>
                    <td className="py-4 px-6 text-gray-600">{item.deliveryDetails?.name || 'Guest'}</td>
                    <td className="py-4 px-6 text-gray-600">{item.date}</td>
                    <td className="py-4 px-6 font-medium text-amber-600 font-bold">₹{item.totalAmount?.toLocaleString()}</td>
                    <td className="py-4 px-6">
                      <div className="relative inline-block w-40">
                        <select
                          value={item.status}
                          onChange={(e) => handleStatusChange(item.id, e.target.value)}
                          className={`w-full px-3 py-1.5 rounded-full text-xs font-bold border-2 cursor-pointer outline-none appearance-none pr-8 transition-colors ${
                            item.status === 'Processing' ? 'bg-amber-50 border-amber-200 text-amber-700 hover:bg-amber-100' :
                            item.status === 'Shipped' ? 'bg-blue-50 border-blue-200 text-blue-700 hover:bg-blue-100' :
                            item.status === 'Out for Delivery' ? 'bg-purple-50 border-purple-200 text-purple-700 hover:bg-purple-100' :
                            item.status === 'Delivered' ? 'bg-emerald-50 border-emerald-200 text-emerald-700 hover:bg-emerald-100' :
                            item.status === 'Cancelled' ? 'bg-red-50 border-red-200 text-red-700 hover:bg-red-100' :
                            'bg-gray-50 dark:bg-[#0B0B1A] border-gray-200 dark:border-[#2A2A42] text-gray-700 dark:text-gray-300 hover:bg-gray-100'
                          }`}
                        >
                          <option value="Processing" className="bg-white dark:bg-[#14142B] text-gray-900 dark:text-gray-100">Processing</option>
                          <option value="Shipped" className="bg-white dark:bg-[#14142B] text-gray-900 dark:text-gray-100">Shipped</option>
                          <option value="Out for Delivery" className="bg-white dark:bg-[#14142B] text-gray-900 dark:text-gray-100">Out for Delivery</option>
                          <option value="Delivered" className="bg-white dark:bg-[#14142B] text-gray-900 dark:text-gray-100">Delivered</option>
                          <option value="Cancelled" className="bg-white dark:bg-[#14142B] text-gray-900 dark:text-gray-100">Cancelled</option>
                        </select>
                        <div className="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-gray-500">
                          <svg className="w-4 h-4 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7" />
                          </svg>
                        </div>
                      </div>
                    </td>
                    <td className="py-4 px-6 text-right">
                      <button className="text-gray-400 hover:text-amber-600 p-1 rounded-md hover:bg-amber-50 transition-colors">
                        <MoreHorizontal className="w-5 h-5" />
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        <div className="p-4 border-t border-gray-100 dark:border-[#2A2A42] flex items-center justify-between text-sm text-gray-500 bg-gray-50 dark:bg-[#0B0B1A]/50">
          <span>Showing {filtered.length} luxury results</span>
          <div className="flex items-center gap-1">
            <button className="px-3 py-1 border border-gray-200 dark:border-[#2A2A42] rounded hover:bg-gray-50 dark:bg-[#0B0B1A] disabled:opacity-50" disabled>Prev</button>
            <button className="px-3 py-1 bg-amber-600 text-white rounded font-medium">1</button>
            <button className="px-3 py-1 border border-gray-200 dark:border-[#2A2A42] rounded hover:bg-gray-50 dark:bg-[#0B0B1A] disabled:opacity-50" disabled>Next</button>
          </div>
        </div>
      </div>
    </div>
  );
}
