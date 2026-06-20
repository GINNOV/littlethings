#ifndef VECTORS_H
#define VECTORS_H

#include <exec/exec.h>
#include <exec/interfaces.h>
#include <exec/types.h>
#include <proto/amijansson.h>


#include "amijansson_jansson.h"


/*---------*/

STATIC CONST APTR amijansson_vectors [] = 
{
	_amijansson_Obtain,
	_amijansson_Release,
	NULL,
	NULL,

	/* TYPE */
	_amijansson_json_typeof,

	_amijansson_json_is_object,
	_amijansson_json_is_array,
	_amijansson_json_is_string,
	_amijansson_json_is_integer,
	_amijansson_json_is_real,
	_amijansson_json_is_true,
	_amijansson_json_is_false,
	_amijansson_json_is_null,
	_amijansson_json_is_number,
	_amijansson_json_is_boolean,

	_amijansson_json_boolean_value,

	/* REFERENCE COUNT */
	_amijansson_json_incref,
	_amijansson_json_decref,

	/* TRUE, FALSE AND NULL */
	_amijansson_json_true,
	_amijansson_json_false,
	_amijansson_json_boolean,
	_amijansson_json_null,

	/* STRING */
	_amijansson_json_string,
	_amijansson_json_stringn,  	 
	_amijansson_json_string_nocheck,
	_amijansson_json_stringn_nocheck,
	_amijansson_json_string_value,
	_amijansson_json_string_length,	
	_amijansson_json_string_set,
	_amijansson_json_string_setn,	
	_amijansson_json_string_set_nocheck,
	_amijansson_json_string_setn_nocheck,
	_amijansson_json_sprintf,
	_amijansson_json_vsprintf,		

	/* NUMBER */	
	_amijansson_json_integer,
	_amijansson_json_integer_value,
	_amijansson_json_integer_set,
	_amijansson_json_real,
	_amijansson_json_real_value,
	_amijansson_json_real_set,
	_amijansson_json_number_value,
	
	/* ARRAY */
	_amijansson_json_array,
	_amijansson_json_array_size,
	_amijansson_json_array_get,
	_amijansson_json_array_set,
	_amijansson_json_array_set_new,
	_amijansson_json_array_append,
	_amijansson_json_array_append_new,
	_amijansson_json_array_insert,
	_amijansson_json_array_insert_new,
	_amijansson_json_array_remove,
	_amijansson_json_array_clear,
	_amijansson_json_array_extend,

	/* OBJECT */
	_amijansson_json_object,
	_amijansson_json_object_size,
	_amijansson_json_object_get,
	_amijansson_json_object_set,
	_amijansson_json_object_set_nocheck,
	_amijansson_json_object_set_new,
	_amijansson_json_object_set_new_nocheck,
	_amijansson_json_object_del,
	_amijansson_json_object_clear,
	_amijansson_json_object_update,
	_amijansson_json_object_update_existing,
	_amijansson_json_object_update_missing,			
	_amijansson_json_object_iter,
	_amijansson_json_object_iter_at,
	_amijansson_json_object_iter_next,
	_amijansson_json_object_iter_key,
	_amijansson_json_object_iter_value,
	_amijansson_json_object_iter_set,
	_amijansson_json_object_iter_set_new,
	_amijansson_json_object_key_to_iter,
	_amijansson_json_object_seed,

	/* ERROR REPORTING */	
	_amijansson_json_error_code,			
	
	/* ENCODING */
	_amijansson_json_dumps,
	_amijansson_json_dumpb,
	_amijansson_json_dumpf,
	_amijansson_json_dumpfd,
	_amijansson_json_dump_file,
	_amijansson_json_dump_callback,
	
	/* DECODING */
	_amijansson_json_loads,
	_amijansson_json_loadb,
	_amijansson_json_loadf,
	_amijansson_json_loadfd,
	_amijansson_json_load_file,
	_amijansson_json_load_callback,	
			
	/* BUILDING VALUES */			
	_amijansson_json_pack,
	_amijansson_json_pack_ex,
	_amijansson_json_vpack_ex,
	
	/* PARSING AND VALIDATING VALUES */	
	_amijansson_json_unpack,
	_amijansson_json_unpack_ex,
	_amijansson_json_vunpack_ex,
		
	/* EQUALITY */												
	_amijansson_json_equal,
		
	/* COPYING */																																				
	_amijansson_json_copy,
	_amijansson_json_deep_copy,																																																																							
																																																																																																								
	/* CUSTOM MEMORY ALLOCATION */
	_amijansson_json_set_alloc_funcs,
	_amijansson_json_get_alloc_funcs,
																																																																																																																																																																														
	(APTR) -1
};

#endif		/* #ifndef VECTORS_H */

