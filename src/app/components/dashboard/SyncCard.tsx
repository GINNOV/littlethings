import Actions from "../Actions";

export function SyncCard({ tab, enrichSize, pend, last, settings }: any) {
  return (
    <div className="rounded-lg bg-surface-container-lowest p-5">
      <h2 className="text-base font-semibold">Sync engines</h2>
      <div className="mt-6">
        <Actions enrichBatchSize={enrichSize} source={tab} pendingCount={pend} soundOnComplete={settings?.soundOnComplete ?? false} soundOnError={settings?.soundOnError ?? false} />
      </div>
      <p className="mt-2 text-xs text-on-surface-variant italic">Last sync: {last ? new Date(last).toLocaleString() : "Not yet"}</p>
    </div>
  );
}
