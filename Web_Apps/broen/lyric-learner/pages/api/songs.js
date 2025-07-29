import { createPool } from '@vercel/postgres';

export default async function handler(req, res) {
  // Check if the environment variable exists.
  if (!process.env.STORAGE_POSTGRES_URL) {
    console.error('[API] FATAL: Missing STORAGE_POSTGRES_URL environment variable.');
    return res.status(500).json({ error: 'Server configuration error: Database URL is missing.' });
  }

  const pool = createPool({
    connectionString: process.env.STORAGE_POSTGRES_URL,
  });

  try {
    // Fetch just the id and title for the song list, ordered by title.
    const { rows } = await pool.sql`SELECT id, title FROM songs ORDER BY title ASC;`;
    res.status(200).json(rows);
  } catch (error) {
    console.error('[API] CRITICAL ERROR during songs list query:', error);
    res.status(500).json({ error: 'Internal Server Error during database query.' });
  }
}
