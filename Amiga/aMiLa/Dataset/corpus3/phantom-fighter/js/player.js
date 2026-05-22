import {
    PLAYER_START_X, PLAYER_START_Y_H, PLAYER_START_Y_V,
    PLAYER_CENTER_FRAME, PLAYER_MAX_FRAMES, PLAYER_BANK_DELAY,
    STARTING_LIVES, MAX_LIVES, EXTRA_LIFE_FIRST, EXTRA_LIFE_INTERVAL,
    INTERNAL_W, VIEW_H,
} from './constants.js';

export class Player {
    constructor(framesHoriz, framesVert) {
        this.framesHoriz = framesHoriz;
        this.framesVert = framesVert;
        this.frames = framesHoriz;
        this.scrollDir = 'horizontal';
        this.x = PLAYER_START_X;
        this.y = PLAYER_START_Y_H;
        this.frame = PLAYER_CENTER_FRAME;
        this.bankTimer = 0;
        this.targetFrame = PLAYER_CENTER_FRAME;
        this.lives = STARTING_LIVES;
        this.score = 0;
        this.nextExtraLife = EXTRA_LIFE_FIRST;
        this.power = 1;
        this.maxBullets = 4;
        this.weapon = 'LASER';
        this.speedLevel = 1;
        this.speeds = [[2, 1], [3, 2], [4, 3]];
        this.invincibleTimer = 0;
        this.alive = true;
        this.respawnTimer = 0;
        this.hasHomers = false;
        this.hasSides = false;
    }

    setScrollDir(scrollDir) {
        this.scrollDir = scrollDir;
        if (scrollDir === 'horizontal') {
            this.frames = this.framesHoriz;
            this.y = PLAYER_START_Y_H;
        } else {
            this.frames = this.framesVert;
            this.y = PLAYER_START_Y_V;
        }
        this.x = PLAYER_START_X;
        this.frame = PLAYER_CENTER_FRAME;
    }

    get horizSpeed() { return this.speeds[this.speedLevel][0]; }
    get vertSpeed() { return this.speeds[this.speedLevel][1]; }

    update(input) {
        if (!this.alive) {
            if (this.lives <= 0) return;
            this.respawnTimer--;
            if (this.respawnTimer <= 0) {
                this.alive = true;
                this.x = PLAYER_START_X;
                this.y = this.scrollDir === 'horizontal' ? PLAYER_START_Y_H : PLAYER_START_Y_V;
                this.frame = PLAYER_CENTER_FRAME;
                this.invincibleTimer = 120;
            }
            return;
        }

        if (this.invincibleTimer > 0) this.invincibleTimer--;

        let dx = 0, dy = 0;
        if (input.isDown('ArrowLeft'))  dx = -this.horizSpeed;
        if (input.isDown('ArrowRight')) dx = this.horizSpeed;
        if (input.isDown('ArrowUp'))    dy = -this.vertSpeed;
        if (input.isDown('ArrowDown'))  dy = this.vertSpeed;

        this.x += dx;
        this.y += dy;
        this.x = Math.max(3, Math.min(295, this.x));
        this.y = Math.max(0, Math.min(VIEW_H - 24, this.y));

        // Banking
        const bankInput = this.scrollDir === 'horizontal' ? dy : dx;
        if (bankInput < 0) this.targetFrame = 0;
        else if (bankInput > 0) this.targetFrame = 6;
        else this.targetFrame = PLAYER_CENTER_FRAME;

        this.bankTimer++;
        if (this.bankTimer >= PLAYER_BANK_DELAY) {
            this.bankTimer = 0;
            if (this.frame < this.targetFrame) {
                this.frame = Math.min(this.frame + 1, PLAYER_MAX_FRAMES - 1);
            } else if (this.frame > this.targetFrame) {
                this.frame = Math.max(this.frame - 1, 0);
            }
        }
    }

    addScore(points) {
        this.score += points;
        if (this.score >= this.nextExtraLife) {
            if (this.lives < MAX_LIVES) this.lives++;
            this.nextExtraLife += EXTRA_LIFE_INTERVAL;
        }
    }

    die() {
        if (this.invincibleTimer > 0 || !this.alive) return false;
        this.alive = false;
        this.lives--;
        this.respawnTimer = 90;
        this.power = 1;
        this.maxBullets = 4;
        this.weapon = 'LASER';
        this.speedLevel = 1;
        this.hasHomers = false;
        this.hasSides = false;
        return true;
    }

    getRect() {
        return { x: Math.floor(this.x) + 4, y: Math.floor(this.y) + 4, w: 23, h: 23 };
    }

    draw(ctx) {
        if (!this.alive) return;
        if (this.invincibleTimer > 0 && (Math.floor(this.invincibleTimer / 4) % 2)) return;
        if (this.frame < this.frames.length) {
            ctx.drawImage(this.frames[this.frame], Math.floor(this.x), Math.floor(this.y));
        }
    }
}
