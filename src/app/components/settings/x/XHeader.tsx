import { XLogo } from "../../Icons";

export function XHeader() {
  return (
    <summary className="flex cursor-pointer list-none items-center justify-between text-lg font-semibold">
      <span className="flex items-center gap-3">
        <span className="flex h-9 w-9 items-center justify-center rounded-full bg-black text-white"><XLogo className="h-4 w-4" /></span>
        <span>X integration</span>
      </span>
      <span className="text-slate-500 transition-transform duration-200 group-open:rotate-180">
        <svg viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg" className="h-5 w-5"><path d="M5 7.5L10 12.5L15 7.5" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" /></svg>
      </span>
    </summary>
  );
}
