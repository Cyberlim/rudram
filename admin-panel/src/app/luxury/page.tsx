"use client";
import { useState, useEffect } from "react";
import {
  Plus, Trash2, Edit2, Save, X, Eye, EyeOff, Crown, Gem, Sparkles, Star,
  Image as ImageIcon, Diamond
} from "lucide-react";
import { db } from "@/lib/firebase";
import {
  collection, onSnapshot, doc, deleteDoc, setDoc, updateDoc, serverTimestamp
} from "firebase/firestore";

interface LuxuryFeature { icon: string; text: string; }
interface LuxurySlide { id: string; image: string; headline: string; description: string; features: LuxuryFeature[]; order: number; active: boolean; }
interface LuxuryProduct { id: string; title: string; price: string; image: string; order: number; active: boolean; }

const ICON_OPTIONS = ["auto_awesome","verified_user","diamond","star_border","eco_outlined","design_services","balance","history_edu","workspace_premium","shopping_bag","favorite_border","local_shipping"];

const emptySlide = () => ({ image: "", headline: "", description: "", features: [{ icon: "diamond", text: "" }], order: 0, active: true });
const emptyProduct = () => ({ title: "", price: "", image: "", order: 0, active: true });

export default function LuxuryAdminPage() {
  const [activeTab, setActiveTab] = useState<"slides"|"products">("slides");
  const [slides, setSlides] = useState<LuxurySlide[]>([]);
  const [editingSlide, setEditingSlide] = useState<LuxurySlide|null>(null);
  const [isAddingSlide, setIsAddingSlide] = useState(false);
  const [newSlide, setNewSlide] = useState(emptySlide());
  const [products, setProducts] = useState<LuxuryProduct[]>([]);
  const [editingProduct, setEditingProduct] = useState<LuxuryProduct|null>(null);
  const [isAddingProduct, setIsAddingProduct] = useState(false);
  const [newProduct, setNewProduct] = useState(emptyProduct());
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    const u1 = onSnapshot(collection(db, "luxury_slides"), (snap) => {
      setSlides(snap.docs.map(d => ({ id: d.id, ...d.data() } as LuxurySlide)).sort((a,b) => (a.order??0)-(b.order??0)));
    });
    const u2 = onSnapshot(collection(db, "luxury_products"), (snap) => {
      setProducts(snap.docs.map(d => ({ id: d.id, ...d.data() } as LuxuryProduct)).sort((a,b) => (a.order??0)-(b.order??0)));
    });
    return () => { u1(); u2(); };
  }, []);

  const saveSlide = async (slide: LuxurySlide) => {
    setSaving(true);
    try { await setDoc(doc(db, "luxury_slides", slide.id), { ...slide, updatedAt: serverTimestamp() }); setEditingSlide(null); }
    finally { setSaving(false); }
  };

  const addSlide = async () => {
    if (!newSlide.headline.trim() || !newSlide.image.trim()) return;
    setSaving(true);
    try {
      const id = `slide_${Date.now()}`;
      await setDoc(doc(db, "luxury_slides", id), { ...newSlide, order: slides.length, createdAt: serverTimestamp() });
      setNewSlide(emptySlide()); setIsAddingSlide(false);
    } finally { setSaving(false); }
  };

  const deleteSlide = async (id: string) => { if (!confirm("Delete this slide?")) return; await deleteDoc(doc(db, "luxury_slides", id)); };
  const toggleSlide = async (slide: LuxurySlide) => { await updateDoc(doc(db, "luxury_slides", slide.id), { active: !slide.active }); };

  const saveProduct = async (p: LuxuryProduct) => {
    setSaving(true);
    try { await setDoc(doc(db, "luxury_products", p.id), { ...p, updatedAt: serverTimestamp() }); setEditingProduct(null); }
    finally { setSaving(false); }
  };

  const addProduct = async () => {
    if (!newProduct.title.trim() || !newProduct.image.trim()) return;
    setSaving(true);
    try {
      const id = `luxprod_${Date.now()}`;
      await setDoc(doc(db, "luxury_products", id), { ...newProduct, order: products.length, createdAt: serverTimestamp() });
      setNewProduct(emptyProduct()); setIsAddingProduct(false);
    } finally { setSaving(false); }
  };

  const deleteProduct = async (id: string) => { if (!confirm("Delete this product?")) return; await deleteDoc(doc(db, "luxury_products", id)); };
  const toggleProduct = async (p: LuxuryProduct) => { await updateDoc(doc(db, "luxury_products", p.id), { active: !p.active }); };

  const setFeature = (features: LuxuryFeature[], i: number, key: keyof LuxuryFeature, val: string) =>
    features.map((f, idx) => idx === i ? { ...f, [key]: val } : f);

  return (
    <div className="p-6 md:p-8 max-w-7xl mx-auto">
      <div className="mb-8">
        <div className="flex items-center gap-3 mb-2">
          <div className="p-2.5 bg-gradient-to-br from-amber-400 to-yellow-600 rounded-xl shadow-lg">
            <Crown className="w-6 h-6 text-white" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">Luxury Section</h1>
            <p className="text-sm text-gray-500">Manage carousel slides & featured luxury products shown in the app</p>
          </div>
        </div>

        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-6">
          {[
            { label: "Total Slides", value: slides.length, color: "text-amber-600 bg-amber-50" },
            { label: "Active Slides", value: slides.filter(s=>s.active).length, color: "text-green-600 bg-green-50" },
            { label: "Luxury Products", value: products.length, color: "text-purple-600 bg-purple-50" },
            { label: "Active Products", value: products.filter(p=>p.active).length, color: "text-blue-600 bg-blue-50" },
          ].map((s) => (
            <div key={s.label} className="bg-white dark:bg-[#14142B] rounded-2xl border border-gray-100 dark:border-[#2A2A42] p-4 shadow-sm">
              <p className={`text-2xl font-bold ${s.color.split(" ")[0]}`}>{s.value}</p>
              <p className="text-xs text-gray-500 mt-0.5">{s.label}</p>
            </div>
          ))}
        </div>
      </div>

      <div className="flex gap-2 mb-6 border-b border-gray-200 dark:border-[#2A2A42]">
        {(["slides","products"] as const).map(tab => (
          <button key={tab} onClick={() => setActiveTab(tab)} className={`px-5 py-2.5 text-sm font-semibold capitalize transition-all border-b-2 -mb-px ${activeTab===tab ? "border-amber-500 text-amber-700" : "border-transparent text-gray-500 hover:text-gray-700 dark:text-gray-300"}`}>
            {tab === "slides" ? "🎠 Desktop Carousel Slides" : "💎 Mobile Luxury Products"}
          </button>
        ))}
      </div>

      {activeTab === "slides" && (
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <p className="text-sm text-gray-500">These slides appear in the desktop luxury carousel with image, headline & features.</p>
            <button onClick={() => setIsAddingSlide(true)} className="flex items-center gap-2 px-4 py-2 bg-gray-900 text-white text-sm font-medium rounded-xl hover:bg-gray-800 transition-all">
              <Plus className="w-4 h-4 text-amber-400" /> Add Slide
            </button>
          </div>

          {isAddingSlide && (
            <SlideForm slide={newSlide as any} onChange={setNewSlide as any} onSave={addSlide} onCancel={() => { setIsAddingSlide(false); setNewSlide(emptySlide()); }} saving={saving} isNew setFeature={setFeature} />
          )}

          {slides.length === 0 && !isAddingSlide ? (
            <EmptyState icon={Sparkles} label="No luxury slides yet" sub="Add slides to power the desktop carousel" />
          ) : slides.map(slide => (
            <div key={slide.id}>
              {editingSlide?.id === slide.id ? (
                <SlideForm slide={editingSlide} onChange={setEditingSlide} onSave={() => saveSlide(editingSlide)} onCancel={() => setEditingSlide(null)} saving={saving} setFeature={setFeature} />
              ) : (
                <SlideCard slide={slide} onEdit={() => setEditingSlide({...slide})} onDelete={() => deleteSlide(slide.id)} onToggle={() => toggleSlide(slide)} />
              )}
            </div>
          ))}
        </div>
      )}

      {activeTab === "products" && (
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <p className="text-sm text-gray-500">These products appear in the mobile Luxury Collection horizontal scroll section.</p>
            <button onClick={() => setIsAddingProduct(true)} className="flex items-center gap-2 px-4 py-2 bg-gray-900 text-white text-sm font-medium rounded-xl hover:bg-gray-800 transition-all">
              <Plus className="w-4 h-4 text-amber-400" /> Add Product
            </button>
          </div>

          {isAddingProduct && (
            <ProductForm product={newProduct as any} onChange={setNewProduct as any} onSave={addProduct} onCancel={() => { setIsAddingProduct(false); setNewProduct(emptyProduct()); }} saving={saving} isNew />
          )}

          {products.length === 0 && !isAddingProduct ? (
            <EmptyState icon={Gem} label="No luxury products yet" sub="Add products to power the mobile luxury scroll" />
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {products.map(p => editingProduct?.id === p.id ? (
                <ProductForm key={p.id} product={editingProduct} onChange={setEditingProduct} onSave={() => saveProduct(editingProduct)} onCancel={() => setEditingProduct(null)} saving={saving} />
              ) : (
                <ProductCard key={p.id} product={p} onEdit={() => setEditingProduct({...p})} onDelete={() => deleteProduct(p.id)} onToggle={() => toggleProduct(p)} />
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
}

function SlideCard({ slide, onEdit, onDelete, onToggle }: { slide: LuxurySlide; onEdit: () => void; onDelete: () => void; onToggle: () => void; }) {
  return (
    <div className={`bg-white dark:bg-[#14142B] rounded-2xl border shadow-sm overflow-hidden ${!slide.active && "opacity-60"}`}>
      <div className="flex gap-0">
        <div className="w-48 h-36 flex-shrink-0 relative bg-gray-100">
          {slide.image ? <img src={slide.image} alt="" className="w-full h-full object-cover" /> : <div className="w-full h-full flex items-center justify-center"><ImageIcon className="w-8 h-8 text-gray-300" /></div>}
          <div className="absolute top-2 left-2"><span className="bg-white dark:bg-[#14142B]/90 text-gray-700 dark:text-gray-300 text-[10px] font-bold px-2 py-0.5 rounded-full uppercase tracking-widest">RARE COLLECTION</span></div>
        </div>
        <div className="flex-1 p-4">
          <div className="flex items-start justify-between gap-2">
            <div>
              <p className="text-[10px] font-bold text-amber-600 uppercase tracking-widest mb-1">THE LUXURY EXPERIENCE</p>
              <h3 className="text-base font-bold text-gray-900 dark:text-gray-100 leading-tight whitespace-pre-line">{slide.headline || <span className="text-gray-400 italic">No headline</span>}</h3>
              <p className="text-xs text-gray-500 mt-1 line-clamp-2">{slide.description}</p>
            </div>
            <div className="flex items-center gap-1.5 flex-shrink-0">
              <button onClick={onToggle} className={`p-1.5 rounded-lg transition-colors ${slide.active ? "text-green-600 bg-green-50 hover:bg-green-100" : "text-gray-400 bg-gray-50 dark:bg-[#0B0B1A] hover:bg-gray-100"}`}>{slide.active ? <Eye className="w-4 h-4" /> : <EyeOff className="w-4 h-4" />}</button>
              <button onClick={onEdit} className="p-1.5 rounded-lg text-blue-600 bg-blue-50 hover:bg-blue-100 transition-colors"><Edit2 className="w-4 h-4" /></button>
              <button onClick={onDelete} className="p-1.5 rounded-lg text-red-500 bg-red-50 hover:bg-red-100 transition-colors"><Trash2 className="w-4 h-4" /></button>
            </div>
          </div>
          <div className="flex flex-wrap gap-2 mt-3">
            {slide.features?.map((f, i) => (
              <span key={i} className="flex items-center gap-1 text-[11px] bg-amber-50 text-amber-700 border border-amber-100 px-2 py-0.5 rounded-full">
                <Diamond className="w-3 h-3" />{f.text || "Feature"}
              </span>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

function SlideForm({ slide, onChange, onSave, onCancel, saving, isNew, setFeature }: any) {
  const set = (key: string, val: any) => onChange({ ...slide, [key]: val });
  return (
    <div className="bg-white dark:bg-[#14142B] border-2 border-amber-200 rounded-2xl p-5 shadow-md">
      <h3 className="font-bold text-gray-800 dark:text-gray-200 mb-4 flex items-center gap-2"><Crown className="w-4 h-4 text-amber-500" />{isNew ? "New Luxury Slide" : "Edit Slide"}</h3>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="md:col-span-2">
          <label className="block text-xs font-semibold text-gray-600 mb-1">Image URL</label>
          <div className="flex gap-2">
            <input value={slide.image} onChange={e => set("image", e.target.value)} placeholder="https://..." className="flex-1 border border-gray-200 dark:border-[#2A2A42] rounded-xl px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-amber-400/30 focus:border-amber-400" />
            {slide.image && <img src={slide.image} alt="" className="w-10 h-10 object-cover rounded-lg border border-gray-200 dark:border-[#2A2A42] flex-shrink-0" onError={e => (e.currentTarget.style.display="none")} />}
          </div>
        </div>
        <div>
          <label className="block text-xs font-semibold text-gray-600 mb-1">Headline (use \n for line breaks)</label>
          <textarea value={slide.headline} onChange={e => set("headline", e.target.value)} placeholder={"Bridal Heritage\nmeets Modern Fine Art"} rows={2} className="w-full border border-gray-200 dark:border-[#2A2A42] rounded-xl px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-amber-400/30 focus:border-amber-400 resize-none" />
        </div>
        <div>
          <label className="block text-xs font-semibold text-gray-600 mb-1">Description</label>
          <textarea value={slide.description} onChange={e => set("description", e.target.value)} placeholder="Elevate your presence with..." rows={2} className="w-full border border-gray-200 dark:border-[#2A2A42] rounded-xl px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-amber-400/30 focus:border-amber-400 resize-none" />
        </div>
        <div className="md:col-span-2">
          <label className="block text-xs font-semibold text-gray-600 mb-2">Features</label>
          <div className="space-y-2">
            {(slide.features||[]).map((f: LuxuryFeature, i: number) => (
              <div key={i} className="flex gap-2 items-center">
                <select value={f.icon} onChange={e => set("features", setFeature(slide.features, i, "icon", e.target.value))} className="border border-gray-200 dark:border-[#2A2A42] rounded-lg px-2 py-1.5 text-xs outline-none focus:border-amber-400 bg-white dark:bg-[#14142B]">
                  {ICON_OPTIONS.map(ic => <option key={ic} value={ic}>{ic}</option>)}
                </select>
                <input value={f.text} onChange={e => set("features", setFeature(slide.features, i, "text", e.target.value))} placeholder="Feature label..." className="flex-1 border border-gray-200 dark:border-[#2A2A42] rounded-lg px-3 py-1.5 text-sm outline-none focus:border-amber-400" />
                <button onClick={() => set("features", slide.features.filter((_: any, idx: number) => idx !== i))} className="p-1.5 text-red-400 hover:bg-red-50 rounded-lg"><X className="w-3.5 h-3.5" /></button>
              </div>
            ))}
            <button onClick={() => set("features", [...(slide.features||[]), {icon:"diamond",text:""}])} className="flex items-center gap-1 text-xs text-amber-600 hover:text-amber-700 font-medium"><Plus className="w-3.5 h-3.5" /> Add Feature</button>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <label className="text-xs font-semibold text-gray-600">Active</label>
          <button onClick={() => set("active", !slide.active)} className={`relative w-9 h-5 rounded-full transition-colors ${slide.active ? "bg-green-500" : "bg-gray-300"}`}>
            <div className={`absolute top-0.5 w-4 h-4 bg-white dark:bg-[#14142B] rounded-full shadow-sm transition-all ${slide.active ? "left-4" : "left-0.5"}`} />
          </button>
        </div>
      </div>
      <div className="flex gap-2 mt-4">
        <button onClick={onSave} disabled={saving} className="flex items-center gap-2 px-4 py-2 bg-gray-900 text-white text-sm font-medium rounded-xl hover:bg-gray-800 transition-all disabled:opacity-50"><Save className="w-4 h-4" />{saving ? "Saving..." : "Save Slide"}</button>
        <button onClick={onCancel} className="px-4 py-2 text-sm text-gray-600 hover:bg-gray-100 rounded-xl transition-all">Cancel</button>
      </div>
    </div>
  );
}

function ProductCard({ product, onEdit, onDelete, onToggle }: { product: LuxuryProduct; onEdit: () => void; onDelete: () => void; onToggle: () => void; }) {
  return (
    <div className="bg-white dark:bg-[#14142B] rounded-2xl border shadow-sm overflow-hidden">
      <div className="relative h-44 bg-gray-100">
        {product.image ? <img src={product.image} alt={product.title} className="w-full h-full object-cover" /> : <div className="w-full h-full flex items-center justify-center"><Gem className="w-12 h-12 text-gray-200" /></div>}
        <div className="absolute top-2 right-2 flex gap-1">
          <button onClick={onToggle} className={`p-1.5 rounded-lg backdrop-blur-sm shadow-sm ${product.active ? "bg-green-500/90 text-white" : "bg-white dark:bg-[#14142B]/80 text-gray-400"}`}>{product.active ? <Eye className="w-3.5 h-3.5" /> : <EyeOff className="w-3.5 h-3.5" />}</button>
          <button onClick={onEdit} className="p-1.5 rounded-lg bg-white dark:bg-[#14142B]/80 text-blue-600 backdrop-blur-sm shadow-sm"><Edit2 className="w-3.5 h-3.5" /></button>
          <button onClick={onDelete} className="p-1.5 rounded-lg bg-white dark:bg-[#14142B]/80 text-red-500 backdrop-blur-sm shadow-sm"><Trash2 className="w-3.5 h-3.5" /></button>
        </div>
      </div>
      <div className="p-4 bg-[#1A1A1A]">
        <p className="text-white font-semibold text-sm">{product.title || "Untitled"}</p>
        <p className="text-amber-500 font-bold text-lg mt-1">{product.price || "—"}</p>
      </div>
    </div>
  );
}

function ProductForm({ product, onChange, onSave, onCancel, saving, isNew }: any) {
  const set = (key: string, val: any) => onChange({ ...product, [key]: val });
  return (
    <div className="bg-white dark:bg-[#14142B] border-2 border-amber-200 rounded-2xl p-4 shadow-md">
      <h3 className="font-bold text-gray-800 dark:text-gray-200 mb-3 flex items-center gap-2 text-sm"><Gem className="w-4 h-4 text-amber-500" />{isNew ? "New Luxury Product" : "Edit Product"}</h3>
      <div className="space-y-3">
        <div>
          <label className="block text-xs font-semibold text-gray-600 mb-1">Image URL</label>
          <div className="flex gap-2">
            <input value={product.image} onChange={e => set("image", e.target.value)} placeholder="https://..." className="flex-1 border border-gray-200 dark:border-[#2A2A42] rounded-xl px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-amber-400/30 focus:border-amber-400" />
            {product.image && <img src={product.image} alt="" className="w-10 h-10 object-cover rounded-lg border border-gray-200 dark:border-[#2A2A42] flex-shrink-0" onError={e => (e.currentTarget.style.display="none")} />}
          </div>
        </div>
        <div>
          <label className="block text-xs font-semibold text-gray-600 mb-1">Title</label>
          <input value={product.title} onChange={e => set("title", e.target.value)} placeholder="Diamond Solitaire" className="w-full border border-gray-200 dark:border-[#2A2A42] rounded-xl px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-amber-400/30 focus:border-amber-400" />
        </div>
        <div>
          <label className="block text-xs font-semibold text-gray-600 mb-1">Price</label>
          <input value={product.price} onChange={e => set("price", e.target.value)} placeholder="₹4,50,000" className="w-full border border-gray-200 dark:border-[#2A2A42] rounded-xl px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-amber-400/30 focus:border-amber-400" />
        </div>
        <div className="flex items-center gap-2">
          <label className="text-xs font-semibold text-gray-600">Active</label>
          <button onClick={() => set("active", !product.active)} className={`relative w-9 h-5 rounded-full transition-colors ${product.active ? "bg-green-500" : "bg-gray-300"}`}>
            <div className={`absolute top-0.5 w-4 h-4 bg-white dark:bg-[#14142B] rounded-full shadow-sm transition-all ${product.active ? "left-4" : "left-0.5"}`} />
          </button>
        </div>
      </div>
      <div className="flex gap-2 mt-4">
        <button onClick={onSave} disabled={saving} className="flex items-center gap-2 px-4 py-2 bg-gray-900 text-white text-sm font-medium rounded-xl hover:bg-gray-800 transition-all disabled:opacity-50"><Save className="w-4 h-4" />{saving ? "Saving..." : "Save"}</button>
        <button onClick={onCancel} className="px-4 py-2 text-sm text-gray-600 hover:bg-gray-100 rounded-xl transition-all">Cancel</button>
      </div>
    </div>
  );
}

function EmptyState({ icon: Icon, label, sub }: { icon: any; label: string; sub: string }) {
  return (
    <div className="text-center py-16 bg-white dark:bg-[#14142B] rounded-2xl border border-dashed border-gray-200 dark:border-[#2A2A42]">
      <Icon className="w-12 h-12 text-gray-200 mx-auto mb-3" />
      <p className="font-semibold text-gray-400">{label}</p>
      <p className="text-sm text-gray-300 mt-1">{sub}</p>
    </div>
  );
}
