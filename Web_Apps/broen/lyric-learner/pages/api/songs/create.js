import { createPool } from '@vercel/postgres';

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed' });
  }

  if (!process.env.STORAGE_POSTGRES_URL) {
    return res.status(500).json({ error: 'Server configuration error' });
  }

  const pool = createPool({ connectionString: process.env.STORAGE_POSTGRES_URL });
  const { title, author, youtubeVideoId, lyrics } = req.body;

  if (!title || !author || !youtubeVideoId || !lyrics) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN'); // Start transaction

    // 1. Insert the song
    const songInsertResult = await client.query(
      'INSERT INTO songs (title, author, youtube_video_id) VALUES ($1, $2, $3) RETURNING id',
      [title, author, youtubeVideoId]
    );
    const newSongId = songInsertResult.rows[0].id;

    // 2. Process lyrics and insert stanzas and words
    const stanzas = lyrics.split('\n').filter(line => line.trim() !== '');

    for (const [stanzaIndex, stanzaText] of stanzas.entries()) {
      const stanzaInsertResult = await client.query(
        'INSERT INTO stanzas (song_id, stanza_index) VALUES ($1, $2) RETURNING id',
        [newSongId, stanzaIndex]
      );
      const newStanzaId = stanzaInsertResult.rows[0].id;

      const words = stanzaText.split(' ').filter(word => word.trim() !== '');
      for (const [wordIndex, wordText] of words.entries()) {
        // rationale: Added the 'pronunciation' column to the INSERT statement with a default placeholder.
        await client.query(
          'INSERT INTO words (stanza_id, word_index, text, layer, example, italian, start_time, end_time, pronunciation) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)',
          [newStanzaId, wordIndex, wordText, 1, 'Example needed', 'Italian needed', 0, 0, 'Pronunciation needed'] // Default values
        );
      }
    }

    await client.query('COMMIT'); // Commit transaction
    res.status(201).json({ id: newSongId, title });

  } catch (error) {
    await client.query('ROLLBACK'); // Rollback on error
    console.error('API Error creating song:', error);
    res.status(500).json({ error: 'Error creating song in database' });
  } finally {
    client.release();
  }
}
