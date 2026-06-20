
#include <progress.h>
#include <assert.h>

#include <proto/exec.h>
#include <proto/timer.h>

const char *vers = "\0$VER: progress-test 0.04 (28.04.2020)";

struct Device* TimerBase;
static struct IORequest timereq;

void
on_progress_start (progress_data_t *data);

void
on_progress (progress_data_t *data);

void
on_progress_end (progress_data_t *data);

int
main (void) {
  // open timer device
  OpenDevice((UBYTE*)"timer.device", 0, &timereq, 0);
  TimerBase = timereq.io_Device;

  // init with
  progress_t *progress = progress_new(100, 50);
  progress->fmt = "    progress (:percent) => {:bar} [:elapsed]";
  progress->bg_bar_char = " ";
  progress->bar_char = ".";

  // set events
  progress_on(progress, PROGRESS_EVENT_START, on_progress_start);
  progress_on(progress, PROGRESS_EVENT_PROGRESS, on_progress);
  progress_on(progress, PROGRESS_EVENT_END, on_progress_end);

  // tick progress
  progress_tick(progress, 10);
  sleep(1);
  progress_tick(progress, 30);
  progress_tick(progress, 5);
  progress_tick(progress, 10);
  progress_tick(progress, 20);
  sleep(1);
  progress_tick(progress, 10);
  progress_tick(progress, 5);
  progress_tick(progress, 10);

  // inspect
  progress_inspect(progress);

  progress_free(progress);


  progress = progress_new(100, 50);
  progress->fmt = "    progress (:percent) => {:bar} [:elapsed]";
  progress->bg_bar_char = " ";
  progress->bar_char = ".";

  // set events
  progress_on(progress, PROGRESS_EVENT_START, on_progress_start);
  progress_on(progress, PROGRESS_EVENT_PROGRESS, on_progress);
  progress_on(progress, PROGRESS_EVENT_END, on_progress_end);

  // tick progress
  progress_value(progress, 2);
  sleep(1);
  progress_value(progress, 5);
  progress_value(progress, 10);
  sleep(1);
  progress_value(progress, 15);
  progress_value(progress, 20);
  sleep(1);
  progress_value(progress, 30);
  sleep(1);
  progress_value(progress, 40);
  sleep(1);
  progress_value(progress, 100);

  // inspect
  progress_inspect(progress);

  progress_free(progress);


  progress = progress_new(100, 60);
  progress->fmt = "progress [:bar] :percent :elapsed";

  // listen for progress
  progress_on(progress, PROGRESS_EVENT_PROGRESS, on_progress);

  // tick progress
  for (int i = 0; i <= 10; i++)
  {
    progress_tick(progress, 10);
    sleep(1);
  }

  // inspect
  progress_inspect(progress);

  progress_free(progress);



  progress = progress_new(100, 50);
  progress->fmt = "    progress (:percent) => {:bar} [:elapsed]";
  progress->bg_bar_char = " ";
  progress->bar_char = ".";

  // set events
  progress_on(progress, PROGRESS_EVENT_START, on_progress_start);
  progress_on(progress, PROGRESS_EVENT_PROGRESS, on_progress);
  progress_on(progress, PROGRESS_EVENT_END, on_progress_end);

  for (long i = 0; i < 10000; ++i) {
     progress_value(progress, i / 100);
  }

  progress_free(progress);
  CloseDevice(&timereq);
}

void
on_progress_start (progress_data_t *data) {
  assert(data);
  puts("\nprogress start");
  progress_write(data->holder);
}

void
on_progress (progress_data_t *data) {
  progress_write(data->holder);
}

void
on_progress_end (progress_data_t *data) {
  puts("\nprogress end");
}

