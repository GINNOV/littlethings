#ifndef TIMERS_H
#define TIMERS_H

struct timeinfo {
  struct timerequest *io;
  int sent;
};

struct timeinfo *_alloc_timer(void);
void _free_timer(struct timeinfo *timer);
void _timer_abort(struct timeinfo *timer);
ULONG _timer_sig(struct timeinfo *timer);

void _timer_start(struct timeinfo *timer, int secs, int micros);
/* _timer_start(timer, 0) stops a timer */

int _timer_expired(struct timeinfo *timer);
/* A non-started timer is defined to not have expired */

#endif
