export class AudioManager {
    constructor() {
        this.ctx = null;
        this.sfxBuffers = {};
        this.musicBuffer = null;
        this.musicSource = null;
        this.initialized = false;
    }

    async init() {
        if (this.initialized) return;
        this.ctx = new AudioContext();
        this.initialized = true;

        // Load SFX
        await Promise.all([
            this._loadSfx('laser', '../NTSC/graphics/Sound/laser.sfx'),
            this._loadSfx('explosion', '../NTSC/graphics/Sound/explosion.sfx'),
            this._loadSfx('token', '../NTSC/graphics/Sound/token.sfx'),
        ]);

        // Load music
        try {
            const resp = await fetch('music.wav');
            if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
            const buf = await resp.arrayBuffer();
            this.musicBuffer = await this.ctx.decodeAudioData(buf);
        } catch (e) {
            console.warn('Could not load music:', e);
        }
    }

    async _loadSfx(name, url) {
        try {
            const resp = await fetch(url);
            const buf = await resp.arrayBuffer();
            const raw = new Int8Array(buf);

            // Upsample 4x (11025 -> 44100) and convert to float
            const upsampled = new Float32Array(raw.length * 4);
            for (let i = 0; i < raw.length; i++) {
                const val = raw[i] / 128.0;
                upsampled[i * 4] = val;
                upsampled[i * 4 + 1] = val;
                upsampled[i * 4 + 2] = val;
                upsampled[i * 4 + 3] = val;
            }

            const audioBuffer = this.ctx.createBuffer(1, upsampled.length, 44100);
            audioBuffer.getChannelData(0).set(upsampled);
            this.sfxBuffers[name] = audioBuffer;
        } catch (e) {
            console.warn(`Could not load SFX ${name}:`, e);
        }
    }

    playSfx(name) {
        if (!this.ctx || !this.sfxBuffers[name]) return;
        if (this.ctx.state === 'suspended') this.ctx.resume();
        const source = this.ctx.createBufferSource();
        source.buffer = this.sfxBuffers[name];
        source.connect(this.ctx.destination);
        source.start();
    }

    async playMusic() {
        if (!this.ctx || !this.musicBuffer) return;
        if (this.ctx.state === 'suspended') {
            await this.ctx.resume();
        }
        this.stopMusic();
        this.musicSource = this.ctx.createBufferSource();
        this.musicSource.buffer = this.musicBuffer;
        this.musicSource.loop = true;
        this.musicGain = this.ctx.createGain();
        this.musicGain.gain.value = 0.4;
        this.musicSource.connect(this.musicGain);
        this.musicGain.connect(this.ctx.destination);
        this.musicSource.start(0);
    }

    stopMusic() {
        if (this.musicSource) {
            try { this.musicSource.stop(); } catch (e) {}
            this.musicSource = null;
        }
    }
}
