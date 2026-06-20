/* Automatically generated header! Do not edit! */

#ifndef _VBCCINLINE_GLIB_H
#define _VBCCINLINE_GLIB_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

GDateDay  __g_date_get_day(const GDate *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-640(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_get_day(__p0) __g_date_get_day((__p0))

void  __g_type_module_add_interface(GTypeModule *, GType , GType , const GInterfaceInfo *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5332(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_module_add_interface(__p0, __p1, __p2, __p3) __g_type_module_add_interface((__p0), (__p1), (__p2), (__p3))

void  __g_main_loop_quit(GMainLoop *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3772(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_loop_quit(__p0) __g_main_loop_quit((__p0))

gboolean  __g_atomic_int_compare_and_exchange(gint *, gint , gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-352(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_atomic_int_compare_and_exchange(__p0, __p1, __p2) __g_atomic_int_compare_and_exchange((__p0), (__p1), (__p2))

GSList * __g_slist_last(GSList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2788(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_last(__p0) __g_slist_last((__p0))

void  __g_allocator_free(GAllocator *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1744(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_allocator_free(__p0) __g_allocator_free((__p0))

GList * __g_list_insert_before(GList *, GList *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1468(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_insert_before(__p0, __p1, __p2) __g_list_insert_before((__p0), (__p1), (__p2))

guint  __g_idle_add(GSourceFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3796(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_idle_add(__p0, __p1) __g_idle_add((__p0), (__p1))

void  __g_assert_warning(const char *, const char *, const int , const char *, const char *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4252(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_assert_warning(__p0, __p1, __p2, __p3, __p4) __g_assert_warning((__p0), (__p1), (__p2), (__p3), (__p4))

void  __g_hook_destroy_link(GHookList *, GHook *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1108(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hook_destroy_link(__p0, __p1) __g_hook_destroy_link((__p0), (__p1))

gboolean  __g_markup_parse_context_parse(GMarkupParseContext *, const gchar *, gssize , GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1606(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_markup_parse_context_parse(__p0, __p1, __p2, __p3) __g_markup_parse_context_parse((__p0), (__p1), (__p2), (__p3))

void  __g_node_reverse_children(GNode *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1912(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_reverse_children(__p0) __g_node_reverse_children((__p0))

GType  __g_gtype_get_type() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5638(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_gtype_get_type() __g_gtype_get_type()

gint  __g_utf8_collate(const gchar *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3604(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_utf8_collate(__p0, __p1) __g_utf8_collate((__p0), (__p1))

void  __g_queue_insert_before(GQueue *, GList *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2278(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_insert_before(__p0, __p1, __p2) __g_queue_insert_before((__p0), (__p1), (__p2))

GIOStatus  __g_io_channel_shutdown(GIOChannel *, gboolean , GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3970(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_shutdown(__p0, __p1, __p2) __g_io_channel_shutdown((__p0), (__p1), (__p2))

GType  __g_type_register_static(GType , const gchar *, const GTypeInfo *, GTypeFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5242(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_register_static(__p0, __p1, __p2, __p3) __g_type_register_static((__p0), (__p1), (__p2), (__p3))

void  __g_get_current_time(GTimeVal *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4000(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_get_current_time(__p0) __g_get_current_time((__p0))

GString * __g_string_append_c(GString *, gchar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3148(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_string_append_c(__p0, __p1) __g_string_append_c((__p0), (__p1))

GIOStatus  __g_io_channel_flush(GIOChannel *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3838(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_flush(__p0, __p1) __g_io_channel_flush((__p0), (__p1))

gboolean  __g_key_file_load_from_data(GKeyFile *, const gchar *, gsize , GKeyFileFlags , GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1228(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_load_from_data(__p0, __p1, __p2, __p3, __p4) __g_key_file_load_from_data((__p0), (__p1), (__p2), (__p3), (__p4))

GTokenType  __g_scanner_cur_token(GScanner *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2560(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_scanner_cur_token(__p0) __g_scanner_cur_token((__p0))

void  __g_signal_query(guint , GSignalQuery *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4942(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_signal_query(__p0, __p1) __g_signal_query((__p0), (__p1))

void  __g_hook_insert_sorted(GHookList *, GHook *, GHookCompareFunc ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1126(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hook_insert_sorted(__p0, __p1, __p2) __g_hook_insert_sorted((__p0), (__p1), (__p2))

gboolean  __g_main_context_prepare(GMainContext *, gint *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3694(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_context_prepare(__p0, __p1) __g_main_context_prepare((__p0), (__p1))

GArray * __g_array_remove_range(GArray *, guint , guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-88(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_array_remove_range(__p0, __p1, __p2) __g_array_remove_range((__p0), (__p1), (__p2))

void  __g_queue_push_nth_link(GQueue *, gint , GList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2308(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_push_nth_link(__p0, __p1, __p2) __g_queue_push_nth_link((__p0), (__p1), (__p2))

guint  __g_date_get_sunday_week_of_year(const GDate *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-664(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_get_sunday_week_of_year(__p0) __g_date_get_sunday_week_of_year((__p0))

guint  __g_child_watch_add(GPid , GChildWatchFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4012(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_child_watch_add(__p0, __p1, __p2) __g_child_watch_add((__p0), (__p1), (__p2))

gboolean  __g_scanner_eof(GScanner *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2584(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_scanner_eof(__p0) __g_scanner_eof((__p0))

GList * __g_list_first(GList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1558(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_first(__p0) __g_list_first((__p0))

gpointer  __g_ptr_array_remove_index_fast(GPtrArray *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-136(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_ptr_array_remove_index_fast(__p0, __p1) __g_ptr_array_remove_index_fast((__p0), (__p1))

void  __g_dir_rewind(GDir *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-844(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_dir_rewind(__p0) __g_dir_rewind((__p0))

void  __g_ptr_array_foreach(GPtrArray *, GFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-178(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_ptr_array_foreach(__p0, __p1, __p2) __g_ptr_array_foreach((__p0), (__p1), (__p2))

gint  __g_ascii_strncasecmp(const gchar *, const gchar *, gsize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2968(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_ascii_strncasecmp(__p0, __p1, __p2) __g_ascii_strncasecmp((__p0), (__p1), (__p2))

GString * __g_string_insert(GString *, gssize , const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3184(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_string_insert(__p0, __p1, __p2) __g_string_insert((__p0), (__p1), (__p2))

gboolean  __g_signal_accumulator_true_handled(GSignalInvocationHint *, GValue *, const GValue *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5074(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_signal_accumulator_true_handled(__p0, __p1, __p2, __p3) __g_signal_accumulator_true_handled((__p0), (__p1), (__p2), (__p3))

gpointer  __g_boxed_copy(GType , gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4270(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_boxed_copy(__p0, __p1) __g_boxed_copy((__p0), (__p1))

GString * __g_string_prepend_unichar(GString *, gunichar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3172(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_string_prepend_unichar(__p0, __p1) __g_string_prepend_unichar((__p0), (__p1))

gboolean  __g_unichar_isxdigit(gunichar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3370(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_unichar_isxdigit(__p0) __g_unichar_isxdigit((__p0))

gint * __g_key_file_get_integer_list(GKeyFile *, const gchar *, const gchar *, gsize *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1372(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_get_integer_list(__p0, __p1, __p2, __p3, __p4) __g_key_file_get_integer_list((__p0), (__p1), (__p2), (__p3), (__p4))

gchar * __g_utf8_offset_to_pointer(const gchar *, glong ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3460(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_utf8_offset_to_pointer(__p0, __p1) __g_utf8_offset_to_pointer((__p0), (__p1))

gpointer  __g_type_instance_get_private(GTypeInstance *, GType ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5296(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_instance_get_private(__p0, __p1) __g_type_instance_get_private((__p0), (__p1))

void  __g_slist_free(GSList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2674(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_free(__p0) __g_slist_free((__p0))

void  __g_key_file_set_locale_string_list(GKeyFile *, const gchar *, const gchar *, const gchar *, const gchar *const *, gsize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1354(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_set_locale_string_list(__p0, __p1, __p2, __p3, __p4, __p5) __g_key_file_set_locale_string_list((__p0), (__p1), (__p2), (__p3), (__p4), (__p5))

guint8  __g_date_get_sunday_weeks_in_year(GDateYear ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-790(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_get_sunday_weeks_in_year(__p0) __g_date_get_sunday_weeks_in_year((__p0))

void  __g_queue_unlink(GQueue *, GList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2356(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_unlink(__p0, __p1) __g_queue_unlink((__p0), (__p1))

gboolean  __g_date_valid_dmy(GDateDay , GDateMonth , GDateYear ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-616(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_valid_dmy(__p0, __p1, __p2) __g_date_valid_dmy((__p0), (__p1), (__p2))

void  __g_hook_insert_before(GHookList *, GHook *, GHook *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1120(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hook_insert_before(__p0, __p1, __p2) __g_hook_insert_before((__p0), (__p1), (__p2))

gchar * __g_locale_to_utf8(const gchar *, gssize , gsize *, gsize *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4036(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_locale_to_utf8(__p0, __p1, __p2, __p3, __p4) __g_locale_to_utf8((__p0), (__p1), (__p2), (__p3), (__p4))

void  __g_datalist_id_set_data_full(GData **, GQuark , gpointer , GDestroyNotify ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-490(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_datalist_id_set_data_full(__p0, __p1, __p2, __p3) __g_datalist_id_set_data_full((__p0), (__p1), (__p2), (__p3))

void  __g_object_set_data(GObject *, const gchar *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4588(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_set_data(__p0, __p1, __p2) __g_object_set_data((__p0), (__p1), (__p2))

gpointer  __g_queue_pop_nth(GQueue *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2236(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_pop_nth(__p0, __p1) __g_queue_pop_nth((__p0), (__p1))

GTuples * __g_relation_select(GRelation *, gconstpointer , gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2488(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_relation_select(__p0, __p1, __p2) __g_relation_select((__p0), (__p1), (__p2))

void  __g_source_set_priority(GSource *, gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4132(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_source_set_priority(__p0, __p1) __g_source_set_priority((__p0), (__p1))

gboolean  __g_source_remove(guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4198(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_source_remove(__p0) __g_source_remove((__p0))

gdouble  __g_strtod(const gchar *, gchar **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2920(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_strtod(__p0, __p1) __g_strtod((__p0), (__p1))

void  __g_key_file_set_integer(GKeyFile *, const gchar *, const gchar *, gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1330(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_set_integer(__p0, __p1, __p2, __p3) __g_key_file_set_integer((__p0), (__p1), (__p2), (__p3))

gpointer  __g_realloc(gpointer , gulong ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1654(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_realloc(__p0, __p1) __g_realloc((__p0), (__p1))

GType  __g_value_get_gtype(const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5650(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_get_gtype(__p0) __g_value_get_gtype((__p0))

gboolean  __g_date_is_last_of_month(const GDate *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-730(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_is_last_of_month(__p0) __g_date_is_last_of_month((__p0))

GSList * __g_slist_append(GSList *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2686(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_append(__p0, __p1) __g_slist_append((__p0), (__p1))

gchar * __g_file_read_link(const gchar *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-916(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_file_read_link(__p0, __p1) __g_file_read_link((__p0), (__p1))

void  __g_queue_insert_after(GQueue *, GList *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2284(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_insert_after(__p0, __p1, __p2) __g_queue_insert_after((__p0), (__p1), (__p2))

GParamSpec * __g_param_spec_long(const gchar *, const gchar *, const gchar *, glong , glong , glong , GParamFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4816(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_long(__p0, __p1, __p2, __p3, __p4, __p5, __p6) __g_param_spec_long((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6))

void  __g_ptr_array_sort_with_data(GPtrArray *, GCompareDataFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-172(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_ptr_array_sort_with_data(__p0, __p1, __p2) __g_ptr_array_sort_with_data((__p0), (__p1), (__p2))

GDate * __g_date_new_dmy(GDateDay , GDateMonth , GDateYear ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-562(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_new_dmy(__p0, __p1, __p2) __g_date_new_dmy((__p0), (__p1), (__p2))

void  __g_value_set_gtype(GValue *, GType ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5644(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_set_gtype(__p0, __p1) __g_value_set_gtype((__p0), (__p1))

gboolean  __g_unichar_isupper(gunichar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3364(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_unichar_isupper(__p0) __g_unichar_isupper((__p0))

gfloat  __g_value_get_float(const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5584(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_get_float(__p0) __g_value_get_float((__p0))

gint  __g_ascii_digit_value(gchar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2836(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_ascii_digit_value(__p0) __g_ascii_digit_value((__p0))

gboolean  __g_date_valid_weekday(GDateWeekday ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-604(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_valid_weekday(__p0) __g_date_valid_weekday((__p0))

void  __g_date_add_days(GDate *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-736(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_add_days(__p0, __p1) __g_date_add_days((__p0), (__p1))

guint  __g_type_depth(GType ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5134(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_depth(__p0) __g_type_depth((__p0))

GList * __g_list_reverse(GList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1504(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_reverse(__p0) __g_list_reverse((__p0))

GList * __g_list_sort_with_data(GList *, GCompareDataFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1582(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_sort_with_data(__p0, __p1, __p2) __g_list_sort_with_data((__p0), (__p1), (__p2))

gchar * __g_string_free(GString *, gboolean ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3094(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_string_free(__p0, __p1) __g_string_free((__p0), (__p1))

GParamSpec * __g_param_spec_pointer(const gchar *, const gchar *, const gchar *, GParamFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4888(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_pointer(__p0, __p1, __p2, __p3) __g_param_spec_pointer((__p0), (__p1), (__p2), (__p3))

guint  __g_value_get_uint(const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5524(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_get_uint(__p0) __g_value_get_uint((__p0))

GSList * __g_slist_prepend(GSList *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2692(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_prepend(__p0, __p1) __g_slist_prepend((__p0), (__p1))

GNode * __g_node_copy_deep(GNode *, GCopyFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1828(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_copy_deep(__p0, __p1, __p2) __g_node_copy_deep((__p0), (__p1), (__p2))

gulong  __g_signal_connect_object(gpointer , const gchar *, GCallback , gpointer , GConnectFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4648(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_signal_connect_object(__p0, __p1, __p2, __p3, __p4) __g_signal_connect_object((__p0), (__p1), (__p2), (__p3), (__p4))

void  __g_value_set_float(GValue *, gfloat ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5578(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_set_float(__p0, __p1) __g_value_set_float((__p0), (__p1))

gpointer  __g_list_nth_data(GList *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1588(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_nth_data(__p0, __p1) __g_list_nth_data((__p0), (__p1))

void  __g_option_context_free(GOptionContext *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1972(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_option_context_free(__p0) __g_option_context_free((__p0))

GArray * __g_array_prepend_vals(GArray *, gconstpointer , guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-58(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_array_prepend_vals(__p0, __p1, __p2) __g_array_prepend_vals((__p0), (__p1), (__p2))

gchar * __g_filename_from_uri(const gchar *, gchar **, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4060(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_filename_from_uri(__p0, __p1, __p2) __g_filename_from_uri((__p0), (__p1), (__p2))

void  __g_source_set_can_recurse(GSource *, gboolean ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4144(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_source_set_can_recurse(__p0, __p1) __g_source_set_can_recurse((__p0), (__p1))

void  __g_tuples_destroy(GTuples *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2506(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_tuples_destroy(__p0) __g_tuples_destroy((__p0))

GHashTable * __g_hash_table_ref(GHashTable *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1018(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hash_table_ref(__p0) __g_hash_table_ref((__p0))

void  __g_key_file_remove_comment(GKeyFile *, const gchar *, const gchar *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1396(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_remove_comment(__p0, __p1, __p2, __p3) __g_key_file_remove_comment((__p0), (__p1), (__p2), (__p3))

GArray * __g_array_insert_vals(GArray *, guint , gconstpointer , guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-64(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_array_insert_vals(__p0, __p1, __p2, __p3) __g_array_insert_vals((__p0), (__p1), (__p2), (__p3))

guint8  __g_date_get_days_in_month(GDateMonth , GDateYear ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-778(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_get_days_in_month(__p0, __p1) __g_date_get_days_in_month((__p0), (__p1))

guint8  __g_date_get_monday_weeks_in_year(GDateYear ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-784(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_get_monday_weeks_in_year(__p0) __g_date_get_monday_weeks_in_year((__p0))

void  __g_datalist_init(GData **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-472(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_datalist_init(__p0) __g_datalist_init((__p0))

GSource * __g_main_context_find_source_by_user_data(GMainContext *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3664(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_context_find_source_by_user_data(__p0, __p1) __g_main_context_find_source_by_user_data((__p0), (__p1))

gchar * __g_strdup_vprintf(const gchar *, va_list ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2992(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_strdup_vprintf(__p0, __p1) __g_strdup_vprintf((__p0), (__p1))

void  __g_random_set_seed(guint32 ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2434(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_random_set_seed(__p0) __g_random_set_seed((__p0))

void  __g_key_file_set_boolean_list(GKeyFile *, const gchar *, const gchar *, gboolean *, gsize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1366(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_set_boolean_list(__p0, __p1, __p2, __p3, __p4) __g_key_file_set_boolean_list((__p0), (__p1), (__p2), (__p3), (__p4))

gboolean  __g_source_remove_by_funcs_user_data(GSourceFuncs *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4210(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_source_remove_by_funcs_user_data(__p0, __p1) __g_source_remove_by_funcs_user_data((__p0), (__p1))

gboolean  __g_param_value_convert(GParamSpec *, const GValue *, GValue *, gboolean ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4726(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_value_convert(__p0, __p1, __p2, __p3) __g_param_value_convert((__p0), (__p1), (__p2), (__p3))

GParamSpec * __g_param_spec_uchar(const gchar *, const gchar *, const gchar *, guint8 , guint8 , guint8 , GParamFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4792(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_uchar(__p0, __p1, __p2, __p3, __p4, __p5, __p6) __g_param_spec_uchar((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6))

void  __g_atomic_int_add(gint *, gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-346(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_atomic_int_add(__p0, __p1) __g_atomic_int_add((__p0), (__p1))

gint  __g_value_get_enum(const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4354(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_get_enum(__p0) __g_value_get_enum((__p0))

GParamSpec * __g_object_class_find_property(GObjectClass *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4408(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_class_find_property(__p0, __p1) __g_object_class_find_property((__p0), (__p1))

gpointer  __g_slist_nth_data(GSList *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2818(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_nth_data(__p0, __p1) __g_slist_nth_data((__p0), (__p1))

gunichar * __g_utf8_to_ucs4_fast(const gchar *, glong , glong *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3532(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_utf8_to_ucs4_fast(__p0, __p1, __p2) __g_utf8_to_ucs4_fast((__p0), (__p1), (__p2))

void  __g_type_plugin_complete_type_info(GTypePlugin *, GType , GTypeInfo *, GTypeValueTable *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5368(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_plugin_complete_type_info(__p0, __p1, __p2, __p3) __g_type_plugin_complete_type_info((__p0), (__p1), (__p2), (__p3))

void  __g_main_context_set_poll_func(GMainContext *, GPollFunc ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3724(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_context_set_poll_func(__p0, __p1) __g_main_context_set_poll_func((__p0), (__p1))

void  __g_io_channel_set_line_term(GIOChannel *, const gchar *, gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3964(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_set_line_term(__p0, __p1, __p2) __g_io_channel_set_line_term((__p0), (__p1), (__p2))

void  __g_queue_push_tail_link(GQueue *, GList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2302(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_push_tail_link(__p0, __p1) __g_queue_push_tail_link((__p0), (__p1))

guint  __g_hash_table_foreach_steal(GHashTable *, GHRFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1006(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hash_table_foreach_steal(__p0, __p1, __p2) __g_hash_table_foreach_steal((__p0), (__p1), (__p2))

GList * __g_list_find(GList *, gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1528(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_find(__p0, __p1) __g_list_find((__p0), (__p1))

gchar * __g_utf16_to_utf8(const gunichar2 *, glong , glong *, glong *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3544(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_utf16_to_utf8(__p0, __p1, __p2, __p3, __p4) __g_utf16_to_utf8((__p0), (__p1), (__p2), (__p3), (__p4))

guint32  __g_date_get_julian(const GDate *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-646(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_get_julian(__p0) __g_date_get_julian((__p0))

void  __g_object_interface_install_property(gpointer , GParamSpec *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4426(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_interface_install_property(__p0, __p1) __g_object_interface_install_property((__p0), (__p1))

gboolean  __g_ptr_array_remove(GPtrArray *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-142(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_ptr_array_remove(__p0, __p1) __g_ptr_array_remove((__p0), (__p1))

void  __g_async_queue_push(GAsyncQueue *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-280(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_async_queue_push(__p0, __p1) __g_async_queue_push((__p0), (__p1))

void  __g_mem_chunk_print(GMemChunk *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1720(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_mem_chunk_print(__p0) __g_mem_chunk_print((__p0))

void  __g_date_to_struct_tm(const GDate *, struct tm *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-808(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_to_struct_tm(__p0, __p1) __g_date_to_struct_tm((__p0), (__p1))

void  __g_signal_handler_block(gpointer , gulong ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5014(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_signal_handler_block(__p0, __p1) __g_signal_handler_block((__p0), (__p1))

void  __g_key_file_set_comment(GKeyFile *, const gchar *, const gchar *, const gchar *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1384(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_set_comment(__p0, __p1, __p2, __p3, __p4) __g_key_file_set_comment((__p0), (__p1), (__p2), (__p3), (__p4))

void  __g_option_group_add_entries(GOptionGroup *, const GOptionEntry *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2056(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_option_group_add_entries(__p0, __p1) __g_option_group_add_entries((__p0), (__p1))

GOptionContext * __g_option_context_new(const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1966(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_option_context_new(__p0) __g_option_context_new((__p0))

void  __g_object_get_valist(GObject *, const gchar *, va_list ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4462(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_get_valist(__p0, __p1, __p2) __g_object_get_valist((__p0), (__p1), (__p2))

GList * __g_list_remove(GList *, gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1480(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_remove(__p0, __p1) __g_list_remove((__p0), (__p1))

gboolean  __g_pattern_match(GPatternSpec *, guint , const gchar *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2092(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_pattern_match(__p0, __p1, __p2, __p3) __g_pattern_match((__p0), (__p1), (__p2), (__p3))

GArray * __g_array_append_vals(GArray *, gconstpointer , guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-52(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_array_append_vals(__p0, __p1, __p2) __g_array_append_vals((__p0), (__p1), (__p2))

guint  __g_hash_table_foreach_remove(GHashTable *, GHRFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1000(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hash_table_foreach_remove(__p0, __p1, __p2) __g_hash_table_foreach_remove((__p0), (__p1), (__p2))

void  __g_scanner_scope_foreach_symbol(GScanner *, guint , GHFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2614(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_scanner_scope_foreach_symbol(__p0, __p1, __p2, __p3) __g_scanner_scope_foreach_symbol((__p0), (__p1), (__p2), (__p3))

gpointer  __g_mem_chunk_alloc0(GMemChunk *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1696(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_mem_chunk_alloc0(__p0) __g_mem_chunk_alloc0((__p0))

void  __g_boxed_free(GType , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4276(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_boxed_free(__p0, __p1) __g_boxed_free((__p0), (__p1))

void  __g_enum_complete_type_info(GType , GTypeInfo *, const GEnumValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4384(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_enum_complete_type_info(__p0, __p1, __p2) __g_enum_complete_type_info((__p0), (__p1), (__p2))

gpointer  __g_object_steal_qdata(GObject *, GQuark ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4576(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_steal_qdata(__p0, __p1) __g_object_steal_qdata((__p0), (__p1))

gdouble  __g_random_double() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2452(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_random_double() __g_random_double()

gboolean  __g_get_filename_charsets(G_CONST_RETURN ***charsets) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4006(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_get_filename_charsets(__p0) __g_get_filename_charsets((__p0))

gpointer  __g_atomic_pointer_get(volatile gpointer *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-376(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_atomic_pointer_get(__p0) __g_atomic_pointer_get((__p0))

GQuark  __g_io_channel_error_quark() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3832(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_error_quark() __g_io_channel_error_quark()

gboolean  __g_type_is_a(GType , GType ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5146(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_is_a(__p0, __p1) __g_type_is_a((__p0), (__p1))

GList * __g_queue_find_custom(GQueue *, gconstpointer , GCompareFunc ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2194(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_find_custom(__p0, __p1, __p2) __g_queue_find_custom((__p0), (__p1), (__p2))

gchar * __g_strjoinv(const gchar *, gchar **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3040(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_strjoinv(__p0, __p1) __g_strjoinv((__p0), (__p1))

GMainContext * __g_main_loop_get_context(GMainLoop *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3754(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_loop_get_context(__p0) __g_main_loop_get_context((__p0))

gboolean  __g_shell_parse_argv(const gchar *, gint *, gchar ***, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2650(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_shell_parse_argv(__p0, __p1, __p2, __p3) __g_shell_parse_argv((__p0), (__p1), (__p2), (__p3))

gpointer  __g_async_queue_try_pop_unlocked(GAsyncQueue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-310(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_async_queue_try_pop_unlocked(__p0) __g_async_queue_try_pop_unlocked((__p0))

void  __g_object_thaw_notify(GObject *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4492(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_thaw_notify(__p0) __g_object_thaw_notify((__p0))

gchar * __g_key_file_get_value(GKeyFile *, const gchar *, const gchar *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1276(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_get_value(__p0, __p1, __p2, __p3) __g_key_file_get_value((__p0), (__p1), (__p2), (__p3))

gpointer  __g_hash_table_lookup(GHashTable *, gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-976(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hash_table_lookup(__p0, __p1) __g_hash_table_lookup((__p0), (__p1))

void  __g_signal_handler_disconnect(gpointer , gulong ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5026(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_signal_handler_disconnect(__p0, __p1) __g_signal_handler_disconnect((__p0), (__p1))

void  __g_option_context_set_ignore_unknown_options(GOptionContext *, gboolean ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1990(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_option_context_set_ignore_unknown_options(__p0, __p1) __g_option_context_set_ignore_unknown_options((__p0), (__p1))

void  __g_value_set_static_string(GValue *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5608(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_set_static_string(__p0, __p1) __g_value_set_static_string((__p0), (__p1))

GList * __g_list_alloc() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1426(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_alloc() __g_list_alloc()

gchar ** __g_key_file_get_locale_string_list(GKeyFile *, const gchar *, const gchar *, const gchar *, gsize *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1348(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_get_locale_string_list(__p0, __p1, __p2, __p3, __p4, __p5) __g_key_file_get_locale_string_list((__p0), (__p1), (__p2), (__p3), (__p4), (__p5))

guint  __g_scanner_cur_position(GScanner *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2578(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_scanner_cur_position(__p0) __g_scanner_cur_position((__p0))

void  __g_tree_foreach(GTree *, GTraverseFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3280(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_tree_foreach(__p0, __p1, __p2) __g_tree_foreach((__p0), (__p1), (__p2))

GValueArray * __g_value_array_remove(GValueArray *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5452(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_array_remove(__p0, __p1) __g_value_array_remove((__p0), (__p1))

GType * __g_type_children(GType , guint *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5212(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_children(__p0, __p1) __g_type_children((__p0), (__p1))

GByteArray * __g_byte_array_remove_range(GByteArray *, guint , guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-232(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_byte_array_remove_range(__p0, __p1, __p2) __g_byte_array_remove_range((__p0), (__p1), (__p2))

gboolean  __g_unichar_iswide(gunichar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3388(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_unichar_iswide(__p0) __g_unichar_iswide((__p0))

void  __g_key_file_set_value(GKeyFile *, const gchar *, const gchar *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1282(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_set_value(__p0, __p1, __p2, __p3) __g_key_file_set_value((__p0), (__p1), (__p2), (__p3))

void  __g_queue_remove(GQueue *, gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2266(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_remove(__p0, __p1) __g_queue_remove((__p0), (__p1))

gchar * __g_utf8_collate_key(const gchar *, gssize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3610(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_utf8_collate_key(__p0, __p1) __g_utf8_collate_key((__p0), (__p1))

void  __g_type_init() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5098(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_init() __g_type_init()

gulong  __g_signal_handler_find(gpointer , GSignalMatchType , guint , GQuark , GClosure *, gpointer , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5038(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_signal_handler_find(__p0, __p1, __p2, __p3, __p4, __p5, __p6) __g_signal_handler_find((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6))

VOID  __GLib_SetExit(void (*)(int)) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-28(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define GLib_SetExit(__p0) __GLib_SetExit((__p0))

guint  __g_signal_newv(const gchar *, GType , GSignalFlags , GClosure *, GSignalAccumulator , gpointer , GSignalCMarshaller , GType , guint , GType *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4918(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_signal_newv(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7, __p8, __p9) __g_signal_newv((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7), (__p8), (__p9))

gboolean  __g_file_test(const gchar *, GFileTest ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-904(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_file_test(__p0, __p1) __g_file_test((__p0), (__p1))

gboolean  __g_io_channel_get_close_on_unref(GIOChannel *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3862(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_get_close_on_unref(__p0) __g_io_channel_get_close_on_unref((__p0))

GFileError  __g_file_error_from_errno(gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-898(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_file_error_from_errno(__p0) __g_file_error_from_errno((__p0))

GSource * __g_io_create_watch(GIOChannel *, GIOCondition ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3994(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_create_watch(__p0, __p1) __g_io_create_watch((__p0), (__p1))

void  __g_type_add_interface_static(GType , GType , const GInterfaceInfo *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5266(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_add_interface_static(__p0, __p1, __p2) __g_type_add_interface_static((__p0), (__p1), (__p2))

gsize  __g_io_channel_get_buffer_size(GIOChannel *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3850(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_get_buffer_size(__p0) __g_io_channel_get_buffer_size((__p0))

GArray * __g_array_set_size(GArray *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-70(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_array_set_size(__p0, __p1) __g_array_set_size((__p0), (__p1))

GQuark  __g_shell_error_quark() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2632(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_shell_error_quark() __g_shell_error_quark()

GString * __g_string_erase(GString *, gssize , gssize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3202(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_string_erase(__p0, __p1, __p2) __g_string_erase((__p0), (__p1), (__p2))

GIOStatus  __g_io_channel_write_chars(GIOChannel *, const gchar *, gssize , gsize *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3982(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_write_chars(__p0, __p1, __p2, __p3, __p4) __g_io_channel_write_chars((__p0), (__p1), (__p2), (__p3), (__p4))

guint  __g_log_set_handler(const gchar *, GLogLevelFlags , GLogFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1756(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_log_set_handler(__p0, __p1, __p2, __p3) __g_log_set_handler((__p0), (__p1), (__p2), (__p3))

GHook * __g_hook_ref(GHookList *, GHook *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1090(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hook_ref(__p0, __p1) __g_hook_ref((__p0), (__p1))

gunichar  __g_unichar_totitle(gunichar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3406(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_unichar_totitle(__p0) __g_unichar_totitle((__p0))

void  __g_signal_override_class_closure(guint , GType , GClosure *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5062(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_signal_override_class_closure(__p0, __p1, __p2) __g_signal_override_class_closure((__p0), (__p1), (__p2))

void  __g_source_unref(GSource *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4114(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_source_unref(__p0) __g_source_unref((__p0))

guint  __g_strv_length(gchar **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3058(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_strv_length(__p0) __g_strv_length((__p0))

gboolean  __g_direct_equal(gconstpointer , gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1060(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_direct_equal(__p0, __p1) __g_direct_equal((__p0), (__p1))

gpointer  __g_tuples_index(GTuples *, gint , gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2512(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_tuples_index(__p0, __p1, __p2) __g_tuples_index((__p0), (__p1), (__p2))

gchar  __g_ascii_tolower(gchar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2824(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_ascii_tolower(__p0) __g_ascii_tolower((__p0))

gchar * __g_ascii_formatd(gchar *, gint , const gchar *, gdouble ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2944(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_ascii_formatd(__p0, __p1, __p2, __p3) __g_ascii_formatd((__p0), (__p1), (__p2), (__p3))

void  __g_object_unref(gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4516(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_unref(__p0) __g_object_unref((__p0))

gboolean  __g_param_value_validate(GParamSpec *, GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4720(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_value_validate(__p0, __p1) __g_param_value_validate((__p0), (__p1))

GType  __g_type_module_register_flags(GTypeModule *, const gchar *, const GFlagsValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5344(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_module_register_flags(__p0, __p1, __p2) __g_type_module_register_flags((__p0), (__p1), (__p2))

void  __g_date_set_year(GDate *, GDateYear ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-706(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_set_year(__p0, __p1) __g_date_set_year((__p0), (__p1))

gpointer  __g_type_default_interface_peek(GType ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5200(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_default_interface_peek(__p0) __g_type_default_interface_peek((__p0))

void  __g_dataset_foreach(gconstpointer , GDataForeachFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-550(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_dataset_foreach(__p0, __p1, __p2) __g_dataset_foreach((__p0), (__p1), (__p2))

GPtrArray * __g_ptr_array_new() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-106(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_ptr_array_new() __g_ptr_array_new()

void  __g_main_loop_unref(GMainLoop *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3790(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_loop_unref(__p0) __g_main_loop_unref((__p0))

void  __g_hook_list_init(GHookList *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1066(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hook_list_init(__p0, __p1) __g_hook_list_init((__p0), (__p1))

GList * __g_queue_peek_tail_link(GQueue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2338(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_peek_tail_link(__p0) __g_queue_peek_tail_link((__p0))

GClosure * __g_cclosure_new_object(GCallback , GObject *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4612(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_cclosure_new_object(__p0, __p1) __g_cclosure_new_object((__p0), (__p1))

GValue * __g_value_reset(GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5392(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_reset(__p0) __g_value_reset((__p0))

void  __g_queue_push_head_link(GQueue *, GList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2296(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_push_head_link(__p0, __p1) __g_queue_push_head_link((__p0), (__p1))

gint  __g_async_queue_length(GAsyncQueue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-328(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_async_queue_length(__p0) __g_async_queue_length((__p0))

void  __g_queue_delete_link(GQueue *, GList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2362(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_delete_link(__p0, __p1) __g_queue_delete_link((__p0), (__p1))

void  __g_object_class_install_property(GObjectClass *, guint , GParamSpec *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4402(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_class_install_property(__p0, __p1, __p2) __g_object_class_install_property((__p0), (__p1), (__p2))

gdouble  __g_random_double_range(gdouble , gdouble ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2458(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_random_double_range(__p0, __p1) __g_random_double_range((__p0), (__p1))

void  __g_option_group_set_translate_func(GOptionGroup *, GTranslateFunc , gpointer , GDestroyNotify ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2062(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_option_group_set_translate_func(__p0, __p1, __p2, __p3) __g_option_group_set_translate_func((__p0), (__p1), (__p2), (__p3))

void  __g_main_context_release(GMainContext *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3712(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_context_release(__p0) __g_main_context_release((__p0))

void  __g_pattern_spec_free(GPatternSpec *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2080(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_pattern_spec_free(__p0) __g_pattern_spec_free((__p0))

gboolean  __g_key_file_has_key(GKeyFile *, const gchar *, const gchar *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1270(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_has_key(__p0, __p1, __p2, __p3) __g_key_file_has_key((__p0), (__p1), (__p2), (__p3))

gboolean  __g_option_context_get_help_enabled(GOptionContext *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1984(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_option_context_get_help_enabled(__p0) __g_option_context_get_help_enabled((__p0))

guint  __g_scanner_set_scope(GScanner *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2590(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_scanner_set_scope(__p0, __p1) __g_scanner_set_scope((__p0), (__p1))

gint  __g_relation_delete(GRelation *, gconstpointer , gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2482(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_relation_delete(__p0, __p1, __p2) __g_relation_delete((__p0), (__p1), (__p2))

guint  __g_signal_handlers_unblock_matched(gpointer , GSignalMatchType , guint , GQuark , GClosure *, gpointer , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5050(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_signal_handlers_unblock_matched(__p0, __p1, __p2, __p3, __p4, __p5, __p6) __g_signal_handlers_unblock_matched((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6))

gsize  __g_strlcpy(gchar *, const gchar *, gsize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2878(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_strlcpy(__p0, __p1, __p2) __g_strlcpy((__p0), (__p1), (__p2))

GParamSpec * __g_param_spec_get_redirect_target(GParamSpec *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4702(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_get_redirect_target(__p0) __g_param_spec_get_redirect_target((__p0))

void  __g_value_set_int(GValue *, gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5506(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_set_int(__p0, __p1) __g_value_set_int((__p0), (__p1))

guint8 * __g_byte_array_free(GByteArray *, gboolean ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-196(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_byte_array_free(__p0, __p1) __g_byte_array_free((__p0), (__p1))

GList * __g_list_append(GList *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1444(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_append(__p0, __p1) __g_list_append((__p0), (__p1))

GNode * __g_node_prepend(GNode *, GNode *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1858(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_prepend(__p0, __p1) __g_node_prepend((__p0), (__p1))

void  __g_dir_close(GDir *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-850(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_dir_close(__p0) __g_dir_close((__p0))

gpointer  __g_try_malloc(gulong ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1666(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_try_malloc(__p0) __g_try_malloc((__p0))

gboolean  __g_option_context_parse(GOptionContext *, gint *, gchar ***, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2008(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_option_context_parse(__p0, __p1, __p2, __p3) __g_option_context_parse((__p0), (__p1), (__p2), (__p3))

void  __g_value_set_long(GValue *, glong ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5530(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_set_long(__p0, __p1) __g_value_set_long((__p0), (__p1))

void  __g_scanner_input_file(GScanner *, gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2530(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_scanner_input_file(__p0, __p1) __g_scanner_input_file((__p0), (__p1))

int  __g_main_depth() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3748(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_depth() __g_main_depth()

void  __g_mem_chunk_clean(GMemChunk *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1708(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_mem_chunk_clean(__p0) __g_mem_chunk_clean((__p0))

void  __g_tree_destroy(GTree *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3238(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_tree_destroy(__p0) __g_tree_destroy((__p0))

guint  __g_node_depth(GNode *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1882(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_depth(__p0) __g_node_depth((__p0))

GClosure * __g_closure_new_object(guint , GObject *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4624(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_closure_new_object(__p0, __p1) __g_closure_new_object((__p0), (__p1))

void  __g_cache_destroy(GCache *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-394(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_cache_destroy(__p0) __g_cache_destroy((__p0))

GType  __g_boxed_type_register_static(const gchar *, GBoxedCopyFunc , GBoxedFreeFunc ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4306(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_boxed_type_register_static(__p0, __p1, __p2) __g_boxed_type_register_static((__p0), (__p1), (__p2))

void  __g_return_if_fail_warning(const char *, const char *, const char *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4246(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_return_if_fail_warning(__p0, __p1, __p2) __g_return_if_fail_warning((__p0), (__p1), (__p2))

gulong  __g_signal_connect_data(gpointer , const gchar *, GCallback , gpointer , GClosureNotify , GConnectFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5008(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_signal_connect_data(__p0, __p1, __p2, __p3, __p4, __p5) __g_signal_connect_data((__p0), (__p1), (__p2), (__p3), (__p4), (__p5))

void  __g_signal_remove_emission_hook(guint , gulong ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4984(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_signal_remove_emission_hook(__p0, __p1) __g_signal_remove_emission_hook((__p0), (__p1))

void  __g_async_queue_unref(GAsyncQueue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-274(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_async_queue_unref(__p0) __g_async_queue_unref((__p0))

void  __g_cache_remove(GCache *, gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-406(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_cache_remove(__p0, __p1) __g_cache_remove((__p0), (__p1))

gchar * __g_strdup(const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2986(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_strdup(__p0) __g_strdup((__p0))

guint  __g_node_max_height(GNode *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1900(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_max_height(__p0) __g_node_max_height((__p0))

void  __g_date_set_day(GDate *, GDateDay ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-700(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_set_day(__p0, __p1) __g_date_set_day((__p0), (__p1))

void  __g_main_context_add_poll(GMainContext *, GPollFD *, gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3628(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_context_add_poll(__p0, __p1, __p2) __g_main_context_add_poll((__p0), (__p1), (__p2))

void  __g_hash_table_unref(GHashTable *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1024(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hash_table_unref(__p0) __g_hash_table_unref((__p0))

gboolean  __g_unichar_isalpha(gunichar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3316(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_unichar_isalpha(__p0) __g_unichar_isalpha((__p0))

void  __g_tree_replace(GTree *, gpointer , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3250(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_tree_replace(__p0, __p1, __p2) __g_tree_replace((__p0), (__p1), (__p2))

GString * __g_string_insert_c(GString *, gssize , gchar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3190(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_string_insert_c(__p0, __p1, __p2) __g_string_insert_c((__p0), (__p1), (__p2))

void  __g_datalist_foreach(GData **, GDataForeachFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-502(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_datalist_foreach(__p0, __p1, __p2) __g_datalist_foreach((__p0), (__p1), (__p2))

gboolean  __g_key_file_has_group(GKeyFile *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1264(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_has_group(__p0, __p1) __g_key_file_has_group((__p0), (__p1))

void  __g_value_take_param(GValue *, GParamSpec *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4774(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_take_param(__p0, __p1) __g_value_take_param((__p0), (__p1))

GHook * __g_hook_find(GHookList *, gboolean , GHookFindFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1138(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hook_find(__p0, __p1, __p2, __p3) __g_hook_find((__p0), (__p1), (__p2), (__p3))

GIOChannelError  __g_io_channel_error_from_errno(gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3826(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_error_from_errno(__p0) __g_io_channel_error_from_errno((__p0))

GValueArray * __g_value_array_append(GValueArray *, const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5440(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_array_append(__p0, __p1) __g_value_array_append((__p0), (__p1))

gboolean  __g_date_valid_month(GDateMonth ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-592(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_valid_month(__p0) __g_date_valid_month((__p0))

void  __g_hook_list_marshal(GHookList *, gboolean , GHookMarshaller , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1192(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hook_list_marshal(__p0, __p1, __p2, __p3) __g_hook_list_marshal((__p0), (__p1), (__p2), (__p3))

GQuark  __g_quark_from_static_string(const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2128(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_quark_from_static_string(__p0) __g_quark_from_static_string((__p0))

void  __g_node_unlink(GNode *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1822(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_unlink(__p0) __g_node_unlink((__p0))

GString * __g_string_append_unichar(GString *, gunichar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3154(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_string_append_unichar(__p0, __p1) __g_string_append_unichar((__p0), (__p1))

void  __g_mem_chunk_free(GMemChunk *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1702(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_mem_chunk_free(__p0, __p1) __g_mem_chunk_free((__p0), (__p1))

gboolean  __g_date_is_first_of_month(const GDate *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-724(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_is_first_of_month(__p0) __g_date_is_first_of_month((__p0))

guint  __g_node_n_children(GNode *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1918(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_n_children(__p0) __g_node_n_children((__p0))

gint32  __g_rand_int_range(GRand *, gint32 , gint32 ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2416(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_rand_int_range(__p0, __p1, __p2) __g_rand_int_range((__p0), (__p1), (__p2))

GString * __g_string_new_len(const gchar *, gssize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3082(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_string_new_len(__p0, __p1) __g_string_new_len((__p0), (__p1))

void  __g_scanner_scope_add_symbol(GScanner *, guint , const gchar *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2596(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_scanner_scope_add_symbol(__p0, __p1, __p2, __p3) __g_scanner_scope_add_symbol((__p0), (__p1), (__p2), (__p3))

gboolean  __g_unichar_get_mirror_char(gunichar , gunichar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3616(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_unichar_get_mirror_char(__p0, __p1) __g_unichar_get_mirror_char((__p0), (__p1))

void  __g_signal_chain_from_overridden(const GValue *, GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5068(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_signal_chain_from_overridden(__p0, __p1) __g_signal_chain_from_overridden((__p0), (__p1))

gint  __g_relation_count(GRelation *, gconstpointer , gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2494(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_relation_count(__p0, __p1, __p2) __g_relation_count((__p0), (__p1), (__p2))

gchar * __g_strcanon(gchar *, const gchar *, gchar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2854(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_strcanon(__p0, __p1, __p2) __g_strcanon((__p0), (__p1), (__p2))

gboolean  __g_unichar_iscntrl(gunichar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3322(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_unichar_iscntrl(__p0) __g_unichar_iscntrl((__p0))

gpointer  __g_object_steal_data(GObject *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4600(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_steal_data(__p0, __p1) __g_object_steal_data((__p0), (__p1))

GHook * __g_hook_find_data(GHookList *, gboolean , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1144(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hook_find_data(__p0, __p1, __p2) __g_hook_find_data((__p0), (__p1), (__p2))

gboolean  __g_date_is_leap_year(GDateYear ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-772(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_is_leap_year(__p0) __g_date_is_leap_year((__p0))

GTokenType  __g_scanner_peek_next_token(GScanner *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2554(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_scanner_peek_next_token(__p0) __g_scanner_peek_next_token((__p0))

void  __g_slist_push_allocator(GAllocator *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2656(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_push_allocator(__p0) __g_slist_push_allocator((__p0))

gboolean  __g_unichar_islower(gunichar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3340(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_unichar_islower(__p0) __g_unichar_islower((__p0))

GType  __g_initially_unowned_get_type() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4396(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_initially_unowned_get_type() __g_initially_unowned_get_type()

gboolean  __g_date_valid_julian(guint32 ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-610(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_valid_julian(__p0) __g_date_valid_julian((__p0))

void  __g_dataset_destroy(gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-526(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_dataset_destroy(__p0) __g_dataset_destroy((__p0))

gpointer  __g_value_get_object(const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4636(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_get_object(__p0) __g_value_get_object((__p0))

void  __g_list_foreach(GList *, GFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1570(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_foreach(__p0, __p1, __p2) __g_list_foreach((__p0), (__p1), (__p2))

GScanner * __g_scanner_new(const GScannerConfig *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2518(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_scanner_new(__p0) __g_scanner_new((__p0))

gpointer  __g_object_ref(gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4510(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_ref(__p0) __g_object_ref((__p0))

gint  __g_key_file_get_integer(GKeyFile *, const gchar *, const gchar *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1324(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_get_integer(__p0, __p1, __p2, __p3) __g_key_file_get_integer((__p0), (__p1), (__p2), (__p3))

GHook * __g_hook_find_func_data(GHookList *, gboolean , gpointer , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1156(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hook_find_func_data(__p0, __p1, __p2, __p3) __g_hook_find_func_data((__p0), (__p1), (__p2), (__p3))

GList * __g_list_copy(GList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1510(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_copy(__p0) __g_list_copy((__p0))

gboolean  __g_atomic_pointer_compare_and_exchange(gpointer *, gpointer , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-358(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_atomic_pointer_compare_and_exchange(__p0, __p1, __p2) __g_atomic_pointer_compare_and_exchange((__p0), (__p1), (__p2))

void  __g_type_class_add_private(gpointer , gsize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5290(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_class_add_private(__p0, __p1) __g_type_class_add_private((__p0), (__p1))

GPtrArray * __g_ptr_array_sized_new(guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-112(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_ptr_array_sized_new(__p0) __g_ptr_array_sized_new((__p0))

GString * __g_string_assign(GString *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3112(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_string_assign(__p0, __p1) __g_string_assign((__p0), (__p1))

GNode * __g_node_last_child(GNode *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1930(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_last_child(__p0) __g_node_last_child((__p0))

gint  __g_queue_index(GQueue *, gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2260(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_index(__p0, __p1) __g_queue_index((__p0), (__p1))

void  __g_slist_pop_allocator() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2662(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_pop_allocator() __g_slist_pop_allocator()

GSource * __g_main_context_find_source_by_id(GMainContext *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3652(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_context_find_source_by_id(__p0, __p1) __g_main_context_find_source_by_id((__p0), (__p1))

gchar * __g_key_file_get_start_group(GKeyFile *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1246(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_get_start_group(__p0) __g_key_file_get_start_group((__p0))

GString * __g_string_new(const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3076(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_string_new(__p0) __g_string_new((__p0))

void  __g_option_context_add_main_entries(GOptionContext *, const GOptionEntry *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2002(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_option_context_add_main_entries(__p0, __p1, __p2) __g_option_context_add_main_entries((__p0), (__p1), (__p2))

void  __g_type_init_with_debug_flags(GTypeDebugFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5104(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_init_with_debug_flags(__p0) __g_type_init_with_debug_flags((__p0))

void  __g_array_sort(GArray *, GCompareFunc ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-94(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_array_sort(__p0, __p1) __g_array_sort((__p0), (__p1))

GList * __g_queue_peek_head_link(GQueue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2332(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_peek_head_link(__p0) __g_queue_peek_head_link((__p0))

void  __g_value_set_boolean(GValue *, gboolean ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5494(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_set_boolean(__p0, __p1) __g_value_set_boolean((__p0), (__p1))

GSource * __g_main_context_find_source_by_funcs_user_data(GMainContext *, GSourceFuncs *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3658(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_context_find_source_by_funcs_user_data(__p0, __p1, __p2) __g_main_context_find_source_by_funcs_user_data((__p0), (__p1), (__p2))

GRand * __g_rand_new_with_seed(guint32 ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2368(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_rand_new_with_seed(__p0) __g_rand_new_with_seed((__p0))

void  __g_list_pop_allocator() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1420(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_pop_allocator() __g_list_pop_allocator()

gunichar * __g_unicode_canonical_decomposition(gunichar , gsize *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3442(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_unicode_canonical_decomposition(__p0, __p1) __g_unicode_canonical_decomposition((__p0), (__p1))

guint32  __g_random_int() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2440(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_random_int() __g_random_int()

void  __g_scanner_sync_file_offset(GScanner *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2536(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_scanner_sync_file_offset(__p0) __g_scanner_sync_file_offset((__p0))

GTree * __g_tree_new_full(GCompareDataFunc , gpointer , GDestroyNotify , GDestroyNotify ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3232(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_tree_new_full(__p0, __p1, __p2, __p3) __g_tree_new_full((__p0), (__p1), (__p2), (__p3))

gchar * __g_markup_vprintf_escaped(const char *, va_list ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1636(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_markup_vprintf_escaped(__p0, __p1) __g_markup_vprintf_escaped((__p0), (__p1))

GString * __g_string_append_len(GString *, const gchar *, gssize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3142(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_string_append_len(__p0, __p1, __p2) __g_string_append_len((__p0), (__p1), (__p2))

void  __g_ptr_array_remove_range(GPtrArray *, guint , guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-154(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_ptr_array_remove_range(__p0, __p1, __p2) __g_ptr_array_remove_range((__p0), (__p1), (__p2))

void  __g_markup_parse_context_free(GMarkupParseContext *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1600(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_markup_parse_context_free(__p0) __g_markup_parse_context_free((__p0))

void  __g_object_freeze_notify(GObject *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4480(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_freeze_notify(__p0) __g_object_freeze_notify((__p0))

gboolean  __g_utf8_validate(const gchar *, gssize , const gchar **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3568(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_utf8_validate(__p0, __p1, __p2) __g_utf8_validate((__p0), (__p1), (__p2))

void  __g_value_set_uint64(GValue *, guint64 ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5566(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_set_uint64(__p0, __p1) __g_value_set_uint64((__p0), (__p1))

GMainContext * __g_main_context_new() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3682(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_context_new() __g_main_context_new()

gboolean  __g_main_context_acquire(GMainContext *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3622(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_context_acquire(__p0) __g_main_context_acquire((__p0))

gdouble  __g_value_get_double(const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5596(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_get_double(__p0) __g_value_get_double((__p0))

GSource * __g_idle_source_new() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3808(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_idle_source_new() __g_idle_source_new()

GByteArray * __g_byte_array_sized_new(guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-190(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_byte_array_sized_new(__p0) __g_byte_array_sized_new((__p0))

guint  __g_spaced_primes_closest(guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2110(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_spaced_primes_closest(__p0) __g_spaced_primes_closest((__p0))

void  __g_ptr_array_add(GPtrArray *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-160(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_ptr_array_add(__p0, __p1) __g_ptr_array_add((__p0), (__p1))

void  __g_param_value_set_default(GParamSpec *, GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4708(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_value_set_default(__p0, __p1) __g_param_value_set_default((__p0), (__p1))

gulong  __g_signal_add_emission_hook(guint , GQuark , GSignalEmissionHook , gpointer , GDestroyNotify ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4978(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_signal_add_emission_hook(__p0, __p1, __p2, __p3, __p4) __g_signal_add_emission_hook((__p0), (__p1), (__p2), (__p3), (__p4))

GCache * __g_cache_new(GCacheNewFunc , GCacheDestroyFunc , GCacheDupFunc , GCacheDestroyFunc , GHashFunc , GHashFunc , GEqualFunc ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-388(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_cache_new(__p0, __p1, __p2, __p3, __p4, __p5, __p6) __g_cache_new((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6))

gboolean  __g_main_context_wait(GMainContext *, GCond *, GMutex *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3736(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_context_wait(__p0, __p1, __p2) __g_main_context_wait((__p0), (__p1), (__p2))

gboolean  __g_pattern_match_string(GPatternSpec *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2098(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_pattern_match_string(__p0, __p1) __g_pattern_match_string((__p0), (__p1))

guint  __g_timeout_add_full(gint , guint , GSourceFunc , gpointer , GDestroyNotify ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4090(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_timeout_add_full(__p0, __p1, __p2, __p3, __p4) __g_timeout_add_full((__p0), (__p1), (__p2), (__p3), (__p4))

void  __g_mem_chunk_info() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1726(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_mem_chunk_info() __g_mem_chunk_info()

GString * __g_string_prepend_len(GString *, const gchar *, gssize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3178(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_string_prepend_len(__p0, __p1, __p2) __g_string_prepend_len((__p0), (__p1), (__p2))

void  __g_completion_add_items(GCompletion *, GList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-430(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_completion_add_items(__p0, __p1) __g_completion_add_items((__p0), (__p1))

GParamSpec * __g_param_spec_uint64(const gchar *, const gchar *, const gchar *, guint64 , guint64 , guint64 , GParamFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4834(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_uint64(__p0, __p1, __p2, __p3, __p4, __p5, __p6) __g_param_spec_uint64((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6))

gpointer  __g_type_class_peek_parent(gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5176(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_class_peek_parent(__p0) __g_type_class_peek_parent((__p0))

gboolean  __g_signal_handler_is_connected(gpointer , gulong ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5032(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_signal_handler_is_connected(__p0, __p1) __g_signal_handler_is_connected((__p0), (__p1))

GUnicodeType  __g_unichar_type(gunichar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3424(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_unichar_type(__p0) __g_unichar_type((__p0))

void  __g_queue_sort(GQueue *, GCompareDataFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2200(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_sort(__p0, __p1, __p2) __g_queue_sort((__p0), (__p1), (__p2))

gboolean  __g_main_context_pending(GMainContext *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3688(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_context_pending(__p0) __g_main_context_pending((__p0))

GList * __g_list_last(GList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1552(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_last(__p0) __g_list_last((__p0))

void  __g_param_spec_sink(GParamSpec *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4666(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_sink(__p0) __g_param_spec_sink((__p0))

gint  __g_hook_compare_ids(GHook *, GHook *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1174(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hook_compare_ids(__p0, __p1) __g_hook_compare_ids((__p0), (__p1))

gpointer  __g_object_newv(GType , guint , GParameter *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4444(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_newv(__p0, __p1, __p2) __g_object_newv((__p0), (__p1), (__p2))

void  __g_date_set_time(GDate *, GTime ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-688(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_set_time(__p0, __p1) __g_date_set_time((__p0), (__p1))

GParamSpec * __g_param_spec_char(const gchar *, const gchar *, const gchar *, gint8 , gint8 , gint8 , GParamFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4786(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_char(__p0, __p1, __p2, __p3, __p4, __p5, __p6) __g_param_spec_char((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6))

gchar * __g_key_file_get_comment(GKeyFile *, const gchar *, const gchar *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1390(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_get_comment(__p0, __p1, __p2, __p3) __g_key_file_get_comment((__p0), (__p1), (__p2), (__p3))

void  __g_ptr_array_sort(GPtrArray *, GCompareFunc ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-166(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_ptr_array_sort(__p0, __p1) __g_ptr_array_sort((__p0), (__p1))

void  __g_tree_remove(GTree *, gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3256(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_tree_remove(__p0, __p1) __g_tree_remove((__p0), (__p1))

GHook * __g_hook_next_valid(GHookList *, GHook *, gboolean ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1168(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hook_next_valid(__p0, __p1, __p2) __g_hook_next_valid((__p0), (__p1), (__p2))

gint  __g_main_context_query(GMainContext *, gint , gint *, GPollFD *, gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3700(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_context_query(__p0, __p1, __p2, __p3, __p4) __g_main_context_query((__p0), (__p1), (__p2), (__p3), (__p4))

gulong  __g_value_get_ulong(const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5548(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_get_ulong(__p0) __g_value_get_ulong((__p0))

gpointer  __g_async_queue_timed_pop(GAsyncQueue *, GTimeVal *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-316(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_async_queue_timed_pop(__p0, __p1) __g_async_queue_timed_pop((__p0), (__p1))

gpointer  __g_type_class_peek_static(GType ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5164(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_class_peek_static(__p0) __g_type_class_peek_static((__p0))

GIOStatus  __g_io_channel_read_to_end(GIOChannel *, gchar **, gsize *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3910(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_read_to_end(__p0, __p1, __p2, __p3) __g_io_channel_read_to_end((__p0), (__p1), (__p2), (__p3))

gboolean  __g_param_value_defaults(GParamSpec *, GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4714(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_value_defaults(__p0, __p1) __g_param_value_defaults((__p0), (__p1))

GRelation * __g_relation_new(gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2464(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_relation_new(__p0) __g_relation_new((__p0))

gpointer  __g_object_ref_sink(gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4504(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_ref_sink(__p0) __g_object_ref_sink((__p0))

guint  __g_value_get_flags(const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4366(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_get_flags(__p0) __g_value_get_flags((__p0))

GString * __g_string_insert_len(GString *, gssize , const gchar *, gssize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3130(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_string_insert_len(__p0, __p1, __p2, __p3) __g_string_insert_len((__p0), (__p1), (__p2), (__p3))

gpointer  __g_type_get_qdata(GType , GQuark ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5230(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_get_qdata(__p0, __p1) __g_type_get_qdata((__p0), (__p1))

void  __g_value_set_ulong(GValue *, gulong ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5542(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_set_ulong(__p0, __p1) __g_value_set_ulong((__p0), (__p1))

void  __g_qsort_with_data(gconstpointer , gint , gsize , GCompareDataFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2116(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_qsort_with_data(__p0, __p1, __p2, __p3, __p4) __g_qsort_with_data((__p0), (__p1), (__p2), (__p3), (__p4))

gchar * __g_strstr_len(const gchar *, gssize , const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2890(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_strstr_len(__p0, __p1, __p2) __g_strstr_len((__p0), (__p1), (__p2))

void  __g_strfreev(gchar **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3046(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_strfreev(__p0) __g_strfreev((__p0))

void  __g_main_loop_run(GMainLoop *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3784(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_loop_run(__p0) __g_main_loop_run((__p0))

GQuark  __g_type_qname(GType ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5116(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_qname(__p0) __g_type_qname((__p0))

GIOStatus  __g_io_channel_read_unichar(GIOChannel *, gunichar *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3916(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_read_unichar(__p0, __p1, __p2) __g_io_channel_read_unichar((__p0), (__p1), (__p2))

void  __g_hook_list_invoke_check(GHookList *, gboolean ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1186(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hook_list_invoke_check(__p0, __p1) __g_hook_list_invoke_check((__p0), (__p1))

void  __g_value_set_flags(GValue *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4360(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_set_flags(__p0, __p1) __g_value_set_flags((__p0), (__p1))

GValueArray * __g_value_array_copy(const GValueArray *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5428(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_array_copy(__p0) __g_value_array_copy((__p0))

guint  __g_io_add_watch(GIOChannel *, GIOCondition , GIOFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3814(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_add_watch(__p0, __p1, __p2, __p3) __g_io_add_watch((__p0), (__p1), (__p2), (__p3))

gpointer  __g_async_queue_timed_pop_unlocked(GAsyncQueue *, GTimeVal *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-322(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_async_queue_timed_pop_unlocked(__p0, __p1) __g_async_queue_timed_pop_unlocked((__p0), (__p1))

GType  __g_type_register_static_simple(GType , const gchar *, guint , GClassInitFunc , guint , GInstanceInitFunc , GTypeFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5248(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_register_static_simple(__p0, __p1, __p2, __p3, __p4, __p5, __p6) __g_type_register_static_simple((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6))

gint32  __g_random_int_range(gint32 , gint32 ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2446(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_random_int_range(__p0, __p1) __g_random_int_range((__p0), (__p1))

void  __g_type_set_qdata(GType , GQuark , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5224(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_set_qdata(__p0, __p1, __p2) __g_type_set_qdata((__p0), (__p1), (__p2))

GSList * __g_slist_alloc() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2668(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_alloc() __g_slist_alloc()

void  __g_completion_free(GCompletion *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-466(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_completion_free(__p0) __g_completion_free((__p0))

void  __g_list_free(GList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1432(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_free(__p0) __g_list_free((__p0))

glong  __g_utf8_strlen(const gchar *, gssize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3490(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_utf8_strlen(__p0, __p1) __g_utf8_strlen((__p0), (__p1))

gpointer  __g_type_interface_peek_parent(gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5188(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_interface_peek_parent(__p0) __g_type_interface_peek_parent((__p0))

void  __g_queue_reverse(GQueue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2170(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_reverse(__p0) __g_queue_reverse((__p0))

guint  __g_datalist_get_flags(GData **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-520(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_datalist_get_flags(__p0) __g_datalist_get_flags((__p0))

void  __g_object_remove_toggle_ref(GObject *, GToggleNotify , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4552(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_remove_toggle_ref(__p0, __p1, __p2) __g_object_remove_toggle_ref((__p0), (__p1), (__p2))

void  __g_free(gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1660(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_free(__p0) __g_free((__p0))

gchar * __g_strrstr_len(const gchar *, gssize , const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2902(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_strrstr_len(__p0, __p1, __p2) __g_strrstr_len((__p0), (__p1), (__p2))

GFlagsValue * __g_flags_get_value_by_name(GFlagsClass *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4336(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_flags_get_value_by_name(__p0, __p1) __g_flags_get_value_by_name((__p0), (__p1))

GError * __g_error_copy(const GError *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-868(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_error_copy(__p0) __g_error_copy((__p0))

gchar ** __g_strsplit(const gchar *, const gchar *, gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3028(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_strsplit(__p0, __p1, __p2) __g_strsplit((__p0), (__p1), (__p2))

GDateWeekday  __g_date_get_weekday(const GDate *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-622(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_get_weekday(__p0) __g_date_get_weekday((__p0))

guint  __g_io_add_watch_full(GIOChannel *, gint , GIOCondition , GIOFunc , gpointer , GDestroyNotify ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3820(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_add_watch_full(__p0, __p1, __p2, __p3, __p4, __p5) __g_io_add_watch_full((__p0), (__p1), (__p2), (__p3), (__p4), (__p5))

gchar * __g_ascii_dtostr(gchar *, gint , gdouble ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2938(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_ascii_dtostr(__p0, __p1, __p2) __g_ascii_dtostr((__p0), (__p1), (__p2))

GAsyncQueue * __g_async_queue_new() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-250(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_async_queue_new() __g_async_queue_new()

gchar * __g_strdup_value_contents(const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5662(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_strdup_value_contents(__p0) __g_strdup_value_contents((__p0))

GType  __g_type_module_register_type(GTypeModule *, GType , const gchar *, const GTypeInfo *, GTypeFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5326(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_module_register_type(__p0, __p1, __p2, __p3, __p4) __g_type_module_register_type((__p0), (__p1), (__p2), (__p3), (__p4))

void  __g_datalist_set_flags(GData **, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-508(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_datalist_set_flags(__p0, __p1) __g_datalist_set_flags((__p0), (__p1))

gboolean  __g_error_matches(const GError *, GQuark , gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-874(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_error_matches(__p0, __p1, __p2) __g_error_matches((__p0), (__p1), (__p2))

void  __g_rand_set_seed_array(GRand *, const guint32 *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2404(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_rand_set_seed_array(__p0, __p1, __p2) __g_rand_set_seed_array((__p0), (__p1), (__p2))

guint  __g_timeout_add(guint , GSourceFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4084(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_timeout_add(__p0, __p1, __p2) __g_timeout_add((__p0), (__p1), (__p2))

gpointer  __g_object_get_data(GObject *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4582(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_get_data(__p0, __p1) __g_object_get_data((__p0), (__p1))

gpointer  __g_scanner_scope_lookup_symbol(GScanner *, guint , const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2608(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_scanner_scope_lookup_symbol(__p0, __p1, __p2) __g_scanner_scope_lookup_symbol((__p0), (__p1), (__p2))

#if defined(USE_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
gchar * __g_strconcat(const gchar *, ...) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4240(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_strconcat(...) __g_strconcat(__VA_ARGS__)
#endif

GList * __g_completion_complete(GCompletion *, const gchar *, gchar **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-448(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_completion_complete(__p0, __p1, __p2) __g_completion_complete((__p0), (__p1), (__p2))

void  __g_type_default_interface_unref(gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5206(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_default_interface_unref(__p0) __g_type_default_interface_unref((__p0))

GSource * __g_source_new(GSourceFuncs *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4102(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_source_new(__p0, __p1) __g_source_new((__p0), (__p1))

GString * __g_string_set_size(GString *, gsize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3124(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_string_set_size(__p0, __p1) __g_string_set_size((__p0), (__p1))

void  __g_key_file_set_list_separator(GKeyFile *, gchar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1216(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_set_list_separator(__p0, __p1) __g_key_file_set_list_separator((__p0), (__p1))

GIOStatus  __g_io_channel_set_encoding(GIOChannel *, const gchar *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3952(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_set_encoding(__p0, __p1, __p2) __g_io_channel_set_encoding((__p0), (__p1), (__p2))

GArray * __g_array_remove_index(GArray *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-76(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_array_remove_index(__p0, __p1) __g_array_remove_index((__p0), (__p1))

void  __g_log_default_handler(const gchar *, GLogLevelFlags , const gchar *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1768(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_log_default_handler(__p0, __p1, __p2, __p3) __g_log_default_handler((__p0), (__p1), (__p2), (__p3))

guint  __g_source_attach(GSource *, GMainContext *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4120(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_source_attach(__p0, __p1) __g_source_attach((__p0), (__p1))

gchar * __g_shell_quote(const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2638(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_shell_quote(__p0) __g_shell_quote((__p0))

GType * __g_type_interfaces(GType , guint *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5218(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_interfaces(__p0, __p1) __g_type_interfaces((__p0), (__p1))

GByteArray * __g_byte_array_append(GByteArray *, const guint8 *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-202(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_byte_array_append(__p0, __p1, __p2) __g_byte_array_append((__p0), (__p1), (__p2))

GList * __g_queue_pop_tail_link(GQueue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2320(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_pop_tail_link(__p0) __g_queue_pop_tail_link((__p0))

void  __g_relation_print(GRelation *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2500(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_relation_print(__p0) __g_relation_print((__p0))

GParamSpec * __g_param_spec_ref_sink(GParamSpec *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4672(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_ref_sink(__p0) __g_param_spec_ref_sink((__p0))

void  __g_value_unset(GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5398(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_unset(__p0) __g_value_unset((__p0))

GNode * __g_node_insert_before(GNode *, GNode *, GNode *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1846(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_insert_before(__p0, __p1, __p2) __g_node_insert_before((__p0), (__p1), (__p2))

void  __g_io_channel_set_buffer_size(GIOChannel *, gsize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3934(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_set_buffer_size(__p0, __p1) __g_io_channel_set_buffer_size((__p0), (__p1))

void  __g_io_channel_unref(GIOChannel *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3976(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_unref(__p0) __g_io_channel_unref((__p0))

guint32  __g_rand_int(GRand *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2410(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_rand_int(__p0) __g_rand_int((__p0))

GArray * __g_array_remove_index_fast(GArray *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-82(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_array_remove_index_fast(__p0, __p1) __g_array_remove_index_fast((__p0), (__p1))

gint  __g_list_position(GList *, GList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1540(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_position(__p0, __p1) __g_list_position((__p0), (__p1))

gchar ** __g_strsplit_set(const gchar *, const gchar *, gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3034(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_strsplit_set(__p0, __p1, __p2) __g_strsplit_set((__p0), (__p1), (__p2))

gunichar  __g_utf8_get_char_validated(const gchar *, gssize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3454(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_utf8_get_char_validated(__p0, __p1) __g_utf8_get_char_validated((__p0), (__p1))

GEnumValue * __g_enum_get_value(GEnumClass *, gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4312(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_enum_get_value(__p0, __p1) __g_enum_get_value((__p0), (__p1))

GKeyFile * __g_key_file_new() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1204(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_new() __g_key_file_new()

gint  __g_unichar_to_utf8(gunichar , gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3562(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_unichar_to_utf8(__p0, __p1) __g_unichar_to_utf8((__p0), (__p1))

guint  __g_date_get_monday_week_of_year(const GDate *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-658(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_get_monday_week_of_year(__p0) __g_date_get_monday_week_of_year((__p0))

gunichar * __g_utf16_to_ucs4(const gunichar2 *, glong , glong *, glong *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3538(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_utf16_to_ucs4(__p0, __p1, __p2, __p3, __p4) __g_utf16_to_ucs4((__p0), (__p1), (__p2), (__p3), (__p4))

GIOChannel * __g_io_channel_new_file(const gchar *, const gchar *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3886(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_new_file(__p0, __p1, __p2) __g_io_channel_new_file((__p0), (__p1), (__p2))

GQuark  __g_quark_try_string(const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2122(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_quark_try_string(__p0) __g_quark_try_string((__p0))

gboolean  __g_key_file_load_from_file(GKeyFile *, const gchar *, GKeyFileFlags , GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1222(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_load_from_file(__p0, __p1, __p2, __p3) __g_key_file_load_from_file((__p0), (__p1), (__p2), (__p3))

void  __g_scanner_unexp_token(GScanner *, GTokenType , const gchar *, const gchar *, const gchar *, const gchar *, gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2626(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_scanner_unexp_token(__p0, __p1, __p2, __p3, __p4, __p5, __p6) __g_scanner_unexp_token((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6))

void  __g_array_sort_with_data(GArray *, GCompareDataFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-100(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_array_sort_with_data(__p0, __p1, __p2) __g_array_sort_with_data((__p0), (__p1), (__p2))

gchar * __g_filename_from_utf8(const gchar *, gssize , gsize *, gsize *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4066(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_filename_from_utf8(__p0, __p1, __p2, __p3, __p4) __g_filename_from_utf8((__p0), (__p1), (__p2), (__p3), (__p4))

void  __g_hash_table_insert(GHashTable *, gpointer , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-952(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hash_table_insert(__p0, __p1, __p2) __g_hash_table_insert((__p0), (__p1), (__p2))

void  __g_date_free(GDate *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-574(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_free(__p0) __g_date_free((__p0))

gboolean  __g_pattern_spec_equal(GPatternSpec *, GPatternSpec *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2086(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_pattern_spec_equal(__p0, __p1) __g_pattern_spec_equal((__p0), (__p1))

GType  __g_type_module_register_enum(GTypeModule *, const gchar *, const GEnumValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5338(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_module_register_enum(__p0, __p1, __p2) __g_type_module_register_enum((__p0), (__p1), (__p2))

gboolean * __g_key_file_get_boolean_list(GKeyFile *, const gchar *, const gchar *, gsize *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1360(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_get_boolean_list(__p0, __p1, __p2, __p3, __p4) __g_key_file_get_boolean_list((__p0), (__p1), (__p2), (__p3), (__p4))

gchar * __g_key_file_to_data(GKeyFile *, gsize *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1240(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_to_data(__p0, __p1, __p2) __g_key_file_to_data((__p0), (__p1), (__p2))

void  __g_io_channel_init(GIOChannel *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3880(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_init(__p0) __g_io_channel_init((__p0))

gint  __g_slist_position(GSList *, GSList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2776(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_position(__p0, __p1) __g_slist_position((__p0), (__p1))

gpointer  __g_queue_pop_head(GQueue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2224(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_pop_head(__p0) __g_queue_pop_head((__p0))

void  __g_node_push_allocator(GAllocator *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1798(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_push_allocator(__p0) __g_node_push_allocator((__p0))

GParamSpec * __g_param_spec_int(const gchar *, const gchar *, const gchar *, gint , gint , gint , GParamFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4804(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_int(__p0, __p1, __p2, __p3, __p4, __p5, __p6) __g_param_spec_int((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6))

GDate * __g_date_new() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-556(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_new() __g_date_new()

void  __g_unicode_canonical_ordering(gunichar *, gsize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3436(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_unicode_canonical_ordering(__p0, __p1) __g_unicode_canonical_ordering((__p0), (__p1))

gunichar * __g_utf8_to_ucs4(const gchar *, glong , glong *, glong *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3526(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_utf8_to_ucs4(__p0, __p1, __p2, __p3, __p4) __g_utf8_to_ucs4((__p0), (__p1), (__p2), (__p3), (__p4))

gchar * __g_ucs4_to_utf8(const gunichar *, glong , glong *, glong *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3556(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_ucs4_to_utf8(__p0, __p1, __p2, __p3, __p4) __g_ucs4_to_utf8((__p0), (__p1), (__p2), (__p3), (__p4))

gint  __g_tree_height(GTree *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3292(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_tree_height(__p0) __g_tree_height((__p0))

void  __g_signal_handler_unblock(gpointer , gulong ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5020(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_signal_handler_unblock(__p0, __p1) __g_signal_handler_unblock((__p0), (__p1))

void  __g_value_set_pointer(GValue *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5626(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_set_pointer(__p0, __p1) __g_value_set_pointer((__p0), (__p1))

GEnumValue * __g_enum_get_value_by_name(GEnumClass *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4318(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_enum_get_value_by_name(__p0, __p1) __g_enum_get_value_by_name((__p0), (__p1))

GNode * __g_node_insert_after(GNode *, GNode *, GNode *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1852(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_insert_after(__p0, __p1, __p2) __g_node_insert_after((__p0), (__p1), (__p2))

gdouble  __g_rand_double_range(GRand *, gdouble , gdouble ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2428(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_rand_double_range(__p0, __p1, __p2) __g_rand_double_range((__p0), (__p1), (__p2))

GParamSpec * __g_object_interface_find_property(gpointer , const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4432(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_interface_find_property(__p0, __p1) __g_object_interface_find_property((__p0), (__p1))

GParamSpec * __g_value_get_param(const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4762(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_get_param(__p0) __g_value_get_param((__p0))

void  __g_option_group_set_parse_hooks(GOptionGroup *, GOptionParseFunc , GOptionParseFunc ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2038(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_option_group_set_parse_hooks(__p0, __p1, __p2) __g_option_group_set_parse_hooks((__p0), (__p1), (__p2))

GRand * __g_rand_new() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2380(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_rand_new() __g_rand_new()

guint64  __g_ascii_strtoull(const gchar *, gchar **, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2932(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_ascii_strtoull(__p0, __p1, __p2) __g_ascii_strtoull((__p0), (__p1), (__p2))

gboolean  __g_unichar_isprint(gunichar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3346(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_unichar_isprint(__p0) __g_unichar_isprint((__p0))

GSource * __g_child_watch_source_new(GPid ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4024(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_child_watch_source_new(__p0) __g_child_watch_source_new((__p0))

void  __g_queue_push_head(GQueue *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2206(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_push_head(__p0, __p1) __g_queue_push_head((__p0), (__p1))

GParamSpec * __g_value_dup_param(const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4768(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_dup_param(__p0) __g_value_dup_param((__p0))

void  __g_type_query(GType , GTypeQuery *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5236(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_query(__p0, __p1) __g_type_query((__p0), (__p1))

void  __g_value_take_string(GValue *, gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5668(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_take_string(__p0, __p1) __g_value_take_string((__p0), (__p1))

void  __g_value_set_param(GValue *, GParamSpec *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4756(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_set_param(__p0, __p1) __g_value_set_param((__p0), (__p1))

void  __g_mem_chunk_reset(GMemChunk *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1714(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_mem_chunk_reset(__p0) __g_mem_chunk_reset((__p0))

gboolean  __g_hook_destroy(GHookList *, gulong ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1102(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hook_destroy(__p0, __p1) __g_hook_destroy((__p0), (__p1))

void  __g_value_array_free(GValueArray *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5422(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_array_free(__p0) __g_value_array_free((__p0))

void  __g_type_plugin_use(GTypePlugin *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5356(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_plugin_use(__p0) __g_type_plugin_use((__p0))

void  __g_date_add_months(GDate *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-748(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_add_months(__p0, __p1) __g_date_add_months((__p0), (__p1))

gint  __g_param_values_cmp(GParamSpec *, const GValue *, const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4732(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_values_cmp(__p0, __p1, __p2) __g_param_values_cmp((__p0), (__p1), (__p2))

gpointer  __g_object_get_qdata(GObject *, GQuark ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4558(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_get_qdata(__p0, __p1) __g_object_get_qdata((__p0), (__p1))

GMemChunk * __g_mem_chunk_new(const gchar *, gint , gulong , gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1678(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_mem_chunk_new(__p0, __p1, __p2, __p3) __g_mem_chunk_new((__p0), (__p1), (__p2), (__p3))

gboolean  __g_int_equal(gconstpointer , gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1042(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_int_equal(__p0, __p1) __g_int_equal((__p0), (__p1))

#if defined(USE_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void  __g_log(const gchar *, GLogLevelFlags , const gchar *, ...) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4228(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_log(__p0, __p1, ...) __g_log((__p0), (__p1), __VA_ARGS__)
#endif

GParamSpec * __g_param_spec_gtype(const gchar *, const gchar *, const gchar *, GType , GParamFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4912(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_gtype(__p0, __p1, __p2, __p3, __p4) __g_param_spec_gtype((__p0), (__p1), (__p2), (__p3), (__p4))

GSList * __g_slist_insert(GSList *, gpointer , gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2698(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_insert(__p0, __p1, __p2) __g_slist_insert((__p0), (__p1), (__p2))

void  __g_dataset_id_set_data_full(gconstpointer , GQuark , gpointer , GDestroyNotify ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-538(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_dataset_id_set_data_full(__p0, __p1, __p2, __p3) __g_dataset_id_set_data_full((__p0), (__p1), (__p2), (__p3))

void  __g_source_set_callback(GSource *, GSourceFunc , gpointer , GDestroyNotify ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4168(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_source_set_callback(__p0, __p1, __p2, __p3) __g_source_set_callback((__p0), (__p1), (__p2), (__p3))

GSList * __g_slist_find_custom(GSList *, gconstpointer , GCompareFunc ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2770(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_find_custom(__p0, __p1, __p2) __g_slist_find_custom((__p0), (__p1), (__p2))

GNode * __g_node_find_child(GNode *, GTraverseFlags , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1936(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_find_child(__p0, __p1, __p2) __g_node_find_child((__p0), (__p1), (__p2))

GSList * __g_slist_reverse(GSList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2746(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_reverse(__p0) __g_slist_reverse((__p0))

void  __g_date_set_julian(GDate *, guint32 ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-718(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_set_julian(__p0, __p1) __g_date_set_julian((__p0), (__p1))

void  __g_error_free(GError *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-862(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_error_free(__p0) __g_error_free((__p0))

void  __g_object_set_qdata(GObject *, GQuark , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4564(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_set_qdata(__p0, __p1, __p2) __g_object_set_qdata((__p0), (__p1), (__p2))

GMainContext * __g_main_context_default() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3640(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_context_default() __g_main_context_default()

GTokenValue  __g_scanner_cur_value(GScanner *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2566(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_scanner_cur_value(__p0) __g_scanner_cur_value((__p0))

gint64  __g_value_get_int64(const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5560(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_get_int64(__p0) __g_value_get_int64((__p0))

GParamSpec * __g_param_spec_float(const gchar *, const gchar *, const gchar *, gfloat , gfloat , gfloat , GParamFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4858(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_float(__p0, __p1, __p2, __p3, __p4, __p5, __p6) __g_param_spec_float((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6))

void  __g_clear_error(GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-886(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_clear_error(__p0) __g_clear_error((__p0))

GHook * __g_hook_get(GHookList *, gulong ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1132(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hook_get(__p0, __p1) __g_hook_get((__p0), (__p1))

void  __g_object_set_valist(GObject *, const gchar *, va_list ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4456(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_set_valist(__p0, __p1, __p2) __g_object_set_valist((__p0), (__p1), (__p2))

void  __g_date_subtract_days(GDate *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-742(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_subtract_days(__p0, __p1) __g_date_subtract_days((__p0), (__p1))

GSList * __g_slist_sort(GSList *, GCompareFunc ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2806(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_sort(__p0, __p1) __g_slist_sort((__p0), (__p1))

gint  __g_async_queue_length_unlocked(GAsyncQueue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-334(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_async_queue_length_unlocked(__p0) __g_async_queue_length_unlocked((__p0))

gunichar  __g_unichar_toupper(gunichar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3394(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_unichar_toupper(__p0) __g_unichar_toupper((__p0))

guint  __g_idle_add_full(gint , GSourceFunc , gpointer , GDestroyNotify ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3802(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_idle_add_full(__p0, __p1, __p2, __p3) __g_idle_add_full((__p0), (__p1), (__p2), (__p3))

guint  __g_scanner_cur_line(GScanner *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2572(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_scanner_cur_line(__p0) __g_scanner_cur_line((__p0))

gpointer  __g_type_class_peek(GType ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5158(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_class_peek(__p0) __g_type_class_peek((__p0))

void  __g_value_set_int64(GValue *, gint64 ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5554(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_set_int64(__p0, __p1) __g_value_set_int64((__p0), (__p1))

GType  __g_param_type_register_static(const gchar *, const GParamSpecTypeInfo *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4780(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_type_register_static(__p0, __p1) __g_param_type_register_static((__p0), (__p1))

void  __g_slist_free_1(GSList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2680(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_free_1(__p0) __g_slist_free_1((__p0))

GCompletion * __g_completion_new(GCompletionFunc ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-424(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_completion_new(__p0) __g_completion_new((__p0))

gunichar  __g_utf8_get_char(const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3448(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_utf8_get_char(__p0) __g_utf8_get_char((__p0))

void  __g_value_set_char(GValue *, gchar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5470(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_set_char(__p0, __p1) __g_value_set_char((__p0), (__p1))

gint  __g_atomic_int_get(volatile gint *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-364(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_atomic_int_get(__p0) __g_atomic_int_get((__p0))

GSList * __g_slist_concat(GSList *, GSList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2716(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_concat(__p0, __p1) __g_slist_concat((__p0), (__p1))

void  __g_relation_destroy(GRelation *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2470(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_relation_destroy(__p0) __g_relation_destroy((__p0))

GType  __g_type_module_get_type() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5302(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_module_get_type() __g_type_module_get_type()

void  __g_date_add_years(GDate *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-760(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_add_years(__p0, __p1) __g_date_add_years((__p0), (__p1))

gchar * __g_strescape(const gchar *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3016(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_strescape(__p0, __p1) __g_strescape((__p0), (__p1))

void  __g_queue_push_nth(GQueue *, gpointer , gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2218(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_push_nth(__p0, __p1, __p2) __g_queue_push_nth((__p0), (__p1), (__p2))

void  __g_async_queue_unlock(GAsyncQueue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-262(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_async_queue_unlock(__p0) __g_async_queue_unlock((__p0))

gpointer  __g_value_get_boxed(const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4294(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_get_boxed(__p0) __g_value_get_boxed((__p0))

GDir * __g_dir_open(const gchar *, guint , GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-832(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_dir_open(__p0, __p1, __p2) __g_dir_open((__p0), (__p1), (__p2))

guint  __g_slist_length(GSList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2794(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_length(__p0) __g_slist_length((__p0))

GList * __g_queue_pop_head_link(GQueue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2314(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_pop_head_link(__p0) __g_queue_pop_head_link((__p0))

void  __g_hook_free(GHookList *, GHook *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1084(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hook_free(__p0, __p1) __g_hook_free((__p0), (__p1))

gint  __g_list_index(GList *, gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1546(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_index(__p0, __p1) __g_list_index((__p0), (__p1))

gpointer  __g_value_dup_boxed(const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4300(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_dup_boxed(__p0) __g_value_dup_boxed((__p0))

void  __g_type_module_unuse(GTypeModule *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5314(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_module_unuse(__p0) __g_type_module_unuse((__p0))

void  __g_source_set_callback_indirect(GSource *, gpointer , GSourceCallbackFuncs *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4174(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_source_set_callback_indirect(__p0, __p1, __p2) __g_source_set_callback_indirect((__p0), (__p1), (__p2))

gboolean  __g_tree_lookup_extended(GTree *, gconstpointer , gpointer *, gpointer *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3274(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_tree_lookup_extended(__p0, __p1, __p2, __p3) __g_tree_lookup_extended((__p0), (__p1), (__p2), (__p3))

void  __g_value_set_boxed(GValue *, gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4282(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_set_boxed(__p0, __p1) __g_value_set_boxed((__p0), (__p1))

GParamSpec * __g_param_spec_uint(const gchar *, const gchar *, const gchar *, guint , guint , guint , GParamFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4810(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_uint(__p0, __p1, __p2, __p3, __p4, __p5, __p6) __g_param_spec_uint((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6))

gboolean  __g_value_get_boolean(const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5500(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_get_boolean(__p0) __g_value_get_boolean((__p0))

guint  __g_source_get_id(GSource *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4156(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_source_get_id(__p0) __g_source_get_id((__p0))

GHook * __g_hook_find_func(GHookList *, gboolean , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1150(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hook_find_func(__p0, __p1, __p2) __g_hook_find_func((__p0), (__p1), (__p2))

gchar * __g_key_file_get_string(GKeyFile *, const gchar *, const gchar *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1288(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_get_string(__p0, __p1, __p2, __p3) __g_key_file_get_string((__p0), (__p1), (__p2), (__p3))

GByteArray * __g_byte_array_prepend(GByteArray *, const guint8 *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-208(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_byte_array_prepend(__p0, __p1, __p2) __g_byte_array_prepend((__p0), (__p1), (__p2))

void  __g_value_set_static_boxed(GValue *, gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4288(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_set_static_boxed(__p0, __p1) __g_value_set_static_boxed((__p0), (__p1))

GType  __g_enum_register_static(const gchar *, const GEnumValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4372(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_enum_register_static(__p0, __p1) __g_enum_register_static((__p0), (__p1))

gchar ** __g_key_file_get_keys(GKeyFile *, const gchar *, gsize *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1258(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_get_keys(__p0, __p1, __p2, __p3) __g_key_file_get_keys((__p0), (__p1), (__p2), (__p3))

void  __g_hash_table_foreach(GHashTable *, GHFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-988(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hash_table_foreach(__p0, __p1, __p2) __g_hash_table_foreach((__p0), (__p1), (__p2))

gboolean  __g_unichar_isalnum(gunichar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3310(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_unichar_isalnum(__p0) __g_unichar_isalnum((__p0))

GByteArray * __g_byte_array_remove_index_fast(GByteArray *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-226(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_byte_array_remove_index_fast(__p0, __p1) __g_byte_array_remove_index_fast((__p0), (__p1))

GMainContext * __g_main_context_ref(GMainContext *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3706(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_context_ref(__p0) __g_main_context_ref((__p0))

void  __g_scanner_scope_remove_symbol(GScanner *, guint , const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2602(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_scanner_scope_remove_symbol(__p0, __p1, __p2) __g_scanner_scope_remove_symbol((__p0), (__p1), (__p2))

GHashTable * __g_hash_table_new_full(GHashFunc , GEqualFunc , GDestroyNotify , GDestroyNotify ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-940(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hash_table_new_full(__p0, __p1, __p2, __p3) __g_hash_table_new_full((__p0), (__p1), (__p2), (__p3))

gchar * __g_ascii_strup(const gchar *, gssize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2980(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_ascii_strup(__p0, __p1) __g_ascii_strup((__p0), (__p1))

GRand * __g_rand_new_with_seed_array(const guint32 *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2374(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_rand_new_with_seed_array(__p0, __p1) __g_rand_new_with_seed_array((__p0), (__p1))

gchar * __g_utf8_casefold(const gchar *, gssize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3592(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_utf8_casefold(__p0, __p1) __g_utf8_casefold((__p0), (__p1))

GNode * __g_node_get_root(GNode *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1870(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_get_root(__p0) __g_node_get_root((__p0))

gulong  __g_signal_connect_closure_by_id(gpointer , guint , GQuark , GClosure *, gboolean ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4996(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_signal_connect_closure_by_id(__p0, __p1, __p2, __p3, __p4) __g_signal_connect_closure_by_id((__p0), (__p1), (__p2), (__p3), (__p4))

guint  __g_node_n_nodes(GNode *, GTraverseFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1864(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_n_nodes(__p0, __p1) __g_node_n_nodes((__p0), (__p1))

void  __g_io_channel_set_close_on_unref(GIOChannel *, gboolean ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3946(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_set_close_on_unref(__p0, __p1) __g_io_channel_set_close_on_unref((__p0), (__p1))

GQuark  __g_file_error_quark() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-892(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_file_error_quark() __g_file_error_quark()

GDateYear  __g_date_get_year(const GDate *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-634(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_get_year(__p0) __g_date_get_year((__p0))

gchar * __g_intern_static_string(const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4264(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_intern_static_string(__p0) __g_intern_static_string((__p0))

GType  __g_pointer_type_register_static(const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5656(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_pointer_type_register_static(__p0) __g_pointer_type_register_static((__p0))

gboolean  __g_queue_is_empty(GQueue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2158(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_is_empty(__p0) __g_queue_is_empty((__p0))

GSList * __g_slist_delete_link(GSList *, GSList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2740(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_delete_link(__p0, __p1) __g_slist_delete_link((__p0), (__p1))

gint  __g_unichar_xdigit_value(gunichar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3418(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_unichar_xdigit_value(__p0) __g_unichar_xdigit_value((__p0))

GParamSpec * __g_param_spec_enum(const gchar *, const gchar *, const gchar *, GType , gint , GParamFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4846(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_enum(__p0, __p1, __p2, __p3, __p4, __p5) __g_param_spec_enum((__p0), (__p1), (__p2), (__p3), (__p4), (__p5))

gpointer  __g_type_default_interface_ref(GType ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5194(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_default_interface_ref(__p0) __g_type_default_interface_ref((__p0))

void  __g_cache_key_foreach(GCache *, GHFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-412(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_cache_key_foreach(__p0, __p1, __p2) __g_cache_key_foreach((__p0), (__p1), (__p2))

void  __g_relation_index(GRelation *, gint , GHashFunc , GEqualFunc ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2476(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_relation_index(__p0, __p1, __p2, __p3) __g_relation_index((__p0), (__p1), (__p2), (__p3))

GByteArray * __g_byte_array_remove_index(GByteArray *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-220(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_byte_array_remove_index(__p0, __p1) __g_byte_array_remove_index((__p0), (__p1))

gchar * __g_utf8_normalize(const gchar *, gssize , GNormalizeMode ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3598(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_utf8_normalize(__p0, __p1, __p2) __g_utf8_normalize((__p0), (__p1), (__p2))

void  __g_option_context_set_main_group(GOptionContext *, GOptionGroup *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2020(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_option_context_set_main_group(__p0, __p1) __g_option_context_set_main_group((__p0), (__p1))

gchar * __g_ascii_strdown(const gchar *, gssize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2974(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_ascii_strdown(__p0, __p1) __g_ascii_strdown((__p0), (__p1))

void  __g_object_weak_ref(GObject *, GWeakNotify , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4522(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_weak_ref(__p0, __p1, __p2) __g_object_weak_ref((__p0), (__p1), (__p2))

GObject * __g_value_dup_object(const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4642(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_dup_object(__p0) __g_value_dup_object((__p0))

gpointer  __g_param_spec_steal_qdata(GParamSpec *, GQuark ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4696(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_steal_qdata(__p0, __p1) __g_param_spec_steal_qdata((__p0), (__p1))

GRand * __g_rand_copy(GRand *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2392(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_rand_copy(__p0) __g_rand_copy((__p0))

gpointer  __g_try_realloc(gpointer , gulong ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1672(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_try_realloc(__p0, __p1) __g_try_realloc((__p0), (__p1))

gint  __g_mkstemp(gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-922(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_mkstemp(__p0) __g_mkstemp((__p0))

gchar * __g_strdelimit(gchar *, const gchar *, gchar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2848(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_strdelimit(__p0, __p1, __p2) __g_strdelimit((__p0), (__p1), (__p2))

GDateMonth  __g_date_get_month(const GDate *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-628(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_get_month(__p0) __g_date_get_month((__p0))

GValueArray * __g_value_array_new(guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5416(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_array_new(__p0) __g_value_array_new((__p0))

GList * __g_queue_find(GQueue *, gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2188(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_find(__p0, __p1) __g_queue_find((__p0), (__p1))

guint  __g_hash_table_size(GHashTable *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1012(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hash_table_size(__p0) __g_hash_table_size((__p0))

gchar * __g_intern_string(const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4258(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_intern_string(__p0) __g_intern_string((__p0))

GFlagsValue * __g_flags_get_value_by_nick(GFlagsClass *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4342(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_flags_get_value_by_nick(__p0, __p1) __g_flags_get_value_by_nick((__p0), (__p1))

void  __g_main_context_unref(GMainContext *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3730(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_context_unref(__p0) __g_main_context_unref((__p0))

GIOStatus  __g_io_channel_read_line_string(GIOChannel *, GString *, gsize *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3904(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_read_line_string(__p0, __p1, __p2, __p3) __g_io_channel_read_line_string((__p0), (__p1), (__p2), (__p3))

gchar * __g_shell_unquote(const gchar *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2644(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_shell_unquote(__p0, __p1) __g_shell_unquote((__p0), (__p1))

GPollFunc  __g_main_context_get_poll_func(GMainContext *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3670(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_context_get_poll_func(__p0) __g_main_context_get_poll_func((__p0))

gpointer  __g_tree_lookup(GTree *, gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3268(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_tree_lookup(__p0, __p1) __g_tree_lookup((__p0), (__p1))

glong  __g_value_get_long(const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5536(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_get_long(__p0) __g_value_get_long((__p0))

void  __g_log_remove_handler(const gchar *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1762(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_log_remove_handler(__p0, __p1) __g_log_remove_handler((__p0), (__p1))

GOptionGroup * __g_option_group_new(const gchar *, const gchar *, const gchar *, gpointer , GDestroyNotify ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2032(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_option_group_new(__p0, __p1, __p2, __p3, __p4) __g_option_group_new((__p0), (__p1), (__p2), (__p3), (__p4))

GLogFunc  __g_log_set_default_handler(GLogFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1774(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_log_set_default_handler(__p0, __p1) __g_log_set_default_handler((__p0), (__p1))

void  __g_date_set_month(GDate *, GDateMonth ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-694(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_set_month(__p0, __p1) __g_date_set_month((__p0), (__p1))

GString * __g_string_append(GString *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3136(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_string_append(__p0, __p1) __g_string_append((__p0), (__p1))

void  __g_source_add_poll(GSource *, GPollFD *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4180(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_source_add_poll(__p0, __p1) __g_source_add_poll((__p0), (__p1))

gpointer  __g_dataset_id_remove_no_notify(gconstpointer , GQuark ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-544(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_dataset_id_remove_no_notify(__p0, __p1) __g_dataset_id_remove_no_notify((__p0), (__p1))

gchar ** __g_strdupv(gchar **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3052(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_strdupv(__p0) __g_strdupv((__p0))

GByteArray * __g_byte_array_new() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-184(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_byte_array_new() __g_byte_array_new()

gpointer  __g_queue_pop_tail(GQueue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2230(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_pop_tail(__p0) __g_queue_pop_tail((__p0))

void  __g_queue_foreach(GQueue *, GFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2182(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_foreach(__p0, __p1, __p2) __g_queue_foreach((__p0), (__p1), (__p2))

void  __g_object_add_toggle_ref(GObject *, GToggleNotify , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4546(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_add_toggle_ref(__p0, __p1, __p2) __g_object_add_toggle_ref((__p0), (__p1), (__p2))

gunichar2 * __g_utf8_to_utf16(const gchar *, glong , glong *, glong *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3520(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_utf8_to_utf16(__p0, __p1, __p2, __p3, __p4) __g_utf8_to_utf16((__p0), (__p1), (__p2), (__p3), (__p4))

GLogLevelFlags  __g_log_set_fatal_mask(const gchar *, GLogLevelFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1786(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_log_set_fatal_mask(__p0, __p1) __g_log_set_fatal_mask((__p0), (__p1))

void  __g_source_get_current_time(GSource *, GTimeVal *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4192(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_source_get_current_time(__p0, __p1) __g_source_get_current_time((__p0), (__p1))

gchar * __g_utf8_find_next_char(const gchar *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3478(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_utf8_find_next_char(__p0, __p1) __g_utf8_find_next_char((__p0), (__p1))

gboolean  __g_hash_table_steal(GHashTable *, gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-970(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hash_table_steal(__p0, __p1) __g_hash_table_steal((__p0), (__p1))

gulong  __g_signal_connect_closure(gpointer , const gchar *, GClosure *, gboolean ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5002(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_signal_connect_closure(__p0, __p1, __p2, __p3) __g_signal_connect_closure((__p0), (__p1), (__p2), (__p3))

void  __g_node_children_foreach(GNode *, GTraverseFlags , GNodeForeachFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1906(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_children_foreach(__p0, __p1, __p2, __p3) __g_node_children_foreach((__p0), (__p1), (__p2), (__p3))

GMainLoop * __g_main_loop_new(GMainContext *, gboolean ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3766(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_loop_new(__p0, __p1) __g_main_loop_new((__p0), (__p1))

GTokenType  __g_scanner_get_next_token(GScanner *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2548(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_scanner_get_next_token(__p0) __g_scanner_get_next_token((__p0))

gpointer  __g_malloc0(gulong ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1648(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_malloc0(__p0) __g_malloc0((__p0))

void  __g_completion_remove_items(GCompletion *, GList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-436(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_completion_remove_items(__p0, __p1) __g_completion_remove_items((__p0), (__p1))

void  __g_object_watch_closure(GObject *, GClosure *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4606(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_watch_closure(__p0, __p1) __g_object_watch_closure((__p0), (__p1))

void  __g_queue_push_tail(GQueue *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2212(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_push_tail(__p0, __p1) __g_queue_push_tail((__p0), (__p1))

void  __g_object_class_override_property(GObjectClass *, guint , const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4420(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_class_override_property(__p0, __p1, __p2) __g_object_class_override_property((__p0), (__p1), (__p2))

gchar * __g_strndup(const gchar *, gsize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2998(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_strndup(__p0, __p1) __g_strndup((__p0), (__p1))

GIOStatus  __g_io_channel_read_line(GIOChannel *, gchar **, gsize *, gsize *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3898(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_read_line(__p0, __p1, __p2, __p3, __p4) __g_io_channel_read_line((__p0), (__p1), (__p2), (__p3), (__p4))

void  __g_date_set_dmy(GDate *, GDateDay , GDateMonth , GDateYear ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-712(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_set_dmy(__p0, __p1, __p2, __p3) __g_date_set_dmy((__p0), (__p1), (__p2), (__p3))

gboolean  __g_type_module_use(GTypeModule *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5308(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_module_use(__p0) __g_type_module_use((__p0))

void  __g_hash_table_destroy(GHashTable *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-946(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hash_table_destroy(__p0) __g_hash_table_destroy((__p0))

#if defined(USE_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
gchar * __g_strdup_printf(const gchar *, ...) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4234(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_strdup_printf(...) __g_strdup_printf(__VA_ARGS__)
#endif

void  __g_option_group_set_translation_domain(GOptionGroup *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2068(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_option_group_set_translation_domain(__p0, __p1) __g_option_group_set_translation_domain((__p0), (__p1))

void  __g_main_context_wakeup(GMainContext *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3742(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_context_wakeup(__p0) __g_main_context_wakeup((__p0))

gpointer  __g_malloc(gulong ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1642(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_malloc(__p0) __g_malloc((__p0))

GClosure * __g_cclosure_new_object_swap(GCallback , GObject *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4618(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_cclosure_new_object_swap(__p0, __p1) __g_cclosure_new_object_swap((__p0), (__p1))

guint  __g_string_hash(const GString *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3106(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_string_hash(__p0) __g_string_hash((__p0))

void  __g_object_get_property(GObject *, const gchar *, GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4474(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_get_property(__p0, __p1, __p2) __g_object_get_property((__p0), (__p1), (__p2))

gchar * __g_utf8_strreverse(const gchar *, gssize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3514(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_utf8_strreverse(__p0, __p1) __g_utf8_strreverse((__p0), (__p1))

gint  __g_ascii_strcasecmp(const gchar *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2962(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_ascii_strcasecmp(__p0, __p1) __g_ascii_strcasecmp((__p0), (__p1))

GAsyncQueue * __g_async_queue_ref(GAsyncQueue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-268(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_async_queue_ref(__p0) __g_async_queue_ref((__p0))

gdouble  __g_rand_double(GRand *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2422(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_rand_double(__p0) __g_rand_double((__p0))

GIOStatus  __g_io_channel_write_unichar(GIOChannel *, gunichar , GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3988(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_write_unichar(__p0, __p1, __p2) __g_io_channel_write_unichar((__p0), (__p1), (__p2))

gpointer  __g_datalist_id_remove_no_notify(GData **, GQuark ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-496(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_datalist_id_remove_no_notify(__p0, __p1) __g_datalist_id_remove_no_notify((__p0), (__p1))

GLogLevelFlags  __g_log_set_always_fatal(GLogLevelFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1792(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_log_set_always_fatal(__p0) __g_log_set_always_fatal((__p0))

void  __g_date_clear(GDate *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-676(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_clear(__p0, __p1) __g_date_clear((__p0), (__p1))

gboolean  __g_object_is_floating(gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4498(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_is_floating(__p0) __g_object_is_floating((__p0))

void  __g_hash_table_replace(GHashTable *, gpointer , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-958(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hash_table_replace(__p0, __p1, __p2) __g_hash_table_replace((__p0), (__p1), (__p2))

GString * __g_string_prepend_c(GString *, gchar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3166(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_string_prepend_c(__p0, __p1) __g_string_prepend_c((__p0), (__p1))

void  __g_object_add_weak_pointer(GObject *, gpointer *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4534(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_add_weak_pointer(__p0, __p1) __g_object_add_weak_pointer((__p0), (__p1))

GValueArray * __g_value_array_prepend(GValueArray *, const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5434(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_array_prepend(__p0, __p1) __g_value_array_prepend((__p0), (__p1))

GList * __g_list_prepend(GList *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1450(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_prepend(__p0, __p1) __g_list_prepend((__p0), (__p1))

gboolean  __g_date_valid_day(GDateDay ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-586(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_valid_day(__p0) __g_date_valid_day((__p0))

GSList * __g_slist_sort_with_data(GSList *, GCompareDataFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2812(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_sort_with_data(__p0, __p1, __p2) __g_slist_sort_with_data((__p0), (__p1), (__p2))

gchar * __g_key_file_get_locale_string(GKeyFile *, const gchar *, const gchar *, const gchar *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1300(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_get_locale_string(__p0, __p1, __p2, __p3, __p4) __g_key_file_get_locale_string((__p0), (__p1), (__p2), (__p3), (__p4))

GSource * __g_source_ref(GSource *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4108(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_source_ref(__p0) __g_source_ref((__p0))

GQueue * __g_queue_new() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2146(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_new() __g_queue_new()

GEnumValue * __g_enum_get_value_by_nick(GEnumClass *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4324(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_enum_get_value_by_nick(__p0, __p1) __g_enum_get_value_by_nick((__p0), (__p1))

guchar  __g_value_get_uchar(const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5488(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_get_uchar(__p0) __g_value_get_uchar((__p0))

void  __g_object_notify(GObject *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4486(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_notify(__p0, __p1) __g_object_notify((__p0), (__p1))

GList * __g_list_insert(GList *, gpointer , gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1456(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_insert(__p0, __p1, __p2) __g_list_insert((__p0), (__p1), (__p2))

gboolean  __g_io_channel_get_buffered(GIOChannel *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3856(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_get_buffered(__p0) __g_io_channel_get_buffered((__p0))

void  __g_key_file_set_boolean(GKeyFile *, const gchar *, const gchar *, gboolean ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1318(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_set_boolean(__p0, __p1, __p2, __p3) __g_key_file_set_boolean((__p0), (__p1), (__p2), (__p3))

void  __g_hook_list_clear(GHookList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1072(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hook_list_clear(__p0) __g_hook_list_clear((__p0))

GNode * __g_node_first_sibling(GNode *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1954(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_first_sibling(__p0) __g_node_first_sibling((__p0))

gpointer  __g_type_interface_peek(gpointer , GType ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5182(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_interface_peek(__p0, __p1) __g_type_interface_peek((__p0), (__p1))

void  __g_key_file_set_locale_string(GKeyFile *, const gchar *, const gchar *, const gchar *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1306(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_set_locale_string(__p0, __p1, __p2, __p3, __p4) __g_key_file_set_locale_string((__p0), (__p1), (__p2), (__p3), (__p4))

gboolean  __g_signal_parse_name(const gchar *, GType , guint *, GQuark *, gboolean ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4954(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_signal_parse_name(__p0, __p1, __p2, __p3, __p4) __g_signal_parse_name((__p0), (__p1), (__p2), (__p3), (__p4))

gboolean  __g_signal_has_handler_pending(gpointer , guint , GQuark , gboolean ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4990(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_signal_has_handler_pending(__p0, __p1, __p2, __p3) __g_signal_has_handler_pending((__p0), (__p1), (__p2), (__p3))

void  __g_value_set_uchar(GValue *, guchar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5482(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_set_uchar(__p0, __p1) __g_value_set_uchar((__p0), (__p1))

void  __g_key_file_set_integer_list(GKeyFile *, const gchar *, const gchar *, gint *, gsize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1378(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_set_integer_list(__p0, __p1, __p2, __p3, __p4) __g_key_file_set_integer_list((__p0), (__p1), (__p2), (__p3), (__p4))

gboolean  __g_markup_parse_context_end_parse(GMarkupParseContext *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1612(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_markup_parse_context_end_parse(__p0, __p1) __g_markup_parse_context_end_parse((__p0), (__p1))

void  __g_value_set_object(GValue *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4630(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_set_object(__p0, __p1) __g_value_set_object((__p0), (__p1))

gboolean  __g_node_is_ancestor(GNode *, GNode *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1876(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_is_ancestor(__p0, __p1) __g_node_is_ancestor((__p0), (__p1))

GNode * __g_node_last_sibling(GNode *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1960(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_last_sibling(__p0) __g_node_last_sibling((__p0))

gpointer  __g_param_spec_get_qdata(GParamSpec *, GQuark ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4678(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_get_qdata(__p0, __p1) __g_param_spec_get_qdata((__p0), (__p1))

void  __g_rand_free(GRand *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2386(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_rand_free(__p0) __g_rand_free((__p0))

gchar ** __g_uri_list_extract_uris(const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4042(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_uri_list_extract_uris(__p0) __g_uri_list_extract_uris((__p0))

gchar * __g_filename_to_utf8(const gchar *, gssize , gsize *, gsize *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4078(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_filename_to_utf8(__p0, __p1, __p2, __p3, __p4) __g_filename_to_utf8((__p0), (__p1), (__p2), (__p3), (__p4))

void  __g_signal_stop_emission(gpointer , guint , GQuark ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4966(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_signal_stop_emission(__p0, __p1, __p2) __g_signal_stop_emission((__p0), (__p1), (__p2))

GOptionGroup * __g_option_context_get_main_group(GOptionContext *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2026(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_option_context_get_main_group(__p0) __g_option_context_get_main_group((__p0))

guint  __g_signal_handlers_disconnect_matched(gpointer , GSignalMatchType , guint , GQuark , GClosure *, gpointer , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5056(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_signal_handlers_disconnect_matched(__p0, __p1, __p2, __p3, __p4, __p5, __p6) __g_signal_handlers_disconnect_matched((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6))

void  __g_list_free_1(GList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1438(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_free_1(__p0) __g_list_free_1((__p0))

gboolean  __g_date_valid(const GDate *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-580(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_valid(__p0) __g_date_valid((__p0))

GUnicodeBreakType  __g_unichar_break_type(gunichar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3430(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_unichar_break_type(__p0) __g_unichar_break_type((__p0))

GValueArray * __g_value_array_insert(GValueArray *, guint , const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5446(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_array_insert(__p0, __p1, __p2) __g_value_array_insert((__p0), (__p1), (__p2))

void  __g_param_spec_set_qdata(GParamSpec *, GQuark , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4684(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_set_qdata(__p0, __p1, __p2) __g_param_spec_set_qdata((__p0), (__p1), (__p2))

gchar * __g_filename_display_basename(void *, const gchar *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-4050\n"
	"\tblrl";
#define g_filename_display_basename(__p0) __g_filename_display_basename(GLibBase, (__p0))

GParamSpec * __g_param_spec_object(const gchar *, const gchar *, const gchar *, GType , GParamFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4900(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_object(__p0, __p1, __p2, __p3, __p4) __g_param_spec_object((__p0), (__p1), (__p2), (__p3), (__p4))

gpointer  __g_queue_peek_nth(GQueue *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2254(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_peek_nth(__p0, __p1) __g_queue_peek_nth((__p0), (__p1))

GNode * __g_node_nth_child(GNode *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1924(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_nth_child(__p0, __p1) __g_node_nth_child((__p0), (__p1))

GList * __g_list_concat(GList *, GList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1474(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_concat(__p0, __p1) __g_list_concat((__p0), (__p1))

GMainContext * __g_source_get_context(GSource *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4162(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_source_get_context(__p0) __g_source_get_context((__p0))

gboolean  __g_hash_table_lookup_extended(GHashTable *, gconstpointer , gpointer *, gpointer *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-982(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hash_table_lookup_extended(__p0, __p1, __p2, __p3) __g_hash_table_lookup_extended((__p0), (__p1), (__p2), (__p3))

GType  __g_type_from_name(const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5122(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_from_name(__p0) __g_type_from_name((__p0))

GList * __g_list_find_custom(GList *, gconstpointer , GCompareFunc ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1534(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_find_custom(__p0, __p1, __p2) __g_list_find_custom((__p0), (__p1), (__p2))

gchar * __g_filename_display_name(const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4054(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_filename_display_name(__p0) __g_filename_display_name((__p0))

gunichar2 * __g_ucs4_to_utf16(const gunichar *, glong , glong *, glong *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3550(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_ucs4_to_utf16(__p0, __p1, __p2, __p3, __p4) __g_ucs4_to_utf16((__p0), (__p1), (__p2), (__p3), (__p4))

void  __g_value_copy(const GValue *, GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5386(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_copy(__p0, __p1) __g_value_copy((__p0), (__p1))

gchar ** __g_key_file_get_string_list(GKeyFile *, const gchar *, const gchar *, gsize *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1336(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_get_string_list(__p0, __p1, __p2, __p3, __p4) __g_key_file_get_string_list((__p0), (__p1), (__p2), (__p3), (__p4))

void  __g_byte_array_sort(GByteArray *, GCompareFunc ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-238(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_byte_array_sort(__p0, __p1) __g_byte_array_sort((__p0), (__p1))

GType  __g_type_next_base(GType , GType ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5140(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_next_base(__p0, __p1) __g_type_next_base((__p0), (__p1))

void  __g_list_push_allocator(GAllocator *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1414(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_push_allocator(__p0) __g_list_push_allocator((__p0))

gpointer  __g_value_get_pointer(const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5632(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_get_pointer(__p0) __g_value_get_pointer((__p0))

guint  __g_list_length(GList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1564(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_length(__p0) __g_list_length((__p0))

void  __g_scanner_input_text(GScanner *, const gchar *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2542(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_scanner_input_text(__p0, __p1, __p2) __g_scanner_input_text((__p0), (__p1), (__p2))

GSource * __g_timeout_source_new(guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4096(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_timeout_source_new(__p0) __g_timeout_source_new((__p0))

gchar * __g_utf8_find_prev_char(const gchar *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3484(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_utf8_find_prev_char(__p0, __p1) __g_utf8_find_prev_char((__p0), (__p1))

void  __g_value_set_double(GValue *, gdouble ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5590(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_set_double(__p0, __p1) __g_value_set_double((__p0), (__p1))

void  __g_slist_foreach(GSList *, GFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2800(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_foreach(__p0, __p1, __p2) __g_slist_foreach((__p0), (__p1), (__p2))

void  __g_value_set_uint(GValue *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5518(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_set_uint(__p0, __p1) __g_value_set_uint((__p0), (__p1))

guint  __g_int_hash(gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1048(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_int_hash(__p0) __g_int_hash((__p0))

gchar * __g_strnfill(gsize , gchar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3004(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_strnfill(__p0, __p1) __g_strnfill((__p0), (__p1))

gboolean  __g_unichar_ispunct(gunichar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3352(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_unichar_ispunct(__p0) __g_unichar_ispunct((__p0))

void  __g_hook_unref(GHookList *, GHook *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1096(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hook_unref(__p0, __p1) __g_hook_unref((__p0), (__p1))

gboolean  __g_unichar_validate(gunichar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3574(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_unichar_validate(__p0) __g_unichar_validate((__p0))

GType  __g_type_register_fundamental(GType , const gchar *, const GTypeInfo *, const GTypeFundamentalInfo *, GTypeFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5260(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_register_fundamental(__p0, __p1, __p2, __p3, __p4) __g_type_register_fundamental((__p0), (__p1), (__p2), (__p3), (__p4))

gchar * __g_strreverse(gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2872(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_strreverse(__p0) __g_strreverse((__p0))

gunichar  __g_unichar_tolower(gunichar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3400(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_unichar_tolower(__p0) __g_unichar_tolower((__p0))

GParamSpec * __g_param_spec_double(const gchar *, const gchar *, const gchar *, gdouble , gdouble , gdouble , GParamFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4864(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_double(__p0, __p1, __p2, __p3, __p4, __p5, __p6) __g_param_spec_double((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6))

gint  __g_unichar_digit_value(gunichar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3412(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_unichar_digit_value(__p0) __g_unichar_digit_value((__p0))

gint  __g_date_days_between(const GDate *, const GDate *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-796(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_days_between(__p0, __p1) __g_date_days_between((__p0), (__p1))

GParamSpec * __g_param_spec_ref(GParamSpec *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4654(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_ref(__p0) __g_param_spec_ref((__p0))

guint  __g_signal_lookup(const gchar *, GType ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4930(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_signal_lookup(__p0, __p1) __g_signal_lookup((__p0), (__p1))

gpointer  __g_ptr_array_remove_index(GPtrArray *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-130(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_ptr_array_remove_index(__p0, __p1) __g_ptr_array_remove_index((__p0), (__p1))

void  __g_type_interface_add_prerequisite(GType , GType ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5278(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_interface_add_prerequisite(__p0, __p1) __g_type_interface_add_prerequisite((__p0), (__p1))

guint  __g_str_hash(gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1036(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_str_hash(__p0) __g_str_hash((__p0))

void  __g_value_set_enum(GValue *, gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4348(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_set_enum(__p0, __p1) __g_value_set_enum((__p0), (__p1))

gboolean  __g_date_valid_year(GDateYear ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-598(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_valid_year(__p0) __g_date_valid_year((__p0))

gsize  __g_strlcat(gchar *, const gchar *, gsize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2884(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_strlcat(__p0, __p1, __p2) __g_strlcat((__p0), (__p1), (__p2))

void  __g_type_add_interface_dynamic(GType , GType , GTypePlugin *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5272(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_add_interface_dynamic(__p0, __p1, __p2) __g_type_add_interface_dynamic((__p0), (__p1), (__p2))

gchar * __g_utf8_prev_char(const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3472(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_utf8_prev_char(__p0) __g_utf8_prev_char((__p0))

void  __g_markup_parse_context_get_position(GMarkupParseContext *, gint *, gint *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1624(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_markup_parse_context_get_position(__p0, __p1, __p2) __g_markup_parse_context_get_position((__p0), (__p1), (__p2))

GList * __g_list_remove_all(GList *, gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1486(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_remove_all(__p0, __p1) __g_list_remove_all((__p0), (__p1))

GNode * __g_node_find(GNode *, GTraverseType , GTraverseFlags , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1888(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_find(__p0, __p1, __p2, __p3) __g_node_find((__p0), (__p1), (__p2), (__p3))

void  __g_cache_value_foreach(GCache *, GHFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-418(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_cache_value_foreach(__p0, __p1, __p2) __g_cache_value_foreach((__p0), (__p1), (__p2))

gboolean  __g_unichar_istitle(gunichar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3376(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_unichar_istitle(__p0) __g_unichar_istitle((__p0))

GSignalInvocationHint * __g_signal_get_invocation_hint(gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4960(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_signal_get_invocation_hint(__p0) __g_signal_get_invocation_hint((__p0))

gchar * __g_locale_from_utf8(const gchar *, gssize , gsize *, gsize *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4030(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_locale_from_utf8(__p0, __p1, __p2, __p3, __p4) __g_locale_from_utf8((__p0), (__p1), (__p2), (__p3), (__p4))

GDate * __g_date_new_julian(guint32 ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-568(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_new_julian(__p0) __g_date_new_julian((__p0))

void  __g_key_file_free(GKeyFile *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1210(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_free(__p0) __g_key_file_free((__p0))

gsize  __g_printf_string_upper_bound(const gchar *, va_list ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1750(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_printf_string_upper_bound(__p0, __p1) __g_printf_string_upper_bound((__p0), (__p1))

gsize  __g_date_strftime(gchar *, gsize , const gchar *, const GDate *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-826(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_strftime(__p0, __p1, __p2, __p3) __g_date_strftime((__p0), (__p1), (__p2), (__p3))

void  __g_object_remove_weak_pointer(GObject *, gpointer *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4540(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_remove_weak_pointer(__p0, __p1) __g_object_remove_weak_pointer((__p0), (__p1))

GQuark  __g_quark_from_string(const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2134(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_quark_from_string(__p0) __g_quark_from_string((__p0))

gpointer  __g_async_queue_try_pop(GAsyncQueue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-304(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_async_queue_try_pop(__p0) __g_async_queue_try_pop((__p0))

GSList * __g_slist_find(GSList *, gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2764(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_find(__p0, __p1) __g_slist_find((__p0), (__p1))

GObject * __g_object_new_valist(GType , const gchar *, va_list ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4450(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_new_valist(__p0, __p1, __p2) __g_object_new_valist((__p0), (__p1), (__p2))

void  __g_node_pop_allocator() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1804(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_pop_allocator() __g_node_pop_allocator()

void  __g_type_class_unref(gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5170(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_class_unref(__p0) __g_type_class_unref((__p0))

gboolean  __g_option_context_get_ignore_unknown_options(GOptionContext *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1996(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_option_context_get_ignore_unknown_options(__p0) __g_option_context_get_ignore_unknown_options((__p0))

gboolean  __g_main_loop_is_running(GMainLoop *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3760(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_loop_is_running(__p0) __g_main_loop_is_running((__p0))

gchar * __g_utf8_strncpy(gchar *, const gchar *, gsize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3496(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_utf8_strncpy(__p0, __p1, __p2) __g_utf8_strncpy((__p0), (__p1), (__p2))

GList * __g_list_delete_link(GList *, GList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1498(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_delete_link(__p0, __p1) __g_list_delete_link((__p0), (__p1))

void  __g_key_file_remove_key(GKeyFile *, const gchar *, const gchar *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1402(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_remove_key(__p0, __p1, __p2, __p3) __g_key_file_remove_key((__p0), (__p1), (__p2), (__p3))

void  __g_hook_prepend(GHookList *, GHook *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1114(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hook_prepend(__p0, __p1) __g_hook_prepend((__p0), (__p1))

GQueue * __g_queue_copy(GQueue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2176(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_copy(__p0) __g_queue_copy((__p0))

GError * __g_error_new_literal(GQuark , gint , const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-856(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_error_new_literal(__p0, __p1, __p2) __g_error_new_literal((__p0), (__p1), (__p2))

void  __g_mem_chunk_destroy(GMemChunk *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1684(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_mem_chunk_destroy(__p0) __g_mem_chunk_destroy((__p0))

void  __g_completion_clear_items(GCompletion *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-442(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_completion_clear_items(__p0) __g_completion_clear_items((__p0))

void  __g_param_spec_set_qdata_full(GParamSpec *, GQuark , gpointer , GDestroyNotify ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4690(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_set_qdata_full(__p0, __p1, __p2, __p3) __g_param_spec_set_qdata_full((__p0), (__p1), (__p2), (__p3))

gint  __g_slist_index(GSList *, gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2782(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_index(__p0, __p1) __g_slist_index((__p0), (__p1))

void  __g_object_set_property(GObject *, const gchar *, const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4468(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_set_property(__p0, __p1, __p2) __g_object_set_property((__p0), (__p1), (__p2))

GHook * __g_hook_first_valid(GHookList *, gboolean ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1162(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hook_first_valid(__p0, __p1) __g_hook_first_valid((__p0), (__p1))

gpointer  __g_cache_insert(GCache *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-400(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_cache_insert(__p0, __p1) __g_cache_insert((__p0), (__p1))

GSList * __g_slist_remove_link(GSList *, GSList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2734(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_remove_link(__p0, __p1) __g_slist_remove_link((__p0), (__p1))

void  __g_date_clamp(GDate *, const GDate *, const GDate *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-814(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_clamp(__p0, __p1, __p2) __g_date_clamp((__p0), (__p1), (__p2))

void  __g_main_context_remove_poll(GMainContext *, GPollFD *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3718(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_context_remove_poll(__p0, __p1) __g_main_context_remove_poll((__p0), (__p1))

void  __g_byte_array_sort_with_data(GByteArray *, GCompareDataFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-244(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_byte_array_sort_with_data(__p0, __p1, __p2) __g_byte_array_sort_with_data((__p0), (__p1), (__p2))

gboolean  __g_string_equal(const GString *, const GString *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3100(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_string_equal(__p0, __p1) __g_string_equal((__p0), (__p1))

GNode * __g_node_new(gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1810(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_new(__p0) __g_node_new((__p0))

GType  __g_type_plugin_get_type() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5350(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_plugin_get_type() __g_type_plugin_get_type()

gboolean  __g_unichar_isspace(gunichar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3358(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_unichar_isspace(__p0) __g_unichar_isspace((__p0))

gboolean  __g_unichar_isdefined(gunichar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3382(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_unichar_isdefined(__p0) __g_unichar_isdefined((__p0))

GParamSpec * __g_param_spec_value_array(const gchar *, const gchar *, const gchar *, GParamSpec *, GParamFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4894(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_value_array(__p0, __p1, __p2, __p3, __p4) __g_param_spec_value_array((__p0), (__p1), (__p2), (__p3), (__p4))

GString * __g_string_ascii_down(GString *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3208(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_string_ascii_down(__p0) __g_string_ascii_down((__p0))

gchar * __g_utf8_strdown(const gchar *, gssize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3586(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_utf8_strdown(__p0, __p1) __g_utf8_strdown((__p0), (__p1))

void  __g_date_order(GDate *, GDate *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-820(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_order(__p0, __p1) __g_date_order((__p0), (__p1))

gpointer  __g_queue_peek_head(GQueue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2242(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_peek_head(__p0) __g_queue_peek_head((__p0))

GParamSpec * __g_param_spec_override(const gchar *, GParamSpec *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4906(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_override(__p0, __p1) __g_param_spec_override((__p0), (__p1))

void  __g_io_channel_set_buffered(GIOChannel *, gboolean ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3940(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_set_buffered(__p0, __p1) __g_io_channel_set_buffered((__p0), (__p1))

GParamSpec * __g_param_spec_ulong(const gchar *, const gchar *, const gchar *, gulong , gulong , gulong , GParamFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4822(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_ulong(__p0, __p1, __p2, __p3, __p4, __p5, __p6) __g_param_spec_ulong((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6))

gint  __g_node_child_index(GNode *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1948(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_child_index(__p0, __p1) __g_node_child_index((__p0), (__p1))

gint  __g_file_open_tmp(const gchar *, gchar **, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-928(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_file_open_tmp(__p0, __p1, __p2) __g_file_open_tmp((__p0), (__p1), (__p2))

void  __g_nullify_pointer(gpointer *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4216(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_nullify_pointer(__p0) __g_nullify_pointer((__p0))

gpointer  __g_async_queue_pop_unlocked(GAsyncQueue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-298(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_async_queue_pop_unlocked(__p0) __g_async_queue_pop_unlocked((__p0))

gboolean  __g_key_file_load_from_data_dirs(GKeyFile *, const gchar *, gchar **, GKeyFileFlags , GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1234(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_load_from_data_dirs(__p0, __p1, __p2, __p3, __p4) __g_key_file_load_from_data_dirs((__p0), (__p1), (__p2), (__p3), (__p4))

guint  __g_queue_get_length(GQueue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2164(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_get_length(__p0) __g_queue_get_length((__p0))

gchar * __g_strcompress(const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3010(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_strcompress(__p0) __g_strcompress((__p0))

void  __g_option_group_free(GOptionGroup *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2050(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_option_group_free(__p0) __g_option_group_free((__p0))

GParamSpec * __g_param_spec_flags(const gchar *, const gchar *, const gchar *, GType , guint , GParamFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4852(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_flags(__p0, __p1, __p2, __p3, __p4, __p5) __g_param_spec_flags((__p0), (__p1), (__p2), (__p3), (__p4), (__p5))

GArray * __g_array_new(gboolean , gboolean , guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-34(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_array_new(__p0, __p1, __p2) __g_array_new((__p0), (__p1), (__p2))

void  __g_option_group_set_error_hook(GOptionGroup *, GOptionErrorFunc ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2044(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_option_group_set_error_hook(__p0, __p1) __g_option_group_set_error_hook((__p0), (__p1))

void  __g_propagate_error(GError **, GError *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-880(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_propagate_error(__p0, __p1) __g_propagate_error((__p0), (__p1))

gboolean  __g_ptr_array_remove_fast(GPtrArray *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-148(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_ptr_array_remove_fast(__p0, __p1) __g_ptr_array_remove_fast((__p0), (__p1))

void  __g_datalist_unset_flags(GData **, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-514(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_datalist_unset_flags(__p0, __p1) __g_datalist_unset_flags((__p0), (__p1))

void  __g_flags_complete_type_info(GType , GTypeInfo *, const GFlagsValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4390(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_flags_complete_type_info(__p0, __p1, __p2) __g_flags_complete_type_info((__p0), (__p1), (__p2))

gint  __g_tree_nnodes(GTree *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3298(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_tree_nnodes(__p0) __g_tree_nnodes((__p0))

gboolean  __g_unichar_isdigit(gunichar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3328(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_unichar_isdigit(__p0) __g_unichar_isdigit((__p0))

GMarkupParseContext * __g_markup_parse_context_new(const GMarkupParser *, GMarkupParseFlags , gpointer , GDestroyNotify ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1594(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_markup_parse_context_new(__p0, __p1, __p2, __p3) __g_markup_parse_context_new((__p0), (__p1), (__p2), (__p3))

void  __g_source_set_closure(GSource *, GClosure *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5080(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_source_set_closure(__p0, __p1) __g_source_set_closure((__p0), (__p1))

gboolean  __g_source_get_can_recurse(GSource *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4150(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_source_get_can_recurse(__p0) __g_source_get_can_recurse((__p0))

GTree * __g_tree_new(GCompareFunc ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3220(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_tree_new(__p0) __g_tree_new((__p0))

GIOFlags  __g_io_channel_get_flags(GIOChannel *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3868(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_get_flags(__p0) __g_io_channel_get_flags((__p0))

gchar * __g_value_dup_string(const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5620(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_dup_string(__p0) __g_value_dup_string((__p0))

gchar * __g_array_free(GArray *, gboolean ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-46(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_array_free(__p0, __p1) __g_array_free((__p0), (__p1))

gchar * __g_strchug(gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2950(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_strchug(__p0) __g_strchug((__p0))

GList * __g_list_nth_prev(GList *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1522(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_nth_prev(__p0, __p1) __g_list_nth_prev((__p0), (__p1))

gint  __g_atomic_int_exchange_and_add(gint *, gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-340(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_atomic_int_exchange_and_add(__p0, __p1) __g_atomic_int_exchange_and_add((__p0), (__p1))

gchar * __g_stpcpy(gchar *, const char *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3064(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_stpcpy(__p0, __p1) __g_stpcpy((__p0), (__p1))

void  __g_type_plugin_complete_interface_info(GTypePlugin *, GType , GType , GInterfaceInfo *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5374(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_plugin_complete_interface_info(__p0, __p1, __p2, __p3) __g_type_plugin_complete_interface_info((__p0), (__p1), (__p2), (__p3))

GIOStatus  __g_io_channel_set_flags(GIOChannel *, GIOFlags , GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3958(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_set_flags(__p0, __p1, __p2) __g_io_channel_set_flags((__p0), (__p1), (__p2))

void  __g_async_queue_lock(GAsyncQueue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-256(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_async_queue_lock(__p0) __g_async_queue_lock((__p0))

gpointer  __g_dataset_id_get_data(gconstpointer , GQuark ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-532(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_dataset_id_get_data(__p0, __p1) __g_dataset_id_get_data((__p0), (__p1))

void  __g_completion_set_compare(GCompletion *, GCompletionStrncmpFunc ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-460(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_completion_set_compare(__p0, __p1) __g_completion_set_compare((__p0), (__p1))

void  __g_object_set_data_full(GObject *, const gchar *, gpointer , GDestroyNotify ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4594(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_set_data_full(__p0, __p1, __p2, __p3) __g_object_set_data_full((__p0), (__p1), (__p2), (__p3))

GFlagsValue * __g_flags_get_first_value(GFlagsClass *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4330(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_flags_get_first_value(__p0, __p1) __g_flags_get_first_value((__p0), (__p1))

void  __g_rand_set_seed(GRand *, guint32 ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2398(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_rand_set_seed(__p0, __p1) __g_rand_set_seed((__p0), (__p1))

gpointer  __g_async_queue_pop(GAsyncQueue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-292(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_async_queue_pop(__p0) __g_async_queue_pop((__p0))

void  __g_node_traverse(GNode *, GTraverseType , GTraverseFlags , gint , GNodeTraverseFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1894(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_traverse(__p0, __p1, __p2, __p3, __p4, __p5) __g_node_traverse((__p0), (__p1), (__p2), (__p3), (__p4), (__p5))

gchar * __g_filename_to_uri(const gchar *, const gchar *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4072(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_filename_to_uri(__p0, __p1, __p2) __g_filename_to_uri((__p0), (__p1), (__p2))

gboolean  __g_pattern_match_simple(const gchar *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2104(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_pattern_match_simple(__p0, __p1) __g_pattern_match_simple((__p0), (__p1))

GParamSpec ** __g_object_class_list_properties(GObjectClass *, guint *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4414(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_class_list_properties(__p0, __p1) __g_object_class_list_properties((__p0), (__p1))

gpointer  __g_type_class_ref(GType ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5152(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_class_ref(__p0) __g_type_class_ref((__p0))

GHashTable * __g_hash_table_new(GHashFunc , GEqualFunc ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-934(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hash_table_new(__p0, __p1) __g_hash_table_new((__p0), (__p1))

void  __g_async_queue_push_unlocked(GAsyncQueue *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-286(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_async_queue_push_unlocked(__p0, __p1) __g_async_queue_push_unlocked((__p0), (__p1))

GValueArray * __g_value_array_sort_with_data(GValueArray *, GCompareDataFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5464(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_array_sort_with_data(__p0, __p1, __p2) __g_value_array_sort_with_data((__p0), (__p1), (__p2))

void  __g_logv(const gchar *, GLogLevelFlags , const gchar *, va_list ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1780(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_logv(__p0, __p1, __p2, __p3) __g_logv((__p0), (__p1), (__p2), (__p3))

void  __g_ptr_array_set_size(GPtrArray *, gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-124(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_ptr_array_set_size(__p0, __p1) __g_ptr_array_set_size((__p0), (__p1))

void  __g_option_context_set_help_enabled(GOptionContext *, gboolean ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1978(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_option_context_set_help_enabled(__p0, __p1) __g_option_context_set_help_enabled((__p0), (__p1))

GMainLoop * __g_main_loop_ref(GMainLoop *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3778(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_loop_ref(__p0) __g_main_loop_ref((__p0))

GIOStatus  __g_io_channel_read_chars(GIOChannel *, gchar *, gsize , gsize *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3892(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_read_chars(__p0, __p1, __p2, __p3, __p4) __g_io_channel_read_chars((__p0), (__p1), (__p2), (__p3), (__p4))

void  __g_datalist_clear(GData **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-478(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_datalist_clear(__p0) __g_datalist_clear((__p0))

void  __g_date_subtract_months(GDate *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-754(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_subtract_months(__p0, __p1) __g_date_subtract_months((__p0), (__p1))

void  __g_blow_chunks() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1732(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_blow_chunks() __g_blow_chunks()

gpointer  __g_mem_chunk_alloc(GMemChunk *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1690(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_mem_chunk_alloc(__p0) __g_mem_chunk_alloc((__p0))

GList * __g_list_sort(GList *, GCompareFunc ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1576(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_sort(__p0, __p1) __g_list_sort((__p0), (__p1))

void  __g_date_set_parse(GDate *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-682(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_set_parse(__p0, __p1) __g_date_set_parse((__p0), (__p1))

gint  __g_date_compare(const GDate *, const GDate *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-802(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_compare(__p0, __p1) __g_date_compare((__p0), (__p1))

GString * __g_string_prepend(GString *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3160(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_string_prepend(__p0, __p1) __g_string_prepend((__p0), (__p1))

guint  __g_date_get_iso8601_week_of_year(const GDate *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-670(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_get_iso8601_week_of_year(__p0) __g_date_get_iso8601_week_of_year((__p0))

void  __g_queue_free(GQueue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2152(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_free(__p0) __g_queue_free((__p0))

gint  __g_main_context_check(GMainContext *, gint , GPollFD *, gint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3634(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_context_check(__p0, __p1, __p2, __p3) __g_main_context_check((__p0), (__p1), (__p2), (__p3))

gboolean  __g_str_has_suffix(const gchar *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2908(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_str_has_suffix(__p0, __p1) __g_str_has_suffix((__p0), (__p1))

GList * __g_queue_pop_nth_link(GQueue *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2326(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_pop_nth_link(__p0, __p1) __g_queue_pop_nth_link((__p0), (__p1))

GIOStatus  __g_io_channel_seek_position(GIOChannel *, gint64 , GSeekType , GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3928(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_seek_position(__p0, __p1, __p2, __p3) __g_io_channel_seek_position((__p0), (__p1), (__p2), (__p3))

GType  __g_type_parent(GType ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5128(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_parent(__p0) __g_type_parent((__p0))

gint  __g_ascii_xdigit_value(gchar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2842(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_ascii_xdigit_value(__p0) __g_ascii_xdigit_value((__p0))

GIOCondition  __g_io_channel_get_buffer_condition(GIOChannel *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3844(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_get_buffer_condition(__p0) __g_io_channel_get_buffer_condition((__p0))

gchar * __g_utf8_strrchr(const gchar *, gssize , gunichar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3508(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_utf8_strrchr(__p0, __p1, __p2) __g_utf8_strrchr((__p0), (__p1), (__p2))

void  __g_source_remove_poll(GSource *, GPollFD *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4186(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_source_remove_poll(__p0, __p1) __g_source_remove_poll((__p0), (__p1))

gpointer * __g_ptr_array_free(GPtrArray *, gboolean ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-118(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_ptr_array_free(__p0, __p1) __g_ptr_array_free((__p0), (__p1))

gboolean  __g_unichar_isgraph(gunichar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3334(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_unichar_isgraph(__p0) __g_unichar_isgraph((__p0))

guint  __g_signal_new_valist(const gchar *, GType , GSignalFlags , GClosure *, GSignalAccumulator , gpointer , GSignalCMarshaller , GType , guint , va_list ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4924(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_signal_new_valist(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7, __p8, __p9) __g_signal_new_valist((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7), (__p8), (__p9))

gchar  __g_value_get_char(const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5476(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_get_char(__p0) __g_value_get_char((__p0))

gpointer  __g_datalist_id_get_data(GData **, GQuark ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-484(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_datalist_id_get_data(__p0, __p1) __g_datalist_id_get_data((__p0), (__p1))

void  __g_param_spec_unref(GParamSpec *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4660(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_unref(__p0) __g_param_spec_unref((__p0))

void  __g_value_set_instance(GValue *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5404(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_set_instance(__p0, __p1) __g_value_set_instance((__p0), (__p1))

guint  __g_date_get_day_of_year(const GDate *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-652(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_get_day_of_year(__p0) __g_date_get_day_of_year((__p0))

void  __g_tree_insert(GTree *, gpointer , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3244(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_tree_insert(__p0, __p1, __p2) __g_tree_insert((__p0), (__p1), (__p2))

gchar * __g_utf8_strup(const gchar *, gssize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3580(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_utf8_strup(__p0, __p1) __g_utf8_strup((__p0), (__p1))

gboolean  __g_key_file_get_boolean(GKeyFile *, const gchar *, const gchar *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1312(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_get_boolean(__p0, __p1, __p2, __p3) __g_key_file_get_boolean((__p0), (__p1), (__p2), (__p3))

GType * __g_type_interface_prerequisites(GType , guint *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5284(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_interface_prerequisites(__p0, __p1) __g_type_interface_prerequisites((__p0), (__p1))

void  __g_atomic_pointer_set(volatile gpointer *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-382(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_atomic_pointer_set(__p0, __p1) __g_atomic_pointer_set((__p0), (__p1))

void  __g_tree_steal(GTree *, gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3262(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_tree_steal(__p0, __p1) __g_tree_steal((__p0), (__p1))

void  __g_queue_remove_all(GQueue *, gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2272(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_remove_all(__p0, __p1) __g_queue_remove_all((__p0), (__p1))

GAllocator * __g_allocator_new(const gchar *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1738(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_allocator_new(__p0, __p1) __g_allocator_new((__p0), (__p1))

GParamSpec * __g_param_spec_param(const gchar *, const gchar *, const gchar *, GType , GParamFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4876(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_param(__p0, __p1, __p2, __p3, __p4) __g_param_spec_param((__p0), (__p1), (__p2), (__p3), (__p4))

GTree * __g_tree_new_with_data(GCompareDataFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3226(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_tree_new_with_data(__p0, __p1) __g_tree_new_with_data((__p0), (__p1))

GParamSpec ** __g_object_interface_list_properties(gpointer , guint *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4438(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_interface_list_properties(__p0, __p1) __g_object_interface_list_properties((__p0), (__p1))

glong  __g_utf8_pointer_to_offset(const gchar *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3466(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_utf8_pointer_to_offset(__p0, __p1) __g_utf8_pointer_to_offset((__p0), (__p1))

void  __g_hook_list_marshal_check(GHookList *, gboolean , GHookCheckMarshaller , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1198(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hook_list_marshal_check(__p0, __p1, __p2, __p3) __g_hook_list_marshal_check((__p0), (__p1), (__p2), (__p3))

GType  __g_io_channel_get_type() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5086(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_get_type() __g_io_channel_get_type()

GPatternSpec * __g_pattern_spec_new(const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2074(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_pattern_spec_new(__p0) __g_pattern_spec_new((__p0))

gint  __g_source_get_priority(GSource *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4138(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_source_get_priority(__p0) __g_source_get_priority((__p0))

guint  __g_child_watch_add_full(gint , GPid , GChildWatchFunc , gpointer , GDestroyNotify ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4018(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_child_watch_add_full(__p0, __p1, __p2, __p3, __p4) __g_child_watch_add_full((__p0), (__p1), (__p2), (__p3), (__p4))

GList * __g_completion_complete_utf8(GCompletion *, const gchar *, gchar **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-454(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_completion_complete_utf8(__p0, __p1, __p2) __g_completion_complete_utf8((__p0), (__p1), (__p2))

gboolean  __g_hash_table_remove(GHashTable *, gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-964(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hash_table_remove(__p0, __p1) __g_hash_table_remove((__p0), (__p1))

gpointer  __g_scanner_lookup_symbol(GScanner *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2620(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_scanner_lookup_symbol(__p0, __p1) __g_scanner_lookup_symbol((__p0), (__p1))

GNode * __g_node_insert(GNode *, gint , GNode *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1840(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_insert(__p0, __p1, __p2) __g_node_insert((__p0), (__p1), (__p2))

GParamSpec * __g_param_spec_boolean(const gchar *, const gchar *, const gchar *, gboolean , GParamFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4798(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_boolean(__p0, __p1, __p2, __p3, __p4) __g_param_spec_boolean((__p0), (__p1), (__p2), (__p3), (__p4))

GString * __g_string_truncate(GString *, gsize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3118(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_string_truncate(__p0, __p1) __g_string_truncate((__p0), (__p1))

gchar * __g_utf8_strchr(const gchar *, gssize , gunichar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3502(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_utf8_strchr(__p0, __p1, __p2) __g_utf8_strchr((__p0), (__p1), (__p2))

gint  __g_node_child_position(GNode *, GNode *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1942(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_child_position(__p0, __p1) __g_node_child_position((__p0), (__p1))

void  __g_object_weak_unref(GObject *, GWeakNotify , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4528(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_weak_unref(__p0, __p1, __p2) __g_object_weak_unref((__p0), (__p1), (__p2))

guint  __g_direct_hash(gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1054(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_direct_hash(__p0) __g_direct_hash((__p0))

GType  __g_io_condition_get_type() =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5092(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_condition_get_type() __g_io_condition_get_type()

void  __g_value_set_string(GValue *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5602(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_set_string(__p0, __p1) __g_value_set_string((__p0), (__p1))

GNode * __g_node_copy(GNode *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1834(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_copy(__p0) __g_node_copy((__p0))

void  __g_key_file_remove_group(GKeyFile *, const gchar *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1408(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_remove_group(__p0, __p1, __p2) __g_key_file_remove_group((__p0), (__p1), (__p2))

gboolean  __g_str_has_prefix(const gchar *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2914(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_str_has_prefix(__p0, __p1) __g_str_has_prefix((__p0), (__p1))

gchar * __g_strrstr(const gchar *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2896(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_strrstr(__p0, __p1) __g_strrstr((__p0), (__p1))

GParamSpec * __g_param_spec_unichar(const gchar *, const gchar *, const gchar *, gunichar , GParamFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4840(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_unichar(__p0, __p1, __p2, __p3, __p4) __g_param_spec_unichar((__p0), (__p1), (__p2), (__p3), (__p4))

GList * __g_list_nth(GList *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1516(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_nth(__p0, __p1) __g_list_nth((__p0), (__p1))

guint64  __g_value_get_uint64(const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5572(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_get_uint64(__p0) __g_value_get_uint64((__p0))

void  __g_date_subtract_years(GDate *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-766(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_date_subtract_years(__p0, __p1) __g_date_subtract_years((__p0), (__p1))

gdouble  __g_ascii_strtod(const gchar *, gchar **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2926(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_ascii_strtod(__p0, __p1) __g_ascii_strtod((__p0), (__p1))

gpointer  __g_memdup(gconstpointer , guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3022(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_memdup(__p0, __p1) __g_memdup((__p0), (__p1))

void  __g_key_file_set_string(GKeyFile *, const gchar *, const gchar *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1294(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_set_string(__p0, __p1, __p2, __p3) __g_key_file_set_string((__p0), (__p1), (__p2), (__p3))

GSList * __g_slist_copy(GSList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2752(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_copy(__p0) __g_slist_copy((__p0))

gboolean  __g_get_charset(G_CONST_RETURN char **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3304(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_get_charset(__p0) __g_get_charset((__p0))

GType  __g_type_register_dynamic(GType , const gchar *, GTypePlugin *, GTypeFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5254(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_register_dynamic(__p0, __p1, __p2, __p3) __g_type_register_dynamic((__p0), (__p1), (__p2), (__p3))

gboolean  __g_file_get_contents(const gchar *, gchar **, gsize *, GError **) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-910(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_file_get_contents(__p0, __p1, __p2, __p3) __g_file_get_contents((__p0), (__p1), (__p2), (__p3))

guint  __g_signal_handlers_block_matched(gpointer , GSignalMatchType , guint , GQuark , GClosure *, gpointer , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5044(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_signal_handlers_block_matched(__p0, __p1, __p2, __p3, __p4, __p5, __p6) __g_signal_handlers_block_matched((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6))

void  __g_node_destroy(GNode *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1816(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_node_destroy(__p0) __g_node_destroy((__p0))

gboolean  __g_source_remove_by_user_data(gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4204(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_source_remove_by_user_data(__p0) __g_source_remove_by_user_data((__p0))

GParamSpec * __g_param_spec_int64(const gchar *, const gchar *, const gchar *, gint64 , gint64 , gint64 , GParamFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4828(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_int64(__p0, __p1, __p2, __p3, __p4, __p5, __p6) __g_param_spec_int64((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6))

gboolean  __g_str_equal(gconstpointer , gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1030(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_str_equal(__p0, __p1) __g_str_equal((__p0), (__p1))

gchar * __g_strchomp(gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2956(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_strchomp(__p0) __g_strchomp((__p0))

void  __g_option_context_add_group(GOptionContext *, GOptionGroup *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2014(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_option_context_add_group(__p0, __p1) __g_option_context_add_group((__p0), (__p1))

GParamSpec * __g_param_spec_string(const gchar *, const gchar *, const gchar *, const gchar *, GParamFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4870(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_string(__p0, __p1, __p2, __p3, __p4) __g_param_spec_string((__p0), (__p1), (__p2), (__p3), (__p4))

gpointer  __g_queue_peek_tail(GQueue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2248(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_peek_tail(__p0) __g_queue_peek_tail((__p0))

void  __g_scanner_destroy(GScanner *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2524(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_scanner_destroy(__p0) __g_scanner_destroy((__p0))

GSList * __g_slist_insert_sorted(GSList *, gpointer , GCompareFunc ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2704(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_insert_sorted(__p0, __p1, __p2) __g_slist_insert_sorted((__p0), (__p1), (__p2))

GSList * __g_slist_remove_all(GSList *, gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2728(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_remove_all(__p0, __p1) __g_slist_remove_all((__p0), (__p1))

GString * __g_string_insert_unichar(GString *, gssize , gunichar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3196(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_string_insert_unichar(__p0, __p1, __p2) __g_string_insert_unichar((__p0), (__p1), (__p2))

gboolean  __g_main_context_iteration(GMainContext *, gboolean ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3676(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_context_iteration(__p0, __p1) __g_main_context_iteration((__p0), (__p1))

GByteArray * __g_byte_array_set_size(GByteArray *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-214(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_byte_array_set_size(__p0, __p1) __g_byte_array_set_size((__p0), (__p1))

void  __g_main_context_dispatch(GMainContext *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3646(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_main_context_dispatch(__p0) __g_main_context_dispatch((__p0))

void  __g_source_destroy(GSource *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4126(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_source_destroy(__p0) __g_source_destroy((__p0))

GHook * __g_hook_alloc(GHookList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1078(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hook_alloc(__p0) __g_hook_alloc((__p0))

GSList * __g_slist_remove(GSList *, gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2722(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_remove(__p0, __p1) __g_slist_remove((__p0), (__p1))

GString * __g_string_sized_new(gsize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3088(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_string_sized_new(__p0) __g_string_sized_new((__p0))

void  __g_object_set_qdata_full(GObject *, GQuark , gpointer , GDestroyNotify ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4570(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_object_set_qdata_full(__p0, __p1, __p2, __p3) __g_object_set_qdata_full((__p0), (__p1), (__p2), (__p3))

GList * __g_queue_peek_nth_link(GQueue *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2344(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_peek_nth_link(__p0, __p1) __g_queue_peek_nth_link((__p0), (__p1))

void  __g_type_plugin_unuse(GTypePlugin *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5362(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_plugin_unuse(__p0) __g_type_plugin_unuse((__p0))

GList * __g_list_insert_sorted(GList *, gpointer , GCompareFunc ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1462(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_insert_sorted(__p0, __p1, __p2) __g_list_insert_sorted((__p0), (__p1), (__p2))

GValueArray * __g_value_array_sort(GValueArray *, GCompareFunc ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5458(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_array_sort(__p0, __p1) __g_value_array_sort((__p0), (__p1))

GString * __g_string_ascii_up(GString *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3214(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_string_ascii_up(__p0) __g_string_ascii_up((__p0))

void  __g_signal_stop_emission_by_name(gpointer , const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4972(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_signal_stop_emission_by_name(__p0, __p1) __g_signal_stop_emission_by_name((__p0), (__p1))

GValue * __g_value_array_get_nth(GValueArray *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5410(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_array_get_nth(__p0, __p1) __g_value_array_get_nth((__p0), (__p1))

gchar * __g_markup_escape_text(const gchar *, gssize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1630(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_markup_escape_text(__p0, __p1) __g_markup_escape_text((__p0), (__p1))

void  __g_key_file_set_string_list(GKeyFile *, const gchar *, const gchar *, const gchar *const *, gsize ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1342(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_set_string_list(__p0, __p1, __p2, __p3, __p4) __g_key_file_set_string_list((__p0), (__p1), (__p2), (__p3), (__p4))

gpointer  __g_tree_search(GTree *, GCompareFunc , gconstpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3286(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_tree_search(__p0, __p1, __p2) __g_tree_search((__p0), (__p1), (__p2))

GArray * __g_array_sized_new(gboolean , gboolean , guint , guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-40(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_array_sized_new(__p0, __p1, __p2, __p3) __g_array_sized_new((__p0), (__p1), (__p2), (__p3))

gchar ** __g_key_file_get_groups(GKeyFile *, gsize *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1252(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_key_file_get_groups(__p0, __p1) __g_key_file_get_groups((__p0), (__p1))

gint  __g_value_get_int(const GValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5512(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_get_int(__p0) __g_value_get_int((__p0))

gint  __g_queue_link_index(GQueue *, GList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2350(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_link_index(__p0, __p1) __g_queue_link_index((__p0), (__p1))

void  __g_queue_insert_sorted(GQueue *, gpointer , GCompareDataFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2290(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_queue_insert_sorted(__p0, __p1, __p2, __p3) __g_queue_insert_sorted((__p0), (__p1), (__p2), (__p3))

gpointer  __g_hash_table_find(GHashTable *, GHRFunc , gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-994(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hash_table_find(__p0, __p1, __p2) __g_hash_table_find((__p0), (__p1), (__p2))

GIOChannel * __g_io_channel_ref(GIOChannel *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-3922(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_io_channel_ref(__p0) __g_io_channel_ref((__p0))

GParamSpec * __g_param_spec_boxed(const gchar *, const gchar *, const gchar *, GType , GParamFlags ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4882(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_param_spec_boxed(__p0, __p1, __p2, __p3, __p4) __g_param_spec_boxed((__p0), (__p1), (__p2), (__p3), (__p4))

GValue * __g_value_init(GValue *, GType ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5380(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_value_init(__p0, __p1) __g_value_init((__p0), (__p1))

void  __g_type_module_set_name(GTypeModule *, const gchar *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-5320(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_type_module_set_name(__p0, __p1) __g_type_module_set_name((__p0), (__p1))

GSList * __g_slist_insert_before(GSList *, GSList *, gpointer ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2710(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_insert_before(__p0, __p1, __p2) __g_slist_insert_before((__p0), (__p1), (__p2))

GList * __g_list_remove_link(GList *, GList *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1492(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_list_remove_link(__p0, __p1) __g_list_remove_link((__p0), (__p1))

void  __g_hook_list_invoke(GHookList *, gboolean ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-1180(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_hook_list_invoke(__p0, __p1) __g_hook_list_invoke((__p0), (__p1))

gchar  __g_ascii_toupper(gchar ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2830(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_ascii_toupper(__p0) __g_ascii_toupper((__p0))

GSList * __g_slist_nth(GSList *, guint ) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-2758(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_slist_nth(__p0, __p1) __g_slist_nth((__p0), (__p1))

GType  __g_flags_register_static(const gchar *, const GFlagsValue *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4378(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_flags_register_static(__p0, __p1) __g_flags_register_static((__p0), (__p1))

guint * __g_signal_list_ids(GType , guint *) =
	"\tlis\t11,GLibBase@ha\n"
	"\tlwz\t12,GLibBase@l(11)\n"
	"\tlwz\t0,-4948(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define g_signal_list_ids(__p0, __p1) __g_signal_list_ids((__p0), (__p1))

#endif /* !_VBCCINLINE_GLIB_H */
