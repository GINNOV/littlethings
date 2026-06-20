/*
 * GAP-Lib (C)1998-1999 Peter Bengtsson
 * The Genetic Algorithm Programming Library.
 *
 */

#ifndef	__GAP_H__
#define	__GAP_H__

#ifdef	__STDC_VERSION__
#if	__STDC_VERSION__==199901L
#include <inttypes.h>
typedef intptr_t IPTR
#define	__IPTR_DONE
#endif
#endif

#ifndef	TAG_DONE	/* This should be defined if tags are already defined. */

typedef	long	Tag;
#ifndef	__IPTR_DONE
typedef	unsigned long IPTR;
#endif

struct TagItem	{
	Tag	ti_Tag;
	IPTR	ti_Data;
};

#define	TAG_DONE		(0L)
#define  TAG_END     TAG_DONE
#define	TAG_IGNORE	(1L)
#define	TAG_MORE		(2L)

#endif

#ifndef	TAG_DUMMY
#define	TAG_DUMMY	(64L)
#endif

#ifndef	TRUE
#define	TRUE	(~0)
#define	FALSE	(0)
#endif

#define	GAP_RAND_MAX	0x7ffffffd

/* Tags for CreatePopulation.
 *
 */

#define	POP_Init			(TAG_DUMMY+0x01)	/* Initialization function. */
#define	POP_Destruct	(TAG_DUMMY+0x02)	/* Destructor function. */
#define	POP_Cache		(TAG_DUMMY+0x03)	/* Cache? Defaults to TRUE. */

/* Tags for Evolve(). These define different parameters of the evolution
 * of the Polyphant population.
 */

#define	EVL_Evaluator	 (TAG_DUMMY+0x01)	/* Fitness function, _REQUIRED_ */
#define	EVL_Mutator		 (TAG_DUMMY+0x02)	/* Mutator function */
#define	EVL_Crosser		 (TAG_DUMMY+0x03)	/* Crossover function */
#define	EVL_Elite		 (TAG_DUMMY+0x04)	/* No. of Elite individuals to copy without modification */
#define	EVL_Dump			 (TAG_DUMMY+0x05)	/* Dump the worst individuals */
#define	EVL_Select		 (TAG_DUMMY+0x06)	/* Select type */
#define	EVL_Stats		 (TAG_DUMMY+0x07)	/* Generate statistics  (Defaults to TRUE) */
#define	EVL_PreMutate	 (TAG_DUMMY+0x08)	/* Mutate before generating new individuals (Defaults to FALSE) */
#define	EVL_Newbies		 (TAG_DUMMY+0x09)	/* No. of new individuals to generate. */
#define	EVL_Flags		 (TAG_DUMMY+0x0A)	/* Mode of operation Flags */
#define	EVL_Mensurator	 (TAG_DUMMY+0x0B)	/* Measures the distance 'twixt individuals */
#define	EVL_Crowding	 (TAG_DUMMY+0x0C)	/* Use crowding replacement */
#define	EVL_InitDumped	 (TAG_DUMMY+0x0D)	/* If EVL_Dump>0, re-initialize dumped individuals. */
#define	EVL_EraseBest	 (TAG_DUMMY+0x0E)	/* If EVL_Newbies>0, replace the best individuals. */
#define	EVL_Transcriber (TAG_DUMMY+0x0F)	/* Transcription function. */
#define	EVL_Thermostat	 (TAG_DUMMY+0x10)	/* Regulates selection 'temperature'. */

/* For EVL_Select */

#define	DRANDOM		1L		/* Double Random */
#define	FITPROP		2L		/* Fitness Proportionate */
#define	SIGMA			3L		/* Sigma Scaled Selection */
#define	TOURNAMENT	4L		/* Tournament Selection */
#define	INORDER		5L		/* Sorted in order of fitness */
#define	TEMPERATURE	6L		/* Temperature-dependant selection eg. Boltzmann */
#define	UNIVERSAL	7L		/* Stochastic Universal selection */

/* For POP_Init */

#define	ZERO_INIT	0L		/* Zeroed bits */
#define	RAND_INIT	1L		/* Random bits */

/* For EVL_Flags */

#define	FLG_InitDumped			(1L<<0)
#define	FLG_EraseBest			(1L<<1)
#define	FLG_Crowding			(1L<<2)
#define	FLG_Statistics			(1L<<3)

#define	UnitedKingdomFlag	(1L<<31)

/* Structures */

struct Popstat {
	double	AverageFitness;		/* Average fitness of population. */
	double	MedianFitness;			/* Median fitness of the population. */
	double	TypeFitness;			/* Type fitness value (Most common) */
	long		TypeCount;				/* Countvalue for type fitness */
	double	StdDeviation;			/* Standard deviation */
	double	MaxFitness;				/* Fitness of the fittest individual.  */
	double	MinFitness;				/* Fitness of the least fit individual. */
	void		*Max;						/* Pointer to the fittest individual. */
	long		Generation;
};

struct Population {
	long	 NumPolys;
	long	 Generation;
	long	 Flags;
	struct Popstat Stat;
	long	 Bytes;
	void	*Polys;
	void	*Magic;
};

extern int						 EnterGAP(int);
extern void 					 Crossover(void *Ind1,void *Ind2,const long int At,const long int Size);
extern void 					 Flip(void *Individual,const long int At);
extern int 					 	 Testbit(void *Individual,long int At);
extern void						 InitRand(const long int);
extern unsigned long int	 Rnd(const long int Max);
extern double					 InRand(const double From,const double To);
extern double					 GaussRand(const double My,const double Sigma);
extern double					 PoissonRand(const double My);
extern int						 TossRand(const double P);
extern struct Population	*CreatePopulation(const long int NumIndividuals,const long int Size,struct TagItem *);
extern struct Population	*CreatePopulationT(const long int NumIndividuals,const long int Size,...);
extern struct Population	*Evolve(struct Population *OldPop,struct TagItem *);
extern struct Population	*EvolveT(struct Population *,...); /* Varargs interface to Evolve() */
extern void						 DeletePopulation(struct Population *Pop);
extern void						*PopMember(struct Population *,const long int);
extern double					 IRange(const unsigned long int,const double,const double);
extern unsigned long int	 HammingDist(void *,void *,const int);

#endif
