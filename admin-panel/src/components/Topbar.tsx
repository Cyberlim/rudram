"use client";
import { useState, useRef, useEffect } from "react";
import { Menu, Bell, Mail, ShoppingBag, Users, Store, Sparkles, ChevronDown, CheckCircle2 } from "lucide-react";
import Link from "next/link";
import { useNotifications } from "@/hooks/useNotifications";
import { useSidebar } from "@/context/SidebarContext";

export default function Topbar() {
  const { notifications, unreadCount, markAsRead, markAllAsRead } = useNotifications('admin');
  const { toggleSidebar } = useSidebar();
  const [showNotifs, setShowNotifs] = useState(false);
  const notifRef = useRef<HTMLDivElement>(null);

  // Close dropdown when clicking outside
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (notifRef.current && !notifRef.current.contains(event.target as Node)) {
        setShowNotifs(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  return (
    <header className="h-20 bg-white dark:bg-[#14142B]/70 backdrop-blur-xl border-b border-gray-100 dark:border-[#2A2A42] flex items-center justify-between px-6 md:px-8 sticky top-0 z-40 shadow-sm transition-all">
      
      {/* Left section: Hamburger & Search */}
      <div className="flex items-center gap-4 flex-1">
        <button onClick={toggleSidebar} className="p-2 text-gray-500 hover:text-amber-600 hover:bg-amber-50 rounded-xl transition-colors md:hidden z-50">
          <Menu className="w-6 h-6" />
        </button>
      </div>

      {/* Center - Quick Actions (Premium Pills) */}
      <div className="hidden md:flex flex-1 justify-center items-center gap-2 lg:gap-3 px-2 overflow-x-auto" style={{ scrollbarWidth: 'none' }}>
        <Link href="/customers" className="group flex items-center gap-2 px-3 lg:px-4 py-2 rounded-full bg-gradient-to-r from-gray-900 to-gray-800 text-white text-sm font-medium hover:shadow-lg hover:shadow-gray-900/20 transition-all active:scale-95 whitespace-nowrap">
          <Users className="w-4 h-4 text-emerald-400 group-hover:scale-110 transition-transform duration-300 flex-shrink-0" />
          <span>Customers</span>
        </Link>
        <Link href="/vendors" className="flex items-center gap-2 px-3 lg:px-4 py-2 rounded-full bg-amber-50 text-amber-700 text-sm font-medium hover:bg-amber-100 hover:shadow-sm transition-all active:scale-95 border border-amber-100/50 whitespace-nowrap">
          <Store className="w-4 h-4 flex-shrink-0" />
          <span>Vendors</span>
        </Link>
        <Link href="/orders" className="flex items-center gap-2 px-3 lg:px-4 py-2 rounded-full bg-blue-50 text-blue-700 text-sm font-medium hover:bg-blue-100 hover:shadow-sm transition-all active:scale-95 border border-blue-100/50 whitespace-nowrap">
          <ShoppingBag className="w-4 h-4 flex-shrink-0" />
          <span>Orders</span>
        </Link>
      </div>

      {/* Right section: Icons & Profile */}
      <div className="flex items-center gap-5">
        
        {/* Notifications & Badges */}
        <div className="flex items-center gap-1 md:gap-2 relative">
          <button className="relative p-2.5 text-gray-400 hover:text-blue-600 hover:bg-blue-50 rounded-full transition-all group">
            <Mail className="w-5 h-5 group-hover:scale-110 transition-transform" />
          </button>
          
          <button 
            onClick={() => setShowNotifs(!showNotifs)}
            className="relative p-2.5 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded-full transition-all group"
          >
            <Bell className="w-5 h-5 group-hover:scale-110 transition-transform origin-top" />
            {unreadCount > 0 && (
              <span className="absolute top-1 right-1 w-4 h-4 bg-red-500 text-white text-[10px] font-bold flex items-center justify-center rounded-full border-2 border-white shadow-sm">
                {unreadCount > 9 ? '9+' : unreadCount}
              </span>
            )}
          </button>

          {/* Notifications Dropdown */}
          {showNotifs && (
            <div 
              ref={notifRef}
              className="absolute top-full right-0 mt-2 w-80 bg-white dark:bg-[#14142B] rounded-2xl shadow-xl border border-gray-100 dark:border-[#2A2A42] overflow-hidden z-50 transform origin-top-right transition-all"
            >
              <div className="flex items-center justify-between px-4 py-3 border-b border-gray-50 dark:border-[#2A2A42] bg-gray-50 dark:bg-[#0B0B1A]/50">
                <h3 className="font-bold text-gray-900 dark:text-gray-100">Notifications</h3>
                {unreadCount > 0 && (
                  <button 
                    onClick={() => markAllAsRead()}
                    className="text-xs font-medium text-amber-600 hover:text-amber-700 flex items-center gap-1"
                  >
                    <CheckCircle2 className="w-3 h-3" />
                    Mark all read
                  </button>
                )}
              </div>
              
              <div className="max-h-[320px] overflow-y-auto">
                {notifications.length === 0 ? (
                  <div className="px-4 py-8 text-center text-gray-500 text-sm">
                    No new notifications
                  </div>
                ) : (
                  notifications.map((notif) => (
                    <div 
                      key={notif.id} 
                      onClick={() => {
                        if (!notif.isRead) markAsRead(notif.id);
                      }}
                      className={`px-4 py-3 border-b border-gray-50 dark:border-[#2A2A42] hover:bg-gray-50 dark:bg-[#0B0B1A] cursor-pointer transition-colors ${!notif.isRead ? 'bg-amber-50/30' : ''}`}
                    >
                      <div className="flex gap-3">
                        <div className={`mt-1 w-2 h-2 rounded-full flex-shrink-0 ${!notif.isRead ? 'bg-amber-500' : 'bg-transparent'}`} />
                        <div>
                          <p className={`text-sm ${!notif.isRead ? 'font-bold text-gray-900 dark:text-gray-100' : 'font-medium text-gray-700 dark:text-gray-300'}`}>
                            {notif.title}
                          </p>
                          <p className="text-xs text-gray-500 mt-0.5 line-clamp-2">
                            {notif.message}
                          </p>
                        </div>
                      </div>
                    </div>
                  ))
                )}
              </div>
              <div className="px-4 py-2 border-t border-gray-50 dark:border-[#2A2A42] bg-gray-50 dark:bg-[#0B0B1A]/50 text-center">
                <Link href="/settings/notifications" className="text-xs font-medium text-gray-500 hover:text-gray-900 dark:text-gray-100">
                  View all notifications
                </Link>
              </div>
            </div>
          )}
        </div>

        <div className="h-8 w-px bg-gray-200 hidden md:block"></div>

        {/* User Profile */}
        <div className="flex items-center gap-3 cursor-pointer group p-1 pr-3 hover:bg-gray-50 dark:bg-[#0B0B1A] rounded-full border border-transparent hover:border-gray-200 dark:border-[#2A2A42] transition-all">
          <div className="relative">
            <img 
              src="https://ui-avatars.com/api/?name=Kuldeep+Sengar&background=f59e0b&color=fff&bold=true" 
              alt="Profile" 
              className="w-10 h-10 rounded-full object-cover shadow-sm ring-2 ring-white group-hover:ring-amber-200 transition-all"
            />
            <div className="absolute bottom-0 right-0 w-3 h-3 bg-green-500 border-2 border-white rounded-full shadow-sm"></div>
          </div>
          <div className="text-left hidden md:block">
            <p className="text-sm font-bold text-gray-900 dark:text-gray-100 group-hover:text-amber-600 transition-colors leading-tight flex items-center gap-1">
              Kuldeep Sengar
              <Sparkles className="w-3 h-3 text-amber-500 hidden group-hover:block animate-pulse" />
            </p>
            <p className="text-[11px] text-gray-500 font-medium">Super Admin</p>
          </div>
          <ChevronDown className="w-4 h-4 text-gray-400 group-hover:text-amber-600 transition-colors hidden md:block" />
        </div>

      </div>
    </header>
  );
}
