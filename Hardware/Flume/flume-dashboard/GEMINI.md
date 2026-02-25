# Flume Personal Water Dashboard

A private web application built with Next.js to visualize and analyze water usage data from Flume devices. This project aims to provide deeper historical insights and custom breakdowns beyond the official Flume application.

## 🛠 Tech Stack
- **Framework:** [Next.js 15+](https://nextjs.org/) (App Router, TypeScript)
- **Styling:** [Tailwind CSS v4](https://tailwindcss.com/)
- **Charts:** [Recharts](https://recharts.org/)
- **Data Fetching:** [Axios](https://axios-http.com/)
- **Utilities:** [date-fns](https://date-fns.org/)
- **Deployment:** [Vercel](https://vercel.com/)

## 🚀 Getting Started

### Prerequisites
- Node.js (Latest LTS recommended)
- Flume API Credentials (CLIENT_ID, CLIENT_SECRET, USERNAME, PASSWORD)

### Installation
```bash
npm install
```

### Environment Variables
Create a `.env.local` file with the following keys:
- `FLUME_CLIENT_ID`
- `FLUME_CLIENT_SECRET`
- `FLUME_USERNAME`
- `FLUME_PASSWORD`

### Development
```bash
npm run dev
```

### Building for Production
```bash
npm run build
npm start
```

## 🏗 Project Structure
- `src/app/`: Next.js App Router pages and layouts.
- `src/components/`: Reusable UI components (Planned for shadcn/ui).
- `src/lib/`: Utility functions and API clients.
- `AI/plan.md`: Detailed Product Requirements Document (PRD) and implementation roadmap.

## 📝 Development Conventions
- **Component Architecture:** Use React Server Components (RSC) by default; use `'use client'` only when interactivity or browser APIs are required.
- **Styling:** Follow Tailwind CSS v4 conventions.
- **Type Safety:** Ensure all API responses and component props are strictly typed with TypeScript.
- **API Integration:** Centralize Flume API logic in server actions or dedicated API routes to keep credentials secure.

## 🗺 Roadmap (MVP)
1. **Phase 1:** Setup Authentication and Device listing.
2. **Phase 2:** Implement Core Data Fetching for usage metrics.
3. **Phase 3:** Build Dashboard UI with Recharts (Daily/Hourly views).
4. **Phase 4:** Historical Explorer with date range selection.
5. **Phase 5:** Alerts, Insights, and Settings.

Refer to `AI/plan.md` for the full technical specification and roadmap.
