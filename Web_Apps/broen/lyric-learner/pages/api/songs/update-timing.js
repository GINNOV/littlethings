import { createPool } from '@vercel/postgres';

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed' });
  }

  if (!process.env.STORAGE_POSTGRES_URL) {
    return res.status(500).json({ error: 'Server configuration error' });
  }

  const pool = createPool({ connectionString: process.env.STORAGE_POSTGRES_URL });
  const { songId, stanzas } = req.body;

  if (!songId || !stanzas) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // To update correctly, we need to find each word's unique ID.
    // First, fetch all word IDs for the given song in their correct order.
    const existingWordsResult = await client.query(
      `SELECT w.id FROM words w 
       JOIN stanzas s ON w.stanza_id = s.id 
       WHERE s.song_id = $1 
       ORDER BY s.stanza_index, w.word_index`,
      [songId]
    );
    const existingWordIds = existingWordsResult.rows.map(row => row.id);
    const flatNewWords = stanzas.flat();

    if (existingWordIds.length !== flatNewWords.length) {
      throw new Error("Word count mismatch between database and submission. Cannot update.");
    }

    // Create an array of promises to update all words
    const updatePromises = flatNewWords.map((newWordData, index) => {
      const wordId = existingWordIds[index];
      return client.query(
        'UPDATE words SET start_time = $1, end_time = $2 WHERE id = $3',
        [newWordData.startTime || 0, newWordData.endTime || 0, wordId]
      );
    });

    // Execute all update queries in parallel
    await Promise.all(updatePromises);

    await client.query('COMMIT');
    res.status(200).json({ message: 'Timings updated successfully.' });

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('API Error updating timings:', error);
    res.status(500).json({ error: 'Error updating timings in database' });
  } finally {
    client.release();
  }
}
