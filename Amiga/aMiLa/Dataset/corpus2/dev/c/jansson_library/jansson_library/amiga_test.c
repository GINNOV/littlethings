#include "jansson.h"

#include "proto/amijansson.h"


#include <proto/exec.h>

#include <stdlib.h>
#include <stdio.h>

struct Library *JanssonBase = NULL;
struct JanssonIFace *IJansson = NULL;


static void RunTests (void);
static json_t *RunStringTest (void);
static int RunDumpLoadTest (json_t *src_p);
static int PackTest (void);



int main (void)
{
	JanssonBase = IExec->OpenLibrary ("jansson.library", 0);

	if (JanssonBase)
		{
			IJansson = (struct JanssonIFace *) IExec->GetInterface (JanssonBase, "main", 1, NULL);

			if (IJansson)
				{
					RunTests ();

					IExec->DropInterface ((struct Interface *) IJansson);
				}
			else
				{
					puts ("failed to open jansson interface");
				}

			IExec->CloseLibrary (JanssonBase);
		}
	else
		{
			puts ("failed to open jansson library");
		}

	return 0;
} 


static void RunTests (void)
{
	int num_tests = 0;
	int num_successes = 0;
	
	json_t *json_p = RunStringTest ();
	
	++ num_tests;

	if (json_p)
		{
			++ num_successes;

			if (RunDumpLoadTest (json_p) == 1)
				{
					++ num_successes;
				}
			++ num_tests;

			if (PackTest ())
				{
					++num_successes;
				}
			++ num_tests;

			IJansson->json_decref (json_p);
		}

	printf ("results: [%d/%d] tests ran successfully\n", num_successes, num_tests);
}


static json_t *RunStringTest (void)
{
	json_t *json_p = IJansson->json_object ();

	if (json_p)
		{
			char *dump_s = NULL;

			if (IJansson->json_object_set_new (json_p, "string_key", IJansson->json_string ("string_value")) != 0)
				{
					puts ("failed to add \"string_key\": \"string_value\"");
				}

			dump_s = IJansson->json_dumps (json_p, 0);

			if (dump_s)
				{
					printf ("json: %s\n", dump_s);

					free (dump_s);
				}

			if (IJansson->json_dump_file (json_p, "test.json", 0) != 0)
				{
					printf ("failed to dump data to \"test.json\"\n");
				}
		}
	else
		{
			puts ("failed to create json object");
		}

	return json_p;
}



static int RunDumpLoadTest (json_t *src_p)
{
	int res = 0;
	const char * const FILE_S = "test.json";

	if (IJansson->json_dump_file (src_p, FILE_S, 0) == 0)
		{
			json_error_t err;
			json_t *loaded_p = IJansson->json_load_file (FILE_S, 0, &err);

			if (loaded_p)
				{
					if (IJansson->json_equal (src_p, loaded_p) == 1)
						{
							puts ("loaded json is equal to saved json");
							res = 1;
						}
					else
						{
							char *src_s = IJansson->json_dumps (src_p, 0);

							if (src_s)
								{
									char *loaded_s = IJansson->json_dumps (loaded_p, 0);

									if (loaded_s)
										{
                      printf ("loaded json\n%s\n not equal to saved json\n%s\n", src_s, loaded_s);

											free (loaded_s);
										}

                  free (src_s);
								}

						}

					IJansson->json_decref (loaded_p);
				}
			else
				{
					printf ("failed to load json from \"%s\"\n", FILE_S);
				}
		}
	else
		{
			printf ("failed to dump data to \"%s\"\n", FILE_S);
		}

	return res;
}


static int PackTest (void)
{
	int res = 0;
	json_error_t err;
	json_t *json_p = IJansson->json_pack_ex (&err, 0, "[{s:i,s:{s:s,s:b}},{s:f}]", "key", 4, "my", "nested", "value", "boolean false", 0, "real pi", 3.141592);

	if (json_p)
		{
			char *json_s = IJansson->json_dumps (json_p, JSON_INDENT(2));

			if (json_s)
				{
					printf ("packed successfully:\n%s\n", json_s);

					free (json_s);
				}

			++ res;
			IJansson->json_decref (json_p);
		}

	return res;
}

