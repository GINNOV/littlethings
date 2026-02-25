# Product Requirements Document (PRD)  
**Product Name**: Flume Personal Water Dashboard  
**Version**: 1.0 (MVP)  
**Owner/Target User**: Mario Esposito (@windrago) – personal use only  
**Goal**: A private web app to visualize, analyze, and explore Flume water usage data beyond the official app (deeper historical views, custom breakdowns, anomaly detection basics, export).  
**Platform**: Web (responsive, mobile-friendly)  
**Tech Stack** (fixed for execution):
- Next.js 14+ (App Router, TypeScript, Server Components/Actions)
- Tailwind CSS + shadcn/ui components
- Recharts for charts
- date-fns for date handling
- axios for API calls
- Vercel for hosting + env vars + optional cron (via Vercel Cron Jobs)
- No external DB for MVP (query live from Flume API); optional future: Vercel Postgres or Upstash

**Non-Functional Requirements**
- Private access only (no public routes; simple password protect or rely on Vercel auth preview if needed)
- Secure: Never expose FLUME_USERNAME, PASSWORD, CLIENT_ID, CLIENT_SECRET client-side
- Handle API rate limits (~120 req/hour per personal client)
- Token management: Use refresh token when provided (expires ~1h for access token)
- Error handling: Graceful fallbacks, loading states, toast notifications (via sonner or shadcn)
- Performance: Cache token server-side (in-memory or Vercel KV if added); limit queries to reasonable ranges
- Deploy: One-click Vercel (GitHub repo → Vercel)

**Core User Stories / Features (MVP – prioritized)**
1. **Authentication & Data Fetching**  
   - Server-side only: Endpoint `/api/flume/token` (or action) that gets/refresh access token using env vars.  
   - On app load: Fetch user devices → auto-select first (or only) device.  
   - Store user_id/device_id(s) in state after first fetch (or hardcode after manual check).

2. **Dashboard Home Page** (`/`)  
   - Layout: Sidebar (nav) + main content.  
   - Top: Current flow (GPM if flowing), today's usage, this week's total, vs budget if set.  
   - Cards:  
     - Daily usage bar chart (last 14 days)  
     - Hourly usage line chart (last 24–48h)  
     - Total this month / last month comparison  
   - Refresh button + auto-refresh toggle (every 5–15 min).

3. **Historical Explorer Page** (`/history`)  
   - Date range picker (default: last 30 days)  
   - Granularity selector: 1m / 5m / 15m / 1h / 1d / 1w / 1M  
   - Multi-query support: Show total + breakdowns if Flume tags (e.g., irrigation vs indoor – query separately if possible)  
   - Charts: Stacked area or line for usage over time; heatmap for weekday/hour patterns.  
   - Table view: Exportable CSV (date, bucket, gallons/litres).

4. **Alerts & Insights Page** (`/insights`)  
   - List recent notifications/leak alerts from `/notifications` endpoint.  
   - Simple anomaly detection: Highlight days > 2× average or sudden spikes.  
   - Basic stats: Avg daily use, peak hour, lowest use day, conservation score (e.g., vs previous month % change).

5. **Settings Page** (`/settings`)  
   - Display (masked) API creds status.  
   - Unit toggle: GALLONS ↔ LITERS (pass to query).  
   - Custom budget inputs (sync to Flume if API allows PUT budgets).  
   - Manual device selection if >1.

**API Integration Details (from Flume docs)**
- Base: `https://api.flumewater.com`
- Auth: POST `/oauth/token`  
  Body: `{ "grant_type": "password", "username": "...", "password": "...", "client_id": "...", "client_secret": "..." }`  
  → Returns `{ access_token, refresh_token, expires_in }`  
  Use refresh: POST same route with `grant_type: "refresh_token", refresh_token: "..."`
- Key endpoints:
  - GET `/me` or `/users/me` → user_id, devices
  - POST `/users/{user_id}/devices/{device_id}/query`  
    Body example:
    ```json
    {
      "queries": [
        {
          "request_id": "daily",
          "bucket": "1d",
          "since_datetime": "2026-01-01T00:00:00Z",
          "until_datetime": "2026-02-24T23:59:59Z",
          "unit_of_measure": "GALLONS",
          "group_multiplier": 1
        }
      ]
    }
    ```
    Bucket options: 1m, 5m, 15m, 1h, DAY, MON, etc. (case-sensitive per docs)
- Headers: `Authorization: Bearer {access_token}`, `Content-Type: application/json`

**Implementation Roadmap for AI Execution**
Phase 1: Setup & Auth
- Create Next.js project
- Add env vars in Vercel: FLUME_CLIENT_ID, FLUME_CLIENT_SECRET, FLUME_USERNAME, FLUME_PASSWORD
- Build `/api/flume/auth` route → get token (with refresh logic)
- Build `/api/flume/devices` → list devices

Phase 2: Core Data Fetch
- `/api/flume/usage` route: Accept params (since, until, bucket, unit) → run query → return data
- Handle token refresh on 401

Phase 3: UI & Charts
- Root layout with sidebar
- Home page: Use Recharts BarChart/LineChart with fetched data
- History page: react-day-picker + granularity dropdown → dynamic query

Phase 4: Polish & Deploy
- Add loading/error states
- Basic insights calculations (use date-fns + simple math)
- Deploy to Vercel; test private access

**Success Criteria for MVP Launch**
- Loads data from your Flume device without errors
- Shows at least daily + hourly charts accurately
- Handles date ranges >1 week without hitting rate limits badly
- Deployed and accessible privately
