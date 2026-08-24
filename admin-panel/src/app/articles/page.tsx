"use client";
import { useState, useEffect } from "react";
import { db } from "@/lib/firebase";
import { collection, query, orderBy, onSnapshot, doc, setDoc, deleteDoc, serverTimestamp } from "firebase/firestore";
import { Plus, Trash2, Edit2, Loader2, Newspaper, X, Save } from "lucide-react";
import toast from "react-hot-toast";

interface Article {
  id: string;
  title: string;
  subtitle: string;
  tag: string;
  imageUrl: string;
  featured: boolean;
  status: string;
  createdAt?: any;
}

const TAG_OPTIONS = ["TRENDS", "LAUNCHES", "BEHIND THE SCENES", "GUIDES", "COMMUNITY", "EVENTS"];

const EMPTY_FORM = {
  title: "",
  subtitle: "",
  tag: "LAUNCHES",
  imageUrl: "",
  featured: false,
  status: "Published",
};

export default function ArticlesPage() {
  const [articles, setArticles] = useState<Article[]>([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [form, setForm] = useState(EMPTY_FORM);

  useEffect(() => {
    const q = query(collection(db, "articles"), orderBy("createdAt", "desc"));
    const unsub = onSnapshot(q, (snap) => {
      setArticles(snap.docs.map((d) => ({ id: d.id, ...d.data() })) as Article[]);
      setLoading(false);
    }, () => setLoading(false));
    return () => unsub();
  }, []);

  const openAddModal = () => {
    setEditingId(null);
    setForm(EMPTY_FORM);
    setIsModalOpen(true);
  };

  const openEditModal = (article: Article) => {
    setEditingId(article.id);
    setForm({
      title: article.title,
      subtitle: article.subtitle,
      tag: article.tag,
      imageUrl: article.imageUrl,
      featured: article.featured,
      status: article.status,
    });
    setIsModalOpen(true);
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form.title || !form.imageUrl) return toast.error("Title and Image URL are required.");
    setIsSaving(true);
    try {
      const ref = editingId ? doc(db, "articles", editingId) : doc(collection(db, "articles"));
      await setDoc(ref, {
        ...form,
        createdAt: serverTimestamp(),
      }, { merge: true });
      toast.success(editingId ? "Article updated!" : "Article published!");
      setIsModalOpen(false);
    } catch (err) {
      toast.error("Failed to save article.");
    } finally {
      setIsSaving(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Delete this article?")) return;
    await deleteDoc(doc(db, "articles", id));
    toast.success("Article deleted.");
  };

  const featured = articles.find((a) => a.featured);
  const rest = articles.filter((a) => !a.featured);

  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-1000 ease-out pb-20">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black text-gray-900 dark:text-gray-100">Latest Articles</h1>
          <p className="text-gray-500 mt-1">Manage news, updates & guides shown on the Latest page.</p>
        </div>
        <button
          onClick={openAddModal}
          className="flex items-center gap-2 bg-amber-500 hover:bg-amber-600 text-white px-5 py-2.5 rounded-lg font-bold transition-colors shadow-sm"
        >
          <Plus className="w-4 h-4" />
          <span>Add Article</span>
        </button>
      </div>

      {/* Featured Article */}
      <div className="bg-white dark:bg-[#14142B] rounded-2xl border border-gray-100 dark:border-[#2A2A42] overflow-hidden">
        <div className="px-6 py-4 border-b border-gray-100 dark:border-[#2A2A42] bg-gray-50 dark:bg-[#0B0B1A]/50 flex items-center gap-2">
          <Newspaper className="w-4 h-4 text-amber-500" />
          <h2 className="font-bold text-gray-900 dark:text-gray-100">Featured Article</h2>
        </div>
        {featured ? (
          <div className="p-6 flex gap-6 items-start">
            <img src={featured.imageUrl} alt={featured.title} className="w-48 h-32 rounded-xl object-cover flex-shrink-0" />
            <div className="flex-1">
              <span className="text-xs font-bold text-amber-600 tracking-widest uppercase">{featured.tag}</span>
              <h3 className="text-xl font-bold text-gray-900 dark:text-gray-100 mt-1">{featured.title}</h3>
              <p className="text-gray-500 text-sm mt-1 line-clamp-2">{featured.subtitle}</p>
            </div>
            <div className="flex gap-2 flex-shrink-0">
              <button onClick={() => openEditModal(featured)} className="p-2 text-blue-500 hover:bg-blue-50 dark:hover:bg-blue-900/20 rounded-lg transition-colors"><Edit2 className="w-4 h-4" /></button>
              <button onClick={() => handleDelete(featured.id)} className="p-2 text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-lg transition-colors"><Trash2 className="w-4 h-4" /></button>
            </div>
          </div>
        ) : (
          <div className="py-10 text-center text-gray-400 text-sm">
            No featured article. Create one and mark it as "Featured".
          </div>
        )}
      </div>

      {/* Articles Grid */}
      <div className="bg-white dark:bg-[#14142B] rounded-2xl border border-gray-100 dark:border-[#2A2A42] overflow-hidden">
        <div className="px-6 py-4 border-b border-gray-100 dark:border-[#2A2A42] bg-gray-50 dark:bg-[#0B0B1A]/50">
          <h2 className="font-bold text-gray-900 dark:text-gray-100">All Articles ({articles.length})</h2>
        </div>
        {loading ? (
          <div className="flex h-48 items-center justify-center"><Loader2 className="w-8 h-8 animate-spin text-amber-500" /></div>
        ) : articles.length === 0 ? (
          <div className="py-16 text-center text-gray-400">No articles yet. Click "Add Article" to get started.</div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm text-left">
              <thead className="bg-gray-50 dark:bg-[#0B0B1A]/50 text-gray-500 font-semibold border-b border-gray-100 dark:border-[#2A2A42]">
                <tr>
                  <th className="py-3 px-6">Article</th>
                  <th className="py-3 px-6">Tag</th>
                  <th className="py-3 px-6">Status</th>
                  <th className="py-3 px-6">Featured</th>
                  <th className="py-3 px-6 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-50 dark:divide-[#2A2A42]">
                {articles.map((article) => (
                  <tr key={article.id} className="hover:bg-gray-50 dark:hover:bg-[#0B0B1A]/40 transition-colors">
                    <td className="py-4 px-6">
                      <div className="flex items-center gap-3">
                        <img src={article.imageUrl} alt={article.title} className="w-12 h-9 rounded-lg object-cover flex-shrink-0" />
                        <div>
                          <p className="font-bold text-gray-900 dark:text-gray-100 truncate max-w-[200px]">{article.title}</p>
                          <p className="text-xs text-gray-400 truncate max-w-[200px]">{article.subtitle}</p>
                        </div>
                      </div>
                    </td>
                    <td className="py-4 px-6">
                      <span className="px-2 py-1 bg-amber-50 dark:bg-amber-900/20 text-amber-700 dark:text-amber-400 rounded text-xs font-bold">{article.tag}</span>
                    </td>
                    <td className="py-4 px-6">
                      <span className={`px-2.5 py-1 rounded-full text-xs font-semibold ${article.status === "Published" ? "bg-green-100 text-green-700" : "bg-gray-100 text-gray-600"}`}>
                        {article.status}
                      </span>
                    </td>
                    <td className="py-4 px-6">
                      {article.featured && <span className="px-2 py-1 bg-purple-100 text-purple-700 rounded text-xs font-bold">⭐ Featured</span>}
                    </td>
                    <td className="py-4 px-6 text-right">
                      <div className="flex items-center justify-end gap-2">
                        <button onClick={() => openEditModal(article)} className="p-1.5 text-blue-500 hover:bg-blue-50 dark:hover:bg-blue-900/20 rounded-lg transition-colors"><Edit2 className="w-4 h-4" /></button>
                        <button onClick={() => handleDelete(article.id)} className="p-1.5 text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-lg transition-colors"><Trash2 className="w-4 h-4" /></button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white dark:bg-[#14142B] rounded-2xl w-full max-w-xl shadow-2xl border border-gray-100 dark:border-[#2A2A42]">
            <div className="flex items-center justify-between px-6 py-4 border-b border-gray-100 dark:border-[#2A2A42]">
              <h2 className="text-lg font-bold text-gray-900 dark:text-gray-100">{editingId ? "Edit Article" : "Add New Article"}</h2>
              <button onClick={() => setIsModalOpen(false)} className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-200"><X className="w-5 h-5" /></button>
            </div>
            <form onSubmit={handleSave} className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1.5">Title *</label>
                <input type="text" required value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} placeholder="Article title..." className="w-full border border-gray-200 dark:border-[#2A2A42] dark:bg-[#0B0B1A] dark:text-white rounded-lg px-4 py-2.5 text-sm focus:ring-2 focus:ring-amber-500/30 focus:border-amber-500 outline-none" />
              </div>
              <div>
                <label className="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1.5">Subtitle / Excerpt</label>
                <textarea rows={3} value={form.subtitle} onChange={(e) => setForm({ ...form, subtitle: e.target.value })} placeholder="Brief description..." className="w-full border border-gray-200 dark:border-[#2A2A42] dark:bg-[#0B0B1A] dark:text-white rounded-lg px-4 py-2.5 text-sm focus:ring-2 focus:ring-amber-500/30 focus:border-amber-500 outline-none" />
              </div>
              <div>
                <label className="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1.5">Image URL *</label>
                <input type="url" required value={form.imageUrl} onChange={(e) => setForm({ ...form, imageUrl: e.target.value })} placeholder="https://..." className="w-full border border-gray-200 dark:border-[#2A2A42] dark:bg-[#0B0B1A] dark:text-white rounded-lg px-4 py-2.5 text-sm focus:ring-2 focus:ring-amber-500/30 focus:border-amber-500 outline-none" />
                {form.imageUrl && <img src={form.imageUrl} alt="" className="mt-2 w-full h-32 object-cover rounded-lg" />}
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1.5">Tag</label>
                  <select value={form.tag} onChange={(e) => setForm({ ...form, tag: e.target.value })} className="w-full border border-gray-200 dark:border-[#2A2A42] dark:bg-[#0B0B1A] dark:text-white rounded-lg px-4 py-2.5 text-sm focus:ring-2 focus:ring-amber-500/30 focus:border-amber-500 outline-none">
                    {TAG_OPTIONS.map((t) => <option key={t}>{t}</option>)}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1.5">Status</label>
                  <select value={form.status} onChange={(e) => setForm({ ...form, status: e.target.value })} className="w-full border border-gray-200 dark:border-[#2A2A42] dark:bg-[#0B0B1A] dark:text-white rounded-lg px-4 py-2.5 text-sm focus:ring-2 focus:ring-amber-500/30 focus:border-amber-500 outline-none">
                    <option>Published</option>
                    <option>Draft</option>
                  </select>
                </div>
              </div>
              <div className="flex items-center gap-3 pt-1">
                <input type="checkbox" id="featured" checked={form.featured} onChange={(e) => setForm({ ...form, featured: e.target.checked })} className="w-4 h-4 accent-amber-500" />
                <label htmlFor="featured" className="text-sm font-semibold text-gray-700 dark:text-gray-300">Mark as Featured (shown prominently at top)</label>
              </div>
              <div className="flex justify-end gap-3 pt-2">
                <button type="button" onClick={() => setIsModalOpen(false)} className="px-5 py-2.5 rounded-lg border border-gray-200 dark:border-[#2A2A42] text-gray-600 dark:text-gray-300 text-sm font-semibold hover:bg-gray-50 dark:hover:bg-[#2A2A42] transition-colors">Cancel</button>
                <button type="submit" disabled={isSaving} className="flex items-center gap-2 px-5 py-2.5 bg-amber-500 hover:bg-amber-600 text-white rounded-lg text-sm font-bold transition-colors">
                  {isSaving ? <Loader2 className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />}
                  {isSaving ? "Saving..." : "Publish Article"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
