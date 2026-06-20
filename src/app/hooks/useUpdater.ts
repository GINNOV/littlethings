"use client";

import { useEffect, useState } from "react";

export function useUpdater() {
  const [updateAvailable, setUpdateAvailable] = useState(false);
  const [isUpdating, setIsUpdating] = useState(false);
  const [updateVersion, setUpdateVersion] = useState<string | null>(null);

  useEffect(() => {
    // Check if running in Tauri environment
    if (typeof window === "undefined" || !(window as any).__TAURI_INTERNALS__) {
      return;
    }

    const checkUpdates = async () => {
      try {
        const { check } = await import("@tauri-apps/plugin-updater");
        const update = await check();
        if (update) {
          console.log(`[Updater] New version found: ${update.version}`);
          setUpdateVersion(update.version);
          setUpdateAvailable(true);

          // Ask the user if they want to update
          const confirmUpdate = window.confirm(
            `A new version (${update.version}) of XBook Console is available. Would you like to download and install it now?`
          );

          if (confirmUpdate) {
            setIsUpdating(true);
            console.log("[Updater] Starting update download and install...");
            
            // Download and install
            await update.downloadAndInstall();
            console.log("[Updater] Update installed successfully. Relaunching...");
            
            // Relaunch the application
            const { invoke } = await import("@tauri-apps/api/core");
            await invoke("relaunch_app");
          }
        } else {
          console.log("[Updater] No updates found.");
        }
      } catch (err) {
        // If the update server is not deployed or offline, warn rather than throwing a red console error
        console.warn("[Updater] Update check failed or server is offline (this is expected when running a local build without a deployed release server):", err);
      } finally {
        setIsUpdating(false);
      }
    };

    // Delay the update check slightly after boot so it doesn't block startup
    const timer = setTimeout(() => {
      checkUpdates();
    }, 5000);

    return () => clearTimeout(timer);
  }, []);

  return { updateAvailable, isUpdating, updateVersion };
}
