import {
    INTERNAL_W, INTERNAL_H, SCREEN_W, SCREEN_H, FPS, PANEL_H, VIEW_H,
    SCROLL_TICKS, SCROLL_SPEED, BULLET_SPEED,
    WAVE_SPAWN_INTERVAL, ALIEN_FIRE_CHANCE, BOSS_FIRE_CHANCE,
    TOKEN_SPAWN_INTERVAL, TOKEN_TYPES,
    ALIEN_SCORE_FIRST, ALIEN_SCORE_OTHER, BUG_SCORE, BOSS_SCORE,
    ALL_PATTERNS, LEVELS, LEVEL_BG_ENEMIES,
    BLACK, WHITE, YELLOW, RED, CYAN, GREEN, PANEL_BG,
} from './constants.js';
import { InputManager } from './input.js';
import { loadAllAssets, getBossSprites, getBgEnemySprites } from './assets.js';
import { AudioManager } from './audio.js';
import { Player } from './player.js';
import { Bullet, AlienBullet } from './projectiles.js';
import { Alien, Wave, Boss, CircularBoss, BackgroundEnemy } from './enemies.js';
import { Explosion, Token } from './effects.js';

function rectsCollide(a, b) {
    return a.x < b.x + b.w && a.x + a.w > b.x &&
           a.y < b.y + b.h && a.y + a.h > b.y;
}

function randInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

export class Game {
    constructor(canvas) {
        this.canvas = canvas;
        this.ctx = canvas.getContext('2d');
        this.internal = document.createElement('canvas');
        this.internal.width = INTERNAL_W;
        this.internal.height = INTERNAL_H;
        this.ictx = this.internal.getContext('2d');
        this.input = new InputManager();
        this.audio = new AudioManager();
        this.assets = null;
        this.state = 'loading';
        this.tick = 0;
        this.titleCycleIdx = 0;
        this.lastTime = 0;
    }

    async init() {
        // Show loading text
        this.ctx.fillStyle = '#000';
        this.ctx.fillRect(0, 0, SCREEN_W, SCREEN_H);
        this.ctx.fillStyle = '#fff';
        this.ctx.font = '24px monospace';
        this.ctx.fillText('Loading...', SCREEN_W / 2 - 60, SCREEN_H / 2);

        await this.audio.init();
        this.assets = await loadAllAssets();
        Bullet.sprites = this.assets.bulletSprites;

        this.state = 'title';
        this.initGame();
        await this.audio.playMusic();
        this.lastTime = performance.now();
        requestAnimationFrame((t) => this.loop(t));
    }

    loop(timestamp) {
        const elapsed = timestamp - this.lastTime;
        if (elapsed >= 1000 / FPS) {
            this.lastTime = timestamp - (elapsed % (1000 / FPS));
            this.tick++;
            this.update();
            this.draw();
            this.input.clearFrame();
        }
        requestAnimationFrame((t) => this.loop(t));
    }

    // ── Game State ───────────────────────────────────────────

    initGame() {
        this.player = new Player(this.assets.playerFramesHoriz, this.assets.playerFramesVert);
        this.currentLevel = 0;
        this.loadLevel(0);
    }

    loadLevel(levelIdx) {
        this.currentLevel = levelIdx;
        const level = LEVELS[levelIdx];
        this.scrollDir = level.scroll_dir;
        this.player.setScrollDir(this.scrollDir);

        // Background
        this.background = this.assets.backgrounds[levelIdx] || null;

        // Scroll setup
        this.scrollX = 0;
        this.scrollY = 0;
        if (this.scrollDir === 'horizontal') {
            this.maxScroll = this.background ? this.background.width - INTERNAL_W : 896;
        } else {
            this.maxScroll = this.background ? this.background.height - VIEW_H : 1024;
            this.scrollY = this.maxScroll;
        }

        // Reset gameplay
        this.bullets = [];
        this.alienBullets = [];
        this.waves = [];
        this.explosions = [];
        this.tokens = [];
        this.bosses = [];
        this.circularBoss = null;
        this.bossActive = false;
        this.bossDefeated = false;
        this.scrollPaused = false;
        this.levelComplete = false;
        this.levelCompleteTimer = 0;
        this.scrollTimer = 0;
        this.waveTimer = 60;
        this.tokenTimer = TOKEN_SPAWN_INTERVAL;
        this.tokenCycle = 0;
        this.lastPattern = -1;
        this.announceTimer = 120;
        this.cycleTimer = 0;

        // Background enemies
        this.bgEnemies = [];
        const bgDefs = LEVEL_BG_ENEMIES[levelIdx] || [];
        for (const be of bgDefs) {
            const frames = getBgEnemySprites(this.assets, levelIdx, be.type);
            if (frames.length > 0) {
                this.bgEnemies.push(new BackgroundEnemy(be.x, be.y, frames, be.type, be.hp));
            }
        }
    }

    // ── Spawning ─────────────────────────────────────────────

    _mirrorPatternH(pattern) {
        return pattern.map(([d, f, vx, vy], i) =>
            [d, f, i === 0 ? INTERNAL_W - vx : -vx, vy]);
    }

    _mirrorPatternV(pattern) {
        return pattern.map(([d, f, vx, vy], i) =>
            [d, f, vx, i === 0 ? VIEW_H - vy : -vy]);
    }

    spawnWave() {
        if (this.bossActive || this.levelComplete) return;
        const level = LEVELS[this.currentLevel];
        let active = 0;
        for (const w of this.waves) for (const a of w.aliens) if (a.alive) active++;
        if (active >= level.max_aliens) return;

        let patIdx = randInt(0, ALL_PATTERNS.length - 1);
        while (patIdx === this.lastPattern && ALL_PATTERNS.length > 1) {
            patIdx = randInt(0, ALL_PATTERNS.length - 1);
        }
        this.lastPattern = patIdx;
        let pattern = ALL_PATTERNS[patIdx];

        const [, , sx, sy] = pattern[0];
        if (this.scrollDir === 'horizontal') {
            if (sx < INTERNAL_W / 2) pattern = this._mirrorPatternH(pattern);
        } else {
            if (sy > VIEW_H / 2) pattern = this._mirrorPatternV(pattern);
        }

        if (this.assets.alienShipFrames.length === 0) return;
        const shipFrames = this.assets.alienShipFrames[
            randInt(0, this.assets.alienShipFrames.length - 1)];

        const remaining = level.max_aliens - active;
        let waveSize = Math.min(remaining, randInt(level.min_wave, level.max_wave));
        waveSize = Math.max(2, waveSize);

        const wave = new Wave();
        for (let i = 0; i < waveSize; i++) {
            const alien = new Alien(pattern, shipFrames, wave);
            alien.x += randInt(-10, 10);
            alien.y += randInt(-10, 10);
            alien.stepTimer = -i * 10;
            wave.aliens.push(alien);
        }
        this.waves.push(wave);
    }

    spawnBoss() {
        const level = LEVELS[this.currentLevel];
        const bossFrames = getBossSprites(this.assets, this.currentLevel);
        const bossType = level.boss_type;
        const hp = level.boss_hp;

        this.bossActive = true;
        this.scrollPaused = true;

        if (bossType === 'single' || bossType === 'dual') {
            this.bosses = level.boss_patterns.map(p => new Boss(bossFrames, p, hp));
        } else if (bossType === 'circular') {
            this.circularBoss = new CircularBoss(bossFrames, hp);
        } else if (bossType === 'lavaball') {
            this.bosses = level.boss_patterns.map(p => new Boss(bossFrames, p, hp, true));
        }
    }

    spawnExplosion(x, y) {
        if (this.assets.explosionFrames.length > 0) {
            this.explosions.push(new Explosion(x, y, this.assets.explosionFrames));
            this.audio.playSfx('explosion');
        }
    }

    spawnToken(x, y) {
        const tokenType = TOKEN_TYPES[this.tokenCycle % TOKEN_TYPES.length];
        this.tokenCycle++;
        let frames = [];
        if (this.assets.tokenFrames.length > 0) {
            const idx = (this.tokenCycle - 1) % this.assets.tokenFrames.length;
            frames = [this.assets.tokenFrames[idx]];
        }
        this.tokens.push(new Token(x, y, tokenType, frames));
    }

    fireAlienBullet(ax, ay) {
        if (!this.player.alive) return;
        const dx = this.player.x - ax;
        const dy = this.player.y - ay;
        const dist = Math.max(1, Math.sqrt(dx * dx + dy * dy));
        const speed = 3;
        this.alienBullets.push(new AlienBullet(ax, ay, dx / dist * speed, dy / dist * speed));
    }

    // ── Boss Status ──────────────────────────────────────────

    allBossesDead() {
        if (this.circularBoss) return !this.circularBoss.alive;
        return this.bosses.every(b => !b.alive);
    }

    getBossHp() {
        let cur = 0, mx = 0;
        for (const b of this.bosses) {
            mx += b.maxHp;
            if (b.alive) cur += Math.max(0, b.hp);
        }
        if (this.circularBoss) {
            cur += this.circularBoss.totalHp;
            mx += this.circularBoss.totalMaxHp;
        }
        return [cur, mx];
    }

    // ── Update ───────────────────────────────────────────────

    update() {
        if (this.state === 'title') {
            if (this.input.wasPressed('Space') || this.input.wasPressed('KeyZ') || this.input.wasPressed('Enter')) {
                this.state = 'playing';
                this.initGame();
            }
            return;
        }

        if (this.state === 'game_over' || this.state === 'victory') {
            if (this.input.wasPressed('Space') || this.input.wasPressed('KeyZ') || this.input.wasPressed('Enter')) {
                this.state = 'title';
            }
            return;
        }

        if (this.state !== 'playing') return;

        this.updateGameplay();
    }

    updateGameplay() {
        // Color cycling timer (visual only — handled in draw)
        if (LEVELS[this.currentLevel].cycle && this.background) {
            this.cycleTimer++;
            if (this.cycleTimer >= 6) {
                this.cycleTimer = 0;
            }
        }

        // Level announcement
        if (this.announceTimer > 0) this.announceTimer--;

        // Player
        this.player.update(this.input);

        // Firing
        if ((this.input.isDown('Space') || this.input.isDown('KeyZ')) && this.player.alive) {
            if (this.bullets.length < this.player.maxBullets && this.tick % 6 === 0) {
                if (this.scrollDir === 'horizontal') {
                    const bx = this.player.x + 28, by = this.player.y + 8;
                    this.bullets.push(new Bullet(bx, by, BULLET_SPEED, 0));
                    if (this.player.hasSides) {
                        this.bullets.push(new Bullet(bx, by - 8, BULLET_SPEED, -2));
                        this.bullets.push(new Bullet(bx, by + 8, BULLET_SPEED, 2));
                    }
                } else {
                    const bx = this.player.x + 8, by = this.player.y - 4;
                    this.bullets.push(new Bullet(bx, by, 0, -BULLET_SPEED));
                    if (this.player.hasSides) {
                        this.bullets.push(new Bullet(bx - 8, by, -2, -BULLET_SPEED));
                        this.bullets.push(new Bullet(bx + 8, by, 2, -BULLET_SPEED));
                    }
                }
                this.audio.playSfx('laser');
            }
        }

        // Scrolling
        if (!this.scrollPaused) {
            this.scrollTimer++;
            if (this.scrollTimer >= SCROLL_TICKS) {
                this.scrollTimer = 0;
                let scrollDone = false;
                if (this.scrollDir === 'horizontal') {
                    this.scrollX += SCROLL_SPEED;
                    if (this.scrollX >= this.maxScroll) {
                        this.scrollX = this.maxScroll;
                        scrollDone = true;
                    }
                } else {
                    this.scrollY -= SCROLL_SPEED;
                    if (this.scrollY <= 0) {
                        this.scrollY = 0;
                        scrollDone = true;
                    }
                }
                if (scrollDone && !this.bossActive && !this.levelComplete) {
                    if (!this.bossDefeated) {
                        this.spawnBoss();
                    } else {
                        this.levelComplete = true;
                        this.levelCompleteTimer = 180;
                    }
                }
            }
        }

        // Bullets
        for (const b of this.bullets) b.update();
        this.bullets = this.bullets.filter(b => b.alive);
        for (const b of this.alienBullets) b.update();
        this.alienBullets = this.alienBullets.filter(b => b.alive);

        // Waves
        this.waveTimer--;
        if (this.waveTimer <= 0) {
            this.spawnWave();
            this.waveTimer = WAVE_SPAWN_INTERVAL;
        }
        for (const wave of this.waves) {
            for (const alien of wave.aliens) {
                alien.update();
                if (alien.alive && alien.visible && randInt(0, 999) < ALIEN_FIRE_CHANCE) {
                    this.fireAlienBullet(alien.x, alien.y);
                }
            }
        }
        this.waves = this.waves.filter(w => !w.allDead());

        // Bosses
        for (const boss of this.bosses) {
            boss.update();
            if (boss.alive && randInt(0, 999) < BOSS_FIRE_CHANCE) {
                const cx = boss.x + (boss.frames.length > 0 ? Math.floor(boss.frames[0].width / 2) : 16);
                const cy = boss.y + (boss.frames.length > 0 ? Math.floor(boss.frames[0].height / 2) : 16);
                this.fireAlienBullet(cx, cy);
            }
        }

        if (this.circularBoss && this.circularBoss.alive) {
            this.circularBoss.update();
            for (let i = 0; i < this.circularBoss.segments.length; i++) {
                const seg = this.circularBoss.segments[i];
                if (seg.alive && randInt(0, 999) < BOSS_FIRE_CHANCE) {
                    const [x, y] = this.circularBoss.getSegmentPos(i);
                    this.fireAlienBullet(x + 16, y + 16);
                }
            }
        }

        // Boss fight over?
        if (this.bossActive && this.allBossesDead()) {
            this.bossActive = false;
            this.bossDefeated = true;
            this.scrollPaused = false;
            const atEnd = (this.scrollDir === 'horizontal' && this.scrollX >= this.maxScroll) ||
                          (this.scrollDir === 'vertical' && this.scrollY <= 0);
            if (atEnd) {
                this.levelComplete = true;
                this.levelCompleteTimer = 180;
            }
        }

        // Background enemies
        for (const be of this.bgEnemies) {
            be.update(this.scrollX, this.scrollY, this.scrollDir);
            if (be.shouldFire() && randInt(0, 999) < 150) {
                const [bsx, bsy] = be.screenPos(this.scrollX, this.scrollY, this.scrollDir);
                if (be.enemyType === 'lava_eye') {
                    for (const [ddx, ddy] of [[0, -2], [2, -2], [2, 0], [2, 2],
                                               [0, 2], [-2, -2], [-2, 0], [-2, 2]]) {
                        this.alienBullets.push(new AlienBullet(bsx + 8, bsy + 8, ddx, ddy));
                    }
                } else {
                    this.fireAlienBullet(bsx + 8, bsy + 8);
                }
            }
        }

        // Explosions
        for (const e of this.explosions) e.update();
        this.explosions = this.explosions.filter(e => e.alive);

        // Tokens
        for (const t of this.tokens) t.update(this.scrollDir);
        this.tokens = this.tokens.filter(t => t.alive);

        this.tokenTimer--;
        if (this.tokenTimer <= 0) {
            this.tokenTimer = TOKEN_SPAWN_INTERVAL;
            if (this.scrollDir === 'horizontal') {
                this.spawnToken(INTERNAL_W + 10, randInt(20, VIEW_H - 30));
            } else {
                this.spawnToken(randInt(20, INTERNAL_W - 30), -10);
            }
        }

        // Collisions
        this.checkCollisions();

        // Level complete
        if (this.levelComplete) {
            this.levelCompleteTimer--;
            if (this.levelCompleteTimer <= 0) {
                this.advanceLevel();
            }
        }

        // Game over
        if (this.player.lives <= 0 && !this.player.alive) {
            this.state = 'game_over';
        }
    }

    advanceLevel() {
        if (this.currentLevel >= LEVELS.length - 1) {
            this.state = 'victory';
        } else {
            this.loadLevel(this.currentLevel + 1);
        }
    }

    checkCollisions() {
        if (!this.player.alive) return;
        const playerRect = this.player.getRect();
        const sx = this.scrollX, sy = this.scrollY;

        // Player bullets vs enemies
        for (const bullet of this.bullets) {
            if (!bullet.alive) continue;
            const brect = bullet.getRect();

            // vs aliens
            for (const wave of this.waves) {
                for (const alien of wave.aliens) {
                    if (!alien.alive || !alien.visible) continue;
                    if (rectsCollide(brect, alien.getRect())) {
                        alien.hp -= this.player.power;
                        bullet.alive = false;
                        if (alien.hp <= 0) {
                            alien.alive = false;
                            this.spawnExplosion(alien.x, alien.y);
                            if (wave.firstKill) {
                                wave.firstKill = false;
                                this.player.addScore(ALIEN_SCORE_FIRST);
                                this.spawnToken(alien.x, alien.y);
                            } else {
                                this.player.addScore(ALIEN_SCORE_OTHER);
                            }
                        }
                        break;
                    }
                }
                if (!bullet.alive) break;
            }

            // vs bosses
            if (bullet.alive) {
                for (const boss of this.bosses) {
                    if (boss.alive && rectsCollide(brect, boss.getRect())) {
                        bullet.alive = false;
                        if (boss.hit(this.player.power)) {
                            this.player.addScore(BOSS_SCORE);
                            this.spawnExplosion(boss.x, boss.y);
                            this.spawnExplosion(boss.x + 20, boss.y + 10);
                        }
                        break;
                    }
                }
            }

            // vs circular boss segments
            if (bullet.alive && this.circularBoss && this.circularBoss.alive) {
                for (let i = 0; i < this.circularBoss.segments.length; i++) {
                    const seg = this.circularBoss.segments[i];
                    if (seg.alive && rectsCollide(brect, this.circularBoss.getSegmentRect(i))) {
                        bullet.alive = false;
                        if (this.circularBoss.hitSegment(i, this.player.power)) {
                            const [x, y] = this.circularBoss.getSegmentPos(i);
                            this.spawnExplosion(x, y);
                            this.player.addScore(BOSS_SCORE);
                        }
                        break;
                    }
                }
            }

            // vs background enemies
            if (bullet.alive) {
                for (const be of this.bgEnemies) {
                    if (be.alive && be.visible && rectsCollide(brect, be.getRect(sx, sy, this.scrollDir))) {
                        bullet.alive = false;
                        if (be.hit(this.player.power)) {
                            const [bsx, bsy] = be.screenPos(sx, sy, this.scrollDir);
                            this.spawnExplosion(bsx, bsy);
                            this.player.addScore(BUG_SCORE);
                        }
                        break;
                    }
                }
            }
        }

        // Alien bullets vs player
        for (const bullet of this.alienBullets) {
            if (bullet.alive && rectsCollide(bullet.getRect(), playerRect)) {
                bullet.alive = false;
                if (this.player.die()) {
                    this.spawnExplosion(this.player.x + 16, this.player.y + 16);
                }
            }
        }

        // Aliens vs player
        for (const wave of this.waves) {
            for (const alien of wave.aliens) {
                if (alien.alive && alien.visible && rectsCollide(alien.getRect(), playerRect)) {
                    if (this.player.die()) {
                        this.spawnExplosion(this.player.x + 16, this.player.y + 16);
                    }
                }
            }
        }

        // Bosses vs player
        for (const boss of this.bosses) {
            if (boss.alive && rectsCollide(boss.getRect(), playerRect)) {
                if (this.player.die()) {
                    this.spawnExplosion(this.player.x + 16, this.player.y + 16);
                }
            }
        }

        if (this.circularBoss && this.circularBoss.alive) {
            for (let i = 0; i < this.circularBoss.segments.length; i++) {
                const seg = this.circularBoss.segments[i];
                if (seg.alive && rectsCollide(this.circularBoss.getSegmentRect(i), playerRect)) {
                    if (this.player.die()) {
                        this.spawnExplosion(this.player.x + 16, this.player.y + 16);
                    }
                }
            }
        }

        // Tokens vs player
        for (const token of this.tokens) {
            if (token.alive && rectsCollide(token.getRect(), playerRect)) {
                token.alive = false;
                this.applyToken(token.tokenType);
                this.audio.playSfx('token');
                this.player.addScore(50);
            }
        }
    }

    applyToken(tokenType) {
        const p = this.player;
        switch (tokenType) {
            case 'FASTER': p.speedLevel = Math.min(2, p.speedLevel + 1); break;
            case 'LASER':  p.maxBullets = 6; p.weapon = 'LASER'; p.hasSides = p.hasHomers = false; break;
            case 'DOUBLE': p.power = Math.min(20, p.power + 1); break;
            case 'PLASMA': p.maxBullets = 6; p.weapon = 'PLASMA'; break;
            case 'SIDES':  p.hasSides = true; p.maxBullets = 6; p.weapon = 'SIDES'; break;
            case 'HOMERS': p.hasHomers = true; p.maxBullets = 6; p.weapon = 'HOMERS'; break;
        }
    }

    // ── Drawing ──────────────────────────────────────────────

    draw() {
        switch (this.state) {
            case 'title':     this.drawTitle(); break;
            case 'playing':   this.drawGameplay(); break;
            case 'game_over': this.drawGameOver(); break;
            case 'victory':   this.drawVictory(); break;
        }
    }

    drawGameplay() {
        const ctx = this.ictx;
        ctx.fillStyle = BLACK;
        ctx.fillRect(0, 0, INTERNAL_W, INTERNAL_H);

        // Background
        if (this.background) {
            if (this.scrollDir === 'horizontal') {
                ctx.drawImage(this.background,
                    Math.floor(this.scrollX), 0, INTERNAL_W, VIEW_H,
                    0, 0, INTERNAL_W, VIEW_H);
            } else {
                ctx.drawImage(this.background,
                    0, Math.floor(this.scrollY), INTERNAL_W, VIEW_H,
                    0, 0, INTERNAL_W, VIEW_H);
            }
        }

        // Background enemies
        for (const be of this.bgEnemies) {
            be.draw(ctx, this.scrollX, this.scrollY, this.scrollDir);
        }

        // Aliens
        for (const wave of this.waves) {
            for (const alien of wave.aliens) {
                alien.draw(ctx);
            }
        }

        // Bosses
        for (const boss of this.bosses) boss.draw(ctx);
        if (this.circularBoss) this.circularBoss.draw(ctx);

        // Tokens
        for (const token of this.tokens) token.draw(ctx);

        // Player
        this.player.draw(ctx);

        // Bullets
        for (const b of this.bullets) b.draw(ctx);
        for (const b of this.alienBullets) b.draw(ctx, this.assets.alienBulletFrames);

        // Explosions
        for (const e of this.explosions) e.draw(ctx);

        // Panel
        this.drawPanel(ctx);

        // Level announcement overlay
        if (this.announceTimer > 0) {
            const lvl = LEVELS[this.currentLevel];
            const text = `LEVEL ${this.currentLevel + 1}: ${lvl.name.toUpperCase()}`;
            ctx.font = '14px monospace';
            ctx.fillStyle = YELLOW;
            const tw = ctx.measureText(text).width;
            ctx.fillText(text, (INTERNAL_W - tw) / 2, VIEW_H / 2 - 10 + 14);
        }

        // Level complete overlay
        if (this.levelComplete) {
            const text = `LEVEL ${this.currentLevel + 1} COMPLETE!`;
            ctx.font = '14px monospace';
            ctx.fillStyle = YELLOW;
            const tw = ctx.measureText(text).width;
            ctx.fillText(text, (INTERNAL_W - tw) / 2, VIEW_H / 2 - 10 + 14);
        }

        // Scale to display
        this.ctx.imageSmoothingEnabled = false;
        this.ctx.drawImage(this.internal, 0, 0, SCREEN_W, SCREEN_H);
    }

    drawPanel(ctx) {
        const py = VIEW_H;
        ctx.fillStyle = PANEL_BG;
        ctx.fillRect(0, py, INTERNAL_W, PANEL_H);

        ctx.font = '10px monospace';

        // Level
        ctx.fillStyle = GREEN;
        ctx.fillText(`LVL:${this.currentLevel + 1}`, 4, py + 10);

        // Weapon
        ctx.fillStyle = CYAN;
        ctx.fillText(this.player.weapon, 42, py + 10);

        // Score
        ctx.fillStyle = WHITE;
        ctx.fillText(`SCORE:${String(this.player.score).padStart(6, '0')}`, 110, py + 10);

        // Lives
        ctx.fillStyle = WHITE;
        ctx.fillText(`LEFT:${this.player.lives}`, 250, py + 10);

        // Power
        ctx.fillStyle = YELLOW;
        ctx.fillText(`PWR:${this.player.power}`, 4, py + 21);

        // Boss HP bar
        const [curHp, maxHp] = this.getBossHp();
        if (maxHp > 0 && this.bossActive) {
            ctx.fillStyle = RED;
            ctx.fillText('BOSS:', 120, py + 21);
            const barW = Math.floor(100 * curHp / maxHp);
            ctx.fillStyle = RED;
            ctx.fillRect(160, py + 14, barW, 6);
            ctx.strokeStyle = WHITE;
            ctx.lineWidth = 1;
            ctx.strokeRect(160, py + 14, 100, 6);
        }
    }

    drawTitle() {
        const ctx = this.ictx;
        ctx.fillStyle = BLACK;
        ctx.fillRect(0, 0, INTERNAL_W, INTERNAL_H);

        if (this.assets.titleScreens.length > 0) {
            if (this.tick % 6 === 0) {
                this.titleCycleIdx = (this.titleCycleIdx + 1) % this.assets.titleScreens.length;
            }
            const title = this.assets.titleScreens[this.titleCycleIdx];
            ctx.drawImage(title, 0, 0, INTERNAL_W, INTERNAL_H,
                         0, 0, INTERNAL_W, INTERNAL_H);
        } else {
            ctx.font = '14px monospace';
            ctx.fillStyle = WHITE;
            ctx.fillText('PHANTOM FIGHTER', 80, 60);
        }

        if (Math.floor(this.tick / 30) % 2) {
            ctx.font = '10px monospace';
            ctx.fillStyle = YELLOW;
            const text = 'PRESS SPACE OR FIRE TO START';
            const tw = ctx.measureText(text).width;
            ctx.fillText(text, (INTERNAL_W - tw) / 2, INTERNAL_H - 20);
        }

        this.ctx.imageSmoothingEnabled = false;
        this.ctx.drawImage(this.internal, 0, 0, SCREEN_W, SCREEN_H);
    }

    drawGameOver() {
        const ctx = this.ictx;
        ctx.fillStyle = BLACK;
        ctx.fillRect(0, 0, INTERNAL_W, INTERNAL_H);

        ctx.font = '14px monospace';
        ctx.fillStyle = RED;
        let text = 'GAME OVER';
        let tw = ctx.measureText(text).width;
        ctx.fillText(text, (INTERNAL_W - tw) / 2, 60);

        ctx.fillStyle = CYAN;
        text = `REACHED LEVEL ${this.currentLevel + 1}: ${LEVELS[this.currentLevel].name.toUpperCase()}`;
        tw = ctx.measureText(text).width;
        ctx.fillText(text, (INTERNAL_W - tw) / 2, 90);

        ctx.fillStyle = WHITE;
        text = `FINAL SCORE: ${String(this.player.score).padStart(6, '0')}`;
        tw = ctx.measureText(text).width;
        ctx.fillText(text, (INTERNAL_W - tw) / 2, 120);

        if (Math.floor(this.tick / 30) % 2) {
            ctx.font = '10px monospace';
            ctx.fillStyle = YELLOW;
            text = 'PRESS SPACE TO PLAY AGAIN';
            tw = ctx.measureText(text).width;
            ctx.fillText(text, (INTERNAL_W - tw) / 2, 160);
        }

        this.ctx.imageSmoothingEnabled = false;
        this.ctx.drawImage(this.internal, 0, 0, SCREEN_W, SCREEN_H);
    }

    drawVictory() {
        const ctx = this.ictx;
        ctx.fillStyle = BLACK;
        ctx.fillRect(0, 0, INTERNAL_W, INTERNAL_H);

        ctx.font = '14px monospace';
        ctx.fillStyle = YELLOW;
        let text = 'CONGRATULATIONS!';
        let tw = ctx.measureText(text).width;
        ctx.fillText(text, (INTERNAL_W - tw) / 2, 50);

        ctx.fillStyle = GREEN;
        text = 'ALL 5 LEVELS CLEARED!';
        tw = ctx.measureText(text).width;
        ctx.fillText(text, (INTERNAL_W - tw) / 2, 80);

        ctx.fillStyle = WHITE;
        text = `FINAL SCORE: ${String(this.player.score).padStart(6, '0')}`;
        tw = ctx.measureText(text).width;
        ctx.fillText(text, (INTERNAL_W - tw) / 2, 120);

        if (Math.floor(this.tick / 30) % 2) {
            ctx.font = '10px monospace';
            ctx.fillStyle = YELLOW;
            text = 'PRESS SPACE TO PLAY AGAIN';
            tw = ctx.measureText(text).width;
            ctx.fillText(text, (INTERNAL_W - tw) / 2, 160);
        }

        this.ctx.imageSmoothingEnabled = false;
        this.ctx.drawImage(this.internal, 0, 0, SCREEN_W, SCREEN_H);
    }
}
