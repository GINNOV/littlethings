#include <sge.h>

SGEPARTICLES *sgeParticlesNew(
		void *(*createFunction)(void *),
		Uint32 (*drawFunction)(Uint32, void *),
		void (*freeFunction)(Uint32, void *)
) {
	SGEPARTICLES *ret;
	sgeNew(ret, SGEPARTICLES);
	ret->runtime=0;
	ret->particles=sgeAutoArrayNew(freeFunction);
	ret->timeToLive=100;
	ret->timeToLiveDistribution=50;
	ret->infinite=0;
	ret->angle=0;
	ret->angleDistribution=20;
	ret->gravity=.2;
	ret->emission=20;
	ret->emissionDistribution=10;
	ret->internalEmission=0;
	ret->speed=1;
	ret->speedDistribution=.2;
	ret->create=createFunction;
	ret->draw=drawFunction;
	ret->drawSurface=screen;
	ret->x=0;
	ret->y=0;
	ret->custom=NULL;
	ret->customDestroy=NULL;
	return ret;
}

void sgeParticlesDestroy(SGEPARTICLES *p) {
	sgeArrayDestroy(p->particles);
	if (p->customDestroy!=NULL) {
		(p->customDestroy(p->custom));
	}
	sgeFree(p);
}

void sgeParticlesDraw(SGEPARTICLES *p) {
	Uint32 i;
	float emission;
	p->runtime++;
	emission=sgeParticlesGetNewEmission(p);
	for (i=0;i<(int)emission;i++) {
		sgeArrayAdd(p->particles, (void *)(p->create)((void *)p));
	}
	for (i=0;i<p->particles->numberOfElements;i++) {
		i=(p->draw)(i, (void *)p);
	}
}

float sgeParticlesGetNewEmission(SGEPARTICLES *p) {
	if (p->emission<1) {
		p->internalEmission+=p->emission;
		if (p->internalEmission>1) {
			p->internalEmission-=1;
			return 1;
		}
		return 0;
	}
	if (p->emissionDistribution!=0) {
		return p->emission+sgeRandomFloat(-(p->emissionDistribution/2),(p->emissionDistribution));
	}
	return p->emission;
}

Uint32 sgeParticlesGetNewTimeToLive(SGEPARTICLES *p) {
	if (p->timeToLiveDistribution!=0) {
		Sint32 tmp;
		tmp=p->timeToLive+sgeRandom(-(p->timeToLiveDistribution>>1),(p->timeToLiveDistribution));
		if (tmp>=0) return tmp;
		return 0;
	}
	return p->timeToLive;
}

float sgeParticlesGetNewSpeed(SGEPARTICLES *p) {
	if (p->speedDistribution!=0) {
		return p->speed+sgeRandomFloat(-p->speedDistribution/2,p->speedDistribution);
	}
	return p->speed;
}

float sgeParticlesGetNewAngle(SGEPARTICLES *p) {
	if (p->angleDistribution!=0) {
		return p->angle+sgeRandomFloat(-p->angleDistribution/2,p->angleDistribution);
	}
	return p->angle;
}

inline float sgeParticlesGetNewX(float x, float angle, float speed) {
	return x+cos(M_PI/180*angle)*speed;
}

inline float sgeParticlesGetNewY(float y, float angle, float speed, float gravity) {
	return y+sin(M_PI/180*angle)*speed+gravity;
}

void *sgePixelParticleNew(void *p) {
	SGEPIXELPARTICLE *ret;
	SGEPARTICLES *pp=(SGEPARTICLES *)p;
	SGEPIXELPARTICLEDATA *data=pp->custom;
	Uint8 r,g,b;
	sgeNew(ret, SGEPIXELPARTICLE);
	ret->x=(float)pp->x;
	ret->y=(float)pp->y;
	ret->speed=sgeParticlesGetNewSpeed(pp);
	ret->angle=sgeParticlesGetNewAngle(pp);
	ret->timeToLive=sgeParticlesGetNewTimeToLive(pp);
	r=MIN(data->r1,data->r2)+sgeRandom(0,MAX(data->r2,data->r1)-MIN(data->r2,data->r1));
	g=MIN(data->g1,data->g2)+sgeRandom(0,MAX(data->g2,data->g1)-MIN(data->g2,data->g1));
	b=MIN(data->b1,data->b2)+sgeRandom(0,MAX(data->b2,data->b1)-MIN(data->b2,data->b1));
	ret->color=sgeMakeColor(r,g,b,0xff);
	ret->gravity=0;
	return ret;
}

void sgePixelParticleDestroy(Uint32 arrayidx, void *particle) {
	SGEPIXELPARTICLE *p=(SGEPIXELPARTICLE *)particle;
	sgeFree(p);
}

Uint32 sgePixelParticleDraw(Uint32 arrayidx, void *p) {
	SGEPARTICLES *pp=(SGEPARTICLES *)p;
	SGEPIXELPARTICLE *particle=sgeArrayGet(pp->particles, arrayidx);

	if (pp->infinite==0) {
		if (particle->timeToLive<1) {
			sgeArrayRemove(pp->particles, arrayidx);
			return arrayidx-1;
		} else {
			particle->timeToLive--;
		}
	}
	particle->gravity+=pp->gravity;
	particle->x=sgeParticlesGetNewX(particle->x, particle->angle, particle->speed);
	particle->y=sgeParticlesGetNewY(particle->y, particle->angle, particle->speed, particle->gravity);

	sgeDrawPixel(pp->drawSurface, (int)particle->x, (int)particle->y, particle->color);
	return arrayidx;
}

void sgeParticlesPixelCustomDestroy(void *data) {
	SGEPIXELPARTICLEDATA *d=(SGEPIXELPARTICLEDATA *)data;
	sgeFree(d);
}

SGEPARTICLES *sgeParticlesPixelNew(Uint8 r1, Uint8 g1, Uint8 b1, Uint8 r2, Uint8 g2, Uint8 b2) {
	SGEPIXELPARTICLEDATA *data;
	SGEPARTICLES *ret=sgeParticlesNew(
			sgePixelParticleNew,
			sgePixelParticleDraw,
			sgePixelParticleDestroy
	);
	sgeNew(data, SGEPIXELPARTICLEDATA);
	data->r1=r1;
	data->g1=g1;
	data->b1=b1;
	data->r2=r2;
	data->g2=g2;
	data->b2=b2;
	ret->custom=(void *)data;
	ret->customDestroy=sgeParticlesPixelCustomDestroy;
	return ret;
}

SGEPARTICLES *sgeParticlesSpriteNew(SGESPRITE *sprite) {
	SGESPRITEPARTICLEDATA *data;
	SGEPARTICLES *ret=sgeParticlesNew(
			sgeSpriteParticleNew,
			sgeSpriteParticleDraw,
			sgeSpriteParticleDestroy
	);
	sgeNew(data, SGESPRITEPARTICLEDATA);
	data->sprite=sprite;
	ret->custom=(void *)data;
	ret->customDestroy=sgeParticlesSpriteCustomDestroy;
	return ret;
}

void *sgeSpriteParticleNew(void *p) {
	SGESPRITEPARTICLE *ret;
	SGEPARTICLES *pp=(SGEPARTICLES *)p;
	sgeNew(ret, SGESPRITEPARTICLE);
	ret->x=(float)pp->x;
	ret->y=(float)pp->y;
	ret->speed=sgeParticlesGetNewSpeed(pp);
	ret->angle=sgeParticlesGetNewAngle(pp);
	ret->timeToLive=sgeParticlesGetNewTimeToLive(pp);
	ret->gravity=0;
	return ret;
}

void sgeSpriteParticleDestroy(Uint32 arrayidx, void *particle) {
	SGESPRITEPARTICLE *p=(SGESPRITEPARTICLE *)particle;
	sgeFree(p);
}

Uint32 sgeSpriteParticleDraw(Uint32 arrayidx, void *p) {
	SGEPARTICLES *pp=(SGEPARTICLES *)p;
	SGESPRITEPARTICLE *particle=sgeArrayGet(pp->particles, arrayidx);
	SGESPRITEPARTICLEDATA *data=pp->custom;

	if (pp->infinite==0) {
		if (particle->timeToLive<1) {
			sgeArrayRemove(pp->particles, arrayidx);
			return arrayidx-1;
		} else {
			particle->timeToLive--;
		}
	}
	particle->gravity+=pp->gravity;
	particle->x=sgeParticlesGetNewX(particle->x, particle->angle, particle->speed);
	particle->y=sgeParticlesGetNewY(particle->y, particle->angle, particle->speed, particle->gravity);

	sgeSpriteDrawXY(data->sprite, (int)particle->x, (int)particle->y, pp->drawSurface);
	return arrayidx;
}

void sgeParticlesSpriteCustomDestroy(void *data) {
	SGESPRITEPARTICLEDATA *d=(SGESPRITEPARTICLEDATA *)data;
	sgeSpriteDestroy(d->sprite);
	sgeFree(d);
}

