#include "amijansson_jansson.h"

/* TYPE */
int _amijansson_json_typeof (struct JanssonIFace *Self, const json_t *json)
{
	return json_typeof (json);
}

BOOL _amijansson_json_is_object (struct JanssonIFace *Self, const json_t *json)
{
	return json_is_object (json);
}

BOOL _amijansson_json_is_array (struct JanssonIFace *Self, const json_t *json)
{
	return json_is_array (json);
}

BOOL _amijansson_json_is_string (struct JanssonIFace *Self, const json_t *json)
{
	return json_is_string (json);
}

BOOL _amijansson_json_is_integer (struct JanssonIFace *Self, const json_t *json)
{
	return json_is_integer (json);
}

BOOL _amijansson_json_is_real (struct JanssonIFace *Self, const json_t *json)
{
	return json_is_real (json);
}

BOOL _amijansson_json_is_true (struct JanssonIFace *Self, const json_t *json)
{
	return json_is_true (json);
}

BOOL _amijansson_json_is_false (struct JanssonIFace *Self, const json_t *json)
{
	return json_is_false (json);
}

BOOL _amijansson_json_is_null (struct JanssonIFace *Self, const json_t *json)
{
	return json_is_null (json);
}

BOOL _amijansson_json_is_number (struct JanssonIFace *Self, const json_t *json)
{
	return json_is_number (json);
}

BOOL _amijansson_json_is_boolean (struct JanssonIFace *Self, const json_t *json)
{
	return json_is_boolean (json);
}

BOOL _amijansson_json_boolean_value (struct JanssonIFace *Self, const json_t *json)
{
	return json_boolean_value (json);
}


/* REFERENCE COUNT */
json_t *_amijansson_json_incref (struct JanssonIFace *Self, json_t * json)
{
	return json_incref (json);
}

void _amijansson_json_decref (struct JanssonIFace *Self, json_t * json)
{
	json_decref (json);
}


/* TRUE, FALSE AND NULL */
json_t * _amijansson_json_true (struct JanssonIFace *Self)
{
	return json_true ();
}

json_t * _amijansson_json_false (struct JanssonIFace *Self)
{
	return json_false ();
}

json_t * _amijansson_json_boolean (struct JanssonIFace *Self, int val)
{
	return json_boolean (val);
}

json_t * _amijansson_json_null (struct JanssonIFace *Self)
{
	return json_null ();
}

/* STRING */
json_t * _amijansson_json_string (struct JanssonIFace *Self, const char * value)
{
	return json_string (value);
}

json_t * _amijansson_json_stringn (struct JanssonIFace *Self, const char * value, size_t len)
{
	return json_stringn (value, len);
}

json_t * _amijansson_json_string_nocheck (struct JanssonIFace *Self, const char * value)
{
	return json_string_nocheck (value);
}

json_t * _amijansson_json_stringn_nocheck (struct JanssonIFace *Self, const char * value, size_t len)
{
	return json_stringn_nocheck (value, len);
}

const char * _amijansson_json_string_value (struct JanssonIFace *Self, const json_t * string)
{
	return json_string_value (string);
}

size_t _amijansson_json_string_length (struct JanssonIFace *Self, const json_t * string)
{
	return json_string_length (string);
}

int _amijansson_json_string_set (struct JanssonIFace *Self, json_t * string, const char * value)
{
	return json_string_set (string, value);
}

int _amijansson_json_string_setn (struct JanssonIFace *Self, json_t * string, const char * value, size_t len)
{
	return json_string_setn (string, value, len);
}

int _amijansson_json_string_set_nocheck (struct JanssonIFace *Self, json_t * string, const char * value)
{
	return json_string_set_nocheck (string, value);
}

int _amijansson_json_string_setn_nocheck (struct JanssonIFace *Self, json_t * string, const char * value, size_t len)
{
	return json_string_setn_nocheck (string, value, len);
}

json_t *_amijansson_json_sprintf (struct JanssonIFace *Self, const char *fmt, ...)
{
  json_t *result;
  va_list ap;

  va_start (ap, fmt);
  result = json_vsprintf (fmt, ap);
  va_end (ap);

  return result;

}

json_t *_amijansson_json_vsprintf (struct JanssonIFace *Self, const char *format, va_list ap)
{
	return json_vsprintf (format, ap);
}


/* NUMBER */
json_t * _amijansson_json_integer (struct JanssonIFace *Self, json_int_t value)
{
	return json_integer (value);
}

json_int_t _amijansson_json_integer_value (struct JanssonIFace *Self, const json_t * integer)
{
	return json_integer_value (integer);
}

int _amijansson_json_integer_set (struct JanssonIFace *Self, json_t * integer, json_int_t value)
{
	return json_integer_set (integer, value);
}

json_t * _amijansson_json_real (struct JanssonIFace *Self, double value)
{
	return json_real (value);
}

double _amijansson_json_real_value (struct JanssonIFace *Self, const json_t * real)
{
	return json_real_value (real);
}

int _amijansson_json_real_set (struct JanssonIFace *Self, json_t * real, double value)
{
	return json_real_set (real, value);
}

double _amijansson_json_number_value (struct JanssonIFace *Self, const json_t * json)
{
	return json_number_value (json);
}


/* ARRAY */
json_t * _amijansson_json_array (struct JanssonIFace *Self)
{
	return json_array ();
}

size_t _amijansson_json_array_size (struct JanssonIFace *Self, const json_t * array)
{
	return json_array_size (array);
}

json_t *_amijansson_json_array_get (struct JanssonIFace *Self, json_t * array, size_t ind)
{
	return json_array_get (array, ind);
}

int _amijansson_json_array_set (struct JanssonIFace *Self, json_t * array, size_t ind, json_t * value)
{
	return json_array_set (array, ind, value);
}

int _amijansson_json_array_set_new (struct JanssonIFace *Self, json_t * array, size_t index, json_t * value)
{
	return json_array_set_new (array, index, value);
}

int _amijansson_json_array_append (struct JanssonIFace *Self, json_t * array, json_t * value)
{
	return json_array_append (array, value);
}

int _amijansson_json_array_append_new (struct JanssonIFace *Self, json_t * array, json_t * value)
{
	return json_array_append_new (array, value);
}

int _amijansson_json_array_insert (struct JanssonIFace *Self, json_t * array, size_t ind, json_t * value)
{
	return json_array_insert (array, ind, value);
}

int _amijansson_json_array_insert_new (struct JanssonIFace *Self, json_t * array, size_t index, json_t * value)
{
	return json_array_insert_new (array, index, value);
}

int _amijansson_json_array_remove (struct JanssonIFace *Self, json_t * array, size_t index)
{
	return json_array_remove (array, index);
}

int _amijansson_json_array_clear (struct JanssonIFace *Self, json_t * array)
{
	return json_array_clear (array);
}

int _amijansson_json_array_extend (struct JanssonIFace *Self, json_t * array, json_t * other)
{
	return json_array_extend (array, other);
}


/* OBJECT */
json_t * _amijansson_json_object (struct JanssonIFace *Self)
{
	return json_object ();
}

size_t _amijansson_json_object_size (struct JanssonIFace *Self, const json_t * object)
{
	return json_object_size (object);
}

json_t * _amijansson_json_object_get (struct JanssonIFace *Self, const json_t *object, const char *key)
{
	return json_object_get (object, key);
}

int _amijansson_json_object_set (struct JanssonIFace *Self, json_t * object, const char * key, json_t * value)
{
	return json_object_set (object, key, value);
}

int _amijansson_json_object_set_nocheck (struct JanssonIFace *Self, json_t * object, const char * key, json_t * value)
{
	return json_object_set_nocheck (object, key, value);
}

int _amijansson_json_object_set_new (struct JanssonIFace *Self, json_t * object, const char * key, json_t * value)
{
	return json_object_set_new (object, key, value);
}

int _amijansson_json_object_set_new_nocheck (struct JanssonIFace *Self, json_t * object, const char * key, json_t * value)
{
	return json_object_set_new_nocheck (object, key, value);
}

int _amijansson_json_object_del (struct JanssonIFace *Self, json_t * object, const char * key)
{
	return json_object_del (object, key);
}

int _amijansson_json_object_clear (struct JanssonIFace *Self, json_t * object)
{
	return json_object_clear (object);
}

int _amijansson_json_object_update (struct JanssonIFace *Self, json_t * object, json_t * other)
{
	return json_object_update (object, other);
}

int _amijansson_json_object_update_existing (struct JanssonIFace *Self, json_t * object, json_t * other)
{
	return json_object_update_existing (object, other);
}

int _amijansson_json_object_update_missing (struct JanssonIFace *Self, json_t * object, json_t * other)
{
	return json_object_update_missing (object, other);
}

void * _amijansson_json_object_iter (struct JanssonIFace *Self, json_t * object)
{
	return json_object_iter (object);
}

void * _amijansson_json_object_iter_at (struct JanssonIFace *Self, json_t * object, const char * key)
{
	return json_object_iter_at (object, key);
}

void * _amijansson_json_object_iter_next (struct JanssonIFace *Self, json_t * object, void * iter)
{
	return json_object_iter_next (object, iter);
}

const char * _amijansson_json_object_iter_key (struct JanssonIFace *Self, void * iter)
{
	return json_object_iter_key (iter);
}

json_t * _amijansson_json_object_iter_value (struct JanssonIFace *Self, void * iter)
{
	return json_object_iter_value (iter);
}

int _amijansson_json_object_iter_set (struct JanssonIFace *Self, json_t * object, void * iter, json_t * value)
{
	return json_object_iter_set (object, iter, value);
}

int _amijansson_json_object_iter_set_new (struct JanssonIFace *Self, json_t * object, void * iter, json_t * value)
{
	return json_object_iter_set_new (object, iter, value);
}

void * _amijansson_json_object_key_to_iter (struct JanssonIFace *Self, const char * key)
{
	return json_object_key_to_iter (key);
}

void _amijansson_json_object_seed (struct JanssonIFace *Self, size_t seed)
{
	json_object_seed (seed);
}


/* ERROR REPORTING */
enum json_error_code _amijansson_json_error_code (struct JanssonIFace *Self, const json_error_t *error)
{
	return json_error_code (error);
}


/* ENCODING */
char *_amijansson_json_dumps (struct JanssonIFace *Self, const json_t *json, size_t flags)
{
	return json_dumps (json, flags);
}

size_t _amijansson_json_dumpb (struct JanssonIFace *Self, const json_t * json, char * buffer, size_t size, size_t flags)
{
	return json_dumpb (json, buffer, size, flags);
}

int _amijansson_json_dumpf (struct JanssonIFace *Self, const json_t * json, FILE * output, size_t flags)
{
	return json_dumpf (json, output, flags);
}

int _amijansson_json_dumpfd (struct JanssonIFace *Self, const json_t * json, int output, size_t flags)
{
	return json_dumpfd (json, output, flags);
}

int _amijansson_json_dump_file (struct JanssonIFace *Self, const json_t * json, const char * path, size_t flags)
{
	return json_dump_file (json, path, flags);
}

int _amijansson_json_dump_callback (struct JanssonIFace *Self, const json_t * json, json_dump_callback_t callback, void * data, size_t flags)
{
	return json_dump_callback (json, callback, data, flags);
}


/* DECODING */
json_t *_amijansson_json_loads (struct JanssonIFace *Self, const char *input, size_t flags, json_error_t *error)
{
	return json_loads (input, flags, error);
}

json_t *_amijansson_json_loadb (struct JanssonIFace *Self, const char *buffer, size_t buflen, size_t flags, json_error_t *error)
{
	return json_loadb (buffer, buflen, flags, error);
}

json_t *_amijansson_json_loadf (struct JanssonIFace *Self, FILE *input, size_t flags, json_error_t *error)
{
	return json_loadf (input, flags, error);
}

json_t *_amijansson_json_loadfd (struct JanssonIFace *Self, int input, size_t flags, json_error_t *error)
{
	return json_loadfd (input, flags, error);
}

json_t *_amijansson_json_load_file (struct JanssonIFace *Self, const char *path, size_t flags, json_error_t *error)
{
	return json_load_file (path, flags, error);
}

json_t *_amijansson_json_load_callback (struct JanssonIFace *Self, json_load_callback_t callback, void *data, size_t flags, json_error_t *error)
{
	return json_load_callback (callback, data, flags, error);
}


/* BUILDING VALUES */
json_t *_amijansson_json_pack (struct JanssonIFace *Self, const char *fmt, ...)
{
  json_t *value;
  va_list ap;

  va_start(ap, fmt);
  value = json_vpack_ex (NULL, 0, fmt, ap);
  va_end(ap);

  return value;

}

json_t *_amijansson_json_pack_ex (struct JanssonIFace *Self, json_error_t *error, size_t flags, const char *fmt, ...)
{
  json_t *value;
  va_list ap;

  va_start (ap, fmt);
  value = json_vpack_ex(error, flags, fmt, ap);
  va_end(ap);

  return value;
}

json_t *_amijansson_json_vpack_ex (struct JanssonIFace *Self, json_error_t *error, size_t flags, const char *fmt, va_list ap)
{
	return json_vpack_ex (error, flags, fmt, ap);
}


/* PARSING AND VALIDATING VALUES */
int _amijansson_json_unpack (struct JanssonIFace *Self, json_t * root, const char * fmt)
{
	return json_unpack (root, fmt);
}

int _amijansson_json_unpack_ex (struct JanssonIFace *Self, json_t * root, json_error_t * error, size_t flags, const char * fmt)
{
	return json_unpack_ex (root, error, flags, fmt);
}

int _amijansson_json_vunpack_ex (struct JanssonIFace *Self, json_t * root, json_error_t * error, size_t flags, const char * fmt, va_list ap)
{
	return json_vunpack_ex (root, error, flags, fmt, ap);
}


/* EQUALITY */
int _amijansson_json_equal (struct JanssonIFace *Self, const json_t * value1, const json_t * value2)
{
	return json_equal (value1, value2);
}


/* COPYING */
json_t *_amijansson_json_copy (struct JanssonIFace *Self, json_t *value)
{
	return json_copy (value);
}

json_t *_amijansson_json_deep_copy (struct JanssonIFace *Self, const json_t *value)
{
	return json_deep_copy (value);
}


/* CUSTOM MEMORY ALLOCATION */
void _amijansson_json_set_alloc_funcs (struct JanssonIFace *Self, json_malloc_t malloc_fn, json_free_t free_fn)
{
	json_set_alloc_funcs (malloc_fn, free_fn);
}

void _amijansson_json_get_alloc_funcs (struct JanssonIFace *Self, json_malloc_t * malloc_fn, json_free_t * free_fn)
{
	json_get_alloc_funcs (malloc_fn, free_fn);
}

