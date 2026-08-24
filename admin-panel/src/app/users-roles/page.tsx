"use client";
import { Search, Filter, Plus, MoreHorizontal, Download } from "lucide-react";

export default function usersrolesPage() {
  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-1000 ease-out pb-10">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black text-gray-900 dark:text-gray-100">Users & Roles Management</h1>
          <p className="text-gray-500 mt-1">Manage and view all your users & roles in one place.</p>
        </div>
        <div className="flex items-center gap-3">
          <button className="flex items-center gap-2 bg-white dark:bg-[#14142B] border border-gray-200 dark:border-[#2A2A42] hover:bg-gray-50 dark:bg-[#0B0B1A] text-gray-700 dark:text-gray-300 px-4 py-2 rounded-lg font-medium transition-colors">
            <Download className="w-4 h-4" />
            <span>Export</span>
          </button>
          <button className="flex items-center gap-2 bg-amber-600 hover:bg-amber-700 text-white px-4 py-2 rounded-lg font-medium transition-colors shadow-sm">
            <Plus className="w-4 h-4" />
            <span>Add Users & Role</span>
          </button>
        </div>
      </div>

      {/* Table Container */}
      <div className="bg-white dark:bg-[#14142B] rounded-2xl shadow-sm border border-gray-100 dark:border-[#2A2A42] flex flex-col overflow-hidden">
        {/* Toolbar */}
        <div className="p-4 border-b border-gray-100 dark:border-[#2A2A42] flex flex-col md:flex-row md:items-center justify-between gap-4 bg-gray-50 dark:bg-[#0B0B1A]/50">
          <div className="relative w-full md:w-96">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input 
              type="text" 
              placeholder="Search users & roles..." 
              className="w-full pl-10 pr-4 py-2 bg-white dark:bg-[#14142B] border border-gray-200 dark:border-[#2A2A42] rounded-lg text-sm focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none transition-all"
            />
          </div>
          <button className="flex items-center gap-2 bg-white dark:bg-[#14142B] border border-gray-200 dark:border-[#2A2A42] hover:bg-gray-50 dark:bg-[#0B0B1A] text-gray-700 dark:text-gray-300 px-4 py-2 rounded-lg text-sm font-medium transition-colors w-full md:w-auto justify-center">
            <Filter className="w-4 h-4" />
            <span>Filters</span>
          </button>
        </div>

        {/* Table */}
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm whitespace-nowrap">
            <thead className="bg-gray-50 dark:bg-[#0B0B1A]/50">
              <tr className="text-gray-500 font-semibold border-b border-gray-100 dark:border-[#2A2A42]">
                <th className="py-4 px-6 w-12"><input type="checkbox" className="rounded border-gray-300 text-amber-600 focus:ring-amber-500" /></th>
                <th className="py-4 px-6">User ID</th>
                <th className="py-4 px-6">Name</th>
                <th className="py-4 px-6">Role</th>
                <th className="py-4 px-6">Last Active</th>
                <th className="py-4 px-6">Status</th>
                <th className="py-4 px-6 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {[1, 2, 3, 4, 5, 6, 7, 8].map((item) => (
                <tr key={item} className="hover:bg-gray-50 dark:bg-[#0B0B1A]/50 transition-colors group">
                  <td className="py-4 px-6"><input type="checkbox" className="rounded border-gray-300 text-amber-600 focus:ring-amber-500" /></td>
                  <td className="py-4 px-6 font-medium text-gray-900 dark:text-gray-100">#USE-10${item}</td>
                  <td className="py-4 px-6 text-gray-600">Sample Data ${item}</td>
                  <td className="py-4 px-6 text-gray-600">Sample Data ${item}</td>
                  <td className="py-4 px-6 text-gray-600">Sample Data ${item}</td>
                  <td className="py-4 px-6"><span className="px-2.5 py-1 rounded-full text-xs font-semibold bg-emerald-100 text-emerald-700">Active</span></td>
                  <td className="py-4 px-6 text-right">
                    <button className="text-gray-400 hover:text-gray-600 p-1 rounded-md hover:bg-gray-100 transition-colors">
                      <MoreHorizontal className="w-5 h-5" />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        <div className="p-4 border-t border-gray-100 dark:border-[#2A2A42] flex items-center justify-between text-sm text-gray-500 bg-gray-50 dark:bg-[#0B0B1A]/50">
          <span>Showing 1 to 8 of 24 results</span>
          <div className="flex items-center gap-1">
            <button className="px-3 py-1 border border-gray-200 dark:border-[#2A2A42] rounded hover:bg-gray-50 dark:bg-[#0B0B1A] disabled:opacity-50" disabled>Prev</button>
            <button className="px-3 py-1 bg-amber-600 text-white rounded font-medium">1</button>
            <button className="px-3 py-1 border border-gray-200 dark:border-[#2A2A42] rounded hover:bg-gray-50 dark:bg-[#0B0B1A]">2</button>
            <button className="px-3 py-1 border border-gray-200 dark:border-[#2A2A42] rounded hover:bg-gray-50 dark:bg-[#0B0B1A]">3</button>
            <button className="px-3 py-1 border border-gray-200 dark:border-[#2A2A42] rounded hover:bg-gray-50 dark:bg-[#0B0B1A]">Next</button>
          </div>
        </div>
      </div>
    </div>
  );
}