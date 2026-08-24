"use client";

import Link from "next/link";
import { 
  LayoutDashboard, Store, Package, ShoppingBag, Users, FolderTree, Layers,
  Ticket, Image as ImageIcon, BarChart2, FileText, Settings, Shield, Globe, Gem, Star, LogOut, DoorOpen, Crown, Newspaper, Info
} from "lucide-react";
import { useAuth } from "@/context/AuthContext";
import { useSidebar } from "@/context/SidebarContext";

const navigation = [
  {
    group: "CATALOG",
    items: [
      { name: "Products", href: "/products", icon: Package },
      { name: "Categories", href: "/categories", icon: FolderTree },
      { name: "Collections", href: "/collections", icon: Layers },
      { name: "Coupons", href: "/coupons", icon: Ticket },
    ]
  },
  {
    group: "SALES",
    items: [
      { name: "Orders", href: "/orders", icon: ShoppingBag },
      { name: "Luxury Orders", href: "/luxury-orders", icon: Gem },
    ]
  },
  {
    group: "CONTENT",
    items: [
      { name: "App Banners", href: "/banners", icon: ImageIcon },
      { name: "Web Banners", href: "/web-banners", icon: ImageIcon },
      { name: "Web Content", href: "/web-content", icon: LayoutDashboard },
      { name: "Articles (Latest)", href: "/articles", icon: Newspaper },
      { name: "About Page", href: "/about", icon: Info },
      { name: "Virtual Rooms", href: "/rooms", icon: DoorOpen },
      { name: "Celebrity Styles", href: "/celebrity-styles", icon: Star },
      { name: "Luxury Section", href: "/luxury", icon: Crown },
    ]
  },
  {
    group: "SYSTEM & REPORTS",
    items: [
      { name: "Analytics", href: "/analytics", icon: BarChart2 },
      { name: "Sales Report", href: "/sales-report", icon: FileText },
      { name: "Users & Roles", href: "/users-roles", icon: Shield },
      { name: "SEO Settings", href: "/seo", icon: Globe },
      { name: "Website Settings", href: "/website-settings", icon: Settings },
    ]
  }
];

export default function Sidebar() {
  const { logout } = useAuth();
  const { isSidebarOpen, closeSidebar } = useSidebar();

  return (
    <>
      {/* Mobile Overlay */}
      {isSidebarOpen && (
        <div 
          className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 md:hidden transition-opacity"
          onClick={closeSidebar}
        />
      )}

      <aside className={`fixed inset-y-0 left-0 w-64 bg-[#14142B] flex flex-col z-50 text-gray-300 transform transition-transform duration-300 ease-in-out md:translate-x-0 ${isSidebarOpen ? 'translate-x-0' : '-translate-x-full'}`}>
      {/* Brand */}
      <div className="h-20 flex flex-col justify-center px-6 border-b border-[#2A2A42]">
        <div className="flex items-center gap-3 mb-1">
          <Gem className="w-8 h-8 text-amber-400" />
          <span className="text-xl font-serif font-bold text-amber-400 tracking-wide">JewelCraft</span>
        </div>
        <span className="text-xs text-gray-400 pl-11 font-medium">Admin Panel</span>
      </div>

      {/* Dashboard Primary Button */}
      <div className="p-4">
        <Link href="/" className="flex items-center gap-3 px-4 py-3 bg-[#2A2A42] text-amber-400 rounded-xl transition-all group">
          <LayoutDashboard className="w-5 h-5" />
          <span className="font-semibold text-sm">Dashboard</span>
        </Link>
      </div>

      {/* Navigation Groups */}
      <nav className="flex-1 px-4 overflow-y-auto pb-4 [&::-webkit-scrollbar]:hidden [-ms-overflow-style:none] [scrollbar-width:none]">
        {navigation.map((group, idx) => (
          <div key={idx} className="mb-6">
            <div className="px-4 text-[10px] font-bold text-gray-500 uppercase tracking-widest mb-2">
              {group.group}
            </div>
            <div className="space-y-1">
              {group.items.map((item) => (
                <Link
                  key={item.name}
                  href={item.href}
                  className="flex items-center gap-3 px-4 py-2.5 text-gray-400 hover:text-white hover:bg-[#2A2A42] rounded-xl transition-all group"
                >
                  <item.icon className="w-4 h-4 group-hover:text-white transition-colors" />
                  <span className="text-sm font-medium">{item.name}</span>
                </Link>
              ))}
            </div>
          </div>
        ))}
      </nav>

      {/* Footer Profile */}
      <div className="p-4 border-t border-[#2A2A42] flex items-center gap-3">
        <img 
          src="https://images.weserv.nl/?url=https://i.pravatar.cc/150?img=11" 
          alt="Profile" 
          className="w-10 h-10 rounded-full object-cover"
        />
        <div className="flex-1 min-w-0">
          <p className="text-sm font-semibold text-white truncate">Kuldeep Sengar</p>
          <p className="text-xs text-gray-400 truncate">Super Admin</p>
          <div className="flex items-center gap-1.5 mt-0.5">
            <div className="w-1.5 h-1.5 rounded-full bg-green-500"></div>
            <span className="text-[10px] text-gray-400">Online</span>
          </div>
        </div>
        <button onClick={logout} className="p-2 text-gray-400 hover:text-red-400 hover:bg-red-400/10 rounded-lg transition-colors">
          <LogOut className="w-5 h-5" />
        </button>
      </div>
    </aside>
    </>
  );
}
