# Flume Personal Water Dashboard

A private web application built with Next.js to visualize, analyze, and explore Flume water usage data.

## Features
- **Authentication**: Secure server-side authentication with Flume API.
- **Dashboard**: Real-time monitoring of today's usage and last 14 days history.
- **Historical Explorer**: Deep dive into your data with custom date ranges and granularity (Hourly, Daily, Monthly).
- **Responsive Design**: Modern UI built with Tailwind CSS and Recharts.

## Getting Started

### 1. Prerequisites
- Node.js 18+
- Flume API Credentials (obtain from [Flume Portal](https://portal.flumewater.com/))

### 2. Environment Setup
Copy `.env.example` to `.env.local` and fill in your credentials:
```bash
cp .env.example .env.local
```

### 3. Install Dependencies
```bash
npm install
```

### 4. Run Development Server
```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to see your dashboard.

## Tech Stack
- **Framework**: Next.js 15+ (App Router)
- **Styling**: Tailwind CSS
- **Charts**: Recharts
- **API**: Flume API v1
- **Deployment**: Vercel
