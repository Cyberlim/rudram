"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { LayoutDashboard, Package, ShoppingBag, Users, Menu } from "lucide-react";
import { useSidebar } from "@/context/SidebarContext";

export default function BottomBar() {
  const pathname = usePathname();
  const { toggleSidebar } = useSidebar();

  const navItems = [
    { name: "Home", href: "/", icon: LayoutDashboard },
    { name: "Products", href: "/products", icon: Package },
    { name: "Orders", href: "/orders", icon: ShoppingBag },
    { name: "Customers", href: "/customers", icon: Users },
  ];

  return (
    <div className="md:hidden fixed bottom-0 left-0 right-0 bg-white dark:bg-[#14142B]/90 backdrop-blur-xl border-t border-gray-100 dark:border-[#2A2A42] flex items-center justify-around px-2 pb-[env(safe-area-inset-bottom)] pt-2 z-40 shadow-[0_-4px_20px_-10px_rgba(0,0,0,0.1)]">
      {navItems.map((item) => {
        const isActive = pathname === item.href;
        return (
          <Link
            key={item.name}
            href={item.href}
            className={`flex flex-col items-center gap-1 p-2 min-w-[64px] rounded-xl transition-all ${
              isActive 
                ? "text-amber-600" 
                : "text-gray-400 hover:text-gray-900 dark:hover:text-white"
            }`}
          >
            <div className={`p-1.5 rounded-lg transition-colors ${isActive ? 'bg-amber-100 dark:bg-amber-900/30' : ''}`}>
              <item.icon className={`w-5 h-5 ${isActive ? 'stroke-[2.5px]' : 'stroke-2'}`} />
            </div>
            <span className={`text-[10px] tracking-wide ${isActive ? 'font-bold' : 'font-medium'}`}>
              {item.name}
            </span>
          </Link>
        );
      })}
      
      <button
        onClick={toggleSidebar}
        className="flex flex-col items-center gap-1 p-2 min-w-[64px] rounded-xl text-gray-400 hover:text-gray-900 dark:hover:text-white transition-all"
      >
        <div className="p-1.5 rounded-lg">
          <Menu className="w-5 h-5 stroke-2" />
        </div>
        <span className="text-[10px] font-medium tracking-wide">Menu</span>
      </button>
    </div>
  );
}
