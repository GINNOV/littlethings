void _message(char *format, ...);
/* Display a message which is as visible as possible (either to the console
   or to a requester).
   Assume very little about library state */
void _fail(char *format, ...);
/* Display a message which is as visible as possible (either to the console
   or to a requester).
   Assume very little about library state.
   Exit with error code RETURN_FAIL after that. */
