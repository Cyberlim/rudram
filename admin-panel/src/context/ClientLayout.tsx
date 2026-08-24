"use client";

import { usePathname } from "next/navigation";
import Sidebar from "@/components/Sidebar";
import Topbar from "@/components/Topbar";
import BottomBar from "@/components/BottomBar";
import { AuthProvider } from "./AuthContext";
import ProtectedRoute from "./ProtectedRoute";
import { SidebarProvider } from "./SidebarContext";

export default function ClientLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const isLoginPage = pathname === "/login";

  return (
    <AuthProvider>
      <ProtectedRoute>
        <SidebarProvider>
          {isLoginPage ? (
            <main className="min-h-screen bg-gray-50 dark:bg-[#0B0B1A] flex flex-col">{children}</main>
          ) : (
            <div className="min-h-screen flex text-gray-900 dark:text-gray-100 bg-gray-50 dark:bg-[#0B0B1A]/50">
              <Sidebar />
              <div className="flex-1 md:ml-64 flex flex-col min-h-screen w-full relative">
                <Topbar />
                <main className="flex-1 p-4 md:p-8 pb-24 md:pb-8 overflow-x-hidden">{children}</main>
                <BottomBar />
              </div>
            </div>
          )}
        </SidebarProvider>
      </ProtectedRoute>
    </AuthProvider>
  );
}
