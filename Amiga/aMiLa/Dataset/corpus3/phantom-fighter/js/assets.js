import { LEVELS, LEVEL_BG, BG_ENEMY_SPRITES } from './constants.js';

const ASSET_BASE = '../modern-bitmaps';

function loadImage(path) {
    return new Promise((resolve, reject) => {
        const img = new Image();
        img.onload = () => resolve(img);
        img.onerror = () => { console.warn('Failed to load:', path); resolve(null); };
        img.src = path;
    });
}

export async function loadFrames(subdir, name, count) {
    const base = `${ASSET_BASE}/${subdir}`;
    const frames = [];
    if (count === 1) {
        const img = await loadImage(`${base}/${name}.png`);
        if (img) frames.push(img);
    } else {
        const promises = [];
        for (let i = 0; i < count; i++) {
            promises.push(loadImage(`${base}/${name}_frame${i}.png`));
        }
        const results = await Promise.all(promises);
        for (const img of results) {
            if (img) frames.push(img);
        }
    }
    return frames;
}

export async function loadScreen(subdir, name) {
    return loadImage(`${ASSET_BASE}/${subdir}/${name}.png`);
}

// Decode Amiga hardware sprite (16px wide, 2 bitplanes)
function decodeHwSprite(words, palette) {
    const canvas = document.createElement('canvas');
    canvas.width = 16;
    canvas.height = 16;
    const ctx = canvas.getContext('2d');
    const imgData = ctx.createImageData(16, 16);
    for (let row = 0; row < 16; row++) {
        const p0 = words[2 + row * 2];
        const p1 = words[2 + row * 2 + 1];
        for (let x = 0; x < 16; x++) {
            const bit = 15 - x;
            const c = ((p0 >> bit) & 1) | (((p1 >> bit) & 1) << 1);
            if (c) {
                const [r, g, b] = palette[c - 1];
                const idx = (row * 16 + x) * 4;
                imgData.data[idx] = r;
                imgData.data[idx + 1] = g;
                imgData.data[idx + 2] = b;
                imgData.data[idx + 3] = 255;
            }
        }
    }
    ctx.putImageData(imgData, 0, 0);
    return canvas;
}

function cropToOpaque(canvas) {
    const ctx = canvas.getContext('2d');
    const imgData = ctx.getImageData(0, 0, canvas.width, canvas.height);
    let minX = canvas.width, minY = canvas.height, maxX = 0, maxY = 0;
    for (let y = 0; y < canvas.height; y++) {
        for (let x = 0; x < canvas.width; x++) {
            if (imgData.data[(y * canvas.width + x) * 4 + 3] > 0) {
                minX = Math.min(minX, x);
                minY = Math.min(minY, y);
                maxX = Math.max(maxX, x);
                maxY = Math.max(maxY, y);
            }
        }
    }
    if (maxX < minX) return canvas;
    const w = maxX - minX + 1;
    const h = maxY - minY + 1;
    const cropped = document.createElement('canvas');
    cropped.width = w;
    cropped.height = h;
    cropped.getContext('2d').drawImage(canvas, minX, minY, w, h, 0, 0, w, h);
    return cropped;
}

function rotateCanvas(src, degrees) {
    const rad = degrees * Math.PI / 180;
    // For 90-degree rotations, swap dimensions
    const absDeg = Math.abs(degrees % 360);
    let w, h;
    if (absDeg === 90 || absDeg === 270) {
        w = src.height;
        h = src.width;
    } else {
        w = src.width;
        h = src.height;
    }
    const canvas = document.createElement('canvas');
    canvas.width = w;
    canvas.height = h;
    const ctx = canvas.getContext('2d');
    ctx.translate(w / 2, h / 2);
    ctx.rotate(rad);
    ctx.drawImage(src, -src.width / 2, -src.height / 2);
    return cropToOpaque(canvas);
}

export function makeBulletSprites() {
    const pal = [[255, 0, 0], [255, 204, 0], [255, 255, 255]];

    const up0 = [
        0x0000, 0x0000,
        0xe000, 0x0000, 0x1000, 0xe000, 0xf000, 0xe000,
        0x5000, 0xe000, 0xa000, 0x4000, 0xa000, 0x4000,
        0xa000, 0x4000, 0x4000, 0x0000, 0x0000, 0x4000,
        0x4000, 0x0000, 0x4000, 0x0000, 0x0000, 0x0000,
        0x4000, 0x0000, 0x0000, 0x0000, 0x4000, 0x0000,
        0x0000, 0x0000,
        0x0000, 0x0000,
    ];

    const up1 = [
        0x0000, 0x0000,
        0x4000, 0x0000, 0xa000, 0x4000, 0x5000, 0xe000,
        0xf000, 0xe000, 0x5000, 0xe000, 0x5000, 0xe000,
        0x1000, 0xe000, 0x5000, 0xe000, 0x1000, 0xe000,
        0xe000, 0x4000, 0xa000, 0x4000, 0x0000, 0x4000,
        0x4000, 0x0000, 0x0000, 0x4000, 0x4000, 0x0000,
        0x0000, 0x0000,
        0x0000, 0x0000,
    ];

    const roundData = [
        0x0000, 0x0000,
        0x7800, 0x0000, 0xfc00, 0x7800, 0xcc00, 0x7800,
        0xcc00, 0x7800, 0xfc00, 0x7800, 0x7800, 0x0000,
        0x0000, 0x0000,
    ];

    const sprites = {};
    [up0, up1].forEach((data, power) => {
        const upSurf = cropToOpaque(decodeHwSprite(data, pal));
        sprites[`${power}_up`] = upSurf;
        sprites[`${power}_right`] = rotateCanvas(upSurf, 90);
        sprites[`${power}_down`] = rotateCanvas(upSurf, 180);
        sprites[`${power}_left`] = rotateCanvas(upSurf, -90);
    });

    // Round bullet (pad to 36 words)
    const padded = [...roundData];
    while (padded.length < 36) padded.push(0x0000);
    sprites['round'] = cropToOpaque(decodeHwSprite(padded, pal));

    return sprites;
}

// Pre-rotate player frames for horizontal orientation
// pygame.transform.rotate(-90) = clockwise 90°; Canvas rotate(+π/2) = clockwise 90°
export function rotateFrames(frames) {
    return frames.map(img => {
        const canvas = document.createElement('canvas');
        canvas.width = img.height;
        canvas.height = img.width;
        const ctx = canvas.getContext('2d');
        ctx.translate(canvas.width / 2, canvas.height / 2);
        ctx.rotate(Math.PI / 2);
        ctx.drawImage(img, -img.width / 2, -img.height / 2);
        return canvas;
    });
}

// Load all game assets
export async function loadAllAssets(onProgress) {
    const assets = {};
    let loaded = 0;
    const total = 20; // approximate
    const tick = () => { loaded++; if (onProgress) onProgress(loaded / total); };

    // Player ship frames
    const rawPlayer = await loadFrames('Level-All', 'just_me', 11);
    assets.playerFramesVert = rawPlayer;
    assets.playerFramesHoriz = rotateFrames(rawPlayer);
    tick();

    // Alien ship types
    assets.alienShipFrames = [];
    const counts = [12, 8, 8, 8, 8, 8, 12];
    for (let i = 1; i <= 7; i++) {
        const name = i < 7 ? `ships${i}` : 'Ships7';
        const frames = await loadFrames('Level-All', name, counts[i - 1]);
        if (frames.length > 0) assets.alienShipFrames.push(frames);
        tick();
    }

    // Effects
    assets.explosionFrames = await loadFrames('Level-All', 'bang', 8);
    tick();
    assets.tokenFrames = await loadFrames('Level-All', 'token', 6);
    tick();
    assets.alienBulletFrames = await loadFrames('Level-All', 'AlienBullet', 3);
    tick();

    // Bullet sprites
    assets.bulletSprites = makeBulletSprites();
    tick();

    // Backgrounds
    assets.backgrounds = {};
    for (let i = 0; i < LEVEL_BG.length; i++) {
        const [d, n] = LEVEL_BG[i];
        assets.backgrounds[i] = await loadScreen(d, n);
        tick();
    }

    // Title screen (3 cycling variants)
    assets.titleScreens = [];
    for (let i = 0; i < 3; i++) {
        const img = await loadScreen('Screens', `Title-Screen-cycle${i}`);
        if (img) assets.titleScreens.push(img);
    }
    if (assets.titleScreens.length === 0) {
        const fallback = await loadScreen('Screens', 'Title-Screen');
        if (fallback) assets.titleScreens.push(fallback);
    }
    tick();

    // Panel
    assets.panelImg = await loadScreen('Level-All', 'panel');
    tick();

    // Preload all boss sprites and background enemy sprites
    assets.bossSprites = {};
    assets.bgEnemySprites = {};
    for (let i = 0; i < LEVELS.length; i++) {
        const [d, n, c] = LEVELS[i].boss_sprites;
        assets.bossSprites[i] = await loadFrames(d, n, c);
        tick();
        // BG enemy sprites for this level
        const bgTypes = BG_ENEMY_SPRITES[i];
        if (bgTypes) {
            for (const [type, info] of Object.entries(bgTypes)) {
                const [sd, sn, sc] = info;
                assets.bgEnemySprites[`${i}_${type}`] = await loadFrames(sd, sn, sc);
            }
        }
    }
    tick();

    return assets;
}

export function getBossSprites(assets, levelIdx) {
    return assets.bossSprites[levelIdx] || [];
}

export function getBgEnemySprites(assets, levelIdx, enemyType) {
    return assets.bgEnemySprites[`${levelIdx}_${enemyType}`] || [];
}
