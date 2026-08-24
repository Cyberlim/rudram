"use client";
import { useState, useEffect } from "react";
import { db } from "@/lib/firebase";
import {
  doc, getDoc, collection, query, where, getDocs, orderBy
} from "firebase/firestore";
import { useRouter, useParams } from "next/navigation";
import {
  ArrowLeft, Mail, Phone, MapPin, Calendar, LayoutGrid,
  ShoppingBag, Package, Loader2, User, Clock, ExternalLink
} from "lucide-react";

interface Customer {
  id: string;
  name: string;
  email: string;
  phone?: string;
  photoUrl?: string;
  photoURL?: string;
  address?: string;
  createdAt?: any;
  updatedAt?: any;
  gender?: string;
  dob?: string;
  totalOrders?: number;
}

interface UserRoom {
  id: string;
  name: string;
  image: string;
  productCount: number;
  isActive: boolean;
  createdAt?: any;
}

interface Order {
  id: string;
  total?: number;
  status?: string;
  createdAt?: any;
  itemCount?: number;
}

export default function CustomerDetailPage() {
  const router = useRouter();
  const params = useParams();
  const userId = params.id as string;

  const [customer, setCustomer] = useState<Customer | null>(null);
  const [rooms, setRooms] = useState<UserRoom[]>([]);
  const [orders, setOrders] = useState<Order[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<"overview" | "rooms" | "orders">("overview");

  useEffect(() => {
    if (userId) fetchAll();
  }, [userId]);

  const fetchAll = async () => {
    setIsLoading(true);
    try {
      // Fetch user
      const userDoc = await getDoc(doc(db, "users", userId));
      if (userDoc.exists()) {
        setCustomer({ id: userDoc.id, ...userDoc.data() } as Customer);
      }

      // Fetch user's rooms
      const roomSnap = await getDocs(
        query(collection(db, "user_rooms"), where("userId", "==", userId))
      );
      setRooms(roomSnap.docs.map(d => ({ id: d.id, ...d.data() } as UserRoom)));

      // Fetch user's orders
      try {
        const orderSnap = await getDocs(
          query(collection(db, "orders"), where("userId", "==", userId), orderBy("createdAt", "desc"))
        );
        setOrders(orderSnap.docs.map(d => ({ id: d.id, ...d.data() } as Order)));
      } catch {
        // orderBy may need index, try without
        const orderSnap = await getDocs(
          query(collection(db, "orders"), where("userId", "==", userId))
        );
        setOrders(orderSnap.docs.map(d => ({ id: d.id, ...d.data() } as Order)));
      }
    } catch (error) {
      console.error("Error fetching customer:", error);
    } finally {
      setIsLoading(false);
    }
  };

  const formatDate = (ts: any) => {
    if (!ts?.toDate) return "—";
    return ts.toDate().toLocaleDateString("en-IN", { day: "2-digit", month: "long", year: "numeric" });
  };

  const formatDateShort = (ts: any) => {
    if (!ts?.toDate) return "—";
    return ts.toDate().toLocaleDateString("en-IN", { day: "2-digit", month: "short", year: "numeric" });
  };

  const getAvatar = (c: Customer) => c.photoUrl || c.photoURL || null;

  if (isLoading) {
    return (
      <div className="flex h-64 items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-amber-500" />
      </div>
    );
  }

  if (!customer) {
    return (
      <div className="text-center py-20">
        <User className="w-12 h-12 text-gray-500 mx-auto mb-4" />
        <h3 className="text-white font-semibold text-lg">Customer not found</h3>
        <button onClick={() => router.back()} className="mt-4 text-amber-400 hover:underline text-sm">
          ← Go back
        </button>
      </div>
    );
  }

  const totalSpent = orders.reduce((s, o) => s + (o.total ?? 0), 0);

  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-700 ease-out max-w-5xl pb-20">
      {/* Back */}
      <button
        onClick={() => router.back()}
        className="flex items-center gap-2 text-gray-400 hover:text-white transition-colors text-sm font-medium"
      >
        <ArrowLeft className="w-4 h-4" />
        Back to Customers
      </button>

      {/* Profile Hero Card */}
      <div className="bg-[#1C1C2E] border border-[#2A2A42] rounded-2xl overflow-hidden">
        {/* Gradient top bar */}
        <div className="h-24 bg-gradient-to-r from-amber-500/20 via-purple-600/20 to-amber-500/10" />

        <div className="px-6 pb-6 -mt-12 flex flex-col md:flex-row md:items-end gap-5">
          {/* Avatar */}
          <div className="shrink-0">
            {getAvatar(customer) ? (
              <img
                src={getAvatar(customer)!}
                alt={customer.name}
                className="w-24 h-24 rounded-2xl border-4 border-[#1C1C2E] object-cover shadow-xl"
                onError={(e) => { e.currentTarget.style.display = 'none'; }}
              />
            ) : (
              <div className="w-24 h-24 rounded-2xl border-4 border-[#1C1C2E] bg-amber-500/20 text-amber-400 flex items-center justify-center text-3xl font-black shadow-xl">
                {(customer.name || "?")[0].toUpperCase()}
              </div>
            )}
          </div>

          {/* Name & Info */}
          <div className="flex-1 pb-1">
            <h1 className="text-2xl font-black text-white">{customer.name || "Unknown User"}</h1>
            <p className="text-gray-400 text-sm mt-1">{customer.email}</p>
            <div className="flex items-center gap-3 mt-2 flex-wrap">
              <span className="px-2.5 py-1 bg-green-500/20 text-green-400 text-xs font-bold rounded-full border border-green-500/30">Active</span>
              <span className="flex items-center gap-1.5 text-gray-500 text-xs">
                <Calendar className="w-3.5 h-3.5" />
                Joined {formatDate(customer.createdAt)}
              </span>
            </div>
          </div>

          {/* Quick Stats */}
          <div className="flex gap-4 md:pb-1">
            {[
              { label: "Rooms", value: rooms.length, color: "text-purple-400" },
              { label: "Orders", value: orders.length, color: "text-blue-400" },
              { label: "Spent", value: `₹${totalSpent.toLocaleString("en-IN")}`, color: "text-amber-400" },
            ].map(s => (
              <div key={s.label} className="text-center bg-[#14142B] rounded-xl px-4 py-3 border border-[#2A2A42]">
                <p className={`text-xl font-black ${s.color}`}>{s.value}</p>
                <p className="text-gray-500 text-xs mt-0.5">{s.label}</p>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="flex gap-2 bg-[#14142B] rounded-xl p-1 w-fit border border-[#2A2A42]">
        {[
          { key: "overview", label: "Overview", icon: User },
          { key: "rooms", label: `Rooms (${rooms.length})`, icon: LayoutGrid },
          { key: "orders", label: `Orders (${orders.length})`, icon: ShoppingBag },
        ].map(tab => (
          <button
            key={tab.key}
            onClick={() => setActiveTab(tab.key as any)}
            className={`flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-bold transition-all ${activeTab === tab.key ? "bg-amber-500 text-white shadow-sm" : "text-gray-400 hover:text-white"}`}
          >
            <tab.icon className="w-3.5 h-3.5" />
            {tab.label}
          </button>
        ))}
      </div>

      {/* Overview Tab */}
      {activeTab === "overview" && (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Contact Info */}
          <div className="bg-[#1C1C2E] border border-[#2A2A42] rounded-2xl p-6 space-y-5">
            <h2 className="text-white font-bold text-lg border-b border-[#2A2A42] pb-3">Contact Information</h2>
            {[
              { icon: Mail, label: "Email", value: customer.email },
              { icon: Phone, label: "Phone", value: customer.phone || "Not provided" },
              { icon: MapPin, label: "Address", value: customer.address || "Not provided" },
              { icon: Calendar, label: "Date of Birth", value: customer.dob || "Not provided" },
              { icon: User, label: "Gender", value: customer.gender || "Not provided" },
            ].map(item => (
              <div key={item.label} className="flex items-start gap-3">
                <div className="p-2 bg-[#2A2A42] rounded-lg shrink-0">
                  <item.icon className="w-4 h-4 text-amber-400" />
                </div>
                <div>
                  <p className="text-gray-500 text-xs">{item.label}</p>
                  <p className="text-white text-sm font-medium mt-0.5">{item.value}</p>
                </div>
              </div>
            ))}
          </div>

          {/* Account Info */}
          <div className="bg-[#1C1C2E] border border-[#2A2A42] rounded-2xl p-6 space-y-5">
            <h2 className="text-white font-bold text-lg border-b border-[#2A2A42] pb-3">Account Details</h2>
            {[
              { label: "User ID", value: customer.id },
              { label: "Created At", value: formatDate(customer.createdAt) },
              { label: "Last Updated", value: formatDate(customer.updatedAt) },
              { label: "Total Orders", value: orders.length.toString() },
              { label: "Total Spent", value: `₹${totalSpent.toLocaleString("en-IN")}` },
              { label: "Virtual Rooms", value: rooms.length.toString() },
            ].map(item => (
              <div key={item.label} className="flex justify-between items-center">
                <span className="text-gray-500 text-sm">{item.label}</span>
                <span className="text-white text-sm font-semibold font-mono truncate max-w-[200px] text-right">{item.value}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Rooms Tab */}
      {activeTab === "rooms" && (
        <div>
          {rooms.length === 0 ? (
            <div className="text-center py-20 bg-[#1C1C2E] border border-[#2A2A42] rounded-2xl">
              <LayoutGrid className="w-12 h-12 text-gray-600 mx-auto mb-3" />
              <p className="text-white font-semibold">No rooms created yet</p>
              <p className="text-gray-500 text-sm mt-1">This user hasn't created any virtual showrooms.</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
              {rooms.map(room => (
                <div key={room.id} className="bg-[#1C1C2E] border border-[#2A2A42] rounded-2xl overflow-hidden hover:border-purple-500/40 transition-all group">
                  <div className="h-44 relative bg-[#14142B] flex items-center justify-center overflow-hidden">
                    {room.image ? (
                      <img src={room.image} alt={room.name} className="absolute inset-0 w-full h-full object-cover transition-transform duration-500 group-hover:scale-105" onError={(e) => { e.currentTarget.style.display = 'none'; }} />
                    ) : null}
                    <LayoutGrid className="w-8 h-8 text-gray-600 relative z-[1]" />
                    <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent z-[2]" />
                    <div className="absolute bottom-3 left-3 z-[3]">
                      <span className={`px-2 py-1 text-xs font-bold rounded-md ${room.isActive ? 'bg-green-500/90' : 'bg-red-500/90'} text-white`}>
                        {room.isActive ? "Active" : "Inactive"}
                      </span>
                    </div>
                  </div>
                  <div className="p-4">
                    <h3 className="text-white font-bold">{room.name}</h3>
                    <div className="flex items-center justify-between mt-3">
                      <div className="flex items-center gap-1.5 text-gray-500 text-xs">
                        <Package className="w-3.5 h-3.5" />
                        <span>{room.productCount ?? 0} products</span>
                      </div>
                      <div className="flex items-center gap-1.5 text-gray-500 text-xs">
                        <Clock className="w-3.5 h-3.5" />
                        <span>{formatDateShort(room.createdAt)}</span>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* Orders Tab */}
      {activeTab === "orders" && (
        <div className="bg-[#1C1C2E] border border-[#2A2A42] rounded-2xl overflow-hidden">
          {orders.length === 0 ? (
            <div className="text-center py-20">
              <ShoppingBag className="w-12 h-12 text-gray-600 mx-auto mb-3" />
              <p className="text-white font-semibold">No orders yet</p>
              <p className="text-gray-500 text-sm mt-1">This customer hasn't placed any orders.</p>
            </div>
          ) : (
            <table className="w-full text-left text-sm">
              <thead>
                <tr className="text-gray-500 font-semibold border-b border-[#2A2A42] bg-[#14142B]/50">
                  <th className="py-3 px-5">Order ID</th>
                  <th className="py-3 px-5">Date</th>
                  <th className="py-3 px-5">Items</th>
                  <th className="py-3 px-5">Total</th>
                  <th className="py-3 px-5">Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-[#2A2A42]/50">
                {orders.map(order => (
                  <tr key={order.id} className="hover:bg-[#2A2A42]/20 transition-colors">
                    <td className="py-3 px-5 text-gray-400 font-mono text-xs">{order.id.slice(0, 12)}…</td>
                    <td className="py-3 px-5 text-gray-400 text-xs">{formatDateShort(order.createdAt)}</td>
                    <td className="py-3 px-5 text-white">{order.itemCount ?? "—"}</td>
                    <td className="py-3 px-5 text-amber-400 font-semibold">
                      {order.total ? `₹${order.total.toLocaleString("en-IN")}` : "—"}
                    </td>
                    <td className="py-3 px-5">
                      <span className={`px-2 py-1 rounded-full text-xs font-bold ${
                        order.status === "delivered" ? "bg-green-500/20 text-green-400" :
                        order.status === "processing" ? "bg-blue-500/20 text-blue-400" :
                        order.status === "cancelled" ? "bg-red-500/20 text-red-400" :
                        "bg-amber-500/20 text-amber-400"
                      }`}>
                        {order.status ?? "pending"}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      )}
    </div>
  );
}
