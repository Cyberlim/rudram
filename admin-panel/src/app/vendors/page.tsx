"use client";
import { Search, Store, Trash2, CheckCircle, XCircle, Eye, Clock, FileText, MapPin, CreditCard, Truck } from "lucide-react";
import { useState, useEffect } from "react";
import { db } from "@/lib/firebase";
import { collection, query, orderBy, onSnapshot, doc, deleteDoc, updateDoc } from "firebase/firestore";
import Fuse from "fuse.js";

interface Vendor {
  id: string;
  ownerName?: string;
  storeName?: string;
  email?: string;
  phone?: string;
  status?: string;
  businessType?: string;
  description?: string;
  address?: string;
  city?: string;
  state?: string;
  pinCode?: string;
  kycAadhaar?: string;
  kycPan?: string;
  kycGst?: string;
  bankHolderName?: string;
  bankAccountNumber?: string;
  bankIfsc?: string;
  bankName?: string;
  pickupAddress?: string;
  shippingProvider?: string;
  processingTime?: string;
  returnPolicy?: string;
  isKycVerified?: boolean;
  createdAt?: any;
  profilePhotoUrl?: string;
  storeLogoUrl?: string;
  storeBannerUrl?: string;
  idProofUrl?: string;
  businessCertUrl?: string;
  gstCertUrl?: string;
  bankProofUrl?: string;
  website?: string;
  instagram?: string;
  taxId?: string;
  vendorTier?: string;
  vipRequestStatus?: string;
}

export default function VendorsPage() {
  const [vendors, setVendors] = useState<Vendor[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [activeTab, setActiveTab] = useState<"pending" | "approved" | "rejected" | "all">("pending");
  const [selectedVendor, setSelectedVendor] = useState<Vendor | null>(null);
  const [actionLoading, setActionLoading] = useState<string | null>(null);

  useEffect(() => {
    const q = query(collection(db, "vendors"), orderBy("createdAt", "desc"));
    const unsub = onSnapshot(q, (snap) => {
      setVendors(snap.docs.map((d) => ({ id: d.id, ...d.data() })) as Vendor[]);
      setLoading(false);
    }, () => setLoading(false));
    return () => unsub();
  }, []);

  const handleApprove = async (id: string) => {
    setActionLoading(id + "_approve");
    await updateDoc(doc(db, "vendors", id), { status: "approved", isKycVerified: true, approvedAt: new Date() });
    setActionLoading(null);
    setSelectedVendor(null);
  };

  const handleReject = async (id: string) => {
    setActionLoading(id + "_reject");
    await updateDoc(doc(db, "vendors", id), { status: "rejected", rejectedAt: new Date() });
    setActionLoading(null);
    setSelectedVendor(null);
  };

  const handleDelete = async (id: string) => {
    if (confirm("Permanently delete this vendor?")) await deleteDoc(doc(db, "vendors", id));
  };

  const fuse = new Fuse(vendors, {
    keys: ["ownerName", "storeName", "email", "businessType"],
    threshold: 0.3,
  });

  const filtered = (search ? fuse.search(search).map(r => r.item) : vendors).filter((v) => {
    if (activeTab === "all") return true;
    return (v.status || "pending") === activeTab;
  });

  const counts = {
    pending: vendors.filter((v) => (v.status || "pending") === "pending").length,
    approved: vendors.filter((v) => v.status === "approved").length,
    rejected: vendors.filter((v) => v.status === "rejected").length,
    all: vendors.length,
  };

  const statusBadge = (status?: string) => {
    switch (status) {
      case "approved": return <span className="flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-semibold bg-emerald-100 text-emerald-700"><CheckCircle className="w-3 h-3" />Approved</span>;
      case "rejected": return <span className="flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-semibold bg-red-100 text-red-700"><XCircle className="w-3 h-3" />Rejected</span>;
      default: return <span className="flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-semibold bg-amber-100 text-amber-700"><Clock className="w-3 h-3" />Pending</span>;
    }
  };

  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-1000 ease-out pb-10">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black text-gray-900 dark:text-gray-100">Vendor Applications</h1>
          <p className="text-gray-500 mt-1">{loading ? "Loading..." : `${counts.pending} pending approval · ${counts.approved} approved`}</p>
        </div>
      </div>

      {/* Tabs */}
      <div className="flex gap-2 border-b border-gray-200 dark:border-[#2A2A42]">
        {(["pending", "approved", "rejected", "all"] as const).map((tab) => (
          <button
            key={tab}
            onClick={() => setActiveTab(tab)}
            className={`flex items-center gap-2 px-4 py-2.5 text-sm font-semibold border-b-2 transition-colors capitalize ${activeTab === tab ? "border-amber-500 text-amber-600" : "border-transparent text-gray-500 hover:text-gray-700 dark:text-gray-300"}`}
          >
            {tab}
            <span className={`px-2 py-0.5 rounded-full text-xs ${activeTab === tab ? "bg-amber-100 text-amber-700" : "bg-gray-100 text-gray-600"}`}>
              {counts[tab]}
            </span>
          </button>
        ))}
      </div>

      {/* Table */}
      <div className="bg-white dark:bg-[#14142B] rounded-2xl shadow-sm border border-gray-100 dark:border-[#2A2A42] overflow-hidden">
        <div className="p-4 border-b border-gray-100 dark:border-[#2A2A42] bg-gray-50 dark:bg-[#0B0B1A]/50">
          <div className="relative w-full md:w-96">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input
              type="text"
              placeholder="Search vendors..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full pl-10 pr-4 py-2 bg-white dark:bg-[#14142B] border border-gray-200 dark:border-[#2A2A42] rounded-lg text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none transition-all"
            />
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm whitespace-nowrap">
            <thead className="bg-gray-50 dark:bg-[#0B0B1A]/50">
              <tr className="text-gray-500 font-semibold border-b border-gray-100 dark:border-[#2A2A42]">
                <th className="py-4 px-6">Vendor / Store</th>
                <th className="py-4 px-6">Contact</th>
                <th className="py-4 px-6">Business Type</th>
                <th className="py-4 px-6">Applied On</th>
                <th className="py-4 px-6">Status</th>
                <th className="py-4 px-6 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {loading ? (
                <tr><td colSpan={6} className="py-10 text-center text-gray-400">Loading vendors...</td></tr>
              ) : filtered.length === 0 ? (
                <tr><td colSpan={6} className="py-10 text-center text-gray-400">No vendors found.</td></tr>
              ) : (
                filtered.map((item) => (
                  <tr key={item.id} className="hover:bg-gray-50 dark:bg-[#0B0B1A]/50 transition-colors">
                    <td className="py-4 px-6">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-lg bg-amber-50 flex items-center justify-center border border-amber-100 text-amber-600">
                          <Store className="w-5 h-5" />
                        </div>
                        <div>
                          <p className="font-bold text-gray-900 dark:text-gray-100">{item.storeName || "Unnamed Store"}</p>
                          <p className="text-xs text-gray-500">{item.ownerName || "—"}</p>
                        </div>
                      </div>
                    </td>
                    <td className="py-4 px-6">
                      <p className="text-gray-900 dark:text-gray-100 font-medium">{item.email || "—"}</p>
                      <p className="text-gray-500 text-xs">{item.phone || "—"}</p>
                    </td>
                    <td className="py-4 px-6 text-gray-600">{item.businessType || "—"}</td>
                    <td className="py-4 px-6 text-gray-500">
                      {item.createdAt?.toDate ? item.createdAt.toDate().toLocaleDateString("en-IN") : "—"}
                    </td>
                    <td className="py-4 px-6">{statusBadge(item.status)}</td>
                    <td className="py-4 px-6">
                      <div className="flex items-center justify-end gap-2">
                        <button
                          onClick={() => setSelectedVendor(item)}
                          className="flex items-center gap-1 text-blue-500 hover:text-blue-700 text-xs font-medium px-2 py-1 rounded hover:bg-blue-50 transition-colors"
                        >
                          <Eye className="w-3.5 h-3.5" /> View
                        </button>
                        {(item.status || "pending") === "pending" && (
                          <>
                            <button
                              onClick={() => handleApprove(item.id)}
                              disabled={actionLoading === item.id + "_approve"}
                              className="flex items-center gap-1 text-emerald-600 hover:text-emerald-800 text-xs font-medium px-2 py-1 rounded hover:bg-emerald-50 transition-colors disabled:opacity-50"
                            >
                              <CheckCircle className="w-3.5 h-3.5" />
                              {actionLoading === item.id + "_approve" ? "..." : "Approve"}
                            </button>
                            <button
                              onClick={() => handleReject(item.id)}
                              disabled={actionLoading === item.id + "_reject"}
                              className="flex items-center gap-1 text-red-500 hover:text-red-700 text-xs font-medium px-2 py-1 rounded hover:bg-red-50 transition-colors disabled:opacity-50"
                            >
                              <XCircle className="w-3.5 h-3.5" />
                              {actionLoading === item.id + "_reject" ? "..." : "Reject"}
                            </button>
                          </>
                        )}
                        <button onClick={() => handleDelete(item.id)} className="text-red-400 hover:text-red-600 p-1 rounded-md hover:bg-red-50 transition-colors">
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Vendor Detail Modal */}
      {selectedVendor && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4" onClick={() => setSelectedVendor(null)}>
          <div className="bg-white dark:bg-[#14142B] rounded-2xl shadow-2xl w-full max-w-3xl max-h-[90vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            {/* Modal Header */}
            <div className="p-6 border-b border-gray-100 dark:border-[#2A2A42] flex items-center justify-between sticky top-0 bg-white dark:bg-[#14142B] z-10">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 rounded-xl bg-amber-50 flex items-center justify-center">
                  <Store className="w-6 h-6 text-amber-600" />
                </div>
                <div>
                  <h2 className="text-lg font-bold text-gray-900 dark:text-gray-100">{selectedVendor.storeName || "Unnamed Store"}</h2>
                  <p className="text-sm text-gray-500">{selectedVendor.ownerName} · {selectedVendor.businessType}</p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                {statusBadge(selectedVendor.status)}
                <button onClick={() => setSelectedVendor(null)} className="text-gray-400 hover:text-gray-600 text-2xl leading-none">×</button>
              </div>
            </div>

            <div className="p-6 space-y-6">
              {/* Contact Info */}
              <Section title="Contact Information" icon={<FileText className="w-4 h-4" />}>
                <InfoRow label="Owner Name" value={selectedVendor.ownerName} />
                <InfoRow label="Email" value={selectedVendor.email} />
                <InfoRow label="Phone" value={selectedVendor.phone} />
                <InfoRow label="Business Type" value={selectedVendor.businessType} />
                <InfoRow label="Description" value={selectedVendor.description} />
              </Section>

              {/* Online Presence & Store Settings */}
              <Section title="Online Presence & Store Settings" icon={<FileText className="w-4 h-4" />}>
                <InfoRow label="Website" value={selectedVendor.website} />
                <InfoRow label="Instagram" value={selectedVendor.instagram} />
                <InfoRow label="Tax ID" value={selectedVendor.taxId} />
                <InfoRow label="Vendor Tier" value={selectedVendor.vendorTier || "Normal"} />
                <InfoRow label="VIP Request Status" value={selectedVendor.vipRequestStatus || "None"} />
              </Section>

              {/* Address */}
              <Section title="Business Address" icon={<MapPin className="w-4 h-4" />}>
                <InfoRow label="Address" value={selectedVendor.address} />
                <InfoRow label="City" value={selectedVendor.city} />
                <InfoRow label="State" value={selectedVendor.state} />
                <InfoRow label="PIN Code" value={selectedVendor.pinCode} />
              </Section>

              {/* KYC */}
              <Section title="KYC & Verification" icon={<CreditCard className="w-4 h-4" />}>
                <InfoRow label="Aadhaar Number" value={selectedVendor.kycAadhaar} masked />
                <InfoRow label="PAN Number" value={selectedVendor.kycPan} />
                <InfoRow label="GSTIN" value={selectedVendor.kycGst} />
              </Section>

              {/* Bank */}
              <Section title="Bank Details" icon={<CreditCard className="w-4 h-4" />}>
                <InfoRow label="Account Holder" value={selectedVendor.bankHolderName} />
                <InfoRow label="Account Number" value={selectedVendor.bankAccountNumber} masked />
                <InfoRow label="IFSC Code" value={selectedVendor.bankIfsc} />
                <InfoRow label="Bank Name" value={selectedVendor.bankName} />
              </Section>

              {/* Shipping */}
              <Section title="Shipping Details" icon={<Truck className="w-4 h-4" />}>
                <InfoRow label="Pickup Address" value={selectedVendor.pickupAddress} />
                <InfoRow label="Shipping Provider" value={selectedVendor.shippingProvider} />
                <InfoRow label="Processing Time" value={selectedVendor.processingTime} />
                <InfoRow label="Return Policy" value={selectedVendor.returnPolicy} />
              </Section>
              
              {/* Documents */}
              {(selectedVendor.profilePhotoUrl || selectedVendor.storeLogoUrl || selectedVendor.storeBannerUrl || selectedVendor.idProofUrl || selectedVendor.businessCertUrl || selectedVendor.gstCertUrl || selectedVendor.bankProofUrl) && (
                <Section title="Uploaded Documents" icon={<FileText className="w-4 h-4" />}>
                  <DocumentRow label="Profile Photo" url={selectedVendor.profilePhotoUrl} />
                  <DocumentRow label="Store Logo" url={selectedVendor.storeLogoUrl} />
                  <DocumentRow label="Store Banner" url={selectedVendor.storeBannerUrl} />
                  <DocumentRow label="ID Proof" url={selectedVendor.idProofUrl} />
                  <DocumentRow label="Business Certificate" url={selectedVendor.businessCertUrl} />
                  <DocumentRow label="GST Certificate" url={selectedVendor.gstCertUrl} />
                  <DocumentRow label="Bank Proof (Cancelled Cheque)" url={selectedVendor.bankProofUrl} />
                </Section>
              )}
            </div>

            {/* Modal Footer Actions */}
            {(selectedVendor.status || "pending") === "pending" && (
              <div className="p-6 border-t border-gray-100 dark:border-[#2A2A42] flex items-center justify-end gap-3 sticky bottom-0 bg-white dark:bg-[#14142B]">
                <button
                  onClick={() => handleReject(selectedVendor.id)}
                  disabled={!!actionLoading}
                  className="flex items-center gap-2 px-6 py-2.5 border border-red-200 text-red-600 hover:bg-red-50 rounded-xl font-semibold transition-colors disabled:opacity-50"
                >
                  <XCircle className="w-4 h-4" />
                  {actionLoading === selectedVendor.id + "_reject" ? "Rejecting..." : "Reject Application"}
                </button>
                <button
                  onClick={() => handleApprove(selectedVendor.id)}
                  disabled={!!actionLoading}
                  className="flex items-center gap-2 px-6 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-semibold transition-colors disabled:opacity-50"
                >
                  <CheckCircle className="w-4 h-4" />
                  {actionLoading === selectedVendor.id + "_approve" ? "Approving..." : "Approve Vendor"}
                </button>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

function Section({ title, icon, children }: { title: string; icon: React.ReactNode; children: React.ReactNode }) {
  return (
    <div>
      <div className="flex items-center gap-2 mb-3">
        <div className="text-amber-600">{icon}</div>
        <h3 className="font-bold text-gray-800 dark:text-gray-200 text-sm uppercase tracking-wide">{title}</h3>
      </div>
      <div className="bg-gray-50 dark:bg-[#0B0B1A] rounded-xl p-4 grid grid-cols-1 md:grid-cols-2 gap-3">
        {children}
      </div>
    </div>
  );
}

function InfoRow({ label, value, masked }: { label: string; value?: string; masked?: boolean }) {
  const display = value || "—";
  const shown = masked && value && value.length > 4 ? ("•".repeat(value.length - 4) + value.slice(-4)) : display;
  return (
    <div>
      <p className="text-xs text-gray-500 font-medium">{label}</p>
      <p className="text-sm text-gray-900 dark:text-gray-100 font-semibold mt-0.5">{shown}</p>
    </div>
  );
}

function DocumentRow({ label, url }: { label: string; url?: string }) {
  if (!url) return null;
  return (
    <div className="flex flex-col gap-2">
      <p className="text-xs text-gray-500 font-medium">{label}</p>
      <a href={url} target="_blank" rel="noopener noreferrer" className="block group relative rounded-lg overflow-hidden border border-gray-200 dark:border-[#2A2A42] bg-white dark:bg-[#14142B] shadow-sm hover:shadow-md transition-shadow">
        <div className="aspect-video w-full bg-gray-100 flex items-center justify-center relative">
          {url.toLowerCase().endsWith('.pdf') ? (
            <div className="flex flex-col items-center text-red-500">
              <FileText className="w-8 h-8 mb-2" />
              <span className="text-xs font-semibold">PDF Document</span>
            </div>
          ) : (
            <img src={url} alt={label} className="w-full h-full object-cover" />
          )}
          <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
            <span className="text-white text-xs font-bold px-3 py-1.5 bg-black/50 rounded-full backdrop-blur-sm flex items-center gap-1.5">
              <Eye className="w-3.5 h-3.5" /> View Full
            </span>
          </div>
        </div>
      </a>
    </div>
  );
}