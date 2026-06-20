# XBook UI Overhaul Brief for Stitch

## Product Context

XBook is a local-first bookmark command center for X and YouTube. It imports saved posts/videos, summarizes them with a local or configured LLM, categorizes them, tracks read state, and lets the user search, edit, and reprocess individual items.

The redesign should feel like a focused research console, not a marketing site. Start with the working surface: sync status, cost-aware X imports, enrichment progress, folders, and the bookmark library.

## Visual Thesis

A precise editorial workspace with dark ink, crisp white surfaces, quiet graphite dividers, and a single green action accent. It should feel dense, calm, and trustworthy, with enough hierarchy to scan hundreds of saved items quickly.

## Design Goals

1. Make X API cost control obvious.
2. Make sync and enrichment state easy to understand at a glance.
3. Make the bookmark library faster to scan than the current card grid.
4. Keep X and YouTube visually distinct without turning the UI into two separate products.
5. Replace the current beige, rounded-card dashboard look with a cleaner operator interface.
6. Preserve every existing workflow: import, folder import, summarize/categorize, folder processing, search/filter, read/unread, edit enrichment, reprocess one item, settings.

## Primary Users

The user is a researcher, builder, or analyst who saves many links and wants to recover useful information later. They care about avoiding wasted X API calls because X charges per call. They also care about keeping LLM processing under control.

## App Structure

Use a persistent shell:

- Left sidebar on desktop.
- Top compact header on mobile.
- Main workspace.
- Optional right inspector panel for selected bookmark details on desktop.

Navigation:

- Dashboard
- X Library
- YouTube Library
- Folders
- Settings

Do not make a hero section. Do not use marketing copy.

## Global Layout

Desktop:

- 240px left sidebar.
- Main content max width can be wide, around 1440-1680px.
- Use a two-column workspace when useful: primary list plus right inspector.
- Keep controls sticky near the top of the workspace where possible.

Tablet:

- Collapsible sidebar or compact horizontal nav.
- Two-column layouts may collapse to one column.

Mobile:

- Top nav with product name and menu.
- Full-width controls.
- Bookmark rows become stacked compact list items.
- Avoid horizontal scrolling except for optional filter chips.

## Typography

Use two type styles maximum:

- Sans for all UI text, labels, tables, and controls.
- Optional editorial serif only for product mark or major page titles, used sparingly.

Recommended tone:

- Page titles: direct nouns, such as `Dashboard`, `X Library`, `Settings`.
- Section labels: operational, such as `X API usage`, `Pending enrichment`, `Last sync`, `Folder imports`.
- Avoid slogans like “Turn saved posts into a knowledge vault.”

## Color System

Use a neutral foundation:

- Background: near-white or very light cool gray.
- Primary text: near-black.
- Secondary text: gray.
- Dividers: low-contrast gray.
- Main action accent: green.
- Warning/cost accent: amber.
- Error accent: red.
- X source marker: black.
- YouTube source marker: red, but restrained.

Avoid:

- Beige/cream/tan palette.
- Dominant purple, blue-purple, dark slate, brown, orange, or espresso themes.
- Decorative gradient blobs.
- One-note monochrome screens with no semantic status color.

## Component Style

Prefer tables, rows, segmented controls, tabs, side panels, and inline status blocks over card mosaics.

Cards are allowed only for:

- A selected bookmark detail panel.
- A modal.
- A compact metric module where the boundary improves scanning.

Rules:

- Border radius 8px or less.
- No cards inside cards.
- Minimal shadows. Use borders, spacing, and background tone first.
- Buttons should be rectangular or softly rounded, not pill-heavy everywhere.
- Text must not use negative letter spacing.
- Do not scale text with viewport width.

## Dashboard Screen

Purpose: show operational state and let the user run safe sync/enrichment actions.

Top region:

- Page title: `Dashboard`.
- Source switcher: `X` and `YouTube`.
- Last sync timestamp.
- Connection state indicators for X, YouTube, and LLM.

Primary modules:

1. `X API usage`
   - Show monthly cap, used count, remaining count.
   - Show latest X baseline bookmark ID or “No baseline set.”
   - Show the last folder import call count if available.
   - Include a small warning state when remaining calls are low.

2. `Sync`
   - Primary action: `Sync X bookmarks` or `Sync YouTube bookmarks`.
   - For X, include helper text: `Uses latest baseline to avoid fetching older bookmarks.`
   - Show result copy with new vs refreshed counts.

3. `Enrichment`
   - Primary action: `Summarize and categorize`.
   - Show pending count, processed count, errors.
   - If errors occur, show that processing stopped to avoid retrying failed items.

4. `Folders`
   - List folders with counts and actions.
   - For X folder import, show expected cost behavior: `Stops at first existing item.`
   - Show `X calls: N` after a folder import.

Recent activity:

- Use a compact log/timeline, not a grid of large cards.
- Include sync runs, folder imports, enrichment runs, and errors.

## X Library Screen

Purpose: search, triage, and edit imported X bookmarks.

Default layout:

- Sticky filter bar at top.
- Dense list or table as the primary view.
- Right inspector panel on desktop when an item is selected.

Filter bar:

- Search input.
- Category select.
- Folder select.
- Read state filter: `All`, `Unread`, `Read`.
- Enrichment filter: `All`, `Pending`, `Summarized`, `Edited`.
- Clear filters action.

List columns:

- Source marker.
- Category.
- Summary first line or source text fallback.
- Author handle.
- Folder.
- Status: summarized, edited, read.
- Imported date.
- Actions.

Row behavior:

- Single click selects item and opens inspector.
- Source text can expand inline or in inspector.
- Long text should be clamped by default.
- Read/unread should be a quick inline toggle.
- Reprocess should be visually secondary and should communicate that it spends an LLM call.

Inspector:

- Original post text.
- Summary.
- Category.
- Tags.
- Author.
- Folder.
- External links.
- Actions: `Open on X`, `Edit`, `Reprocess`, `Mark read`.

## YouTube Library Screen

Use the same library architecture as X, but optimize labels for videos:

- `Video title`.
- `Playlist`.
- `Digest`.
- `Open on YouTube`.

YouTube can use red as a source marker, but the overall UI should remain neutral.

## Folders Screen

Purpose: manage imports and processing by folder/playlist.

Desktop layout:

- Two tabs: `X folders`, `YouTube playlists`.
- Dense list/table of folders.

X folder row fields:

- Folder name.
- Local bookmark count.
- Last import result if known.
- Actions: `Import new`, `Process pending`.
- Cost note: `Stops at first existing item`.

YouTube playlist row fields:

- Playlist name.
- Video count.
- Local imported count.
- Actions: `Process pending`.

## Settings Screen

Purpose: configure credentials, limits, and LLM behavior without overwhelming the user.

Use grouped sections with clear status:

1. `X connection`
   - OAuth status.
   - Client ID/secret/redirect URI.
   - User ID.
   - API base.
   - Advanced bearer token section collapsed by default.

2. `YouTube connection`
   - OAuth status.
   - Upload Google OAuth JSON.
   - Client ID/secret/redirect URI.
   - Reconnect/Disconnect/Test actions.
   - If token is invalid, show: `YouTube authorization expired. Reconnect to continue.`

3. `LLM`
   - Base URL.
   - API key.
   - Model.
   - Prompt editor collapsed under `Advanced prompt`.
   - Test action.

4. `Usage limits`
   - X monthly cap.
   - YouTube monthly cap.
   - Enrichment batch size.
   - Mark latest X bookmark as baseline.

Settings should not feel like a stack of giant cards. Use sections with thin dividers and concise labels.

## Key States to Design

Empty states:

- No bookmarks imported.
- No folders synced.
- No search results.
- No pending enrichment.

Loading states:

- Syncing X.
- Importing an X folder.
- Enriching batch.
- Testing OAuth/LLM connections.

Error states:

- X monthly cap reached.
- X API error.
- LLM unavailable.
- YouTube token expired or revoked.
- Enrichment stopped after an error to avoid wasted calls.

Success states:

- Imported N new, refreshed N existing.
- X folder import used N calls and stopped at existing item.
- Enrichment completed.
- Settings saved.

## Motion and Interaction

Use restrained app motion:

- Sidebar active indicator slides between nav items.
- Filter bar and selected row transitions should be fast and subtle.
- Inspector panel should slide/fade in on desktop.
- Modals should fade and scale slightly.
- Progress updates should animate numbers only if it does not distract.

Avoid decorative motion.

## Accessibility

- Strong keyboard focus states.
- All actions reachable by keyboard.
- Buttons have explicit labels.
- Error and success messages are plain text and not color-only.
- Contrast should pass WCAG AA.
- Use stable dimensions for controls so loading labels do not shift layout.

## Copy Guidelines

Use short operational copy:

- `Sync X bookmarks`
- `Import new`
- `Process pending`
- `Stops at first existing item`
- `X calls: 1`
- `Imported 12 new. Refreshed 4 existing.`
- `No bookmarks pending categorization.`
- `Stopped after an error to avoid wasted calls.`

Avoid:

- Marketing claims.
- Long instructional paragraphs.
- Self-referential UI descriptions.

## Stitch Prompt

Create a complete redesign for a Next.js local bookmark management app named XBook. It imports X bookmarks and YouTube playlist videos, summarizes and categorizes them with an LLM, tracks read state, and provides search, folder processing, and settings.

Design it as a precise research console with a persistent app shell, dense bookmark library, cost-aware X sync controls, and clean settings. Use a neutral near-white/graphite system with one green action accent, amber for cost warnings, red for errors and restrained YouTube source markers, and black for X source markers. Avoid beige, decorative gradients, pill-heavy controls, and generic dashboard card mosaics.

Required screens:

- Dashboard with source switcher, X API usage, sync actions, enrichment actions, folder import controls, recent activity.
- X Library with sticky filters, dense bookmark list/table, selected-item inspector, read/edit/reprocess actions.
- YouTube Library with the same structure but video and playlist labels.
- Folders with X folders and YouTube playlists, including X folder import cost feedback.
- Settings with grouped sections for X OAuth, YouTube OAuth, LLM, and usage limits.

Emphasize that X API calls cost money. In X folder import states, show `Stops at first existing item` and post-import feedback such as `X calls: 1`. For enrichment errors, show that processing stopped to avoid retrying failed items.

Use concise product UI copy, not marketing copy. Keep border radii at 8px or less. Use tables, rows, panels, and dividers instead of stacked cards. Make the interface responsive from desktop to mobile.
