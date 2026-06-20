#ifndef DFLOW_H_
#define DFLOW_H_

void dflow_Dom(unsigned fn);
void dflow_LiveOut(unsigned fn);
// void dflow_ReachIn(unsigned fn, int is_last);

extern unsigned char *liveness_and_next_use;
void compute_liveness_and_next_use(void);

#define TAR_LIVE_MASK   0x01
#define AR1_LIVE_MASK   0x02
#define AR2_LIVE_MASK   0x04
#define TAR_NEXT_MASK   0x08
#define AR1_NEXT_MASK   0x10
#define AR2_NEXT_MASK   0x20

#define tar_liveness(i)  (liveness_and_next_use[i] & TAR_LIVE_MASK)
#define arg1_liveness(i) (liveness_and_next_use[i] & AR1_LIVE_MASK)
#define arg2_liveness(i) (liveness_and_next_use[i] & AR2_LIVE_MASK)
#define tar_next_use(i)  (liveness_and_next_use[i] & TAR_NEXT_MASK)
#define arg1_next_use(i) (liveness_and_next_use[i] & AR1_NEXT_MASK)
#define arg2_next_use(i) (liveness_and_next_use[i] & AR2_NEXT_MASK)

#endif
