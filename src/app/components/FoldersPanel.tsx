"use client";

import { useFoldersPanel, Folder } from "../hooks/useFoldersPanel";

type Props = { folders: Folder[]; soundOnComplete?: boolean; soundOnError?: boolean; };

export default function FoldersPanel({ folders, soundOnComplete, soundOnError }: Props) {
  const { msg, loading, syncFolders, importFolder, importAllFolders, processFolder } = useFoldersPanel(folders, soundOnComplete, soundOnError);
  const btn = "rounded-full border border-black/10 px-4 py-2 text-sm font-semibold transition disabled:opacity-60";
  const rowBtn = (l: string, c: string) => `rounded-full px-3 py-1 text-xs font-bold uppercase transition hover:text-white disabled:opacity-60 ${c}`;

  return (
    <section className="flex flex-col gap-4 rounded-3xl border border-black/10 bg-white/70 p-6 shadow-sm">
      {msg?.text && <div className={`rounded-lg p-3 text-sm font-semibold mb-2 shadow-sm border ${msg.isError ? "bg-red-50 text-red-800 border-red-100" : "bg-emerald-50 text-emerald-800 border-emerald-100"}`}>{msg.text}</div>}
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div><h2 className="text-2xl font-semibold">Bookmark folders</h2><p className="text-xs text-slate-500">Counts show locally imported folder items.</p></div>
        <div className="flex flex-wrap items-center gap-2">
          <button onClick={importAllFolders} disabled={loading.all || loading.syncing || !!loading.importing || !!loading.processing} className="rounded-full bg-emerald-700 px-4 py-2 text-sm font-semibold text-white transition disabled:opacity-60">{loading.all ? "Importing..." : "Import all"}</button>
          <button onClick={syncFolders} disabled={loading.syncing || loading.all} className={btn}>{loading.syncing ? "Syncing..." : "Sync folder names"}</button>
        </div>
      </div>
      {folders.length ? (
        <div className="overflow-hidden rounded-lg border border-black/10">
          <table className="w-full text-left text-sm">
            <thead className="bg-surface-container text-xs font-bold uppercase tracking-wider text-on-surface-variant"><tr><th className="px-4 py-2">Folder Name</th><th className="px-4 py-2">Imported</th><th className="px-4 py-2 text-right">Actions</th></tr></thead>
            <tbody className="divide-y divide-black/5 bg-white">
              {folders.map(f => (
                <tr key={f.id} className="hover:bg-slate-50 transition-colors">
                  <td className="px-4 py-3 font-semibold">{f.name ?? "Untitled folder"}</td>
                  <td className="px-4 py-3 text-slate-500">{f.total ?? 0}</td>
                  <td className="px-4 py-3 text-right">
                    <div className="flex justify-end gap-2">
                      <button onClick={() => importFolder(f.id)} disabled={loading.all || loading.importing === f.id || loading.processing === f.id} className={rowBtn("Import", "bg-emerald-700/10 text-emerald-800 hover:bg-emerald-700")}>{loading.importing === f.id ? "..." : "Import"}</button>
                      <button onClick={() => processFolder(f.id)} disabled={loading.all || loading.processing === f.id || loading.importing === f.id} className={rowBtn("Process", "border border-black/10 text-slate-700 hover:bg-black")}>{loading.processing === f.id ? "..." : "Process"}</button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : <p className="text-sm text-slate-600">No folders yet.</p>}
    </section>
  );
}
