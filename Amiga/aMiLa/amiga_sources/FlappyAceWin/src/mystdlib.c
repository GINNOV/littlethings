#include <ace/utils/file.h>
#include <ace/utils/font.h>
#include <ace/utils/string.h>
#include <mini_std/stdio.h>

//The following three std library functions are implemented here since they are not in the mini_std library that comes with the bartman compiler. I could add them there for streamlining but in case of updates i moved them here.
char mfgetc(FILE *stream) {
  if (stream == NULL) {
    return EOF;
  }

  char c;
  if (fread(&c, 1, 1, stream) != 1) {
    return EOF;
  }

  return c;
}

char *fgets(char *str, int num, FILE *stream) {
  if (stream == NULL) {
    return NULL;
  }

  int i = 0;
  char c;

  while ((c = mfgetc(stream)) != EOF) {
    if (c == '\n') {
      str[i] = '\0';
      break;
    } else if (i < num - 1) {
      str[i] = c;
      i++;
    }
  }

  if (i == 0) {
    return NULL;
  }

  return str;
}

long strtol(const char *str, char **endptr, int base) {
  long result = 0;
  int sign = 1;

  // Check for leading sign character
  if (*str == '-') {
    sign = -1;
    str++;
  } else if (*str == '+') {
    str++;
  }

  // Check for valid base
  if (base == 0) {
    // Default to base 10 if no base is specified
    base = 10;
  } else if (base < 2 || base > 36) {
    // Invalid base
    if (endptr) {
      *endptr = (char *)str;
    }
    return 0;
  }

  // Convert characters to digits
  while (*str) {
    int digit;

    if (*str >= '0' && *str <= '9') {
      digit = *str - '0';
    } else if (*str >= 'A' && *str <= 'Z') {
      digit = *str - 'A' + 10;
    } else if (*str >= 'a' && *str <= 'z') {
      digit = *str - 'a' + 10;
    } else {
      // Invalid character
      if (endptr) {
        *endptr = (char *)str;
      }
      return 0;
    }

    // Check if digit is within the valid range for the given base
    if (digit >= base) {
      // Invalid digit
      if (endptr) {
        *endptr = (char *)str;
      }
      return 0;
    }

    // Accumulate the result
    result = result * base + digit;
    str++;
  }

  // Apply sign and return the result
  return result * sign;
}

char *strtok(char *str, const char *delim) {
  static char *prev_ptr = NULL;

  if (str == NULL) {
    str = prev_ptr;
  }

  if (str == NULL || *str == '\0') {
    return NULL;
  }

  char *token_start = str;

  while (*str != '\0') {
    if (strchr(delim, *str) != NULL) {
      *str = '\0';
      str++;
      break;
    }

    str++;
  }

  prev_ptr = str;
  return token_start;
}