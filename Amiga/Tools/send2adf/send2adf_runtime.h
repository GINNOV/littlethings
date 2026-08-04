#ifndef SEND2ADF_RUNTIME_H
#define SEND2ADF_RUNTIME_H

#include <stddef.h>

int send2adf_create_image(const char *output_path,
                          const char *volume_name,
                          const char *bootblock,
                          char *const *input_paths,
                          size_t input_count);

#endif
