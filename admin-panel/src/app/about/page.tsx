"use client";
import { useState, useEffect } from "react";
import { db } from "@/lib/firebase";
import { doc, getDoc, setDoc } from "firebase/firestore";
import { Save, Loader2, Info, Users, Star, Shield } from "lucide-react";
import toast from "react-hot-toast";

interface AboutContent {
  heroBannerImage: string;
  heroTagline: string;
  heroTitle: string;
  storyImage: string;
  storyTagline: string;
  storyYear: string;
  storyParagraph1: string;
  storyParagraph2: string;
  value1Title: string;
  value1Desc: string;
  value2Title: string;
  value2Desc: string;
  value3Title: string;
  value3Desc: string;
  value4Title: string;
  value4Desc: string;
  artisan1Name: string;
  artisan1Role: string;
  artisan1Image: string;
  artisan2Name: string;
  artisan2Role: string;
  artisan2Image: string;
  artisan3Name: string;
  artisan3Role: string;
  artisan3Image: string;
}

const DEFAULT: AboutContent = {
  heroBannerImage: "https://images.unsplash.com/photo-1599643478524-fb66f70a9a18?q=80&w=2070",
  heroTagline: "OUR HERITAGE",
  heroTitle: "A Legacy of Trust & Purity",
  storyImage: "https://images.unsplash.com/photo-1611591437281-460bfbe1220a?q=80&w=2070",
  storyTagline: "THE JOURNEY",
  storyYear: "1985",
  storyParagraph1: "At Rudram Jewels, we believe in the timeless beauty of handcrafted excellence. For decades, our artisans have poured their skill and passion into creating masterpieces that define generations.",
  storyParagraph2: "Every piece of jewelry we create is a testament to our commitment to purity, intricate detailing, and preserving the rich cultural heritage of fine jewelry making.",
  value1Title: "Uncompromising Purity",
  value1Desc: "We source only the highest grade precious metals and certified gemstones.",
  value2Title: "Ethical Sourcing",
  value2Desc: "Our supply chain is fully transparent, ensuring conflict-free and sustainable practices.",
  value3Title: "Master Craftsmanship",
  value3Desc: "Generations of artisanal expertise go into every intricate detail of our designs.",
  value4Title: "Lifetime Support",
  value4Desc: "We stand by our creations with lifetime maintenance and dedicated customer care.",
  artisan1Name: "Vikram Singh",
  artisan1Role: "Master Goldsmith",
  artisan1Image: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1000",
  artisan2Name: "Aarti Sharma",
  artisan2Role: "Lead Designer",
  artisan2Image: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=1000",
  artisan3Name: "Rajesh Patel",
  artisan3Role: "Gemologist",
  artisan3Image: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1000",
};

function Field({ label, value, onChange, textarea = false, placeholder = "" }: { label: string; value: string; onChange: (v: string) => void; textarea?: boolean; placeholder?: string }) {
  const cls = "w-full border border-gray-200 dark:border-[#2A2A42] dark:bg-[#0B0B1A] dark:text-white rounded-lg px-4 py-2.5 text-sm focus:ring-2 focus:ring-amber-500/30 focus:border-amber-500 outline-none";
  return (
    <div>
      <label className="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1.5">{label}</label>
      {textarea
        ? <textarea rows={3} value={value} onChange={(e) => onChange(e.target.value)} placeholder={placeholder} className={cls} />
        : <input type="text" value={value} onChange={(e) => onChange(e.target.value)} placeholder={placeholder} className={cls} />
      }
    </div>
  );
}

function Section({ icon: Icon, title, desc, children }: { icon: any; title: string; desc: string; children: React.ReactNode }) {
  return (
    <section className="bg-white dark:bg-[#14142B] rounded-2xl border border-gray-100 dark:border-[#2A2A42] overflow-hidden">
      <div className="px-6 py-4 border-b border-gray-100 dark:border-[#2A2A42] bg-gray-50 dark:bg-[#0B0B1A]/50 flex items-center gap-3">
        <div className="w-8 h-8 rounded-lg bg-amber-100 dark:bg-amber-900/30 flex items-center justify-center">
          <Icon className="w-4 h-4 text-amber-600" />
        </div>
        <div>
          <h2 className="font-bold text-gray-900 dark:text-gray-100">{title}</h2>
          <p className="text-xs text-gray-400">{desc}</p>
        </div>
      </div>
      <div className="p-6 space-y-4">{children}</div>
    </section>
  );
}

export default function AboutPage() {
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [content, setContent] = useState<AboutContent>(DEFAULT);

  useEffect(() => {
    const load = async () => {
      try {
        const snap = await getDoc(doc(db, "web_settings", "about"));
        if (snap.exists()) setContent({ ...DEFAULT, ...snap.data() });
      } finally {
        setLoading(false);
      }
    };
    load();
  }, []);

  const set = (field: keyof AboutContent) => (value: string) => setContent((prev) => ({ ...prev, [field]: value }));

  const handleSave = async () => {
    setSaving(true);
    try {
      await setDoc(doc(db, "web_settings", "about"), content, { merge: true });
      toast.success("About page updated!");
    } catch {
      toast.error("Failed to save.");
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return <div className="flex h-64 items-center justify-center"><Loader2 className="w-8 h-8 animate-spin text-amber-500" /></div>;
  }

  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-1000 ease-out max-w-4xl pb-20">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-gray-100 dark:border-[#2A2A42] pb-6">
        <div>
          <h1 className="text-2xl font-black text-gray-900 dark:text-gray-100">About / Info Page</h1>
          <p className="text-gray-500 mt-1">Manage the content shown on the Heritage & About Us page of your website.</p>
        </div>
        <button
          onClick={handleSave}
          disabled={saving}
          className="flex items-center gap-2 bg-amber-500 hover:bg-amber-600 disabled:opacity-50 text-white px-6 py-2.5 rounded-lg font-bold transition-colors shadow-sm"
        >
          {saving ? <Loader2 className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />}
          {saving ? "Saving..." : "Save Changes"}
        </button>
      </div>

      {/* Hero Banner */}
      <Section icon={Info} title="Hero Banner" desc="The full-width banner at the top of the page">
        <Field label="Banner Image URL" value={content.heroBannerImage} onChange={set("heroBannerImage")} placeholder="https://..." />
        {content.heroBannerImage && <img src={content.heroBannerImage} alt="" className="w-full h-40 object-cover rounded-xl mt-2" />}
        <div className="grid grid-cols-2 gap-4">
          <Field label="Tagline (small text above title)" value={content.heroTagline} onChange={set("heroTagline")} placeholder="OUR HERITAGE" />
          <Field label="Main Title" value={content.heroTitle} onChange={set("heroTitle")} placeholder="A Legacy of Trust & Purity" />
        </div>
      </Section>

      {/* Story Section */}
      <Section icon={Info} title="Our Story Section" desc="The two-column story section below the hero">
        <Field label="Story Image URL" value={content.storyImage} onChange={set("storyImage")} placeholder="https://..." />
        {content.storyImage && <img src={content.storyImage} alt="" className="w-full h-40 object-cover rounded-xl" />}
        <div className="grid grid-cols-2 gap-4">
          <Field label="Section Tagline" value={content.storyTagline} onChange={set("storyTagline")} placeholder="THE JOURNEY" />
          <Field label="Founding Year" value={content.storyYear} onChange={set("storyYear")} placeholder="1985" />
        </div>
        <Field label="Paragraph 1" value={content.storyParagraph1} onChange={set("storyParagraph1")} textarea placeholder="At Rudram Jewels..." />
        <Field label="Paragraph 2" value={content.storyParagraph2} onChange={set("storyParagraph2")} textarea placeholder="Every piece of jewelry..." />
      </Section>

      {/* Core Values */}
      <Section icon={Shield} title="Core Values" desc="The 4 pillars shown in the values grid">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="space-y-3 border border-gray-100 dark:border-[#2A2A42] rounded-xl p-4">
            <p className="text-xs font-bold text-gray-400 uppercase tracking-widest">Value 1</p>
            <Field label="Title" value={content.value1Title} onChange={set("value1Title")} placeholder="Uncompromising Purity" />
            <Field label="Description" value={content.value1Desc} onChange={set("value1Desc")} textarea placeholder="Description..." />
          </div>
          <div className="space-y-3 border border-gray-100 dark:border-[#2A2A42] rounded-xl p-4">
            <p className="text-xs font-bold text-gray-400 uppercase tracking-widest">Value 2</p>
            <Field label="Title" value={content.value2Title} onChange={set("value2Title")} placeholder="Ethical Sourcing" />
            <Field label="Description" value={content.value2Desc} onChange={set("value2Desc")} textarea placeholder="Description..." />
          </div>
          <div className="space-y-3 border border-gray-100 dark:border-[#2A2A42] rounded-xl p-4">
            <p className="text-xs font-bold text-gray-400 uppercase tracking-widest">Value 3</p>
            <Field label="Title" value={content.value3Title} onChange={set("value3Title")} placeholder="Master Craftsmanship" />
            <Field label="Description" value={content.value3Desc} onChange={set("value3Desc")} textarea placeholder="Description..." />
          </div>
          <div className="space-y-3 border border-gray-100 dark:border-[#2A2A42] rounded-xl p-4">
            <p className="text-xs font-bold text-gray-400 uppercase tracking-widest">Value 4</p>
            <Field label="Title" value={content.value4Title} onChange={set("value4Title")} placeholder="Lifetime Support" />
            <Field label="Description" value={content.value4Desc} onChange={set("value4Desc")} textarea placeholder="Description..." />
          </div>
        </div>
      </Section>

      {/* Artisans */}
      <Section icon={Users} title="Meet the Artisans" desc="The 3 featured team members">
        {([1, 2, 3] as const).map((n) => (
          <div key={n} className="border border-gray-100 dark:border-[#2A2A42] rounded-xl p-4 space-y-3">
            <p className="text-xs font-bold text-amber-600 uppercase tracking-widest">Artisan {n}</p>
            <div className="grid grid-cols-2 gap-4">
              <Field label="Name" value={content[`artisan${n}Name` as keyof AboutContent]} onChange={set(`artisan${n}Name` as keyof AboutContent)} placeholder="Name" />
              <Field label="Role" value={content[`artisan${n}Role` as keyof AboutContent]} onChange={set(`artisan${n}Role` as keyof AboutContent)} placeholder="Role / Title" />
            </div>
            <Field label="Photo URL" value={content[`artisan${n}Image` as keyof AboutContent]} onChange={set(`artisan${n}Image` as keyof AboutContent)} placeholder="https://..." />
            {content[`artisan${n}Image` as keyof AboutContent] && (
              <img src={content[`artisan${n}Image` as keyof AboutContent]} alt="" className="w-24 h-24 rounded-full object-cover" />
            )}
          </div>
        ))}
      </Section>
    </div>
  );
}
