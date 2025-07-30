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

    if (flatNewWords.length === 0) {
      await client.query('COMMIT');
      return res.status(200).json({ message: 'No timings to update.' });
    }

    const wordIds = existingWordIds;
    const startTimes = flatNewWords.map(word => word.startTime || 0);
    const endTimes = flatNewWords.map(word => word.endTime || 0);

    // rationale: This is the defense-in-depth fix. We explicitly cast the incoming data
    // to the correct column type (`real`) within the SQL query itself. This directly
    // addresses the database error and makes the API more resilient to data type issues.
    const updateQuery = `
      UPDATE words AS w SET
        start_time = u.start_time::real,
        end_time = u.end_time::real
      FROM (
        SELECT 
          unnest($1::int[]) AS id,
          unnest($2::numeric[]) AS start_time,
          unnest($3::numeric[]) AS end_time
      ) AS u
      WHERE w.id = u.id
    `;
    
    await client.query(updateQuery, [wordIds, startTimes, endTimes]);

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
