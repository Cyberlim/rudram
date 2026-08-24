"use client";

import { useState } from "react";
import { signInWithPopup } from "firebase/auth";
import { auth, googleProvider } from "@/lib/firebase";
import { useRouter } from "next/navigation";
import { Loader2, Diamond, Shield, AlertCircle, ShieldX } from "lucide-react";

// ✅ Only these emails are allowed to access the admin panel
const ALLOWED_ADMINS = ["kuldeepsengar5678@gmail.com"];

export default function LoginPage() {
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  const handleGoogleLogin = async () => {
    setError("");
    setLoading(true);

    try {
      const result = await signInWithPopup(auth, googleProvider);
      const email = result.user.email || "";

      // Check if the signed-in email is in the allowed list
      if (!ALLOWED_ADMINS.includes(email.toLowerCase())) {
        // Sign them out immediately — not authorized
        await auth.signOut();
        setError(`Access denied for ${email}. This admin panel is restricted to authorized accounts only.`);
        setLoading(false);
        return;
      }

      // ✅ Authorized — go to dashboard
      router.push("/");
    } catch (err: any) {
      if (err.code === "auth/popup-closed-by-user") {
        setError("Sign-in was cancelled. Please try again.");
      } else {
        setError("Sign-in failed. Please try again.");
      }
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex bg-gray-50 dark:bg-[#0B0B1A]">
      {/* Left decorative panel */}
      <div className="hidden lg:flex lg:w-1/2 relative overflow-hidden bg-gradient-to-br from-[#2A1C40] via-[#3d2860] to-[#1a1128] items-center justify-center p-16">
        {/* Background rings */}
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="w-[600px] h-[600px] rounded-full border border-white/5 absolute" />
          <div className="w-[450px] h-[450px] rounded-full border border-white/5 absolute" />
          <div className="w-[300px] h-[300px] rounded-full border border-white/5 absolute" />
        </div>
        {/* Gold accent dots */}
        <div className="absolute top-20 right-20 w-3 h-3 rounded-full bg-amber-400/40" />
        <div className="absolute bottom-32 left-24 w-2 h-2 rounded-full bg-amber-400/30" />
        <div className="absolute top-1/3 left-16 w-4 h-4 rounded-full bg-amber-400/20" />

        <div className="relative text-center">
          <div className="flex items-center justify-center gap-3 mb-8">
            <Diamond className="w-12 h-12 text-amber-400" />
          </div>
          <h1 className="text-5xl font-black text-white mb-2 tracking-tight">JewelCraft</h1>
          <p className="text-amber-400 font-semibold text-lg tracking-widest uppercase mb-12">Admin Panel</p>
          <div className="w-16 h-0.5 bg-amber-400/40 mx-auto mb-12" />
          <p className="text-white/50 text-sm leading-relaxed max-w-xs mx-auto">
            Manage your jewelry marketplace — vendors, products, orders, and more — all in one powerful dashboard.
          </p>

          {/* Stats */}
          <div className="mt-16 grid grid-cols-3 gap-4">
            {[["Vendors", "24+"], ["Products", "1.2k+"], ["Orders", "450+"]].map(([label, val]) => (
              <div key={label} className="bg-white dark:bg-[#14142B]/5 rounded-2xl p-4 border border-white/10">
                <p className="text-amber-400 font-black text-xl">{val}</p>
                <p className="text-white/50 text-xs mt-1">{label}</p>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Right login panel */}
      <div className="w-full lg:w-1/2 flex items-center justify-center p-8">
        <div className="w-full max-w-md">
          {/* Mobile logo */}
          <div className="flex items-center gap-3 mb-10 lg:hidden">
            <Diamond className="w-8 h-8 text-amber-500" />
            <div>
              <p className="text-xl font-black text-gray-900 dark:text-gray-100">JewelCraft</p>
              <p className="text-xs text-gray-500 tracking-widest uppercase">Admin Panel</p>
            </div>
          </div>

          <div className="mb-10">
            <div className="inline-flex items-center gap-2 bg-amber-50 border border-amber-200 rounded-full px-3 py-1.5 mb-6">
              <Shield className="w-3.5 h-3.5 text-amber-600" />
              <span className="text-xs font-semibold text-amber-700">Restricted Access</span>
            </div>
            <h2 className="text-3xl font-black text-gray-900 dark:text-gray-100 mb-2">Welcome back</h2>
            <p className="text-gray-500 text-sm">Sign in with your authorized Google account to continue.</p>
          </div>

          {error && (
            <div className="mb-6 p-4 bg-red-50 border border-red-100 rounded-xl flex items-start gap-3">
              <ShieldX className="w-5 h-5 text-red-500 shrink-0 mt-0.5" />
              <p className="text-sm text-red-700">{error}</p>
            </div>
          )}

          {/* Google Sign-In Button */}
          <button
            onClick={handleGoogleLogin}
            disabled={loading}
            className="w-full flex items-center justify-center gap-3 py-4 px-6 bg-white dark:bg-[#14142B] border-2 border-gray-200 dark:border-[#2A2A42] hover:border-amber-400 hover:bg-amber-50/30 rounded-2xl text-sm font-semibold text-gray-700 dark:text-gray-300 transition-all shadow-sm hover:shadow-md disabled:opacity-50 disabled:cursor-not-allowed active:scale-[0.99] group"
          >
            {loading ? (
              <Loader2 className="w-5 h-5 animate-spin text-amber-500" />
            ) : (
              <>
                {/* Google Logo SVG */}
                <svg className="w-5 h-5" viewBox="0 0 24 24">
                  <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" />
                  <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" />
                  <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" />
                  <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" />
                </svg>
                Continue with Google
              </>
            )}
          </button>

          {/* Security notice */}
          <div className="mt-6 p-4 bg-gray-50 dark:bg-[#0B0B1A] border border-gray-100 dark:border-[#2A2A42] rounded-xl flex items-start gap-3">
            <AlertCircle className="w-4 h-4 text-gray-400 shrink-0 mt-0.5" />
            <p className="text-xs text-gray-500 leading-relaxed">
              This panel is restricted to <span className="font-semibold text-gray-700 dark:text-gray-300">authorized administrators only</span>. 
              Unauthorized access attempts are logged.
            </p>
          </div>

          <p className="mt-8 text-center text-xs text-gray-400">
            © {new Date().getFullYear()} JewelCraft · All rights reserved
          </p>
        </div>
      </div>
    </div>
  );
}
