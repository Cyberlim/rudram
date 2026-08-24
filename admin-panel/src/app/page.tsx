"use client";

import { 
  ShoppingBag, ShoppingCart, Users, Store, Gem, Wallet, 
  ArrowUp, ArrowDown, Calendar, Download, Plus, 
  Settings, Image as ImageIcon, Ticket
} from "lucide-react";
import { 
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, 
  PieChart, Pie, Cell, BarChart, Bar 
} from 'recharts';
import { useState, useEffect } from "react";
import { db } from "@/lib/firebase";
import { collection, onSnapshot, query, orderBy, limit, getDocs } from "firebase/firestore";

interface Order {
  id: string;
  userName?: string;
  userEmail?: string;
  items?: any[];
  total?: number;
  status?: string;
  createdAt?: any;
}

const STATUS_COLORS: Record<string, string> = {
  Pending: "bg-orange-100 text-orange-600",
  Processing: "bg-blue-100 text-blue-600",
  Shipped: "bg-purple-100 text-purple-600",
  Delivered: "bg-green-100 text-green-600",
  Cancelled: "bg-red-100 text-red-600",
};

const PIE_COLORS = ["#f59e0b", "#3b82f6", "#8b5cf6", "#10b981", "#ef4444"];

export default function Dashboard() {
  const [stats, setStats] = useState({
    orders: 0, customers: 0, vendors: 0, products: 0,
    revenue: 0, payouts: 0,
  });
  const [recentOrders, setRecentOrders] = useState<Order[]>([]);
  const [orderStatusData, setOrderStatusData] = useState<{ name: string; value: number; color: string }[]>([]);
  const [topProducts, setTopProducts] = useState<any[]>([]);
  const [revenueData, setRevenueData] = useState<{ name: string; value: number }[]>([]);

  useEffect(() => {
    // Real-time counts
    const unsubs: (() => void)[] = [];

    const watchCount = (col: string, key: keyof typeof stats) => {
      const unsub = onSnapshot(collection(db, col), (snap) =>
        setStats((prev) => ({ ...prev, [key]: snap.size }))
      );
      unsubs.push(unsub);
    };

    watchCount("orders", "orders");
    watchCount("users", "customers");
    watchCount("vendors", "vendors");
    watchCount("products", "products");

    // Recent orders (live)
    const recentQ = query(collection(db, "orders"), orderBy("createdAt", "desc"), limit(5));
    unsubs.push(onSnapshot(recentQ, (snap) => {
      const orders = snap.docs.map((d) => ({ id: d.id, ...d.data() })) as Order[];
      setRecentOrders(orders);

      // Compute revenue
      const total = orders.reduce((sum, o) => sum + (o.total || 0), 0);
      setStats((prev) => ({ ...prev, revenue: total }));

      // Order status distribution
      const statusCount: Record<string, number> = {};
      orders.forEach((o) => {
        const s = o.status || "Pending";
        statusCount[s] = (statusCount[s] || 0) + 1;
      });
      const statuses = ["Pending", "Processing", "Shipped", "Delivered", "Cancelled"];
      setOrderStatusData(
        statuses.map((s, i) => ({ name: s, value: statusCount[s] || 0, color: PIE_COLORS[i] }))
      );
    }));

    // Top products by order frequency
    const allOrdersQ = query(collection(db, "orders"), orderBy("createdAt", "desc"), limit(50));
    getDocs(allOrdersQ).then((snap) => {
      const productCount: Record<string, { name: string; count: number; revenue: number }> = {};
      snap.docs.forEach((d) => {
        const order = d.data();
        (order.items || []).forEach((item: any) => {
          if (!productCount[item.title]) {
            productCount[item.title] = { name: item.title, count: 0, revenue: 0 };
          }
          productCount[item.title].count += item.quantity || 1;
          productCount[item.title].revenue += (item.price || 0) * (item.quantity || 1);
        });
      });
      const top = Object.values(productCount)
        .sort((a, b) => b.count - a.count)
        .slice(0, 5)
        .map((p, i) => ({ rank: i + 1, ...p }));
      setTopProducts(top);

      // Build monthly revenue data from orders
      const monthMap: Record<string, number> = {};
      snap.docs.forEach((d) => {
        const data = d.data();
        const date = data.createdAt?.toDate?.();
        if (date) {
          const key = date.toLocaleString("en-IN", { month: "short" });
          monthMap[key] = (monthMap[key] || 0) + (data.total || 0);
        }
      });
      setRevenueData(Object.entries(monthMap).map(([name, value]) => ({ name, value })));
    });

    return () => unsubs.forEach((u) => u());
  }, []);

  const totalOrders = orderStatusData.reduce((s, d) => s + d.value, 0);

  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-1000 ease-out pb-10">
      
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <h1 className="text-2xl font-black text-gray-900 dark:text-gray-100">Dashboard</h1>
        <div className="flex items-center gap-4">
          <div className="flex items-center gap-2 bg-white dark:bg-[#14142B] px-4 py-2 rounded-lg border border-gray-200 dark:border-[#2A2A42] text-sm font-medium text-gray-600">
            <span>Live Data</span>
            <span className="w-2 h-2 rounded-full bg-green-500 animate-pulse" />
          </div>
        </div>
      </div>

      {/* Stats Row */}
      <div className="grid grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
        <StatCard title="Total Revenue" value={`₹${stats.revenue.toLocaleString("en-IN")}`} trend="+live" icon={ShoppingBag} color="text-amber-500" bg="bg-amber-50" />
        <StatCard title="Total Orders" value={stats.orders.toLocaleString()} trend="+live" icon={ShoppingCart} color="text-emerald-500" bg="bg-emerald-50" />
        <StatCard title="Total Customers" value={stats.customers.toLocaleString()} trend="+live" icon={Users} color="text-blue-500" bg="bg-blue-50" />
        <StatCard title="Total Vendors" value={stats.vendors.toLocaleString()} trend="+live" icon={Store} color="text-purple-500" bg="bg-purple-50" />
        <StatCard title="Total Products" value={stats.products.toLocaleString()} trend="+live" icon={Gem} color="text-rose-500" bg="bg-rose-50" />
        <StatCard title="Total Payouts" value="—" trend="coming soon" icon={Wallet} color="text-orange-500" bg="bg-orange-50" />
      </div>

      {/* Middle Row */}
      <div className="grid grid-cols-1 xl:grid-cols-12 gap-6">
        
        {/* Revenue Chart */}
        <div className="xl:col-span-5 bg-white dark:bg-[#14142B] rounded-2xl p-6 shadow-sm border border-gray-100 dark:border-[#2A2A42] flex flex-col">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h2 className="text-lg font-bold text-gray-900 dark:text-gray-100">Revenue (Orders)</h2>
              <p className="text-xs text-gray-400 mt-1">Based on completed orders by month</p>
            </div>
          </div>
          <div className="flex-1 w-full mt-4 min-h-[250px]">
            {revenueData.length > 0 ? (
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={revenueData} margin={{ top: 10, right: 0, left: -20, bottom: 0 }}>
                  <defs>
                    <linearGradient id="colorGold" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#d97706" stopOpacity={0.3}/>
                      <stop offset="95%" stopColor="#d97706" stopOpacity={0}/>
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f3f4f6" />
                  <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fill: '#9ca3af', fontSize: 11}} dy={10} />
                  <YAxis axisLine={false} tickLine={false} tick={{fill: '#9ca3af', fontSize: 11}} tickFormatter={(v) => `${v/1000}k`} />
                  <Tooltip cursor={{stroke: '#e5e7eb', strokeWidth: 2}} formatter={(v: any) => [`₹${v.toLocaleString()}`, "Revenue"]} />
                  <Area type="monotone" dataKey="value" stroke="#d97706" strokeWidth={3} fillOpacity={1} fill="url(#colorGold)" />
                </AreaChart>
              </ResponsiveContainer>
            ) : (
              <div className="h-full flex items-center justify-center text-gray-400 text-sm">No order data yet</div>
            )}
          </div>
        </div>

        {/* Recent Orders */}
        <div className="xl:col-span-5 bg-white dark:bg-[#14142B] rounded-2xl p-6 shadow-sm border border-gray-100 dark:border-[#2A2A42] flex flex-col overflow-hidden">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-bold text-gray-900 dark:text-gray-100">Recent Orders</h2>
            <a href="/orders" className="text-amber-600 text-sm font-bold hover:underline">View All</a>
          </div>
          {recentOrders.length === 0 ? (
            <div className="flex-1 flex items-center justify-center text-gray-400 text-sm">No orders yet</div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left text-sm whitespace-nowrap">
                <thead>
                  <tr className="text-gray-400 font-medium border-b border-gray-100 dark:border-[#2A2A42]">
                    <th className="pb-3 pr-4 font-medium">Order ID</th>
                    <th className="pb-3 px-4 font-medium">Customer</th>
                    <th className="pb-3 px-4 font-medium">Amount</th>
                    <th className="pb-3 pl-4 font-medium">Status</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-50">
                  {recentOrders.map((order) => (
                    <tr key={order.id} className="hover:bg-gray-50 dark:bg-[#0B0B1A]/50">
                      <td className="py-3 pr-4 font-mono text-xs text-gray-500">#{order.id.slice(0, 8)}</td>
                      <td className="py-3 px-4 text-gray-700 dark:text-gray-300 font-medium">{order.userName || order.userEmail || "—"}</td>
                      <td className="py-3 px-4 font-bold text-gray-900 dark:text-gray-100">₹{(order.total || 0).toLocaleString()}</td>
                      <td className="py-3 pl-4">
                        <span className={`px-2.5 py-1 rounded-full text-xs font-semibold ${STATUS_COLORS[order.status || "Pending"] || "bg-gray-100 text-gray-600"}`}>
                          {order.status || "Pending"}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>

        {/* Quick Links */}
        <div className="xl:col-span-2 bg-white dark:bg-[#14142B] rounded-2xl p-6 shadow-sm border border-gray-100 dark:border-[#2A2A42] flex flex-col">
          <h2 className="text-lg font-bold text-gray-900 dark:text-gray-100 mb-4">Quick Links</h2>
          <div className="space-y-3">
            {[
              { label: "Add Product", href: "/products", icon: Gem, color: "text-amber-600", bg: "bg-amber-50" },
              { label: "Add Vendor", href: "/vendors", icon: Store, color: "text-emerald-600", bg: "bg-emerald-50" },
              { label: "Add Banner", href: "/banners", icon: ImageIcon, color: "text-purple-600", bg: "bg-purple-50" },
              { label: "Add Coupon", href: "/coupons", icon: Ticket, color: "text-rose-600", bg: "bg-rose-50" },
            ].map((item) => (
              <a key={item.label} href={item.href}
                className="flex items-center gap-3 p-2 hover:bg-gray-50 dark:bg-[#0B0B1A] rounded-xl transition-colors">
                <div className={`w-8 h-8 rounded-lg ${item.bg} flex items-center justify-center flex-shrink-0`}>
                  <item.icon className={`w-4 h-4 ${item.color}`} />
                </div>
                <span className="text-sm font-medium text-gray-700 dark:text-gray-300">{item.label}</span>
              </a>
            ))}
          </div>
        </div>
      </div>

      {/* Bottom Row */}
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
        
        {/* Orders Overview Donut */}
        <div className="bg-white dark:bg-[#14142B] rounded-2xl p-6 shadow-sm border border-gray-100 dark:border-[#2A2A42]">
          <h2 className="text-lg font-bold text-gray-900 dark:text-gray-100 mb-4">Orders Overview</h2>
          {totalOrders === 0 ? (
            <div className="h-48 flex items-center justify-center text-gray-400 text-sm">No order data</div>
          ) : (
            <>
              <div className="flex items-center justify-center relative h-48 w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie data={orderStatusData} innerRadius={60} outerRadius={80} paddingAngle={2} dataKey="value" stroke="none">
                      {orderStatusData.map((entry, i) => <Cell key={i} fill={entry.color} />)}
                    </Pie>
                    <Tooltip />
                  </PieChart>
                </ResponsiveContainer>
                <div className="absolute inset-0 flex flex-col items-center justify-center">
                  <span className="text-2xl font-black text-gray-900 dark:text-gray-100">{totalOrders}</span>
                  <span className="text-xs text-gray-500 font-medium">Total Orders</span>
                </div>
              </div>
              <div className="mt-4 space-y-2">
                {orderStatusData.map((item, i) => (
                  <div key={i} className="flex items-center justify-between text-xs">
                    <div className="flex items-center gap-2">
                      <div className="w-2 h-2 rounded-full" style={{ backgroundColor: item.color }}/>
                      <span className="text-gray-600">{item.name}</span>
                    </div>
                    <span className="font-bold text-gray-900 dark:text-gray-100">{item.value}</span>
                  </div>
                ))}
              </div>
            </>
          )}
        </div>

        {/* Top Selling Products */}
        <div className="bg-white dark:bg-[#14142B] rounded-2xl p-6 shadow-sm border border-gray-100 dark:border-[#2A2A42]">
          <h2 className="text-lg font-bold text-gray-900 dark:text-gray-100 mb-4">Top Selling Products</h2>
          {topProducts.length === 0 ? (
            <div className="h-48 flex items-center justify-center text-gray-400 text-sm">No sales data yet</div>
          ) : (
            <div className="space-y-4">
              {topProducts.map((prod) => (
                <div key={prod.rank} className="flex items-center gap-3">
                  <div className="w-5 h-5 rounded-full bg-gray-100 text-[10px] font-bold text-gray-600 flex items-center justify-center flex-shrink-0">
                    {prod.rank}
                  </div>
                  <div className="w-8 h-8 bg-orange-50 rounded-lg flex items-center justify-center flex-shrink-0">
                    <Gem className="w-4 h-4 text-amber-500" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-bold text-gray-800 dark:text-gray-200 leading-none truncate">{prod.name}</p>
                  </div>
                  <div className="text-right flex-shrink-0">
                    <p className="text-xs text-emerald-500 font-bold">{prod.count} sold</p>
                    <p className="text-xs font-bold text-gray-900 dark:text-gray-100">₹{prod.revenue.toLocaleString()}</p>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Live Stats Summary */}
        <div className="bg-white dark:bg-[#14142B] rounded-2xl p-6 shadow-sm border border-gray-100 dark:border-[#2A2A42]">
          <h2 className="text-lg font-bold text-gray-900 dark:text-gray-100 mb-4">Store Summary</h2>
          <div className="space-y-4">
            {[
              { label: "Products Listed", value: stats.products, color: "bg-amber-500" },
              { label: "Registered Customers", value: stats.customers, color: "bg-blue-500" },
              { label: "Active Vendors", value: stats.vendors, color: "bg-purple-500" },
              { label: "Total Orders", value: stats.orders, color: "bg-emerald-500" },
            ].map((item) => (
              <div key={item.label} className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <div className={`w-2 h-2 rounded-full ${item.color}`} />
                  <span className="text-sm text-gray-600">{item.label}</span>
                </div>
                <span className="text-sm font-black text-gray-900 dark:text-gray-100">{item.value.toLocaleString()}</span>
              </div>
            ))}
            <div className="pt-2 border-t border-gray-100 dark:border-[#2A2A42]">
              <div className="flex items-center justify-between">
                <span className="text-sm font-semibold text-gray-700 dark:text-gray-300">Total Revenue</span>
                <span className="text-sm font-black text-amber-700">₹{stats.revenue.toLocaleString("en-IN")}</span>
              </div>
            </div>
          </div>
        </div>

      </div>
    </div>
  );
}

function StatCard({ title, value, trend, icon: Icon, color, bg }: any) {
  return (
    <div className="bg-white dark:bg-[#14142B] rounded-2xl p-4 shadow-sm border border-gray-100 dark:border-[#2A2A42] flex flex-col hover:-translate-y-1 transition-transform duration-300 cursor-default">
      <div className="flex flex-col items-center justify-center mb-3">
        <h3 className="text-gray-500 font-bold text-xs uppercase tracking-wide mb-2 text-center">{title}</h3>
        <div className="flex items-center gap-3">
          <div className={`w-10 h-10 rounded-full ${bg} flex items-center justify-center`}>
            <Icon className={`w-5 h-5 ${color}`} />
          </div>
          <p className="text-2xl font-black text-gray-900 dark:text-gray-100">{value}</p>
        </div>
      </div>
      <div className="text-center mt-auto">
        <span className="text-xs font-bold text-emerald-500 flex items-center justify-center gap-1">
          <ArrowUp className="w-3 h-3" /> {trend}
        </span>
      </div>
    </div>
  );
}
