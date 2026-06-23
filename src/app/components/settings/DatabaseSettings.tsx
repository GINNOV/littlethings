"use client";

import { useState } from "react";
import { useDatabaseSettings } from "../../hooks/settings/useDatabaseSettings";
import { SettingsSection, secondaryButtonClass } from "./SharedFields";
import ConfirmationDialog from "../ConfirmationDialog";

function DatabaseIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      {...props}
    >
      <ellipse cx="12" cy="5" rx="9" ry="3" />
      <path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5" />
      <path d="M3 12c0 1.66 4 3 9 3s9-1.34 9-3" />
    </svg>
  );
}

export function DatabaseSettings() {
  const {
    backups,
    loading,
    creating,
    restoring,
    clearing,
    createLocalBackup,
    deleteLocalBackup,
    restoreLocalBackup,
    restoreFromUpload,
    clearData,
  } = useDatabaseSettings();

  const [customName, setCustomName] = useState("");
  const [confirmClearOpen, setConfirmClearOpen] = useState(false);
  
  const [confirmRestoreOpen, setConfirmRestoreOpen] = useState(false);
  const [pendingRestoreFile, setPendingRestoreFile] = useState<string | null>(null);

  const [confirmDeleteOpen, setConfirmDeleteOpen] = useState(false);
  const [pendingDeleteFile, setPendingDeleteFile] = useState<string | null>(null);

  const [confirmUploadOpen, setConfirmUploadOpen] = useState(false);
  const [pendingUploadFile, setPendingUploadFile] = useState<File | null>(null);

  const handleCreateBackup = () => {
    createLocalBackup(customName);
    setCustomName("");
  };

  return (
    <SettingsSection
      title="Database management"
      description="Back up, download, or restore your database to keep your data safe."
      icon={
        <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-slate-100 text-slate-600">
          <DatabaseIcon className="h-5 w-5" />
        </span>
      }
    >
      <div className="flex flex-col gap-6">
        {/* Actions panel */}
        <div className="grid gap-6 md:grid-cols-2">
          {/* Backups generation */}
          <div className="space-y-4 rounded-lg border border-black/5 bg-slate-50/50 p-4">
            <h4 className="text-sm font-semibold text-slate-700">Backup active database</h4>
            <p className="text-xs text-slate-500">
              Generate a copy of the database. You can download it to your local machine or save it on the server.
            </p>
            
            <div className="flex flex-col gap-3">
              <a
                href="/api/settings/database/backup"
                download
                className={`${secondaryButtonClass} text-center inline-block w-full`}
              >
                Download active database (.db)
              </a>

              <div className="flex flex-col gap-2">
                <label className="text-xs font-semibold text-slate-600">
                  Custom backup name (optional)
                </label>
                <div className="flex gap-2">
                  <input
                    type="text"
                    placeholder="e.g. before_enrichment"
                    value={customName}
                    onChange={(e) => setCustomName(e.target.value)}
                    className="flex-1 min-w-0 rounded-md border border-black/10 bg-white px-3 py-2 text-sm"
                  />
                  <button
                    type="button"
                    onClick={handleCreateBackup}
                    disabled={creating}
                    className={secondaryButtonClass}
                  >
                    {creating ? "Creating..." : "Save to server"}
                  </button>
                </div>
              </div>
            </div>
          </div>

          {/* Restore from upload */}
          <div className="space-y-4 rounded-lg border border-black/5 bg-slate-50/50 p-4">
            <h4 className="text-sm font-semibold text-slate-700">Restore database from file</h4>
            <p className="text-xs text-slate-500">
              Restore the database by uploading a previously downloaded SQLite `.db` file.
            </p>
            
            <div className="space-y-2 pt-2">
              <input
                type="file"
                accept=".db,.sqlite"
                onChange={(e) => {
                  const file = e.target.files?.[0];
                  if (file) {
                    setPendingUploadFile(file);
                    setConfirmUploadOpen(true);
                  }
                  // Reset file input so same file can be selected again if needed
                  e.target.value = "";
                }}
                className="block w-full text-xs text-slate-500 file:mr-4 file:rounded-md file:border-0 file:bg-slate-200 file:px-4 file:py-2 file:text-xs file:font-semibold file:text-slate-700 hover:file:bg-slate-300"
              />
              <p className="text-[10px] text-slate-400">
                Warning: This completely replaces current database data.
              </p>
            </div>
          </div>
        </div>

        {/* Server backups list */}
        <div className="space-y-3">
          <h4 className="text-sm font-semibold text-slate-700">Saved local backups on server</h4>
          {loading ? (
            <p className="text-xs text-slate-500">Loading backups...</p>
          ) : backups.length === 0 ? (
            <p className="text-xs text-slate-400 italic">No local backups stored on server yet.</p>
          ) : (
            <div className="overflow-hidden rounded-lg border border-black/5">
              <table className="min-w-full divide-y divide-black/5 text-sm text-left">
                <thead className="bg-slate-50">
                  <tr className="text-xs font-bold uppercase text-slate-400">
                    <th className="py-2 px-4">Filename</th>
                    <th className="py-2 px-4">Size</th>
                    <th className="py-2 px-4">Created At</th>
                    <th className="py-2 px-4 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-black/5 bg-white">
                  {backups.map((backup) => (
                    <tr key={backup.filename} className="hover:bg-slate-50/50">
                      <td className="py-2 px-4 font-mono text-xs text-slate-700 truncate max-w-[200px]" title={backup.filename}>
                        {backup.filename}
                      </td>
                      <td className="py-2 px-4 text-xs text-slate-500">
                        {(backup.size / 1024 / 1024).toFixed(2)} MB
                      </td>
                      <td className="py-2 px-4 text-xs text-slate-500">
                        {new Date(backup.createdAt).toLocaleString()}
                      </td>
                      <td className="py-2 px-4 text-right space-x-3">
                        <button
                          type="button"
                          onClick={() => {
                            setPendingRestoreFile(backup.filename);
                            setConfirmRestoreOpen(true);
                          }}
                          disabled={restoring}
                          className="text-xs font-semibold text-emerald-600 hover:text-emerald-800 disabled:opacity-50"
                        >
                          Restore
                        </button>
                        <button
                          type="button"
                          onClick={() => {
                            setPendingDeleteFile(backup.filename);
                            setConfirmDeleteOpen(true);
                          }}
                          className="text-xs font-semibold text-red-600 hover:text-red-800"
                        >
                          Delete
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>

        {/* Danger zone */}
        <div className="mt-4 border-t border-red-100 pt-6">
          <h4 className="text-sm font-semibold text-red-700 mb-1">Danger Zone</h4>
          <p className="text-xs text-slate-500 mb-3">
            Permanently clear all bookmarks, folders, and operation logs. Your credentials and custom API settings are kept.
          </p>
          <button
            type="button"
            onClick={() => setConfirmClearOpen(true)}
            disabled={clearing}
            className="rounded-md border border-red-200 px-4 py-2 text-sm font-semibold text-red-600 hover:bg-red-50 disabled:opacity-50 transition"
          >
            {clearing ? "Clearing..." : "Clear database data"}
          </button>
        </div>
      </div>

      {/* Confirmation Dialogs */}
      <ConfirmationDialog
        isOpen={confirmClearOpen}
        onClose={() => setConfirmClearOpen(false)}
        onConfirm={clearData}
        title="Clear Database Data"
        message="Are you sure you want to delete all bookmarks, folders, and log records? Your settings, credentials, and API tokens will be preserved. This action is irreversible."
        confirmLabel="Clear Data"
        variant="danger"
      />

      <ConfirmationDialog
        isOpen={confirmRestoreOpen}
        onClose={() => {
          setConfirmRestoreOpen(false);
          setPendingRestoreFile(null);
        }}
        onConfirm={() => {
          if (pendingRestoreFile) {
            restoreLocalBackup(pendingRestoreFile);
          }
        }}
        title="Restore Local Backup"
        message={`Are you sure you want to restore the database to the backup file: "${pendingRestoreFile}"? This will overwrite your current database. Any changes made since this backup was taken will be lost.`}
        confirmLabel="Restore"
        variant="danger"
      />

      <ConfirmationDialog
        isOpen={confirmDeleteOpen}
        onClose={() => {
          setConfirmDeleteOpen(false);
          setPendingDeleteFile(null);
        }}
        onConfirm={() => {
          if (pendingDeleteFile) {
            deleteLocalBackup(pendingDeleteFile);
          }
        }}
        title="Delete Server Backup"
        message={`Are you sure you want to delete the backup file: "${pendingDeleteFile}" from the server? This action cannot be undone.`}
        confirmLabel="Delete"
        variant="danger"
      />

      <ConfirmationDialog
        isOpen={confirmUploadOpen}
        onClose={() => {
          setConfirmUploadOpen(false);
          setPendingUploadFile(null);
        }}
        onConfirm={() => {
          if (pendingUploadFile) {
            restoreFromUpload(pendingUploadFile);
          }
        }}
        title="Restore from Uploaded File"
        message={`Are you sure you want to overwrite your active database with the uploaded file: "${pendingUploadFile?.name}"? All existing data will be replaced.`}
        confirmLabel="Upload & Restore"
        variant="danger"
      />
    </SettingsSection>
  );
}
