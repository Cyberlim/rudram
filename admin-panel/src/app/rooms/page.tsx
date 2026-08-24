"use client";
import { useState, useEffect } from "react";
import { collection, getDocs, addDoc, doc, updateDoc, deleteDoc, query, orderBy } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { Plus, Trash2, Edit2, X, Loader2, LayoutGrid, Package, Users, Clock, Mail } from "lucide-react";
import toast from "react-hot-toast";

interface Room {
  id: string;
  name: string;
  image: string;
  description: string;
  isActive: boolean;
  order: number;
  productCount?: number;
}

interface UserRoom {
  id: string;
  name: string;
  image: string;
  userId: string;
  userName: string;
  userEmail: string;
  userPhotoUrl?: string;
  productCount: number;
  isActive: boolean;
  createdAt?: { seconds: number };
}

export default function RoomsPage() {
  const [activeTab, setActiveTab] = useState<"admin" | "users">("admin");
  const [rooms, setRooms] = useState<Room[]>([]);
  const [userRooms, setUserRooms] = useState<UserRoom[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isUserLoading, setIsUserLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [currentRoom, setCurrentRoom] = useState<Partial<Room>>({
    name: "", image: "", description: "", isActive: true, order: 0,
  });

  useEffect(() => {
    fetchRooms();
    fetchUserRooms();
  }, []);

  const fetchRooms = async () => {
    try {
      const querySnapshot = await getDocs(collection(db, "rooms"));
      const loaded: Room[] = [];
      querySnapshot.forEach((doc) => loaded.push({ id: doc.id, ...doc.data() } as Room));
      loaded.sort((a, b) => (a.order ?? 0) - (b.order ?? 0));
      setRooms(loaded);
    } catch (error) {
      toast.error("Failed to load admin rooms.");
    } finally {
      setIsLoading(false);
    }
  };

  const fetchUserRooms = async () => {
    try {
      const q = query(collection(db, "user_rooms"), orderBy("createdAt", "desc"));
      const snap = await getDocs(q);
      const loaded: UserRoom[] = [];
      snap.forEach((doc) => loaded.push({ id: doc.id, ...doc.data() } as UserRoom));
      setUserRooms(loaded);
    } catch (error) {
      // If index not ready, fall back without ordering
      try {
        const snap = await getDocs(collection(db, "user_rooms"));
        const loaded: UserRoom[] = [];
        snap.forEach((doc) => loaded.push({ id: doc.id, ...doc.data() } as UserRoom));
        setUserRooms(loaded);
      } catch (e) {
        console.error(e);
      }
    } finally {
      setIsUserLoading(false);
    }
  };

  const handleSave = async () => {
    if (!currentRoom.name || !currentRoom.image) {
      toast.error("Room name and image URL are required.");
      return;
    }
    setIsSaving(true);
    try {
      if (currentRoom.id) {
        const { id, ...data } = currentRoom;
        await updateDoc(doc(db, "rooms", id), data);
        toast.success("Room updated!");
      } else {
        await addDoc(collection(db, "rooms"), currentRoom);
        toast.success("Room created!");
      }
      setIsModalOpen(false);
      fetchRooms();
    } catch (error) {
      toast.error("Failed to save room.");
    } finally {
      setIsSaving(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Delete this room?")) return;
    try {
      await deleteDoc(doc(db, "rooms", id));
      toast.success("Room deleted.");
      fetchRooms();
    } catch { toast.error("Failed to delete."); }
  };

  const handleDeleteUserRoom = async (id: string) => {
    if (!confirm("Delete this user room? This will also remove it from the user's view.")) return;
    try {
      await deleteDoc(doc(db, "user_rooms", id));
      toast.success("User room deleted.");
      fetchUserRooms();
    } catch { toast.error("Failed to delete."); }
  };

  const openModal = (room?: Room) => {
    setCurrentRoom(room ?? { name: "", image: "", description: "", isActive: true, order: rooms.length });
    setIsModalOpen(true);
  };

  const formatDate = (ts?: { seconds: number }) => {
    if (!ts) return "Just now";
    return new Date(ts.seconds * 1000).toLocaleDateString("en-IN", { day: "numeric", month: "short", year: "numeric" });
  };

  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-1000 ease-out max-w-6xl pb-20">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-[#2A2A42] pb-6">
        <div>
          <h1 className="text-2xl font-black text-white">Virtual Rooms</h1>
          <p className="text-gray-400 mt-1">Manage showrooms — admin curated & user created.</p>
        </div>
        {activeTab === "admin" && (
          <button onClick={() => openModal()} className="flex items-center gap-2 bg-amber-500 hover:bg-amber-600 text-white px-6 py-2.5 rounded-lg font-bold transition-colors shadow-sm">
            <Plus className="w-4 h-4" /><span>Create Room</span>
          </button>
        )}
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        {[
          { label: "Admin Rooms", value: rooms.length, icon: LayoutGrid, color: "text-amber-400" },
          { label: "User Rooms", value: userRooms.length, icon: Users, color: "text-purple-400" },
          { label: "Unique Users", value: new Set(userRooms.map(r => r.userId)).size, icon: Users, color: "text-blue-400" },
          { label: "Total Products", value: [...rooms, ...userRooms].reduce((s, r) => s + (r.productCount ?? 0), 0), icon: Package, color: "text-green-400" },
        ].map(stat => (
          <div key={stat.label} className="bg-[#1C1C2E] border border-[#2A2A42] rounded-xl p-4">
            <p className="text-gray-400 text-xs mb-1">{stat.label}</p>
            <p className={`text-2xl font-black ${stat.color}`}>{stat.value}</p>
          </div>
        ))}
      </div>

      {/* Tabs */}
      <div className="flex gap-2 bg-[#14142B] rounded-xl p-1 w-fit">
        <button onClick={() => setActiveTab("admin")} className={`px-5 py-2 rounded-lg text-sm font-bold transition-all ${activeTab === "admin" ? "bg-amber-500 text-white shadow-sm" : "text-gray-400 hover:text-white"}`}>
          <span className="flex items-center gap-2"><LayoutGrid className="w-4 h-4" /> Admin Rooms ({rooms.length})</span>
        </button>
        <button onClick={() => setActiveTab("users")} className={`px-5 py-2 rounded-lg text-sm font-bold transition-all ${activeTab === "users" ? "bg-purple-600 text-white shadow-sm" : "text-gray-400 hover:text-white"}`}>
          <span className="flex items-center gap-2"><Users className="w-4 h-4" /> User Created ({userRooms.length})</span>
        </button>
      </div>

      {/* Admin Rooms Tab */}
      {activeTab === "admin" && (
        isLoading ? (
          <div className="flex h-48 items-center justify-center"><Loader2 className="h-8 w-8 animate-spin text-amber-500" /></div>
        ) : rooms.length === 0 ? (
          <div className="text-center py-24 bg-[#1C1C2E] border border-[#2A2A42] rounded-2xl">
            <LayoutGrid className="w-12 h-12 text-gray-500 mx-auto mb-4" />
            <h3 className="text-white font-semibold">No admin rooms yet</h3>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {rooms.map(room => (
              <div key={room.id} className="bg-[#1C1C2E] border border-[#2A2A42] rounded-2xl overflow-hidden group hover:border-amber-500/40 transition-all duration-300">
                <div className="h-52 relative bg-[#14142B] flex items-center justify-center overflow-hidden">
                  {room.image && <img src={room.image} alt={room.name} className="absolute inset-0 w-full h-full object-cover transition-transform duration-500 group-hover:scale-105" onError={(e) => { e.currentTarget.style.display = 'none'; }} />}
                  <LayoutGrid className="w-8 h-8 text-gray-600 relative z-[1]" />
                  <div className="absolute inset-0 bg-black/0 group-hover:bg-black/30 transition-all duration-300 z-[2]" />
                  <div className="absolute top-3 left-3 z-[3]">
                    <span className={`px-2 py-1 text-xs font-bold rounded-md ${room.isActive ? 'bg-green-500/90' : 'bg-red-500/90'} text-white`}>{room.isActive ? 'Active' : 'Inactive'}</span>
                  </div>
                  <div className="absolute top-3 right-3 flex gap-2 z-[3] opacity-0 group-hover:opacity-100 transition-all">
                    <button onClick={() => openModal(room)} className="p-2 bg-black/60 hover:bg-amber-500 text-white rounded-lg backdrop-blur-sm transition-colors"><Edit2 className="w-4 h-4" /></button>
                    <button onClick={() => handleDelete(room.id)} className="p-2 bg-black/60 hover:bg-red-500 text-white rounded-lg backdrop-blur-sm transition-colors"><Trash2 className="w-4 h-4" /></button>
                  </div>
                </div>
                <div className="p-5">
                  <div className="flex items-start justify-between gap-2">
                    <h3 className="font-bold text-white text-lg leading-tight">{room.name}</h3>
                    <span className="shrink-0 text-xs font-semibold text-amber-500 bg-amber-500/10 px-2 py-1 rounded-md">#{room.order}</span>
                  </div>
                  {room.description && <p className="text-gray-400 text-sm mt-2 line-clamp-2">{room.description}</p>}
                  <div className="mt-4 flex items-center gap-2">
                    <Package className="w-4 h-4 text-gray-500" />
                    <span className="text-gray-500 text-xs">{room.productCount ?? 0} products pinned</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )
      )}

      {/* User Rooms Tab */}
      {activeTab === "users" && (
        isUserLoading ? (
          <div className="flex h-48 items-center justify-center"><Loader2 className="h-8 w-8 animate-spin text-purple-500" /></div>
        ) : userRooms.length === 0 ? (
          <div className="text-center py-24 bg-[#1C1C2E] border border-[#2A2A42] rounded-2xl">
            <Users className="w-12 h-12 text-gray-500 mx-auto mb-4" />
            <h3 className="text-white font-semibold">No user rooms yet</h3>
            <p className="text-gray-500 text-sm mt-1">Rooms created by users in the web app will appear here.</p>
          </div>
        ) : (
          <div className="space-y-4">
            {userRooms.map(room => (
              <div key={room.id} className="bg-[#1C1C2E] border border-[#2A2A42] rounded-2xl overflow-hidden hover:border-purple-500/40 transition-all duration-300">
                {/* User Banner */}
                <div className="px-5 py-4 bg-gradient-to-r from-purple-900/40 to-[#1C1C2E] border-b border-[#2A2A42] flex items-center justify-between gap-4">
                  <div className="flex items-center gap-3">
                    {room.userPhotoUrl ? (
                      <img src={room.userPhotoUrl} alt={room.userName} className="w-10 h-10 rounded-full border-2 border-purple-500/50 object-cover" onError={(e) => { e.currentTarget.src = `https://ui-avatars.com/api/?name=${encodeURIComponent(room.userName)}&background=7c3aed&color=fff`; }} />
                    ) : (
                      <div className="w-10 h-10 rounded-full bg-purple-600 flex items-center justify-center text-white font-bold text-sm">
                        {room.userName?.charAt(0)?.toUpperCase() ?? "U"}
                      </div>
                    )}
                    <div>
                      <p className="text-white font-semibold text-sm">{room.userName || "Unknown User"}</p>
                      <div className="flex items-center gap-1.5 mt-0.5">
                        <Mail className="w-3 h-3 text-gray-500" />
                        <p className="text-gray-400 text-xs">{room.userEmail || "No email"}</p>
                      </div>
                    </div>
                  </div>
                  <div className="flex items-center gap-3">
                    <div className="flex items-center gap-1.5 text-gray-500">
                      <Clock className="w-3.5 h-3.5" />
                      <span className="text-xs">{formatDate(room.createdAt)}</span>
                    </div>
                    <span className="px-2 py-1 text-xs font-bold rounded-md bg-purple-600/30 text-purple-300 border border-purple-600/30">User Created</span>
                    <button onClick={() => handleDeleteUserRoom(room.id)} className="p-2 text-gray-500 hover:text-red-400 hover:bg-red-500/10 rounded-lg transition-colors">
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>

                {/* Room Content */}
                <div className="flex gap-5 p-5">
                  <div className="w-32 h-24 rounded-xl overflow-hidden shrink-0 bg-[#14142B]">
                    {room.image ? (
                      <img src={room.image} alt={room.name} className="w-full h-full object-cover" onError={(e) => { e.currentTarget.style.display = 'none'; }} />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center"><LayoutGrid className="w-6 h-6 text-gray-600" /></div>
                    )}
                  </div>
                  <div className="flex-1 min-w-0">
                    <h3 className="font-bold text-white text-xl">{room.name}</h3>
                    <div className="mt-3 flex items-center gap-4 flex-wrap">
                      <div className="flex items-center gap-1.5">
                        <Package className="w-4 h-4 text-gray-500" />
                        <span className="text-gray-400 text-sm">{room.productCount ?? 0} products</span>
                      </div>
                      <div className="flex items-center gap-1.5">
                        <div className={`w-2 h-2 rounded-full ${room.isActive ? 'bg-green-500' : 'bg-red-500'}`} />
                        <span className="text-gray-400 text-sm">{room.isActive ? "Active" : "Inactive"}</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )
      )}

      {/* Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
          <div className="bg-[#1C1C2E] border border-[#2A2A42] rounded-2xl w-full max-w-lg overflow-hidden shadow-2xl animate-in zoom-in-95 duration-200">
            <div className="px-6 py-4 border-b border-[#2A2A42] flex justify-between items-center bg-[#14142B]/50">
              <h2 className="text-lg font-bold text-white">{currentRoom.id ? "Edit Room" : "Create New Room"}</h2>
              <button onClick={() => setIsModalOpen(false)} className="text-gray-400 hover:text-white"><X className="w-5 h-5" /></button>
            </div>
            <div className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-semibold text-gray-300 mb-1">Room Name *</label>
                <input type="text" value={currentRoom.name} onChange={(e) => setCurrentRoom({ ...currentRoom, name: e.target.value })} placeholder="E.g. The Bridal Lounge" className="w-full bg-[#14142B] border border-[#2A2A42] text-white rounded-lg px-4 py-2 text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none" />
              </div>
              <div>
                <label className="block text-sm font-semibold text-gray-300 mb-1">Room Image URL *</label>
                <input type="text" value={currentRoom.image} onChange={(e) => setCurrentRoom({ ...currentRoom, image: e.target.value })} placeholder="https://..." className="w-full bg-[#14142B] border border-[#2A2A42] text-white rounded-lg px-4 py-2 text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none" />
                {currentRoom.image && <div className="mt-2 h-24 rounded-lg overflow-hidden bg-[#14142B]"><img src={currentRoom.image} alt="Preview" className="w-full h-full object-cover" onError={(e) => e.currentTarget.style.display = 'none'} /></div>}
              </div>
              <div>
                <label className="block text-sm font-semibold text-gray-300 mb-1">Description (Optional)</label>
                <textarea rows={2} value={currentRoom.description} onChange={(e) => setCurrentRoom({ ...currentRoom, description: e.target.value })} className="w-full bg-[#14142B] border border-[#2A2A42] text-white rounded-lg px-4 py-2 text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none" />
              </div>
              <div className="flex gap-4">
                <div className="flex-1">
                  <label className="block text-sm font-semibold text-gray-300 mb-1">Display Order</label>
                  <input type="number" value={currentRoom.order} onChange={(e) => setCurrentRoom({ ...currentRoom, order: parseInt(e.target.value) || 0 })} className="w-full bg-[#14142B] border border-[#2A2A42] text-white rounded-lg px-4 py-2 text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none" />
                </div>
                <div className="flex-1 flex items-center pt-6">
                  <label className="flex items-center gap-2 cursor-pointer">
                    <input type="checkbox" checked={currentRoom.isActive} onChange={(e) => setCurrentRoom({ ...currentRoom, isActive: e.target.checked })} className="w-4 h-4 rounded text-amber-500" />
                    <span className="text-sm font-semibold text-gray-300">Is Active</span>
                  </label>
                </div>
              </div>
            </div>
            <div className="px-6 py-4 border-t border-[#2A2A42] flex justify-end gap-3 bg-[#14142B]/50">
              <button onClick={() => setIsModalOpen(false)} className="px-4 py-2 rounded-lg text-sm font-bold text-gray-400 hover:text-white transition-colors">Cancel</button>
              <button onClick={handleSave} disabled={isSaving} className="flex items-center gap-2 bg-amber-500 hover:bg-amber-600 disabled:opacity-50 text-white px-6 py-2 rounded-lg text-sm font-bold transition-colors">
                {isSaving && <Loader2 className="w-4 h-4 animate-spin" />}
                <span>{isSaving ? "Saving..." : "Save Room"}</span>
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
