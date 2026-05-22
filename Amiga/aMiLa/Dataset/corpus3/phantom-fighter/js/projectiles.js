import { INTERNAL_W, VIEW_H, YELLOW } from './constants.js';

export class Bullet {
    static sprites = null;

    constructor(x, y, dx, dy) {
        this.x = x;
        this.y = y;
        this.dx = dx;
        this.dy = dy;
        this.alive = true;
        this.power = 1;
    }

    update() {
        this.x += this.dx;
        this.y += this.dy;
        if (this.x < -10 || this.x > INTERNAL_W + 10 || this.y < -10 || this.y > VIEW_H + 10) {
            this.alive = false;
        }
    }

    _direction() {
        if (Math.abs(this.dx) > Math.abs(this.dy)) {
            return this.dx > 0 ? 'right' : 'left';
        }
        return this.dy > 0 ? 'down' : 'up';
    }

    getRect() {
        if (Bullet.sprites) {
            const img = Bullet.sprites[`0_${this._direction()}`];
            if (img) {
                return {
                    x: Math.floor(this.x) - Math.floor(img.width / 2),
                    y: Math.floor(this.y) - Math.floor(img.height / 2),
                    w: img.width,
                    h: img.height,
                };
            }
        }
        if (Math.abs(this.dx) > Math.abs(this.dy)) {
            return { x: Math.floor(this.x), y: Math.floor(this.y), w: 16, h: 4 };
        }
        return { x: Math.floor(this.x), y: Math.floor(this.y), w: 4, h: 16 };
    }

    draw(ctx) {
        if (Bullet.sprites) {
            const power = Math.min(this.power - 1, 1);
            const img = Bullet.sprites[`${power}_${this._direction()}`];
            if (img) {
                ctx.drawImage(img,
                    Math.floor(this.x) - Math.floor(img.width / 2),
                    Math.floor(this.y) - Math.floor(img.height / 2));
                return;
            }
        }
        const r = this.getRect();
        ctx.fillStyle = YELLOW;
        ctx.fillRect(r.x, r.y, r.w, r.h);
    }
}

export class AlienBullet {
    constructor(x, y, dx, dy) {
        this.x = x;
        this.y = y;
        this.dx = dx;
        this.dy = dy;
        this.alive = true;
    }

    update() {
        this.x += this.dx;
        this.y += this.dy;
        if (this.x < -20 || this.x > INTERNAL_W + 20 || this.y < -20 || this.y > VIEW_H + 20) {
            this.alive = false;
        }
    }

    getRect() {
        return { x: Math.floor(this.x), y: Math.floor(this.y), w: 5, h: 5 };
    }

    draw(ctx, alienBulletFrames) {
        if (alienBulletFrames && alienBulletFrames.length > 0) {
            ctx.drawImage(alienBulletFrames[0], Math.floor(this.x), Math.floor(this.y));
        } else {
            ctx.fillStyle = '#ff0000';
            ctx.fillRect(Math.floor(this.x), Math.floor(this.y), 5, 5);
        }
    }
}
