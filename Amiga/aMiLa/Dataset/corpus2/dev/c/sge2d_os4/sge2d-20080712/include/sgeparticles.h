#ifndef _SGEPARTICLES_H
#define _SGEPARTICLES_H

typedef struct {
	Uint32 timeToLive;
	float speed;
	float angle;
	float x,y;
	float gravity;
	Uint32 color;
} SGEPIXELPARTICLE;

typedef struct {
	Uint8 r1,g1,b1;
	Uint8 r2,g2,b2;
} SGEPIXELPARTICLEDATA;

typedef struct {
	Uint32 timeToLive;
	float speed;
	float angle;
	float x,y;
	float gravity;
} SGESPRITEPARTICLE;

typedef struct {
	SGESPRITE *sprite;
} SGESPRITEPARTICLEDATA;

typedef struct {
	SDL_Surface *drawSurface;
	Uint32 runtime;

	SGEARRAY *particles;
	Uint32 (*draw)(Uint32, void *);
	void *(*create)(void *);

	Uint32 infinite;
	Uint32 x,y;
	Uint32 timeToLive;
	Uint32 timeToLiveDistribution;
	float emission;
	float emissionDistribution;
	float internalEmission;
	float speed;
	float speedDistribution;
	float angle;
	float angleDistribution;
	float gravity;
	void *custom;
	void (*customDestroy)(void *);
} SGEPARTICLES;

SGEPARTICLES *sgeParticlesNew(
		void *(*createFunction)(void *),
		Uint32 (*drawFunction)(Uint32, void *),
		void (*freeFunction)(Uint32, void *)
);
void sgeParticlesDestroy(SGEPARTICLES *p);

void sgeParticlesDraw(SGEPARTICLES *p);
float sgeParticlesGetNewEmission(SGEPARTICLES *p);
Uint32 sgeParticlesGetNewTimeToLive(SGEPARTICLES *p);
float sgeParticlesGetNewSpeed(SGEPARTICLES *p);
float sgeParticlesGetNewAngle(SGEPARTICLES *p);
inline float sgeParticlesGetNewX(float x, float angle, float speed);
inline float sgeParticlesGetNewY(float y, float angle, float speed, float gravity);

// pixel emitter

SGEPARTICLES *sgeParticlesPixelNew(Uint8 r1, Uint8 g1, Uint8 b1, Uint8 r2, Uint8 g2, Uint8 b2);
void *sgePixelParticleNew(void *p);
void sgePixelParticleDestroy(Uint32 arrayidx, void *particle);
Uint32 sgePixelParticleDraw(Uint32 arrayidx, void *p);
void sgeParticlesPixelCustomDestroy(void *data);

// sprite emitter

SGEPARTICLES *sgeParticlesSpriteNew(SGESPRITE *sprite);
void *sgeSpriteParticleNew(void *p);
void sgeSpriteParticleDestroy(Uint32 arrayidx, void *particle);
Uint32 sgeSpriteParticleDraw(Uint32 arrayidx, void *p);
void sgeParticlesSpriteCustomDestroy(void *data);

#endif
