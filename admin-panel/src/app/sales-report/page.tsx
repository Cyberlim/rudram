"use client";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, LineChart, Line } from 'recharts';
import { Calendar, Download, TrendingUp, Users, DollarSign, Activity } from 'lucide-react';
import { useState, useEffect } from "react";
import { db } from "@/lib/firebase";
import { collection, query, getDocs } from "firebase/firestore";

export default function SalesReportPage() {
  const [stats, setStats] = useState({ revenue: 0, orders: 0, avgValue: 0, visitors: 0 });
  const [revenueData, setRevenueData] = useState<{ name: string; value: number }[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchData() {
      try {
        const snap = await getDocs(query(collection(db, "orders")));
        let totalRev = 0;
        const monthMap: Record<string, number> = {};

        snap.docs.forEach((doc) => {
          const data = doc.data();
          const amount = data.total || 0;
          totalRev += amount;
          
          if (data.createdAt?.toDate) {
            const date = data.createdAt.toDate();
            const month = date.toLocaleString('en-IN', { month: 'short' });
            monthMap[month] = (monthMap[month] || 0) + amount;
          }
        });

        const revTrend = Object.entries(monthMap).map(([name, value]) => ({ name, value }));

        setStats({
          revenue: totalRev,
          orders: snap.size,
          avgValue: snap.size > 0 ? Math.round(totalRev / snap.size) : 0,
          visitors: Math.round(snap.size * 3.5) // Just a placeholder multiplier for visitors
        });
        setRevenueData(revTrend.length > 0 ? revTrend : [{ name: 'No Data', value: 0 }]);
        setLoading(false);
      } catch (e) {
        setLoading(false);
      }
    }
    fetchData();
  }, []);

  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-1000 ease-out pb-10">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black text-gray-900 dark:text-gray-100">Sales Reports</h1>
          <p className="text-gray-500 mt-1">Deep dive into your store's performance metrics.</p>
        </div>
        <div className="flex items-center gap-3">
          <button className="flex items-center gap-2 bg-amber-600 hover:bg-amber-700 text-white px-4 py-2 rounded-lg font-medium transition-colors shadow-sm">
            <Download className="w-4 h-4" />
            <span>Export CSV</span>
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {[
          { title: "Net Revenue", value: `₹${stats.revenue.toLocaleString()}`, icon: DollarSign, color: "text-amber-600", bg: "bg-amber-50" },
          { title: "Total Orders", value: stats.orders.toString(), icon: Activity, color: "text-blue-600", bg: "bg-blue-50" },
          { title: "Avg. Order Value", value: `₹${stats.avgValue.toLocaleString()}`, icon: TrendingUp, color: "text-purple-600", bg: "bg-purple-50" },
          { title: "Est. Visitors", value: stats.visitors.toString(), icon: Users, color: "text-emerald-600", bg: "bg-emerald-50" }
        ].map((stat, i) => (
          <div key={i} className="bg-white dark:bg-[#14142B] rounded-2xl p-6 shadow-sm border border-gray-100 dark:border-[#2A2A42] flex items-start justify-between">
            <div>
              <p className="text-gray-500 text-sm font-medium mb-1">{stat.title}</p>
              <h3 className="text-2xl font-bold text-gray-900 dark:text-gray-100">{loading ? "..." : stat.value}</h3>
              <p className="text-xs font-semibold mt-2 text-gray-400">Lifetime data</p>
            </div>
            <div className={`w-12 h-12 rounded-full ${stat.bg} flex items-center justify-center`}>
              <stat.icon className={`w-6 h-6 ${stat.color}`} />
            </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 h-[400px]">
        <div className="bg-white dark:bg-[#14142B] rounded-2xl p-6 shadow-sm border border-gray-100 dark:border-[#2A2A42] flex flex-col">
          <h2 className="text-lg font-bold text-gray-900 dark:text-gray-100 mb-6">Revenue Trend (Months)</h2>
          <div className="flex-1 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={revenueData}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f3f4f6" />
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fill: '#9ca3af', fontSize: 12}} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{fill: '#9ca3af', fontSize: 12}} />
                <Tooltip cursor={{stroke: '#e5e7eb'}} formatter={(val: any) => `₹${val.toLocaleString()}`} />
                <Line type="monotone" dataKey="value" stroke="#d97706" strokeWidth={3} dot={{r: 4, strokeWidth: 2, fill: '#fff'}} activeDot={{r: 6}} />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>
        
        <div className="bg-white dark:bg-[#14142B] rounded-2xl p-6 shadow-sm border border-gray-100 dark:border-[#2A2A42] flex flex-col">
          <h2 className="text-lg font-bold text-gray-900 dark:text-gray-100 mb-6">Orders Trend (Months)</h2>
          <div className="flex-1 w-full flex items-center justify-center text-gray-400">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={revenueData}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f3f4f6" />
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fill: '#9ca3af', fontSize: 12}} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{fill: '#9ca3af', fontSize: 12}} />
                <Tooltip cursor={{fill: '#f3f4f6'}} />
                <Bar dataKey="value" fill="#8b5cf6" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>
    </div>
  );
}