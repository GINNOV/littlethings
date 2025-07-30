import { createPool } from '@vercel/postgres';

export default async function handler(req, res) {
  if (!process.env.STORAGE_POSTGRES_URL) {
    return res.status(500).json({ error: 'Server configuration error: Database URL is missing.' });
  }

  const pool = createPool({
    connectionString: process.env.STORAGE_POSTGRES_URL,
  });

  const { id } = req.query;

  if (!id || isNaN(parseInt(id))) {
    return res.status(400).json({ error: 'A valid song ID is required.' });
  }

  try {
    const songResult = await pool.query('SELECT id, title, author, youtube_video_id FROM songs WHERE id = $1', [id]);

    if (songResult.rowCount === 0) {
      return res.status(404).json({ error: 'Song not found' });
    }

    const song = songResult.rows[0];

    const [stanzasResult, wordsResult] = await Promise.all([
      pool.query('SELECT id, stanza_index FROM stanzas WHERE song_id = $1 ORDER BY stanza_index ASC', [id]),
      // rationale: Added the 'pronunciation' column to the SELECT statement.
      pool.query(`
        SELECT w.text, w.layer, w.example, w.italian, w.start_time, w.end_time, s.stanza_index, w.word_index, w.pronunciation
        FROM words w
        JOIN stanzas s ON w.stanza_id = s.id
        WHERE s.song_id = $1
        ORDER BY s.stanza_index ASC, w.word_index ASC;
      `, [id]),
    ]);

    const stanzas = stanzasResult.rows.map((stanzaInfo) => {
      return wordsResult.rows
        .filter((word) => word.stanza_index === stanzaInfo.stanza_index)
        .map((word) => ({
          text: word.text,
          layer: word.layer,
          example: word.example,
          italian: word.italian,
          startTime: word.start_time,
          endTime: word.end_time,
          // rationale: Added the pronunciation data to the response object for each word.
          pronunciation: word.pronunciation,
        }));
    });

    const layers = {
      1: { name: 'Vocabolario essenziale', color: '#EBF8FF', textColor: '#2A4365' },
      2: { name: 'Parole descrittive', color: '#F0FFF4', textColor: '#22543D' },
      3: { name: 'Astratto & Figurativo', color: '#FFFBEB', textColor: '#744210' },
      4: { name: 'Riferimenti Culturali', color: '#F9F5FF', textColor: '#44337A' },
    };

    const responseData = {
      title: song.title,
      author: song.author,
      youtubeVideoId: song.youtube_video_id,
      layers: layers,
      stanzas: stanzas,
    };

    res.status(200).json(responseData);
  } catch (error) {
    console.error('[API] CRITICAL ERROR:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
}
