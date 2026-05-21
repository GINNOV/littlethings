import { VIEW_H } from './constants.js';

export class Explosion {
    constructor(x, y, frames) {
        this.x = x;
        this.y = y;
        this.frames = frames;
        this.frameIdx = 0;
        this.timer = 0;
        this.alive = true;
    }

    update() {
        this.timer++;
        if (this.timer >= 4) {
            this.timer = 0;
            this.frameIdx++;
            if (this.frameIdx >= this.frames.length) {
                this.alive = false;
            }
        }
    }

    draw(ctx) {
        if (this.alive && this.frameIdx < this.frames.length) {
            const img = this.frames[this.frameIdx];
            ctx.drawImage(img,
                Math.floor(this.x) - Math.floor(img.width / 2),
                Math.floor(this.y) - Math.floor(img.height / 2));
        }
    }
}

export class Token {
    constructor(x, y, tokenType, frames) {
        this.x = x;
        this.y = y;
        this.tokenType = tokenType;
        this.frames = frames;
        this.alive = true;
        this.frameIdx = 0;
        this.animTimer = 0;
    }

    update(scrollDir = 'horizontal') {
        if (scrollDir === 'horizontal') {
            this.x -= 1;
        } else {
            this.y += 1;
        }
        this.animTimer++;
        if (this.animTimer >= 10) {
            this.animTimer = 0;
            this.frameIdx = (this.frameIdx + 1) % Math.max(1, this.frames.length);
        }
        if (this.x < -32 || this.y > VIEW_H + 32) {
            this.alive = false;
        }
    }

    getRect() {
        return { x: Math.floor(this.x), y: Math.floor(this.y), w: 20, h: 15 };
    }

    draw(ctx) {
        if (this.alive && this.frames.length > 0) {
            ctx.drawImage(this.frames[this.frameIdx % this.frames.length],
                Math.floor(this.x), Math.floor(this.y));
        }
    }
}
