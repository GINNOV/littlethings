# Flume Personal Water Dashboard

A private Next.js application for visualizing, analyzing, and exploring Flume water usage data.

## Features

- Server-side authentication against the Flume API.
- Dashboard for today's usage and recent history.
- Historical explorer with custom date ranges and hourly, daily, or monthly granularity.
- Responsive charts built with Tailwind CSS and Recharts.
- Optional settings UI for storing Flume credentials locally in an encrypted cookie.

## Prerequisites

- Node.js 20 or newer.
- npm.
- Flume API credentials from the [Flume Portal](https://portal.flumewater.com/).

## Environment

Create `.env.local` in this folder:

```bash
FLUME_CLIENT_ID=your_client_id_here
FLUME_CLIENT_SECRET=your_client_secret_here
FLUME_USERNAME=your_flume_email@example.com
FLUME_PASSWORD=your_flume_password_here
FLUME_CONFIG_SECRET=change_this_to_a_long_random_value
```

`FLUME_CONFIG_SECRET` is used to encrypt the optional browser-stored configuration. Use a stable, private value in production.

## Development

```bash
npm install
npm run dev
```

Open <http://localhost:3000>.

## Useful Commands

```bash
npm run lint
npm run build
npm run start
```

## Tech Stack

- Next.js 16 App Router
- React 19
- Tailwind CSS 4
- Recharts
- Flume API v1

## Security Notes

- Do not commit `.env.local` or Flume API credentials.
- This app is intended as a private dashboard, not a public multi-user service.
- The Flume API has rate limits; avoid aggressive refresh loops or large repeated historical queries.
