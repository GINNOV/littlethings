#ifndef WORKSPACE_JANSSON_2_12_SRC_JANSSON_H
#define WORKSPACE_JANSSON_2_12_SRC_JANSSON_H


#include "jansson.h"

#include "proto/amijansson.h"

/* TYPE */
int VARARGS68K _amijansson_json_typeof (struct JanssonIFace *Self, const json_t *json);
BOOL VARARGS68K _amijansson_json_is_object (struct JanssonIFace *Self, const json_t *json);
BOOL VARARGS68K _amijansson_json_is_array (struct JanssonIFace *Self, const json_t *json);
BOOL VARARGS68K _amijansson_json_is_string (struct JanssonIFace *Self, const json_t *json);
BOOL VARARGS68K _amijansson_json_is_integer (struct JanssonIFace *Self, const json_t *json);
BOOL VARARGS68K _amijansson_json_is_real (struct JanssonIFace *Self, const json_t *json);
BOOL VARARGS68K _amijansson_json_is_true (struct JanssonIFace *Self, const json_t *json);
BOOL VARARGS68K _amijansson_json_is_false (struct JanssonIFace *Self, const json_t *json);
BOOL VARARGS68K _amijansson_json_is_null (struct JanssonIFace *Self, const json_t *json);
BOOL VARARGS68K _amijansson_json_is_number (struct JanssonIFace *Self, const json_t *json);
BOOL VARARGS68K _amijansson_json_is_boolean (struct JanssonIFace *Self, const json_t *json);
BOOL VARARGS68K _amijansson_json_boolean_value (struct JanssonIFace *Self, const json_t *json);



/* REFERENCE COUNT */
json_t * VARARGS68K _amijansson_json_incref  (struct JanssonIFace *Self, json_t * json);
void VARARGS68K _amijansson_json_decref  (struct JanssonIFace *Self, json_t * json);

/* TRUE, FALSE AND NULL */
json_t * VARARGS68K _amijansson_json_true  (struct JanssonIFace *Self);
json_t * VARARGS68K _amijansson_json_false  (struct JanssonIFace *Self);
json_t * VARARGS68K _amijansson_json_boolean (struct JanssonIFace *Self, int val);
json_t * VARARGS68K _amijansson_json_null  (struct JanssonIFace *Self);

/* STRING */
json_t * VARARGS68K _amijansson_json_string  (struct JanssonIFace *Self, const char * value);
json_t * VARARGS68K _amijansson_json_stringn  (struct JanssonIFace *Self, const char * value, size_t len);
json_t * VARARGS68K _amijansson_json_string_nocheck  (struct JanssonIFace *Self, const char * value);
json_t * VARARGS68K _amijansson_json_stringn_nocheck  (struct JanssonIFace *Self, const char * value, size_t len);
const char * VARARGS68K _amijansson_json_string_value  (struct JanssonIFace *Self, const json_t * string);
size_t VARARGS68K _amijansson_json_string_length  (struct JanssonIFace *Self, const json_t * string);
int VARARGS68K _amijansson_json_string_set  (struct JanssonIFace *Self, json_t * string, const char * value);
int VARARGS68K _amijansson_json_string_setn  (struct JanssonIFace *Self, json_t * string, const char * value, size_t len);
int VARARGS68K _amijansson_json_string_set_nocheck  (struct JanssonIFace *Self, json_t * string, const char * value);
int VARARGS68K _amijansson_json_string_setn_nocheck  (struct JanssonIFace *Self, json_t * string, const char * value, size_t len);
json_t * VARARGS68K _amijansson_json_sprintf (struct JanssonIFace *Self, const char *format, ...);
json_t * VARARGS68K _amijansson_json_vsprintf (struct JanssonIFace *Self, const char *format, va_list ap);

/* NUMBER */
json_t * VARARGS68K _amijansson_json_integer  (struct JanssonIFace *Self, json_int_t value);
json_int_t VARARGS68K _amijansson_json_integer_value  (struct JanssonIFace *Self, const json_t * integer);
int VARARGS68K _amijansson_json_integer_set  (struct JanssonIFace *Self, json_t * integer, json_int_t value);
json_t * VARARGS68K _amijansson_json_real  (struct JanssonIFace *Self, double value);
double VARARGS68K _amijansson_json_real_value  (struct JanssonIFace *Self, const json_t * real);
int VARARGS68K _amijansson_json_real_set  (struct JanssonIFace *Self, json_t * real, double value);
double VARARGS68K _amijansson_json_number_value  (struct JanssonIFace *Self, const json_t * json);

/* ARRAY */
json_t * VARARGS68K _amijansson_json_array  (struct JanssonIFace *Self);
size_t VARARGS68K _amijansson_json_array_size  (struct JanssonIFace *Self, const json_t * array);
json_t * VARARGS68K _amijansson_json_array_get  (struct JanssonIFace *Self, json_t * array, size_t ind);
int VARARGS68K _amijansson_json_array_set  (struct JanssonIFace *Self, json_t * array, size_t ind, json_t * value);
int VARARGS68K _amijansson_json_array_set_new  (struct JanssonIFace *Self, json_t * array, size_t index, json_t * value);
int VARARGS68K _amijansson_json_array_append  (struct JanssonIFace *Self, json_t * array, json_t * value);
int VARARGS68K _amijansson_json_array_append_new  (struct JanssonIFace *Self, json_t * array, json_t * value);
int VARARGS68K _amijansson_json_array_insert  (struct JanssonIFace *Self, json_t * array, size_t ind, json_t * value);
int VARARGS68K _amijansson_json_array_insert_new  (struct JanssonIFace *Self, json_t * array, size_t index, json_t * value);
int VARARGS68K _amijansson_json_array_remove  (struct JanssonIFace *Self, json_t * array, size_t index);
int VARARGS68K _amijansson_json_array_clear  (struct JanssonIFace *Self, json_t * array);
int VARARGS68K _amijansson_json_array_extend  (struct JanssonIFace *Self, json_t * array, json_t * other);


/* OBJECT */
json_t * VARARGS68K _amijansson_json_object  (struct JanssonIFace *Self);
size_t VARARGS68K _amijansson_json_object_size  (struct JanssonIFace *Self, const json_t * object);
json_t * VARARGS68K _amijansson_json_object_get (struct JanssonIFace *Self, const json_t *object, const char *key);
int VARARGS68K _amijansson_json_object_set  (struct JanssonIFace *Self, json_t * object, const char * key, json_t * value);
int VARARGS68K _amijansson_json_object_set_nocheck  (struct JanssonIFace *Self, json_t * object, const char * key, json_t * value);
int VARARGS68K _amijansson_json_object_set_new  (struct JanssonIFace *Self, json_t * object, const char * key, json_t * value);
int VARARGS68K _amijansson_json_object_set_new_nocheck  (struct JanssonIFace *Self, json_t * object, const char * key, json_t * value);
int VARARGS68K _amijansson_json_object_del  (struct JanssonIFace *Self, json_t * object, const char * key);
int VARARGS68K _amijansson_json_object_clear  (struct JanssonIFace *Self, json_t * object);
int VARARGS68K _amijansson_json_object_update  (struct JanssonIFace *Self, json_t * object, json_t * other);
int VARARGS68K _amijansson_json_object_update_existing  (struct JanssonIFace *Self, json_t * object, json_t * other);
int VARARGS68K _amijansson_json_object_update_missing  (struct JanssonIFace *Self, json_t * object, json_t * other);
void * VARARGS68K _amijansson_json_object_iter  (struct JanssonIFace *Self, json_t * object);
void * VARARGS68K _amijansson_json_object_iter_at  (struct JanssonIFace *Self, json_t * object, const char * key);
void * VARARGS68K _amijansson_json_object_iter_next  (struct JanssonIFace *Self, json_t * object, void * iter);
const char * VARARGS68K _amijansson_json_object_iter_key  (struct JanssonIFace *Self, void * iter);
json_t * VARARGS68K _amijansson_json_object_iter_value  (struct JanssonIFace *Self, void * iter);
int VARARGS68K _amijansson_json_object_iter_set  (struct JanssonIFace *Self, json_t * object, void * iter, json_t * value);
int VARARGS68K _amijansson_json_object_iter_set_new  (struct JanssonIFace *Self, json_t * object, void * iter, json_t * value);
void * VARARGS68K _amijansson_json_object_key_to_iter  (struct JanssonIFace *Self, const char * key);
void VARARGS68K _amijansson_json_object_seed  (struct JanssonIFace *Self, size_t seed);


/* ERROR REPORTING */
enum json_error_code VARARGS68K _amijansson_json_error_code (struct JanssonIFace *Self, const json_error_t *error);

/* ENCODING */
char * VARARGS68K _amijansson_json_dumps (struct JanssonIFace *Self, const json_t *json, size_t flags);
size_t VARARGS68K _amijansson_json_dumpb  (struct JanssonIFace *Self, const json_t * json, char * buffer, size_t size, size_t flags);
int VARARGS68K _amijansson_json_dumpf  (struct JanssonIFace *Self, const json_t * json, FILE * output, size_t flags);
int VARARGS68K _amijansson_json_dumpfd  (struct JanssonIFace *Self, const json_t * json, int output, size_t flags);
int VARARGS68K _amijansson_json_dump_file  (struct JanssonIFace *Self, const json_t * json, const char * path, size_t flags);
int VARARGS68K _amijansson_json_dump_callback  (struct JanssonIFace *Self, const json_t * json, json_dump_callback_t callback, void * data, size_t flags);


/* DECODING */
json_t * VARARGS68K _amijansson_json_loads (struct JanssonIFace *Self, const char *input, size_t flags, json_error_t *error);
json_t * VARARGS68K _amijansson_json_loadb (struct JanssonIFace *Self, const char *buffer, size_t buflen, size_t flags, json_error_t *error);
json_t * VARARGS68K _amijansson_json_loadf (struct JanssonIFace *Self, FILE *input, size_t flags, json_error_t *error);
json_t * VARARGS68K _amijansson_json_loadfd (struct JanssonIFace *Self, int input, size_t flags, json_error_t *error);
json_t * VARARGS68K _amijansson_json_load_file (struct JanssonIFace *Self, const char *path, size_t flags, json_error_t *error);
json_t * VARARGS68K _amijansson_json_load_callback (struct JanssonIFace *Self, json_load_callback_t callback, void *data, size_t flags, json_error_t *error);

/* BUILDING VALUES */
json_t * VARARGS68K _amijansson_json_pack (struct JanssonIFace *Self, const char *fmt, ...);
json_t * VARARGS68K _amijansson_json_pack_ex (struct JanssonIFace *Self, json_error_t *error, size_t flags, const char *fmt, ...);
json_t * VARARGS68K _amijansson_json_vpack_ex (struct JanssonIFace *Self, json_error_t *error, size_t flags, const char *fmt, va_list ap);

/* PARSING AND VALIDATING VALUES */
int VARARGS68K _amijansson_json_unpack  (struct JanssonIFace *Self, json_t * root, const char * fmt);
int VARARGS68K _amijansson_json_unpack_ex  (struct JanssonIFace *Self, json_t * root, json_error_t * error, size_t flags, const char * fmt);
int VARARGS68K _amijansson_json_vunpack_ex  (struct JanssonIFace *Self, json_t * root, json_error_t * error, size_t flags, const char * fmt, va_list ap);

/* EQUALITY */
int VARARGS68K _amijansson_json_equal  (struct JanssonIFace *Self, const json_t * value1, const json_t * value2);

/* COPYING */
json_t * VARARGS68K _amijansson_json_copy (struct JanssonIFace *Self, json_t *value);
json_t * VARARGS68K _amijansson_json_deep_copy (struct JanssonIFace *Self, const json_t *value);

/* CUSTOM MEMORY ALLOCATION */
void VARARGS68K _amijansson_json_set_alloc_funcs  (struct JanssonIFace *Self, json_malloc_t malloc_fn, json_free_t free_fn);
void VARARGS68K _amijansson_json_get_alloc_funcs  (struct JanssonIFace *Self, json_malloc_t * malloc_fn, json_free_t * free_fn);





#endif	/* #ifndef WORKSPACE_JANSSON_2_12_SRC_JANSSON_H */
