import { INTERNAL_W, VIEW_H } from './constants.js';

export class Alien {
    constructor(pattern, frames, wave) {
        this.pattern = pattern;
        this.frames = frames;
        this.wave = wave;
        this.x = 0;
        this.y = 0;
        this.frameIdx = 0;
        this.alive = true;
        this.hp = 1;
        this.stepIdx = 0;
        this.stepTimer = 0;
        this.visible = false;

        if (pattern && pattern.length > 0) {
            const [, frame, sx, sy] = pattern[0];
            this.x = sx;
            this.y = sy;
            this.frameIdx = this.frames.length > 0 ? frame % this.frames.length : 0;
            this.stepIdx = 1;
        }
    }

    update() {
        if (!this.alive || !this.pattern) return;
        if (this.stepIdx >= this.pattern.length) {
            this.alive = false;
            return;
        }

        const [delay, frame, dx, dy] = this.pattern[this.stepIdx];
        this.x += dx * 0.5;
        this.y += dy * 0.5;
        if (this.frames.length > 0) {
            this.frameIdx = frame % this.frames.length;
        }

        this.stepTimer++;
        if (this.stepTimer >= delay) {
            this.stepTimer = 0;
            this.stepIdx++;
        }

        this.visible = (this.x > -32 && this.x < INTERNAL_W + 32 &&
                         this.y > -32 && this.y < VIEW_H + 32);
        if (this.x < -100 || this.x > INTERNAL_W + 100 ||
            this.y < -100 || this.y > VIEW_H + 100) {
            this.alive = false;
        }
    }

    _drawPos() {
        const w = this.frames.length > 0 ? this.frames[0].width : 16;
        const h = this.frames.length > 0 ? this.frames[0].height : 16;
        return [Math.floor(this.x) - Math.floor(w / 2),
                Math.floor(this.y) - Math.floor(h / 2)];
    }

    getRect() {
        const w = this.frames.length > 0 ? this.frames[0].width : 16;
        const h = this.frames.length > 0 ? this.frames[0].height : 16;
        const [dx, dy] = this._drawPos();
        return { x: dx, y: dy, w, h };
    }

    draw(ctx) {
        if (this.alive && this.visible && this.frames.length > 0) {
            const [dx, dy] = this._drawPos();
            ctx.drawImage(this.frames[this.frameIdx % this.frames.length], dx, dy);
        }
    }
}

export class Wave {
    constructor() {
        this.aliens = [];
        this.firstKill = true;
    }

    allDead() {
        return this.aliens.every(a => !a.alive);
    }
}

export class Boss {
    constructor(frames, pattern, hp = 30, loopReset = false) {
        this.frames = frames;
        this.pattern = pattern;
        this.hp = hp;
        this.maxHp = hp;
        this.loopReset = loopReset;
        this.alive = true;
        this.animFrame = 0;
        this.animTimer = 0;
        this.patternStep = 1;
        this.stepTimer = 0;
        this.flashTimer = 0;
        const [, , sx, sy] = pattern[0];
        this.x = sx;
        this.y = sy;
    }

    update() {
        if (!this.alive) return;
        if (this.flashTimer > 0) this.flashTimer--;

        this.animTimer++;
        if (this.animTimer >= 6) {
            this.animTimer = 0;
            this.animFrame = (this.animFrame + 1) % Math.max(1, this.frames.length);
        }

        if (this.patternStep >= this.pattern.length) {
            if (this.loopReset) {
                const [, , sx, sy] = this.pattern[0];
                this.x = sx;
                this.y = sy;
            }
            this.patternStep = 1;
        }

        if (this.patternStep < this.pattern.length) {
            const [delay, , dx, dy] = this.pattern[this.patternStep];
            this.x += dx;
            this.y += dy;
            this.stepTimer++;
            if (this.stepTimer >= Math.max(1, delay)) {
                this.stepTimer = 0;
                this.patternStep++;
            }
        }
    }

    _drawPos() {
        const w = this.frames.length > 0 ? this.frames[0].width : 32;
        const h = this.frames.length > 0 ? this.frames[0].height : 32;
        return [Math.floor(this.x) - Math.floor(w / 2),
                Math.floor(this.y) - Math.floor(h / 2)];
    }

    getRect() {
        const w = this.frames.length > 0 ? this.frames[0].width : 32;
        const h = this.frames.length > 0 ? this.frames[0].height : 32;
        const [dx, dy] = this._drawPos();
        return { x: dx, y: dy, w, h };
    }

    hit(power) {
        this.hp -= power;
        this.flashTimer = 6;
        if (this.hp <= 0) {
            this.alive = false;
            return true;
        }
        return false;
    }

    draw(ctx) {
        if (!this.alive || this.frames.length === 0) return;
        const [dx, dy] = this._drawPos();
        const img = this.frames[this.animFrame % this.frames.length];
        if (this.flashTimer > 0 && (Math.floor(this.flashTimer / 2) % 2)) {
            // Flash: draw normally then additive overlay
            ctx.drawImage(img, dx, dy);
            ctx.save();
            ctx.globalCompositeOperation = 'lighter';
            ctx.drawImage(img, dx, dy);
            ctx.restore();
        } else {
            ctx.drawImage(img, dx, dy);
        }
    }
}

export class CircularBoss {
    constructor(frames, segmentHp = 15, numSegments = 2) {
        this.frames = frames;
        this.cx = 160;
        this.cy = 80;
        this.radius = 40;
        this.angle = 0;
        this.angularSpeed = 0.04;
        this.centerDx = 1.0;
        this.centerDy = 0.5;
        this.segments = [];
        for (let i = 0; i < numSegments; i++) {
            this.segments.push({
                hp: segmentHp, maxHp: segmentHp, alive: true,
                angleOffset: i * (2 * Math.PI / numSegments),
            });
        }
        this.alive = true;
        this.animFrame = 0;
        this.animTimer = 0;
    }

    update() {
        this.cx += this.centerDx;
        this.cy += this.centerDy;
        if (this.cx < 40 || this.cx > 280) this.centerDx = -this.centerDx;
        if (this.cy < 30 || this.cy > 140) this.centerDy = -this.centerDy;
        this.angle += this.angularSpeed;

        this.animTimer++;
        if (this.animTimer >= 6) {
            this.animTimer = 0;
            this.animFrame = (this.animFrame + 1) % Math.max(1, this.frames.length);
        }

        if (this.segments.every(s => !s.alive)) {
            this.alive = false;
        }
    }

    getSegmentPos(idx) {
        const off = this.segments[idx].angleOffset;
        return [
            this.cx + this.radius * Math.cos(this.angle + off),
            this.cy + this.radius * Math.sin(this.angle + off),
        ];
    }

    getSegmentRect(idx) {
        const [x, y] = this.getSegmentPos(idx);
        const w = this.frames.length > 0 ? this.frames[0].width : 32;
        const h = this.frames.length > 0 ? this.frames[0].height : 32;
        return { x: Math.floor(x) - Math.floor(w / 2), y: Math.floor(y) - Math.floor(h / 2), w, h };
    }

    hitSegment(idx, power) {
        const seg = this.segments[idx];
        seg.hp -= power;
        if (seg.hp <= 0) {
            seg.alive = false;
            return true;
        }
        return false;
    }

    get totalHp() {
        return this.segments.filter(s => s.alive).reduce((sum, s) => sum + s.hp, 0);
    }

    get totalMaxHp() {
        return this.segments.reduce((sum, s) => sum + s.maxHp, 0);
    }

    draw(ctx) {
        if (!this.alive) return;
        const img = this.frames.length > 0 ? this.frames[this.animFrame % this.frames.length] : null;
        for (let i = 0; i < this.segments.length; i++) {
            if (!this.segments[i].alive || !img) continue;
            const [x, y] = this.getSegmentPos(i);
            ctx.drawImage(img,
                Math.floor(x) - Math.floor(img.width / 2),
                Math.floor(y) - Math.floor(img.height / 2));
        }
    }
}

export class BackgroundEnemy {
    constructor(worldX, worldY, frames, enemyType = 'eye', hp = 4) {
        this.worldX = worldX;
        this.worldY = worldY;
        this.frames = frames;
        this.enemyType = enemyType;
        this.hp = hp;
        this.alive = true;
        this.animFrame = 0;
        this.animTimer = 0;
        this.animDir = 1;
        this.visible = false;
        this.flashTimer = 0;
    }

    screenPos(scrollX, scrollY, scrollDir) {
        const ox = this.frames.length > 0 ? Math.floor(this.frames[0].width / 2) : 0;
        const oy = this.frames.length > 0 ? Math.floor(this.frames[0].height / 2) : 0;
        if (scrollDir === 'horizontal') {
            return [this.worldX - scrollX - ox, this.worldY - oy];
        }
        return [this.worldX - ox, this.worldY - scrollY - oy];
    }

    update(scrollX, scrollY, scrollDir) {
        if (!this.alive) return;
        const [sx, sy] = this.screenPos(scrollX, scrollY, scrollDir);
        this.visible = (sx > -32 && sx < INTERNAL_W + 32 && sy > -32 && sy < VIEW_H + 32);
        if (!this.visible) return;
        if (this.flashTimer > 0) this.flashTimer--;

        this.animTimer++;
        const delay = this.enemyType === 'hexgun' ? 3 : 4;
        if (this.animTimer >= delay) {
            this.animTimer = 0;
            this.animFrame += this.animDir;
            const mx = this.frames.length - 1;
            if (this.animFrame >= mx) {
                this.animFrame = mx;
                this.animDir = -1;
            } else if (this.animFrame <= 0) {
                this.animFrame = 0;
                this.animDir = 1;
            }
        }
    }

    shouldFire() {
        if (!this.alive || !this.visible) return false;
        if (this.enemyType === 'eye' || this.enemyType === 'iris') {
            return this.animFrame >= this.frames.length - 2 && this.animDir === -1;
        }
        if (this.enemyType === 'hexgun') {
            return this.animFrame === 7 && this.animDir === 1;
        }
        if (this.enemyType === 'lava_eye') {
            return this.animFrame >= this.frames.length - 2;
        }
        return false;
    }

    getRect(scrollX, scrollY, scrollDir) {
        const [sx, sy] = this.screenPos(scrollX, scrollY, scrollDir);
        const w = this.frames.length > 0 ? this.frames[0].width : 16;
        const h = this.frames.length > 0 ? this.frames[0].height : 16;
        return { x: Math.floor(sx), y: Math.floor(sy), w, h };
    }

    hit(power) {
        this.hp -= power;
        this.flashTimer = 6;
        if (this.hp <= 0) {
            this.alive = false;
            return true;
        }
        return false;
    }

    draw(ctx, scrollX, scrollY, scrollDir) {
        if (!this.alive || !this.visible || this.frames.length === 0) return;
        const [sx, sy] = this.screenPos(scrollX, scrollY, scrollDir);
        const img = this.frames[this.animFrame % this.frames.length];
        if (this.flashTimer > 0 && (Math.floor(this.flashTimer / 2) % 2)) {
            ctx.drawImage(img, Math.floor(sx), Math.floor(sy));
            ctx.save();
            ctx.globalCompositeOperation = 'lighter';
            ctx.drawImage(img, Math.floor(sx), Math.floor(sy));
            ctx.restore();
        } else {
            ctx.drawImage(img, Math.floor(sx), Math.floor(sy));
        }
    }
}
