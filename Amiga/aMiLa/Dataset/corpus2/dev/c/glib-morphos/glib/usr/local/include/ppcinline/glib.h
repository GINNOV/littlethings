/* Automatically generated header! Do not edit! */

#ifndef _PPCINLINE_GLIB_H
#define _PPCINLINE_GLIB_H

#ifndef __PPCINLINE_MACROS_H
#include <ppcinline/macros.h>
#endif /* !__PPCINLINE_MACROS_H */

#ifndef GLIB_BASE_NAME
#define GLIB_BASE_NAME GLibBase
#endif /* !GLIB_BASE_NAME */

#define g_date_get_day(__p0) \
	({ \
		const GDate * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GDateDay (*)(const GDate *))*(void**)(__base - 640))(__t__p0));\
	})

#define g_type_module_add_interface(__p0, __p1, __p2, __p3) \
	({ \
		GTypeModule * __t__p0 = __p0;\
		GType  __t__p1 = __p1;\
		GType  __t__p2 = __p2;\
		const GInterfaceInfo * __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GTypeModule *, GType , GType , const GInterfaceInfo *))*(void**)(__base - 5332))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_main_loop_quit(__p0) \
	({ \
		GMainLoop * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GMainLoop *))*(void**)(__base - 3772))(__t__p0));\
	})

#define g_atomic_int_compare_and_exchange(__p0, __p1, __p2) \
	(((gboolean (*)(gint *, gint , gint ))*(void**)((long)(GLIB_BASE_NAME) - 352))(__p0, __p1, __p2))

#define g_slist_last(__p0) \
	({ \
		GSList * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSList *(*)(GSList *))*(void**)(__base - 2788))(__t__p0));\
	})

#define g_allocator_free(__p0) \
	({ \
		GAllocator * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GAllocator *))*(void**)(__base - 1744))(__t__p0));\
	})

#define g_list_insert_before(__p0, __p1, __p2) \
	({ \
		GList * __t__p0 = __p0;\
		GList * __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GList *, GList *, gpointer ))*(void**)(__base - 1468))(__t__p0, __t__p1, __t__p2));\
	})

#define g_idle_add(__p0, __p1) \
	({ \
		GSourceFunc  __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(GSourceFunc , gpointer ))*(void**)(__base - 3796))(__t__p0, __t__p1));\
	})

#define g_assert_warning(__p0, __p1, __p2, __p3, __p4) \
	({ \
		const char * __t__p0 = __p0;\
		const char * __t__p1 = __p1;\
		const int  __t__p2 = __p2;\
		const char * __t__p3 = __p3;\
		const char * __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(const char *, const char *, const int , const char *, const char *))*(void**)(__base - 4252))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_hook_destroy_link(__p0, __p1) \
	({ \
		GHookList * __t__p0 = __p0;\
		GHook * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GHookList *, GHook *))*(void**)(__base - 1108))(__t__p0, __t__p1));\
	})

#define g_markup_parse_context_parse(__p0, __p1, __p2, __p3) \
	({ \
		GMarkupParseContext * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		gssize  __t__p2 = __p2;\
		GError ** __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GMarkupParseContext *, const gchar *, gssize , GError **))*(void**)(__base - 1606))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_node_reverse_children(__p0) \
	({ \
		GNode * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GNode *))*(void**)(__base - 1912))(__t__p0));\
	})

#define g_gtype_get_type() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GType (*)())*(void**)(__base - 5638))());\
	})

#define g_utf8_collate(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(const gchar *, const gchar *))*(void**)(__base - 3604))(__t__p0, __t__p1));\
	})

#define g_queue_insert_before(__p0, __p1, __p2) \
	({ \
		GQueue * __t__p0 = __p0;\
		GList * __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GQueue *, GList *, gpointer ))*(void**)(__base - 2278))(__t__p0, __t__p1, __t__p2));\
	})

#define g_io_channel_shutdown(__p0, __p1, __p2) \
	({ \
		GIOChannel * __t__p0 = __p0;\
		gboolean  __t__p1 = __p1;\
		GError ** __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GIOStatus (*)(GIOChannel *, gboolean , GError **))*(void**)(__base - 3970))(__t__p0, __t__p1, __t__p2));\
	})

#define g_type_register_static(__p0, __p1, __p2, __p3) \
	({ \
		GType  __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const GTypeInfo * __t__p2 = __p2;\
		GTypeFlags  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GType (*)(GType , const gchar *, const GTypeInfo *, GTypeFlags ))*(void**)(__base - 5242))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_get_current_time(__p0) \
	({ \
		GTimeVal * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GTimeVal *))*(void**)(__base - 4000))(__t__p0));\
	})

#define g_string_append_c(__p0, __p1) \
	({ \
		GString * __t__p0 = __p0;\
		gchar  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GString *(*)(GString *, gchar ))*(void**)(__base - 3148))(__t__p0, __t__p1));\
	})

#define g_io_channel_flush(__p0, __p1) \
	({ \
		GIOChannel * __t__p0 = __p0;\
		GError ** __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GIOStatus (*)(GIOChannel *, GError **))*(void**)(__base - 3838))(__t__p0, __t__p1));\
	})

#define g_key_file_load_from_data(__p0, __p1, __p2, __p3, __p4) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		gsize  __t__p2 = __p2;\
		GKeyFileFlags  __t__p3 = __p3;\
		GError ** __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GKeyFile *, const gchar *, gsize , GKeyFileFlags , GError **))*(void**)(__base - 1228))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_scanner_cur_token(__p0) \
	({ \
		GScanner * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GTokenType (*)(GScanner *))*(void**)(__base - 2560))(__t__p0));\
	})

#define g_signal_query(__p0, __p1) \
	({ \
		guint  __t__p0 = __p0;\
		GSignalQuery * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(guint , GSignalQuery *))*(void**)(__base - 4942))(__t__p0, __t__p1));\
	})

#define g_hook_insert_sorted(__p0, __p1, __p2) \
	({ \
		GHookList * __t__p0 = __p0;\
		GHook * __t__p1 = __p1;\
		GHookCompareFunc  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GHookList *, GHook *, GHookCompareFunc ))*(void**)(__base - 1126))(__t__p0, __t__p1, __t__p2));\
	})

#define g_main_context_prepare(__p0, __p1) \
	({ \
		GMainContext * __t__p0 = __p0;\
		gint * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GMainContext *, gint *))*(void**)(__base - 3694))(__t__p0, __t__p1));\
	})

#define g_array_remove_range(__p0, __p1, __p2) \
	({ \
		GArray * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		guint  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GArray *(*)(GArray *, guint , guint ))*(void**)(__base - 88))(__t__p0, __t__p1, __t__p2));\
	})

#define g_queue_push_nth_link(__p0, __p1, __p2) \
	({ \
		GQueue * __t__p0 = __p0;\
		gint  __t__p1 = __p1;\
		GList * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GQueue *, gint , GList *))*(void**)(__base - 2308))(__t__p0, __t__p1, __t__p2));\
	})

#define g_date_get_sunday_week_of_year(__p0) \
	({ \
		const GDate * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(const GDate *))*(void**)(__base - 664))(__t__p0));\
	})

#define g_child_watch_add(__p0, __p1, __p2) \
	({ \
		GPid  __t__p0 = __p0;\
		GChildWatchFunc  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(GPid , GChildWatchFunc , gpointer ))*(void**)(__base - 4012))(__t__p0, __t__p1, __t__p2));\
	})

#define g_scanner_eof(__p0) \
	({ \
		GScanner * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GScanner *))*(void**)(__base - 2584))(__t__p0));\
	})

#define g_list_first(__p0) \
	({ \
		GList * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GList *))*(void**)(__base - 1558))(__t__p0));\
	})

#define g_ptr_array_remove_index_fast(__p0, __p1) \
	({ \
		GPtrArray * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GPtrArray *, guint ))*(void**)(__base - 136))(__t__p0, __t__p1));\
	})

#define g_dir_rewind(__p0) \
	({ \
		GDir * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GDir *))*(void**)(__base - 844))(__t__p0));\
	})

#define g_ptr_array_foreach(__p0, __p1, __p2) \
	({ \
		GPtrArray * __t__p0 = __p0;\
		GFunc  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GPtrArray *, GFunc , gpointer ))*(void**)(__base - 178))(__t__p0, __t__p1, __t__p2));\
	})

#define g_ascii_strncasecmp(__p0, __p1, __p2) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		gsize  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(const gchar *, const gchar *, gsize ))*(void**)(__base - 2968))(__t__p0, __t__p1, __t__p2));\
	})

#define g_string_insert(__p0, __p1, __p2) \
	({ \
		GString * __t__p0 = __p0;\
		gssize  __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GString *(*)(GString *, gssize , const gchar *))*(void**)(__base - 3184))(__t__p0, __t__p1, __t__p2));\
	})

#define g_signal_accumulator_true_handled(__p0, __p1, __p2, __p3) \
	({ \
		GSignalInvocationHint * __t__p0 = __p0;\
		GValue * __t__p1 = __p1;\
		const GValue * __t__p2 = __p2;\
		gpointer  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GSignalInvocationHint *, GValue *, const GValue *, gpointer ))*(void**)(__base - 5074))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_boxed_copy(__p0, __p1) \
	({ \
		GType  __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GType , gconstpointer ))*(void**)(__base - 4270))(__t__p0, __t__p1));\
	})

#define g_string_prepend_unichar(__p0, __p1) \
	({ \
		GString * __t__p0 = __p0;\
		gunichar  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GString *(*)(GString *, gunichar ))*(void**)(__base - 3172))(__t__p0, __t__p1));\
	})

#define g_unichar_isxdigit(__p0) \
	({ \
		gunichar  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(gunichar ) G_GNUC_CONST)*(void**)(__base - 3370))(__t__p0));\
	})

#define g_key_file_get_integer_list(__p0, __p1, __p2, __p3, __p4) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		gsize * __t__p3 = __p3;\
		GError ** __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint *(*)(GKeyFile *, const gchar *, const gchar *, gsize *, GError **) G_GNUC_MALLOC)*(void**)(__base - 1372))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_utf8_offset_to_pointer(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		glong  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, glong ))*(void**)(__base - 3460))(__t__p0, __t__p1));\
	})

#define g_type_instance_get_private(__p0, __p1) \
	({ \
		GTypeInstance * __t__p0 = __p0;\
		GType  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GTypeInstance *, GType ))*(void**)(__base - 5296))(__t__p0, __t__p1));\
	})

#define g_slist_free(__p0) \
	({ \
		GSList * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GSList *))*(void**)(__base - 2674))(__t__p0));\
	})

#define g_key_file_set_locale_string_list(__p0, __p1, __p2, __p3, __p4, __p5) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		const gchar * __t__p3 = __p3;\
		const gchar *const * __t__p4 = __p4;\
		gsize  __t__p5 = __p5;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GKeyFile *, const gchar *, const gchar *, const gchar *, const gchar *const *, gsize ))*(void**)(__base - 1354))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5));\
	})

#define g_date_get_sunday_weeks_in_year(__p0) \
	({ \
		GDateYear  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint8 (*)(GDateYear ) G_GNUC_CONST)*(void**)(__base - 790))(__t__p0));\
	})

#define g_queue_unlink(__p0, __p1) \
	({ \
		GQueue * __t__p0 = __p0;\
		GList * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GQueue *, GList *))*(void**)(__base - 2356))(__t__p0, __t__p1));\
	})

#define g_date_valid_dmy(__p0, __p1, __p2) \
	({ \
		GDateDay  __t__p0 = __p0;\
		GDateMonth  __t__p1 = __p1;\
		GDateYear  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GDateDay , GDateMonth , GDateYear ) G_GNUC_CONST)*(void**)(__base - 616))(__t__p0, __t__p1, __t__p2));\
	})

#define g_hook_insert_before(__p0, __p1, __p2) \
	({ \
		GHookList * __t__p0 = __p0;\
		GHook * __t__p1 = __p1;\
		GHook * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GHookList *, GHook *, GHook *))*(void**)(__base - 1120))(__t__p0, __t__p1, __t__p2));\
	})

#define g_locale_to_utf8(__p0, __p1, __p2, __p3, __p4) \
	({ \
		const gchar * __t__p0 = __p0;\
		gssize  __t__p1 = __p1;\
		gsize * __t__p2 = __p2;\
		gsize * __t__p3 = __p3;\
		GError ** __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, gssize , gsize *, gsize *, GError **) G_GNUC_MALLOC)*(void**)(__base - 4036))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_datalist_id_set_data_full(__p0, __p1, __p2, __p3) \
	({ \
		GData ** __t__p0 = __p0;\
		GQuark  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		GDestroyNotify  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GData **, GQuark , gpointer , GDestroyNotify ))*(void**)(__base - 490))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_object_set_data(__p0, __p1, __p2) \
	({ \
		GObject * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GObject *, const gchar *, gpointer ))*(void**)(__base - 4588))(__t__p0, __t__p1, __t__p2));\
	})

#define g_queue_pop_nth(__p0, __p1) \
	({ \
		GQueue * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GQueue *, guint ))*(void**)(__base - 2236))(__t__p0, __t__p1));\
	})

#define g_relation_select(__p0, __p1, __p2) \
	({ \
		GRelation * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		gint  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GTuples *(*)(GRelation *, gconstpointer , gint ))*(void**)(__base - 2488))(__t__p0, __t__p1, __t__p2));\
	})

#define g_source_set_priority(__p0, __p1) \
	({ \
		GSource * __t__p0 = __p0;\
		gint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GSource *, gint ))*(void**)(__base - 4132))(__t__p0, __t__p1));\
	})

#define g_source_remove(__p0) \
	({ \
		guint  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(guint ))*(void**)(__base - 4198))(__t__p0));\
	})

#define g_strtod(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		gchar ** __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gdouble (*)(const gchar *, gchar **))*(void**)(__base - 2920))(__t__p0, __t__p1));\
	})

#define g_key_file_set_integer(__p0, __p1, __p2, __p3) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		gint  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GKeyFile *, const gchar *, const gchar *, gint ))*(void**)(__base - 1330))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_realloc(__p0, __p1) \
	({ \
		gpointer  __t__p0 = __p0;\
		gulong  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(gpointer , gulong ))*(void**)(__base - 1654))(__t__p0, __t__p1));\
	})

#define g_value_get_gtype(__p0) \
	({ \
		const GValue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GType (*)(const GValue *))*(void**)(__base - 5650))(__t__p0));\
	})

#define g_date_is_last_of_month(__p0) \
	({ \
		const GDate * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(const GDate *))*(void**)(__base - 730))(__t__p0));\
	})

#define g_slist_append(__p0, __p1) \
	({ \
		GSList * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSList *(*)(GSList *, gpointer ))*(void**)(__base - 2686))(__t__p0, __t__p1));\
	})

#define g_file_read_link(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		GError ** __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, GError **))*(void**)(__base - 916))(__t__p0, __t__p1));\
	})

#define g_queue_insert_after(__p0, __p1, __p2) \
	({ \
		GQueue * __t__p0 = __p0;\
		GList * __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GQueue *, GList *, gpointer ))*(void**)(__base - 2284))(__t__p0, __t__p1, __t__p2));\
	})

#define g_param_spec_long(__p0, __p1, __p2, __p3, __p4, __p5, __p6) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		glong  __t__p3 = __p3;\
		glong  __t__p4 = __p4;\
		glong  __t__p5 = __p5;\
		GParamFlags  __t__p6 = __p6;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(const gchar *, const gchar *, const gchar *, glong , glong , glong , GParamFlags ))*(void**)(__base - 4816))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5, __t__p6));\
	})

#define g_ptr_array_sort_with_data(__p0, __p1, __p2) \
	({ \
		GPtrArray * __t__p0 = __p0;\
		GCompareDataFunc  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GPtrArray *, GCompareDataFunc , gpointer ))*(void**)(__base - 172))(__t__p0, __t__p1, __t__p2));\
	})

#define g_date_new_dmy(__p0, __p1, __p2) \
	({ \
		GDateDay  __t__p0 = __p0;\
		GDateMonth  __t__p1 = __p1;\
		GDateYear  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GDate *(*)(GDateDay , GDateMonth , GDateYear ))*(void**)(__base - 562))(__t__p0, __t__p1, __t__p2));\
	})

#define g_value_set_gtype(__p0, __p1) \
	({ \
		GValue * __t__p0 = __p0;\
		GType  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GValue *, GType ))*(void**)(__base - 5644))(__t__p0, __t__p1));\
	})

#define g_unichar_isupper(__p0) \
	({ \
		gunichar  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(gunichar ) G_GNUC_CONST)*(void**)(__base - 3364))(__t__p0));\
	})

#define g_value_get_float(__p0) \
	({ \
		const GValue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gfloat (*)(const GValue *))*(void**)(__base - 5584))(__t__p0));\
	})

#define g_ascii_digit_value(__p0) \
	({ \
		gchar  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(gchar ) G_GNUC_CONST)*(void**)(__base - 2836))(__t__p0));\
	})

#define g_date_valid_weekday(__p0) \
	({ \
		GDateWeekday  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GDateWeekday ) G_GNUC_CONST)*(void**)(__base - 604))(__t__p0));\
	})

#define g_date_add_days(__p0, __p1) \
	({ \
		GDate * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GDate *, guint ))*(void**)(__base - 736))(__t__p0, __t__p1));\
	})

#define g_type_depth(__p0) \
	({ \
		GType  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(GType ))*(void**)(__base - 5134))(__t__p0));\
	})

#define g_list_reverse(__p0) \
	({ \
		GList * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GList *))*(void**)(__base - 1504))(__t__p0));\
	})

#define g_list_sort_with_data(__p0, __p1, __p2) \
	({ \
		GList * __t__p0 = __p0;\
		GCompareDataFunc  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GList *, GCompareDataFunc , gpointer ))*(void**)(__base - 1582))(__t__p0, __t__p1, __t__p2));\
	})

#define g_string_free(__p0, __p1) \
	({ \
		GString * __t__p0 = __p0;\
		gboolean  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(GString *, gboolean ))*(void**)(__base - 3094))(__t__p0, __t__p1));\
	})

#define g_param_spec_pointer(__p0, __p1, __p2, __p3) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		GParamFlags  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(const gchar *, const gchar *, const gchar *, GParamFlags ))*(void**)(__base - 4888))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_value_get_uint(__p0) \
	({ \
		const GValue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(const GValue *))*(void**)(__base - 5524))(__t__p0));\
	})

#define g_slist_prepend(__p0, __p1) \
	({ \
		GSList * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSList *(*)(GSList *, gpointer ))*(void**)(__base - 2692))(__t__p0, __t__p1));\
	})

#define g_node_copy_deep(__p0, __p1, __p2) \
	({ \
		GNode * __t__p0 = __p0;\
		GCopyFunc  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GNode *(*)(GNode *, GCopyFunc , gpointer ))*(void**)(__base - 1828))(__t__p0, __t__p1, __t__p2));\
	})

#define g_signal_connect_object(__p0, __p1, __p2, __p3, __p4) \
	({ \
		gpointer  __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		GCallback  __t__p2 = __p2;\
		gpointer  __t__p3 = __p3;\
		GConnectFlags  __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gulong (*)(gpointer , const gchar *, GCallback , gpointer , GConnectFlags ))*(void**)(__base - 4648))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_value_set_float(__p0, __p1) \
	({ \
		GValue * __t__p0 = __p0;\
		gfloat  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GValue *, gfloat ))*(void**)(__base - 5578))(__t__p0, __t__p1));\
	})

#define g_list_nth_data(__p0, __p1) \
	({ \
		GList * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GList *, guint ))*(void**)(__base - 1588))(__t__p0, __t__p1));\
	})

#define g_option_context_free(__p0) \
	({ \
		GOptionContext * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GOptionContext *))*(void**)(__base - 1972))(__t__p0));\
	})

#define g_array_prepend_vals(__p0, __p1, __p2) \
	({ \
		GArray * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		guint  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GArray *(*)(GArray *, gconstpointer , guint ))*(void**)(__base - 58))(__t__p0, __t__p1, __t__p2));\
	})

#define g_filename_from_uri(__p0, __p1, __p2) \
	({ \
		const gchar * __t__p0 = __p0;\
		gchar ** __t__p1 = __p1;\
		GError ** __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, gchar **, GError **) G_GNUC_MALLOC)*(void**)(__base - 4060))(__t__p0, __t__p1, __t__p2));\
	})

#define g_source_set_can_recurse(__p0, __p1) \
	({ \
		GSource * __t__p0 = __p0;\
		gboolean  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GSource *, gboolean ))*(void**)(__base - 4144))(__t__p0, __t__p1));\
	})

#define g_tuples_destroy(__p0) \
	({ \
		GTuples * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GTuples *))*(void**)(__base - 2506))(__t__p0));\
	})

#define g_hash_table_ref(__p0) \
	({ \
		GHashTable * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GHashTable *(*)(GHashTable *))*(void**)(__base - 1018))(__t__p0));\
	})

#define g_key_file_remove_comment(__p0, __p1, __p2, __p3) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		GError ** __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GKeyFile *, const gchar *, const gchar *, GError **))*(void**)(__base - 1396))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_array_insert_vals(__p0, __p1, __p2, __p3) \
	({ \
		GArray * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		gconstpointer  __t__p2 = __p2;\
		guint  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GArray *(*)(GArray *, guint , gconstpointer , guint ))*(void**)(__base - 64))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_date_get_days_in_month(__p0, __p1) \
	({ \
		GDateMonth  __t__p0 = __p0;\
		GDateYear  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint8 (*)(GDateMonth , GDateYear ) G_GNUC_CONST)*(void**)(__base - 778))(__t__p0, __t__p1));\
	})

#define g_date_get_monday_weeks_in_year(__p0) \
	({ \
		GDateYear  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint8 (*)(GDateYear ) G_GNUC_CONST)*(void**)(__base - 784))(__t__p0));\
	})

#define g_datalist_init(__p0) \
	({ \
		GData ** __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GData **))*(void**)(__base - 472))(__t__p0));\
	})

#define g_main_context_find_source_by_user_data(__p0, __p1) \
	({ \
		GMainContext * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSource *(*)(GMainContext *, gpointer ))*(void**)(__base - 3664))(__t__p0, __t__p1));\
	})

#define g_strdup_vprintf(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		va_list  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, va_list ) G_GNUC_MALLOC)*(void**)(__base - 2992))(__t__p0, __t__p1));\
	})

#define g_random_set_seed(__p0) \
	({ \
		guint32  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(guint32 ))*(void**)(__base - 2434))(__t__p0));\
	})

#define g_key_file_set_boolean_list(__p0, __p1, __p2, __p3, __p4) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		gboolean * __t__p3 = __p3;\
		gsize  __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GKeyFile *, const gchar *, const gchar *, gboolean *, gsize ))*(void**)(__base - 1366))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_source_remove_by_funcs_user_data(__p0, __p1) \
	({ \
		GSourceFuncs * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GSourceFuncs *, gpointer ))*(void**)(__base - 4210))(__t__p0, __t__p1));\
	})

#define g_param_value_convert(__p0, __p1, __p2, __p3) \
	({ \
		GParamSpec * __t__p0 = __p0;\
		const GValue * __t__p1 = __p1;\
		GValue * __t__p2 = __p2;\
		gboolean  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GParamSpec *, const GValue *, GValue *, gboolean ))*(void**)(__base - 4726))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_param_spec_uchar(__p0, __p1, __p2, __p3, __p4, __p5, __p6) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		guint8  __t__p3 = __p3;\
		guint8  __t__p4 = __p4;\
		guint8  __t__p5 = __p5;\
		GParamFlags  __t__p6 = __p6;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(const gchar *, const gchar *, const gchar *, guint8 , guint8 , guint8 , GParamFlags ))*(void**)(__base - 4792))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5, __t__p6));\
	})

#define g_atomic_int_add(__p0, __p1) \
	(((void (*)(gint *, gint ))*(void**)((long)(GLIB_BASE_NAME) - 346))(__p0, __p1))

#define g_value_get_enum(__p0) \
	({ \
		const GValue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(const GValue *))*(void**)(__base - 4354))(__t__p0));\
	})

#define g_object_class_find_property(__p0, __p1) \
	({ \
		GObjectClass * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(GObjectClass *, const gchar *))*(void**)(__base - 4408))(__t__p0, __t__p1));\
	})

#define g_slist_nth_data(__p0, __p1) \
	({ \
		GSList * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GSList *, guint ))*(void**)(__base - 2818))(__t__p0, __t__p1));\
	})

#define g_utf8_to_ucs4_fast(__p0, __p1, __p2) \
	({ \
		const gchar * __t__p0 = __p0;\
		glong  __t__p1 = __p1;\
		glong * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gunichar *(*)(const gchar *, glong , glong *) G_GNUC_MALLOC)*(void**)(__base - 3532))(__t__p0, __t__p1, __t__p2));\
	})

#define g_type_plugin_complete_type_info(__p0, __p1, __p2, __p3) \
	({ \
		GTypePlugin * __t__p0 = __p0;\
		GType  __t__p1 = __p1;\
		GTypeInfo * __t__p2 = __p2;\
		GTypeValueTable * __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GTypePlugin *, GType , GTypeInfo *, GTypeValueTable *))*(void**)(__base - 5368))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_main_context_set_poll_func(__p0, __p1) \
	({ \
		GMainContext * __t__p0 = __p0;\
		GPollFunc  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GMainContext *, GPollFunc ))*(void**)(__base - 3724))(__t__p0, __t__p1));\
	})

#define g_io_channel_set_line_term(__p0, __p1, __p2) \
	({ \
		GIOChannel * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		gint  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GIOChannel *, const gchar *, gint ))*(void**)(__base - 3964))(__t__p0, __t__p1, __t__p2));\
	})

#define g_queue_push_tail_link(__p0, __p1) \
	({ \
		GQueue * __t__p0 = __p0;\
		GList * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GQueue *, GList *))*(void**)(__base - 2302))(__t__p0, __t__p1));\
	})

#define g_hash_table_foreach_steal(__p0, __p1, __p2) \
	({ \
		GHashTable * __t__p0 = __p0;\
		GHRFunc  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(GHashTable *, GHRFunc , gpointer ))*(void**)(__base - 1006))(__t__p0, __t__p1, __t__p2));\
	})

#define g_list_find(__p0, __p1) \
	({ \
		GList * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GList *, gconstpointer ))*(void**)(__base - 1528))(__t__p0, __t__p1));\
	})

#define g_utf16_to_utf8(__p0, __p1, __p2, __p3, __p4) \
	({ \
		const gunichar2 * __t__p0 = __p0;\
		glong  __t__p1 = __p1;\
		glong * __t__p2 = __p2;\
		glong * __t__p3 = __p3;\
		GError ** __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gunichar2 *, glong , glong *, glong *, GError **))*(void**)(__base - 3544))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_date_get_julian(__p0) \
	({ \
		const GDate * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint32 (*)(const GDate *))*(void**)(__base - 646))(__t__p0));\
	})

#define g_object_interface_install_property(__p0, __p1) \
	({ \
		gpointer  __t__p0 = __p0;\
		GParamSpec * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(gpointer , GParamSpec *))*(void**)(__base - 4426))(__t__p0, __t__p1));\
	})

#define g_ptr_array_remove(__p0, __p1) \
	({ \
		GPtrArray * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GPtrArray *, gpointer ))*(void**)(__base - 142))(__t__p0, __t__p1));\
	})

#define g_async_queue_push(__p0, __p1) \
	({ \
		GAsyncQueue * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GAsyncQueue *, gpointer ))*(void**)(__base - 280))(__t__p0, __t__p1));\
	})

#define g_mem_chunk_print(__p0) \
	({ \
		GMemChunk * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GMemChunk *))*(void**)(__base - 1720))(__t__p0));\
	})

#define g_date_to_struct_tm(__p0, __p1) \
	({ \
		const GDate * __t__p0 = __p0;\
		struct tm * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(const GDate *, struct tm *))*(void**)(__base - 808))(__t__p0, __t__p1));\
	})

#define g_signal_handler_block(__p0, __p1) \
	({ \
		gpointer  __t__p0 = __p0;\
		gulong  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(gpointer , gulong ))*(void**)(__base - 5014))(__t__p0, __t__p1));\
	})

#define g_key_file_set_comment(__p0, __p1, __p2, __p3, __p4) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		const gchar * __t__p3 = __p3;\
		GError ** __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GKeyFile *, const gchar *, const gchar *, const gchar *, GError **))*(void**)(__base - 1384))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_option_group_add_entries(__p0, __p1) \
	({ \
		GOptionGroup * __t__p0 = __p0;\
		const GOptionEntry * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GOptionGroup *, const GOptionEntry *))*(void**)(__base - 2056))(__t__p0, __t__p1));\
	})

#define g_option_context_new(__p0) \
	({ \
		const gchar * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GOptionContext *(*)(const gchar *))*(void**)(__base - 1966))(__t__p0));\
	})

#define g_object_get_valist(__p0, __p1, __p2) \
	({ \
		GObject * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		va_list  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GObject *, const gchar *, va_list ))*(void**)(__base - 4462))(__t__p0, __t__p1, __t__p2));\
	})

#define g_list_remove(__p0, __p1) \
	({ \
		GList * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GList *, gconstpointer ))*(void**)(__base - 1480))(__t__p0, __t__p1));\
	})

#define g_pattern_match(__p0, __p1, __p2, __p3) \
	({ \
		GPatternSpec * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		const gchar * __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GPatternSpec *, guint , const gchar *, const gchar *))*(void**)(__base - 2092))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_array_append_vals(__p0, __p1, __p2) \
	({ \
		GArray * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		guint  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GArray *(*)(GArray *, gconstpointer , guint ))*(void**)(__base - 52))(__t__p0, __t__p1, __t__p2));\
	})

#define g_hash_table_foreach_remove(__p0, __p1, __p2) \
	({ \
		GHashTable * __t__p0 = __p0;\
		GHRFunc  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(GHashTable *, GHRFunc , gpointer ))*(void**)(__base - 1000))(__t__p0, __t__p1, __t__p2));\
	})

#define g_scanner_scope_foreach_symbol(__p0, __p1, __p2, __p3) \
	({ \
		GScanner * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		GHFunc  __t__p2 = __p2;\
		gpointer  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GScanner *, guint , GHFunc , gpointer ))*(void**)(__base - 2614))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_mem_chunk_alloc0(__p0) \
	({ \
		GMemChunk * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GMemChunk *))*(void**)(__base - 1696))(__t__p0));\
	})

#define g_boxed_free(__p0, __p1) \
	({ \
		GType  __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GType , gpointer ))*(void**)(__base - 4276))(__t__p0, __t__p1));\
	})

#define g_enum_complete_type_info(__p0, __p1, __p2) \
	({ \
		GType  __t__p0 = __p0;\
		GTypeInfo * __t__p1 = __p1;\
		const GEnumValue * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GType , GTypeInfo *, const GEnumValue *))*(void**)(__base - 4384))(__t__p0, __t__p1, __t__p2));\
	})

#define g_object_steal_qdata(__p0, __p1) \
	({ \
		GObject * __t__p0 = __p0;\
		GQuark  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GObject *, GQuark ))*(void**)(__base - 4576))(__t__p0, __t__p1));\
	})

#define g_random_double() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gdouble (*)())*(void**)(__base - 2452))());\
	})

#define g_get_filename_charsets(__p0) \
	({ \
		G_CONST_RETURN  __t__p0***charsets = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(G_CONST_RETURN ***charsets))*(void**)(__base - 4006))(__t__p0));\
	})

#define g_atomic_pointer_get(__p0) \
	(((gpointer (*)(volatile gpointer *))*(void**)((long)(GLIB_BASE_NAME) - 376))(__p0))

#define g_io_channel_error_quark() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GQuark (*)())*(void**)(__base - 3832))());\
	})

#define g_type_is_a(__p0, __p1) \
	({ \
		GType  __t__p0 = __p0;\
		GType  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GType , GType ))*(void**)(__base - 5146))(__t__p0, __t__p1));\
	})

#define g_queue_find_custom(__p0, __p1, __p2) \
	({ \
		GQueue * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		GCompareFunc  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GQueue *, gconstpointer , GCompareFunc ))*(void**)(__base - 2194))(__t__p0, __t__p1, __t__p2));\
	})

#define g_strjoinv(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		gchar ** __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, gchar **) G_GNUC_MALLOC)*(void**)(__base - 3040))(__t__p0, __t__p1));\
	})

#define g_main_loop_get_context(__p0) \
	({ \
		GMainLoop * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GMainContext *(*)(GMainLoop *))*(void**)(__base - 3754))(__t__p0));\
	})

#define g_shell_parse_argv(__p0, __p1, __p2, __p3) \
	({ \
		const gchar * __t__p0 = __p0;\
		gint * __t__p1 = __p1;\
		gchar *** __t__p2 = __p2;\
		GError ** __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(const gchar *, gint *, gchar ***, GError **))*(void**)(__base - 2650))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_async_queue_try_pop_unlocked(__p0) \
	({ \
		GAsyncQueue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GAsyncQueue *))*(void**)(__base - 310))(__t__p0));\
	})

#define g_object_thaw_notify(__p0) \
	({ \
		GObject * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GObject *))*(void**)(__base - 4492))(__t__p0));\
	})

#define g_key_file_get_value(__p0, __p1, __p2, __p3) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		GError ** __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(GKeyFile *, const gchar *, const gchar *, GError **) G_GNUC_MALLOC)*(void**)(__base - 1276))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_hash_table_lookup(__p0, __p1) \
	({ \
		GHashTable * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GHashTable *, gconstpointer ))*(void**)(__base - 976))(__t__p0, __t__p1));\
	})

#define g_signal_handler_disconnect(__p0, __p1) \
	({ \
		gpointer  __t__p0 = __p0;\
		gulong  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(gpointer , gulong ))*(void**)(__base - 5026))(__t__p0, __t__p1));\
	})

#define g_option_context_set_ignore_unknown_options(__p0, __p1) \
	({ \
		GOptionContext * __t__p0 = __p0;\
		gboolean  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GOptionContext *, gboolean ))*(void**)(__base - 1990))(__t__p0, __t__p1));\
	})

#define g_value_set_static_string(__p0, __p1) \
	({ \
		GValue * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GValue *, const gchar *))*(void**)(__base - 5608))(__t__p0, __t__p1));\
	})

#define g_list_alloc() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)())*(void**)(__base - 1426))());\
	})

#define g_key_file_get_locale_string_list(__p0, __p1, __p2, __p3, __p4, __p5) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		const gchar * __t__p3 = __p3;\
		gsize * __t__p4 = __p4;\
		GError ** __t__p5 = __p5;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar **(*)(GKeyFile *, const gchar *, const gchar *, const gchar *, gsize *, GError **) G_GNUC_MALLOC)*(void**)(__base - 1348))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5));\
	})

#define g_scanner_cur_position(__p0) \
	({ \
		GScanner * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(GScanner *))*(void**)(__base - 2578))(__t__p0));\
	})

#define g_tree_foreach(__p0, __p1, __p2) \
	({ \
		GTree * __t__p0 = __p0;\
		GTraverseFunc  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GTree *, GTraverseFunc , gpointer ))*(void**)(__base - 3280))(__t__p0, __t__p1, __t__p2));\
	})

#define g_value_array_remove(__p0, __p1) \
	({ \
		GValueArray * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GValueArray *(*)(GValueArray *, guint ))*(void**)(__base - 5452))(__t__p0, __t__p1));\
	})

#define g_type_children(__p0, __p1) \
	({ \
		GType  __t__p0 = __p0;\
		guint * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GType *(*)(GType , guint *))*(void**)(__base - 5212))(__t__p0, __t__p1));\
	})

#define g_byte_array_remove_range(__p0, __p1, __p2) \
	({ \
		GByteArray * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		guint  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GByteArray *(*)(GByteArray *, guint , guint ))*(void**)(__base - 232))(__t__p0, __t__p1, __t__p2));\
	})

#define g_unichar_iswide(__p0) \
	({ \
		gunichar  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(gunichar ) G_GNUC_CONST)*(void**)(__base - 3388))(__t__p0));\
	})

#define g_key_file_set_value(__p0, __p1, __p2, __p3) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		const gchar * __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GKeyFile *, const gchar *, const gchar *, const gchar *))*(void**)(__base - 1282))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_queue_remove(__p0, __p1) \
	({ \
		GQueue * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GQueue *, gconstpointer ))*(void**)(__base - 2266))(__t__p0, __t__p1));\
	})

#define g_utf8_collate_key(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		gssize  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, gssize ))*(void**)(__base - 3610))(__t__p0, __t__p1));\
	})

#define g_type_init() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)())*(void**)(__base - 5098))());\
	})

#define g_signal_handler_find(__p0, __p1, __p2, __p3, __p4, __p5, __p6) \
	({ \
		gpointer  __t__p0 = __p0;\
		GSignalMatchType  __t__p1 = __p1;\
		guint  __t__p2 = __p2;\
		GQuark  __t__p3 = __p3;\
		GClosure * __t__p4 = __p4;\
		gpointer  __t__p5 = __p5;\
		gpointer  __t__p6 = __p6;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gulong (*)(gpointer , GSignalMatchType , guint , GQuark , GClosure *, gpointer , gpointer ))*(void**)(__base - 5038))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5, __t__p6));\
	})

#define GLib_SetExit(__p0) \
	({ \
		void (* __t__p0)(int) = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((VOID (*)(void (*)(int)))*(void**)(__base - 28))(__t__p0));\
	})

#define g_signal_newv(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7, __p8, __p9) \
	({ \
		const gchar * __t__p0 = __p0;\
		GType  __t__p1 = __p1;\
		GSignalFlags  __t__p2 = __p2;\
		GClosure * __t__p3 = __p3;\
		GSignalAccumulator  __t__p4 = __p4;\
		gpointer  __t__p5 = __p5;\
		GSignalCMarshaller  __t__p6 = __p6;\
		GType  __t__p7 = __p7;\
		guint  __t__p8 = __p8;\
		GType * __t__p9 = __p9;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(const gchar *, GType , GSignalFlags , GClosure *, GSignalAccumulator , gpointer , GSignalCMarshaller , GType , guint , GType *))*(void**)(__base - 4918))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5, __t__p6, __t__p7, __t__p8, __t__p9));\
	})

#define g_file_test(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		GFileTest  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(const gchar *, GFileTest ))*(void**)(__base - 904))(__t__p0, __t__p1));\
	})

#define g_io_channel_get_close_on_unref(__p0) \
	({ \
		GIOChannel * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GIOChannel *))*(void**)(__base - 3862))(__t__p0));\
	})

#define g_file_error_from_errno(__p0) \
	({ \
		gint  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GFileError (*)(gint ))*(void**)(__base - 898))(__t__p0));\
	})

#define g_io_create_watch(__p0, __p1) \
	({ \
		GIOChannel * __t__p0 = __p0;\
		GIOCondition  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSource *(*)(GIOChannel *, GIOCondition ))*(void**)(__base - 3994))(__t__p0, __t__p1));\
	})

#define g_type_add_interface_static(__p0, __p1, __p2) \
	({ \
		GType  __t__p0 = __p0;\
		GType  __t__p1 = __p1;\
		const GInterfaceInfo * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GType , GType , const GInterfaceInfo *))*(void**)(__base - 5266))(__t__p0, __t__p1, __t__p2));\
	})

#define g_io_channel_get_buffer_size(__p0) \
	({ \
		GIOChannel * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gsize (*)(GIOChannel *))*(void**)(__base - 3850))(__t__p0));\
	})

#define g_array_set_size(__p0, __p1) \
	({ \
		GArray * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GArray *(*)(GArray *, guint ))*(void**)(__base - 70))(__t__p0, __t__p1));\
	})

#define g_shell_error_quark() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GQuark (*)())*(void**)(__base - 2632))());\
	})

#define g_string_erase(__p0, __p1, __p2) \
	({ \
		GString * __t__p0 = __p0;\
		gssize  __t__p1 = __p1;\
		gssize  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GString *(*)(GString *, gssize , gssize ))*(void**)(__base - 3202))(__t__p0, __t__p1, __t__p2));\
	})

#define g_io_channel_write_chars(__p0, __p1, __p2, __p3, __p4) \
	({ \
		GIOChannel * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		gssize  __t__p2 = __p2;\
		gsize * __t__p3 = __p3;\
		GError ** __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GIOStatus (*)(GIOChannel *, const gchar *, gssize , gsize *, GError **))*(void**)(__base - 3982))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_log_set_handler(__p0, __p1, __p2, __p3) \
	({ \
		const gchar * __t__p0 = __p0;\
		GLogLevelFlags  __t__p1 = __p1;\
		GLogFunc  __t__p2 = __p2;\
		gpointer  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(const gchar *, GLogLevelFlags , GLogFunc , gpointer ))*(void**)(__base - 1756))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_hook_ref(__p0, __p1) \
	({ \
		GHookList * __t__p0 = __p0;\
		GHook * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GHook *(*)(GHookList *, GHook *))*(void**)(__base - 1090))(__t__p0, __t__p1));\
	})

#define g_unichar_totitle(__p0) \
	({ \
		gunichar  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gunichar (*)(gunichar ) G_GNUC_CONST)*(void**)(__base - 3406))(__t__p0));\
	})

#define g_signal_override_class_closure(__p0, __p1, __p2) \
	({ \
		guint  __t__p0 = __p0;\
		GType  __t__p1 = __p1;\
		GClosure * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(guint , GType , GClosure *))*(void**)(__base - 5062))(__t__p0, __t__p1, __t__p2));\
	})

#define g_source_unref(__p0) \
	({ \
		GSource * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GSource *))*(void**)(__base - 4114))(__t__p0));\
	})

#define g_strv_length(__p0) \
	({ \
		gchar ** __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(gchar **))*(void**)(__base - 3058))(__t__p0));\
	})

#define g_direct_equal(__p0, __p1) \
	({ \
		gconstpointer  __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(gconstpointer , gconstpointer ) G_GNUC_CONST)*(void**)(__base - 1060))(__t__p0, __t__p1));\
	})

#define g_tuples_index(__p0, __p1, __p2) \
	({ \
		GTuples * __t__p0 = __p0;\
		gint  __t__p1 = __p1;\
		gint  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GTuples *, gint , gint ))*(void**)(__base - 2512))(__t__p0, __t__p1, __t__p2));\
	})

#define g_ascii_tolower(__p0) \
	({ \
		gchar  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar (*)(gchar ) G_GNUC_CONST)*(void**)(__base - 2824))(__t__p0));\
	})

#define g_ascii_formatd(__p0, __p1, __p2, __p3) \
	({ \
		gchar * __t__p0 = __p0;\
		gint  __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		gdouble  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(gchar *, gint , const gchar *, gdouble ))*(void**)(__base - 2944))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_object_unref(__p0) \
	({ \
		gpointer  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(gpointer ))*(void**)(__base - 4516))(__t__p0));\
	})

#define g_param_value_validate(__p0, __p1) \
	({ \
		GParamSpec * __t__p0 = __p0;\
		GValue * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GParamSpec *, GValue *))*(void**)(__base - 4720))(__t__p0, __t__p1));\
	})

#define g_type_module_register_flags(__p0, __p1, __p2) \
	({ \
		GTypeModule * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const GFlagsValue * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GType (*)(GTypeModule *, const gchar *, const GFlagsValue *))*(void**)(__base - 5344))(__t__p0, __t__p1, __t__p2));\
	})

#define g_date_set_year(__p0, __p1) \
	({ \
		GDate * __t__p0 = __p0;\
		GDateYear  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GDate *, GDateYear ))*(void**)(__base - 706))(__t__p0, __t__p1));\
	})

#define g_type_default_interface_peek(__p0) \
	({ \
		GType  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GType ))*(void**)(__base - 5200))(__t__p0));\
	})

#define g_dataset_foreach(__p0, __p1, __p2) \
	({ \
		gconstpointer  __t__p0 = __p0;\
		GDataForeachFunc  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(gconstpointer , GDataForeachFunc , gpointer ))*(void**)(__base - 550))(__t__p0, __t__p1, __t__p2));\
	})

#define g_ptr_array_new() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GPtrArray *(*)())*(void**)(__base - 106))());\
	})

#define g_main_loop_unref(__p0) \
	({ \
		GMainLoop * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GMainLoop *))*(void**)(__base - 3790))(__t__p0));\
	})

#define g_hook_list_init(__p0, __p1) \
	({ \
		GHookList * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GHookList *, guint ))*(void**)(__base - 1066))(__t__p0, __t__p1));\
	})

#define g_queue_peek_tail_link(__p0) \
	({ \
		GQueue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GQueue *))*(void**)(__base - 2338))(__t__p0));\
	})

#define g_cclosure_new_object(__p0, __p1) \
	({ \
		GCallback  __t__p0 = __p0;\
		GObject * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GClosure *(*)(GCallback , GObject *))*(void**)(__base - 4612))(__t__p0, __t__p1));\
	})

#define g_value_reset(__p0) \
	({ \
		GValue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GValue *(*)(GValue *))*(void**)(__base - 5392))(__t__p0));\
	})

#define g_queue_push_head_link(__p0, __p1) \
	({ \
		GQueue * __t__p0 = __p0;\
		GList * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GQueue *, GList *))*(void**)(__base - 2296))(__t__p0, __t__p1));\
	})

#define g_async_queue_length(__p0) \
	({ \
		GAsyncQueue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(GAsyncQueue *))*(void**)(__base - 328))(__t__p0));\
	})

#define g_queue_delete_link(__p0, __p1) \
	({ \
		GQueue * __t__p0 = __p0;\
		GList * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GQueue *, GList *))*(void**)(__base - 2362))(__t__p0, __t__p1));\
	})

#define g_object_class_install_property(__p0, __p1, __p2) \
	({ \
		GObjectClass * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		GParamSpec * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GObjectClass *, guint , GParamSpec *))*(void**)(__base - 4402))(__t__p0, __t__p1, __t__p2));\
	})

#define g_random_double_range(__p0, __p1) \
	({ \
		gdouble  __t__p0 = __p0;\
		gdouble  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gdouble (*)(gdouble , gdouble ))*(void**)(__base - 2458))(__t__p0, __t__p1));\
	})

#define g_option_group_set_translate_func(__p0, __p1, __p2, __p3) \
	({ \
		GOptionGroup * __t__p0 = __p0;\
		GTranslateFunc  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		GDestroyNotify  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GOptionGroup *, GTranslateFunc , gpointer , GDestroyNotify ))*(void**)(__base - 2062))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_main_context_release(__p0) \
	({ \
		GMainContext * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GMainContext *))*(void**)(__base - 3712))(__t__p0));\
	})

#define g_pattern_spec_free(__p0) \
	({ \
		GPatternSpec * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GPatternSpec *))*(void**)(__base - 2080))(__t__p0));\
	})

#define g_key_file_has_key(__p0, __p1, __p2, __p3) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		GError ** __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GKeyFile *, const gchar *, const gchar *, GError **))*(void**)(__base - 1270))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_option_context_get_help_enabled(__p0) \
	({ \
		GOptionContext * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GOptionContext *))*(void**)(__base - 1984))(__t__p0));\
	})

#define g_scanner_set_scope(__p0, __p1) \
	({ \
		GScanner * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(GScanner *, guint ))*(void**)(__base - 2590))(__t__p0, __t__p1));\
	})

#define g_relation_delete(__p0, __p1, __p2) \
	({ \
		GRelation * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		gint  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(GRelation *, gconstpointer , gint ))*(void**)(__base - 2482))(__t__p0, __t__p1, __t__p2));\
	})

#define g_signal_handlers_unblock_matched(__p0, __p1, __p2, __p3, __p4, __p5, __p6) \
	({ \
		gpointer  __t__p0 = __p0;\
		GSignalMatchType  __t__p1 = __p1;\
		guint  __t__p2 = __p2;\
		GQuark  __t__p3 = __p3;\
		GClosure * __t__p4 = __p4;\
		gpointer  __t__p5 = __p5;\
		gpointer  __t__p6 = __p6;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(gpointer , GSignalMatchType , guint , GQuark , GClosure *, gpointer , gpointer ))*(void**)(__base - 5050))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5, __t__p6));\
	})

#define g_strlcpy(__p0, __p1, __p2) \
	({ \
		gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		gsize  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gsize (*)(gchar *, const gchar *, gsize ))*(void**)(__base - 2878))(__t__p0, __t__p1, __t__p2));\
	})

#define g_param_spec_get_redirect_target(__p0) \
	({ \
		GParamSpec * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(GParamSpec *))*(void**)(__base - 4702))(__t__p0));\
	})

#define g_value_set_int(__p0, __p1) \
	({ \
		GValue * __t__p0 = __p0;\
		gint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GValue *, gint ))*(void**)(__base - 5506))(__t__p0, __t__p1));\
	})

#define g_byte_array_free(__p0, __p1) \
	({ \
		GByteArray * __t__p0 = __p0;\
		gboolean  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint8 *(*)(GByteArray *, gboolean ))*(void**)(__base - 196))(__t__p0, __t__p1));\
	})

#define g_list_append(__p0, __p1) \
	({ \
		GList * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GList *, gpointer ))*(void**)(__base - 1444))(__t__p0, __t__p1));\
	})

#define g_node_prepend(__p0, __p1) \
	({ \
		GNode * __t__p0 = __p0;\
		GNode * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GNode *(*)(GNode *, GNode *))*(void**)(__base - 1858))(__t__p0, __t__p1));\
	})

#define g_dir_close(__p0) \
	({ \
		GDir * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GDir *))*(void**)(__base - 850))(__t__p0));\
	})

#define g_try_malloc(__p0) \
	({ \
		gulong  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(gulong ) G_GNUC_MALLOC)*(void**)(__base - 1666))(__t__p0));\
	})

#define g_option_context_parse(__p0, __p1, __p2, __p3) \
	({ \
		GOptionContext * __t__p0 = __p0;\
		gint * __t__p1 = __p1;\
		gchar *** __t__p2 = __p2;\
		GError ** __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GOptionContext *, gint *, gchar ***, GError **))*(void**)(__base - 2008))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_value_set_long(__p0, __p1) \
	({ \
		GValue * __t__p0 = __p0;\
		glong  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GValue *, glong ))*(void**)(__base - 5530))(__t__p0, __t__p1));\
	})

#define g_scanner_input_file(__p0, __p1) \
	({ \
		GScanner * __t__p0 = __p0;\
		gint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GScanner *, gint ))*(void**)(__base - 2530))(__t__p0, __t__p1));\
	})

#define g_main_depth() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((int (*)())*(void**)(__base - 3748))());\
	})

#define g_mem_chunk_clean(__p0) \
	({ \
		GMemChunk * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GMemChunk *))*(void**)(__base - 1708))(__t__p0));\
	})

#define g_tree_destroy(__p0) \
	({ \
		GTree * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GTree *))*(void**)(__base - 3238))(__t__p0));\
	})

#define g_node_depth(__p0) \
	({ \
		GNode * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(GNode *))*(void**)(__base - 1882))(__t__p0));\
	})

#define g_closure_new_object(__p0, __p1) \
	({ \
		guint  __t__p0 = __p0;\
		GObject * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GClosure *(*)(guint , GObject *))*(void**)(__base - 4624))(__t__p0, __t__p1));\
	})

#define g_cache_destroy(__p0) \
	({ \
		GCache * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GCache *))*(void**)(__base - 394))(__t__p0));\
	})

#define g_boxed_type_register_static(__p0, __p1, __p2) \
	({ \
		const gchar * __t__p0 = __p0;\
		GBoxedCopyFunc  __t__p1 = __p1;\
		GBoxedFreeFunc  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GType (*)(const gchar *, GBoxedCopyFunc , GBoxedFreeFunc ))*(void**)(__base - 4306))(__t__p0, __t__p1, __t__p2));\
	})

#define g_return_if_fail_warning(__p0, __p1, __p2) \
	({ \
		const char * __t__p0 = __p0;\
		const char * __t__p1 = __p1;\
		const char * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(const char *, const char *, const char *))*(void**)(__base - 4246))(__t__p0, __t__p1, __t__p2));\
	})

#define g_signal_connect_data(__p0, __p1, __p2, __p3, __p4, __p5) \
	({ \
		gpointer  __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		GCallback  __t__p2 = __p2;\
		gpointer  __t__p3 = __p3;\
		GClosureNotify  __t__p4 = __p4;\
		GConnectFlags  __t__p5 = __p5;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gulong (*)(gpointer , const gchar *, GCallback , gpointer , GClosureNotify , GConnectFlags ))*(void**)(__base - 5008))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5));\
	})

#define g_signal_remove_emission_hook(__p0, __p1) \
	({ \
		guint  __t__p0 = __p0;\
		gulong  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(guint , gulong ))*(void**)(__base - 4984))(__t__p0, __t__p1));\
	})

#define g_async_queue_unref(__p0) \
	({ \
		GAsyncQueue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GAsyncQueue *))*(void**)(__base - 274))(__t__p0));\
	})

#define g_cache_remove(__p0, __p1) \
	({ \
		GCache * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GCache *, gconstpointer ))*(void**)(__base - 406))(__t__p0, __t__p1));\
	})

#define g_strdup(__p0) \
	({ \
		const gchar * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *) G_GNUC_MALLOC)*(void**)(__base - 2986))(__t__p0));\
	})

#define g_node_max_height(__p0) \
	({ \
		GNode * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(GNode *))*(void**)(__base - 1900))(__t__p0));\
	})

#define g_date_set_day(__p0, __p1) \
	({ \
		GDate * __t__p0 = __p0;\
		GDateDay  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GDate *, GDateDay ))*(void**)(__base - 700))(__t__p0, __t__p1));\
	})

#define g_main_context_add_poll(__p0, __p1, __p2) \
	({ \
		GMainContext * __t__p0 = __p0;\
		GPollFD * __t__p1 = __p1;\
		gint  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GMainContext *, GPollFD *, gint ))*(void**)(__base - 3628))(__t__p0, __t__p1, __t__p2));\
	})

#define g_hash_table_unref(__p0) \
	({ \
		GHashTable * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GHashTable *))*(void**)(__base - 1024))(__t__p0));\
	})

#define g_unichar_isalpha(__p0) \
	({ \
		gunichar  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(gunichar ) G_GNUC_CONST)*(void**)(__base - 3316))(__t__p0));\
	})

#define g_tree_replace(__p0, __p1, __p2) \
	({ \
		GTree * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GTree *, gpointer , gpointer ))*(void**)(__base - 3250))(__t__p0, __t__p1, __t__p2));\
	})

#define g_string_insert_c(__p0, __p1, __p2) \
	({ \
		GString * __t__p0 = __p0;\
		gssize  __t__p1 = __p1;\
		gchar  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GString *(*)(GString *, gssize , gchar ))*(void**)(__base - 3190))(__t__p0, __t__p1, __t__p2));\
	})

#define g_datalist_foreach(__p0, __p1, __p2) \
	({ \
		GData ** __t__p0 = __p0;\
		GDataForeachFunc  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GData **, GDataForeachFunc , gpointer ))*(void**)(__base - 502))(__t__p0, __t__p1, __t__p2));\
	})

#define g_key_file_has_group(__p0, __p1) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GKeyFile *, const gchar *))*(void**)(__base - 1264))(__t__p0, __t__p1));\
	})

#define g_value_take_param(__p0, __p1) \
	({ \
		GValue * __t__p0 = __p0;\
		GParamSpec * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GValue *, GParamSpec *))*(void**)(__base - 4774))(__t__p0, __t__p1));\
	})

#define g_hook_find(__p0, __p1, __p2, __p3) \
	({ \
		GHookList * __t__p0 = __p0;\
		gboolean  __t__p1 = __p1;\
		GHookFindFunc  __t__p2 = __p2;\
		gpointer  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GHook *(*)(GHookList *, gboolean , GHookFindFunc , gpointer ))*(void**)(__base - 1138))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_io_channel_error_from_errno(__p0) \
	({ \
		gint  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GIOChannelError (*)(gint ))*(void**)(__base - 3826))(__t__p0));\
	})

#define g_value_array_append(__p0, __p1) \
	({ \
		GValueArray * __t__p0 = __p0;\
		const GValue * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GValueArray *(*)(GValueArray *, const GValue *))*(void**)(__base - 5440))(__t__p0, __t__p1));\
	})

#define g_date_valid_month(__p0) \
	({ \
		GDateMonth  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GDateMonth ) G_GNUC_CONST)*(void**)(__base - 592))(__t__p0));\
	})

#define g_hook_list_marshal(__p0, __p1, __p2, __p3) \
	({ \
		GHookList * __t__p0 = __p0;\
		gboolean  __t__p1 = __p1;\
		GHookMarshaller  __t__p2 = __p2;\
		gpointer  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GHookList *, gboolean , GHookMarshaller , gpointer ))*(void**)(__base - 1192))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_quark_from_static_string(__p0) \
	({ \
		const gchar * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GQuark (*)(const gchar *))*(void**)(__base - 2128))(__t__p0));\
	})

#define g_node_unlink(__p0) \
	({ \
		GNode * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GNode *))*(void**)(__base - 1822))(__t__p0));\
	})

#define g_string_append_unichar(__p0, __p1) \
	({ \
		GString * __t__p0 = __p0;\
		gunichar  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GString *(*)(GString *, gunichar ))*(void**)(__base - 3154))(__t__p0, __t__p1));\
	})

#define g_mem_chunk_free(__p0, __p1) \
	({ \
		GMemChunk * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GMemChunk *, gpointer ))*(void**)(__base - 1702))(__t__p0, __t__p1));\
	})

#define g_date_is_first_of_month(__p0) \
	({ \
		const GDate * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(const GDate *))*(void**)(__base - 724))(__t__p0));\
	})

#define g_node_n_children(__p0) \
	({ \
		GNode * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(GNode *))*(void**)(__base - 1918))(__t__p0));\
	})

#define g_rand_int_range(__p0, __p1, __p2) \
	({ \
		GRand * __t__p0 = __p0;\
		gint32  __t__p1 = __p1;\
		gint32  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint32 (*)(GRand *, gint32 , gint32 ))*(void**)(__base - 2416))(__t__p0, __t__p1, __t__p2));\
	})

#define g_string_new_len(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		gssize  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GString *(*)(const gchar *, gssize ))*(void**)(__base - 3082))(__t__p0, __t__p1));\
	})

#define g_scanner_scope_add_symbol(__p0, __p1, __p2, __p3) \
	({ \
		GScanner * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		gpointer  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GScanner *, guint , const gchar *, gpointer ))*(void**)(__base - 2596))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_unichar_get_mirror_char(__p0, __p1) \
	({ \
		gunichar  __t__p0 = __p0;\
		gunichar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(gunichar , gunichar *))*(void**)(__base - 3616))(__t__p0, __t__p1));\
	})

#define g_signal_chain_from_overridden(__p0, __p1) \
	({ \
		const GValue * __t__p0 = __p0;\
		GValue * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(const GValue *, GValue *))*(void**)(__base - 5068))(__t__p0, __t__p1));\
	})

#define g_relation_count(__p0, __p1, __p2) \
	({ \
		GRelation * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		gint  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(GRelation *, gconstpointer , gint ))*(void**)(__base - 2494))(__t__p0, __t__p1, __t__p2));\
	})

#define g_strcanon(__p0, __p1, __p2) \
	({ \
		gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		gchar  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(gchar *, const gchar *, gchar ))*(void**)(__base - 2854))(__t__p0, __t__p1, __t__p2));\
	})

#define g_unichar_iscntrl(__p0) \
	({ \
		gunichar  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(gunichar ) G_GNUC_CONST)*(void**)(__base - 3322))(__t__p0));\
	})

#define g_object_steal_data(__p0, __p1) \
	({ \
		GObject * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GObject *, const gchar *))*(void**)(__base - 4600))(__t__p0, __t__p1));\
	})

#define g_hook_find_data(__p0, __p1, __p2) \
	({ \
		GHookList * __t__p0 = __p0;\
		gboolean  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GHook *(*)(GHookList *, gboolean , gpointer ))*(void**)(__base - 1144))(__t__p0, __t__p1, __t__p2));\
	})

#define g_date_is_leap_year(__p0) \
	({ \
		GDateYear  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GDateYear ) G_GNUC_CONST)*(void**)(__base - 772))(__t__p0));\
	})

#define g_scanner_peek_next_token(__p0) \
	({ \
		GScanner * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GTokenType (*)(GScanner *))*(void**)(__base - 2554))(__t__p0));\
	})

#define g_slist_push_allocator(__p0) \
	({ \
		GAllocator * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GAllocator *))*(void**)(__base - 2656))(__t__p0));\
	})

#define g_unichar_islower(__p0) \
	({ \
		gunichar  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(gunichar ) G_GNUC_CONST)*(void**)(__base - 3340))(__t__p0));\
	})

#define g_initially_unowned_get_type() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GType (*)())*(void**)(__base - 4396))());\
	})

#define g_date_valid_julian(__p0) \
	({ \
		guint32  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(guint32 ) G_GNUC_CONST)*(void**)(__base - 610))(__t__p0));\
	})

#define g_dataset_destroy(__p0) \
	({ \
		gconstpointer  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(gconstpointer ))*(void**)(__base - 526))(__t__p0));\
	})

#define g_value_get_object(__p0) \
	({ \
		const GValue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(const GValue *))*(void**)(__base - 4636))(__t__p0));\
	})

#define g_list_foreach(__p0, __p1, __p2) \
	({ \
		GList * __t__p0 = __p0;\
		GFunc  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GList *, GFunc , gpointer ))*(void**)(__base - 1570))(__t__p0, __t__p1, __t__p2));\
	})

#define g_scanner_new(__p0) \
	({ \
		const GScannerConfig * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GScanner *(*)(const GScannerConfig *))*(void**)(__base - 2518))(__t__p0));\
	})

#define g_object_ref(__p0) \
	({ \
		gpointer  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(gpointer ))*(void**)(__base - 4510))(__t__p0));\
	})

#define g_key_file_get_integer(__p0, __p1, __p2, __p3) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		GError ** __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(GKeyFile *, const gchar *, const gchar *, GError **))*(void**)(__base - 1324))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_hook_find_func_data(__p0, __p1, __p2, __p3) \
	({ \
		GHookList * __t__p0 = __p0;\
		gboolean  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		gpointer  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GHook *(*)(GHookList *, gboolean , gpointer , gpointer ))*(void**)(__base - 1156))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_list_copy(__p0) \
	({ \
		GList * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GList *))*(void**)(__base - 1510))(__t__p0));\
	})

#define g_atomic_pointer_compare_and_exchange(__p0, __p1, __p2) \
	(((gboolean (*)(gpointer *, gpointer , gpointer ))*(void**)((long)(GLIB_BASE_NAME) - 358))(__p0, __p1, __p2))

#define g_type_class_add_private(__p0, __p1) \
	({ \
		gpointer  __t__p0 = __p0;\
		gsize  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(gpointer , gsize ))*(void**)(__base - 5290))(__t__p0, __t__p1));\
	})

#define g_ptr_array_sized_new(__p0) \
	({ \
		guint  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GPtrArray *(*)(guint ))*(void**)(__base - 112))(__t__p0));\
	})

#define g_string_assign(__p0, __p1) \
	({ \
		GString * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GString *(*)(GString *, const gchar *))*(void**)(__base - 3112))(__t__p0, __t__p1));\
	})

#define g_node_last_child(__p0) \
	({ \
		GNode * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GNode *(*)(GNode *))*(void**)(__base - 1930))(__t__p0));\
	})

#define g_queue_index(__p0, __p1) \
	({ \
		GQueue * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(GQueue *, gconstpointer ))*(void**)(__base - 2260))(__t__p0, __t__p1));\
	})

#define g_slist_pop_allocator() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)())*(void**)(__base - 2662))());\
	})

#define g_main_context_find_source_by_id(__p0, __p1) \
	({ \
		GMainContext * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSource *(*)(GMainContext *, guint ))*(void**)(__base - 3652))(__t__p0, __t__p1));\
	})

#define g_key_file_get_start_group(__p0) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(GKeyFile *) G_GNUC_MALLOC)*(void**)(__base - 1246))(__t__p0));\
	})

#define g_string_new(__p0) \
	({ \
		const gchar * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GString *(*)(const gchar *))*(void**)(__base - 3076))(__t__p0));\
	})

#define g_option_context_add_main_entries(__p0, __p1, __p2) \
	({ \
		GOptionContext * __t__p0 = __p0;\
		const GOptionEntry * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GOptionContext *, const GOptionEntry *, const gchar *))*(void**)(__base - 2002))(__t__p0, __t__p1, __t__p2));\
	})

#define g_type_init_with_debug_flags(__p0) \
	({ \
		GTypeDebugFlags  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GTypeDebugFlags ))*(void**)(__base - 5104))(__t__p0));\
	})

#define g_array_sort(__p0, __p1) \
	({ \
		GArray * __t__p0 = __p0;\
		GCompareFunc  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GArray *, GCompareFunc ))*(void**)(__base - 94))(__t__p0, __t__p1));\
	})

#define g_queue_peek_head_link(__p0) \
	({ \
		GQueue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GQueue *))*(void**)(__base - 2332))(__t__p0));\
	})

#define g_value_set_boolean(__p0, __p1) \
	({ \
		GValue * __t__p0 = __p0;\
		gboolean  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GValue *, gboolean ))*(void**)(__base - 5494))(__t__p0, __t__p1));\
	})

#define g_main_context_find_source_by_funcs_user_data(__p0, __p1, __p2) \
	({ \
		GMainContext * __t__p0 = __p0;\
		GSourceFuncs * __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSource *(*)(GMainContext *, GSourceFuncs *, gpointer ))*(void**)(__base - 3658))(__t__p0, __t__p1, __t__p2));\
	})

#define g_rand_new_with_seed(__p0) \
	({ \
		guint32  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GRand *(*)(guint32 ))*(void**)(__base - 2368))(__t__p0));\
	})

#define g_list_pop_allocator() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)())*(void**)(__base - 1420))());\
	})

#define g_unicode_canonical_decomposition(__p0, __p1) \
	({ \
		gunichar  __t__p0 = __p0;\
		gsize * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gunichar *(*)(gunichar , gsize *) G_GNUC_MALLOC)*(void**)(__base - 3442))(__t__p0, __t__p1));\
	})

#define g_random_int() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint32 (*)())*(void**)(__base - 2440))());\
	})

#define g_scanner_sync_file_offset(__p0) \
	({ \
		GScanner * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GScanner *))*(void**)(__base - 2536))(__t__p0));\
	})

#define g_tree_new_full(__p0, __p1, __p2, __p3) \
	({ \
		GCompareDataFunc  __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		GDestroyNotify  __t__p2 = __p2;\
		GDestroyNotify  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GTree *(*)(GCompareDataFunc , gpointer , GDestroyNotify , GDestroyNotify ))*(void**)(__base - 3232))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_markup_vprintf_escaped(__p0, __p1) \
	({ \
		const char * __t__p0 = __p0;\
		va_list  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const char *, va_list ))*(void**)(__base - 1636))(__t__p0, __t__p1));\
	})

#define g_string_append_len(__p0, __p1, __p2) \
	({ \
		GString * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		gssize  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GString *(*)(GString *, const gchar *, gssize ))*(void**)(__base - 3142))(__t__p0, __t__p1, __t__p2));\
	})

#define g_ptr_array_remove_range(__p0, __p1, __p2) \
	({ \
		GPtrArray * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		guint  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GPtrArray *, guint , guint ))*(void**)(__base - 154))(__t__p0, __t__p1, __t__p2));\
	})

#define g_markup_parse_context_free(__p0) \
	({ \
		GMarkupParseContext * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GMarkupParseContext *))*(void**)(__base - 1600))(__t__p0));\
	})

#define g_object_freeze_notify(__p0) \
	({ \
		GObject * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GObject *))*(void**)(__base - 4480))(__t__p0));\
	})

#define g_utf8_validate(__p0, __p1, __p2) \
	({ \
		const gchar * __t__p0 = __p0;\
		gssize  __t__p1 = __p1;\
		const gchar ** __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(const gchar *, gssize , const gchar **))*(void**)(__base - 3568))(__t__p0, __t__p1, __t__p2));\
	})

#define g_value_set_uint64(__p0, __p1) \
	({ \
		GValue * __t__p0 = __p0;\
		guint64  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GValue *, guint64 ))*(void**)(__base - 5566))(__t__p0, __t__p1));\
	})

#define g_main_context_new() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GMainContext *(*)())*(void**)(__base - 3682))());\
	})

#define g_main_context_acquire(__p0) \
	({ \
		GMainContext * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GMainContext *))*(void**)(__base - 3622))(__t__p0));\
	})

#define g_value_get_double(__p0) \
	({ \
		const GValue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gdouble (*)(const GValue *))*(void**)(__base - 5596))(__t__p0));\
	})

#define g_idle_source_new() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSource *(*)())*(void**)(__base - 3808))());\
	})

#define g_byte_array_sized_new(__p0) \
	({ \
		guint  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GByteArray *(*)(guint ))*(void**)(__base - 190))(__t__p0));\
	})

#define g_spaced_primes_closest(__p0) \
	({ \
		guint  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(guint ) G_GNUC_CONST)*(void**)(__base - 2110))(__t__p0));\
	})

#define g_ptr_array_add(__p0, __p1) \
	({ \
		GPtrArray * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GPtrArray *, gpointer ))*(void**)(__base - 160))(__t__p0, __t__p1));\
	})

#define g_param_value_set_default(__p0, __p1) \
	({ \
		GParamSpec * __t__p0 = __p0;\
		GValue * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GParamSpec *, GValue *))*(void**)(__base - 4708))(__t__p0, __t__p1));\
	})

#define g_signal_add_emission_hook(__p0, __p1, __p2, __p3, __p4) \
	({ \
		guint  __t__p0 = __p0;\
		GQuark  __t__p1 = __p1;\
		GSignalEmissionHook  __t__p2 = __p2;\
		gpointer  __t__p3 = __p3;\
		GDestroyNotify  __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gulong (*)(guint , GQuark , GSignalEmissionHook , gpointer , GDestroyNotify ))*(void**)(__base - 4978))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_cache_new(__p0, __p1, __p2, __p3, __p4, __p5, __p6) \
	({ \
		GCacheNewFunc  __t__p0 = __p0;\
		GCacheDestroyFunc  __t__p1 = __p1;\
		GCacheDupFunc  __t__p2 = __p2;\
		GCacheDestroyFunc  __t__p3 = __p3;\
		GHashFunc  __t__p4 = __p4;\
		GHashFunc  __t__p5 = __p5;\
		GEqualFunc  __t__p6 = __p6;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GCache *(*)(GCacheNewFunc , GCacheDestroyFunc , GCacheDupFunc , GCacheDestroyFunc , GHashFunc , GHashFunc , GEqualFunc ))*(void**)(__base - 388))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5, __t__p6));\
	})

#define g_main_context_wait(__p0, __p1, __p2) \
	({ \
		GMainContext * __t__p0 = __p0;\
		GCond * __t__p1 = __p1;\
		GMutex * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GMainContext *, GCond *, GMutex *))*(void**)(__base - 3736))(__t__p0, __t__p1, __t__p2));\
	})

#define g_pattern_match_string(__p0, __p1) \
	({ \
		GPatternSpec * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GPatternSpec *, const gchar *))*(void**)(__base - 2098))(__t__p0, __t__p1));\
	})

#define g_timeout_add_full(__p0, __p1, __p2, __p3, __p4) \
	({ \
		gint  __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		GSourceFunc  __t__p2 = __p2;\
		gpointer  __t__p3 = __p3;\
		GDestroyNotify  __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(gint , guint , GSourceFunc , gpointer , GDestroyNotify ))*(void**)(__base - 4090))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_mem_chunk_info() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)())*(void**)(__base - 1726))());\
	})

#define g_string_prepend_len(__p0, __p1, __p2) \
	({ \
		GString * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		gssize  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GString *(*)(GString *, const gchar *, gssize ))*(void**)(__base - 3178))(__t__p0, __t__p1, __t__p2));\
	})

#define g_completion_add_items(__p0, __p1) \
	({ \
		GCompletion * __t__p0 = __p0;\
		GList * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GCompletion *, GList *))*(void**)(__base - 430))(__t__p0, __t__p1));\
	})

#define g_param_spec_uint64(__p0, __p1, __p2, __p3, __p4, __p5, __p6) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		guint64  __t__p3 = __p3;\
		guint64  __t__p4 = __p4;\
		guint64  __t__p5 = __p5;\
		GParamFlags  __t__p6 = __p6;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(const gchar *, const gchar *, const gchar *, guint64 , guint64 , guint64 , GParamFlags ))*(void**)(__base - 4834))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5, __t__p6));\
	})

#define g_type_class_peek_parent(__p0) \
	({ \
		gpointer  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(gpointer ))*(void**)(__base - 5176))(__t__p0));\
	})

#define g_signal_handler_is_connected(__p0, __p1) \
	({ \
		gpointer  __t__p0 = __p0;\
		gulong  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(gpointer , gulong ))*(void**)(__base - 5032))(__t__p0, __t__p1));\
	})

#define g_unichar_type(__p0) \
	({ \
		gunichar  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GUnicodeType (*)(gunichar ) G_GNUC_CONST)*(void**)(__base - 3424))(__t__p0));\
	})

#define g_queue_sort(__p0, __p1, __p2) \
	({ \
		GQueue * __t__p0 = __p0;\
		GCompareDataFunc  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GQueue *, GCompareDataFunc , gpointer ))*(void**)(__base - 2200))(__t__p0, __t__p1, __t__p2));\
	})

#define g_main_context_pending(__p0) \
	({ \
		GMainContext * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GMainContext *))*(void**)(__base - 3688))(__t__p0));\
	})

#define g_list_last(__p0) \
	({ \
		GList * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GList *))*(void**)(__base - 1552))(__t__p0));\
	})

#define g_param_spec_sink(__p0) \
	({ \
		GParamSpec * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GParamSpec *))*(void**)(__base - 4666))(__t__p0));\
	})

#define g_hook_compare_ids(__p0, __p1) \
	({ \
		GHook * __t__p0 = __p0;\
		GHook * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(GHook *, GHook *))*(void**)(__base - 1174))(__t__p0, __t__p1));\
	})

#define g_object_newv(__p0, __p1, __p2) \
	({ \
		GType  __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		GParameter * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GType , guint , GParameter *))*(void**)(__base - 4444))(__t__p0, __t__p1, __t__p2));\
	})

#define g_date_set_time(__p0, __p1) \
	({ \
		GDate * __t__p0 = __p0;\
		GTime  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GDate *, GTime ))*(void**)(__base - 688))(__t__p0, __t__p1));\
	})

#define g_param_spec_char(__p0, __p1, __p2, __p3, __p4, __p5, __p6) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		gint8  __t__p3 = __p3;\
		gint8  __t__p4 = __p4;\
		gint8  __t__p5 = __p5;\
		GParamFlags  __t__p6 = __p6;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(const gchar *, const gchar *, const gchar *, gint8 , gint8 , gint8 , GParamFlags ))*(void**)(__base - 4786))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5, __t__p6));\
	})

#define g_key_file_get_comment(__p0, __p1, __p2, __p3) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		GError ** __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(GKeyFile *, const gchar *, const gchar *, GError **) G_GNUC_MALLOC)*(void**)(__base - 1390))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_ptr_array_sort(__p0, __p1) \
	({ \
		GPtrArray * __t__p0 = __p0;\
		GCompareFunc  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GPtrArray *, GCompareFunc ))*(void**)(__base - 166))(__t__p0, __t__p1));\
	})

#define g_tree_remove(__p0, __p1) \
	({ \
		GTree * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GTree *, gconstpointer ))*(void**)(__base - 3256))(__t__p0, __t__p1));\
	})

#define g_hook_next_valid(__p0, __p1, __p2) \
	({ \
		GHookList * __t__p0 = __p0;\
		GHook * __t__p1 = __p1;\
		gboolean  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GHook *(*)(GHookList *, GHook *, gboolean ))*(void**)(__base - 1168))(__t__p0, __t__p1, __t__p2));\
	})

#define g_main_context_query(__p0, __p1, __p2, __p3, __p4) \
	({ \
		GMainContext * __t__p0 = __p0;\
		gint  __t__p1 = __p1;\
		gint * __t__p2 = __p2;\
		GPollFD * __t__p3 = __p3;\
		gint  __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(GMainContext *, gint , gint *, GPollFD *, gint ))*(void**)(__base - 3700))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_value_get_ulong(__p0) \
	({ \
		const GValue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gulong (*)(const GValue *))*(void**)(__base - 5548))(__t__p0));\
	})

#define g_async_queue_timed_pop(__p0, __p1) \
	({ \
		GAsyncQueue * __t__p0 = __p0;\
		GTimeVal * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GAsyncQueue *, GTimeVal *))*(void**)(__base - 316))(__t__p0, __t__p1));\
	})

#define g_type_class_peek_static(__p0) \
	({ \
		GType  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GType ))*(void**)(__base - 5164))(__t__p0));\
	})

#define g_io_channel_read_to_end(__p0, __p1, __p2, __p3) \
	({ \
		GIOChannel * __t__p0 = __p0;\
		gchar ** __t__p1 = __p1;\
		gsize * __t__p2 = __p2;\
		GError ** __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GIOStatus (*)(GIOChannel *, gchar **, gsize *, GError **))*(void**)(__base - 3910))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_param_value_defaults(__p0, __p1) \
	({ \
		GParamSpec * __t__p0 = __p0;\
		GValue * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GParamSpec *, GValue *))*(void**)(__base - 4714))(__t__p0, __t__p1));\
	})

#define g_relation_new(__p0) \
	({ \
		gint  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GRelation *(*)(gint ))*(void**)(__base - 2464))(__t__p0));\
	})

#define g_object_ref_sink(__p0) \
	({ \
		gpointer  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(gpointer ))*(void**)(__base - 4504))(__t__p0));\
	})

#define g_value_get_flags(__p0) \
	({ \
		const GValue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(const GValue *))*(void**)(__base - 4366))(__t__p0));\
	})

#define g_string_insert_len(__p0, __p1, __p2, __p3) \
	({ \
		GString * __t__p0 = __p0;\
		gssize  __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		gssize  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GString *(*)(GString *, gssize , const gchar *, gssize ))*(void**)(__base - 3130))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_type_get_qdata(__p0, __p1) \
	({ \
		GType  __t__p0 = __p0;\
		GQuark  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GType , GQuark ))*(void**)(__base - 5230))(__t__p0, __t__p1));\
	})

#define g_value_set_ulong(__p0, __p1) \
	({ \
		GValue * __t__p0 = __p0;\
		gulong  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GValue *, gulong ))*(void**)(__base - 5542))(__t__p0, __t__p1));\
	})

#define g_qsort_with_data(__p0, __p1, __p2, __p3, __p4) \
	({ \
		gconstpointer  __t__p0 = __p0;\
		gint  __t__p1 = __p1;\
		gsize  __t__p2 = __p2;\
		GCompareDataFunc  __t__p3 = __p3;\
		gpointer  __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(gconstpointer , gint , gsize , GCompareDataFunc , gpointer ))*(void**)(__base - 2116))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_strstr_len(__p0, __p1, __p2) \
	({ \
		const gchar * __t__p0 = __p0;\
		gssize  __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, gssize , const gchar *))*(void**)(__base - 2890))(__t__p0, __t__p1, __t__p2));\
	})

#define g_strfreev(__p0) \
	({ \
		gchar ** __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(gchar **))*(void**)(__base - 3046))(__t__p0));\
	})

#define g_main_loop_run(__p0) \
	({ \
		GMainLoop * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GMainLoop *))*(void**)(__base - 3784))(__t__p0));\
	})

#define g_type_qname(__p0) \
	({ \
		GType  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GQuark (*)(GType ))*(void**)(__base - 5116))(__t__p0));\
	})

#define g_io_channel_read_unichar(__p0, __p1, __p2) \
	({ \
		GIOChannel * __t__p0 = __p0;\
		gunichar * __t__p1 = __p1;\
		GError ** __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GIOStatus (*)(GIOChannel *, gunichar *, GError **))*(void**)(__base - 3916))(__t__p0, __t__p1, __t__p2));\
	})

#define g_hook_list_invoke_check(__p0, __p1) \
	({ \
		GHookList * __t__p0 = __p0;\
		gboolean  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GHookList *, gboolean ))*(void**)(__base - 1186))(__t__p0, __t__p1));\
	})

#define g_value_set_flags(__p0, __p1) \
	({ \
		GValue * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GValue *, guint ))*(void**)(__base - 4360))(__t__p0, __t__p1));\
	})

#define g_value_array_copy(__p0) \
	({ \
		const GValueArray * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GValueArray *(*)(const GValueArray *))*(void**)(__base - 5428))(__t__p0));\
	})

#define g_io_add_watch(__p0, __p1, __p2, __p3) \
	({ \
		GIOChannel * __t__p0 = __p0;\
		GIOCondition  __t__p1 = __p1;\
		GIOFunc  __t__p2 = __p2;\
		gpointer  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(GIOChannel *, GIOCondition , GIOFunc , gpointer ))*(void**)(__base - 3814))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_async_queue_timed_pop_unlocked(__p0, __p1) \
	({ \
		GAsyncQueue * __t__p0 = __p0;\
		GTimeVal * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GAsyncQueue *, GTimeVal *))*(void**)(__base - 322))(__t__p0, __t__p1));\
	})

#define g_type_register_static_simple(__p0, __p1, __p2, __p3, __p4, __p5, __p6) \
	({ \
		GType  __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		guint  __t__p2 = __p2;\
		GClassInitFunc  __t__p3 = __p3;\
		guint  __t__p4 = __p4;\
		GInstanceInitFunc  __t__p5 = __p5;\
		GTypeFlags  __t__p6 = __p6;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GType (*)(GType , const gchar *, guint , GClassInitFunc , guint , GInstanceInitFunc , GTypeFlags ))*(void**)(__base - 5248))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5, __t__p6));\
	})

#define g_random_int_range(__p0, __p1) \
	({ \
		gint32  __t__p0 = __p0;\
		gint32  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint32 (*)(gint32 , gint32 ))*(void**)(__base - 2446))(__t__p0, __t__p1));\
	})

#define g_type_set_qdata(__p0, __p1, __p2) \
	({ \
		GType  __t__p0 = __p0;\
		GQuark  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GType , GQuark , gpointer ))*(void**)(__base - 5224))(__t__p0, __t__p1, __t__p2));\
	})

#define g_slist_alloc() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSList *(*)())*(void**)(__base - 2668))());\
	})

#define g_completion_free(__p0) \
	({ \
		GCompletion * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GCompletion *))*(void**)(__base - 466))(__t__p0));\
	})

#define g_list_free(__p0) \
	({ \
		GList * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GList *))*(void**)(__base - 1432))(__t__p0));\
	})

#define g_utf8_strlen(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		gssize  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((glong (*)(const gchar *, gssize ))*(void**)(__base - 3490))(__t__p0, __t__p1));\
	})

#define g_type_interface_peek_parent(__p0) \
	({ \
		gpointer  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(gpointer ))*(void**)(__base - 5188))(__t__p0));\
	})

#define g_queue_reverse(__p0) \
	({ \
		GQueue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GQueue *))*(void**)(__base - 2170))(__t__p0));\
	})

#define g_datalist_get_flags(__p0) \
	({ \
		GData ** __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(GData **))*(void**)(__base - 520))(__t__p0));\
	})

#define g_object_remove_toggle_ref(__p0, __p1, __p2) \
	({ \
		GObject * __t__p0 = __p0;\
		GToggleNotify  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GObject *, GToggleNotify , gpointer ))*(void**)(__base - 4552))(__t__p0, __t__p1, __t__p2));\
	})

#define g_free(__p0) \
	({ \
		gpointer  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(gpointer ))*(void**)(__base - 1660))(__t__p0));\
	})

#define g_strrstr_len(__p0, __p1, __p2) \
	({ \
		const gchar * __t__p0 = __p0;\
		gssize  __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, gssize , const gchar *))*(void**)(__base - 2902))(__t__p0, __t__p1, __t__p2));\
	})

#define g_flags_get_value_by_name(__p0, __p1) \
	({ \
		GFlagsClass * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GFlagsValue *(*)(GFlagsClass *, const gchar *))*(void**)(__base - 4336))(__t__p0, __t__p1));\
	})

#define g_error_copy(__p0) \
	({ \
		const GError * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GError *(*)(const GError *))*(void**)(__base - 868))(__t__p0));\
	})

#define g_strsplit(__p0, __p1, __p2) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		gint  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar **(*)(const gchar *, const gchar *, gint ) G_GNUC_MALLOC)*(void**)(__base - 3028))(__t__p0, __t__p1, __t__p2));\
	})

#define g_date_get_weekday(__p0) \
	({ \
		const GDate * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GDateWeekday (*)(const GDate *))*(void**)(__base - 622))(__t__p0));\
	})

#define g_io_add_watch_full(__p0, __p1, __p2, __p3, __p4, __p5) \
	({ \
		GIOChannel * __t__p0 = __p0;\
		gint  __t__p1 = __p1;\
		GIOCondition  __t__p2 = __p2;\
		GIOFunc  __t__p3 = __p3;\
		gpointer  __t__p4 = __p4;\
		GDestroyNotify  __t__p5 = __p5;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(GIOChannel *, gint , GIOCondition , GIOFunc , gpointer , GDestroyNotify ))*(void**)(__base - 3820))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5));\
	})

#define g_ascii_dtostr(__p0, __p1, __p2) \
	({ \
		gchar * __t__p0 = __p0;\
		gint  __t__p1 = __p1;\
		gdouble  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(gchar *, gint , gdouble ))*(void**)(__base - 2938))(__t__p0, __t__p1, __t__p2));\
	})

#define g_async_queue_new() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GAsyncQueue *(*)())*(void**)(__base - 250))());\
	})

#define g_strdup_value_contents(__p0) \
	({ \
		const GValue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const GValue *))*(void**)(__base - 5662))(__t__p0));\
	})

#define g_type_module_register_type(__p0, __p1, __p2, __p3, __p4) \
	({ \
		GTypeModule * __t__p0 = __p0;\
		GType  __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		const GTypeInfo * __t__p3 = __p3;\
		GTypeFlags  __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GType (*)(GTypeModule *, GType , const gchar *, const GTypeInfo *, GTypeFlags ))*(void**)(__base - 5326))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_datalist_set_flags(__p0, __p1) \
	({ \
		GData ** __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GData **, guint ))*(void**)(__base - 508))(__t__p0, __t__p1));\
	})

#define g_error_matches(__p0, __p1, __p2) \
	({ \
		const GError * __t__p0 = __p0;\
		GQuark  __t__p1 = __p1;\
		gint  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(const GError *, GQuark , gint ))*(void**)(__base - 874))(__t__p0, __t__p1, __t__p2));\
	})

#define g_rand_set_seed_array(__p0, __p1, __p2) \
	({ \
		GRand * __t__p0 = __p0;\
		const guint32 * __t__p1 = __p1;\
		guint  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GRand *, const guint32 *, guint ))*(void**)(__base - 2404))(__t__p0, __t__p1, __t__p2));\
	})

#define g_timeout_add(__p0, __p1, __p2) \
	({ \
		guint  __t__p0 = __p0;\
		GSourceFunc  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(guint , GSourceFunc , gpointer ))*(void**)(__base - 4084))(__t__p0, __t__p1, __t__p2));\
	})

#define g_object_get_data(__p0, __p1) \
	({ \
		GObject * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GObject *, const gchar *))*(void**)(__base - 4582))(__t__p0, __t__p1));\
	})

#define g_scanner_scope_lookup_symbol(__p0, __p1, __p2) \
	({ \
		GScanner * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GScanner *, guint , const gchar *))*(void**)(__base - 2608))(__t__p0, __t__p1, __t__p2));\
	})

#ifndef __cplusplus
#define g_strconcat(...) \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		(((gchar *(*)(const gchar *, ...) G_GNUC_MALLOC)*(void**)(__base - 4240))(__VA_ARGS__,({__asm volatile("mr 12,%0": :"r"(__base):"r12");0L;})));\
	})
#endif

#define g_completion_complete(__p0, __p1, __p2) \
	({ \
		GCompletion * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		gchar ** __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GCompletion *, const gchar *, gchar **))*(void**)(__base - 448))(__t__p0, __t__p1, __t__p2));\
	})

#define g_type_default_interface_unref(__p0) \
	({ \
		gpointer  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(gpointer ))*(void**)(__base - 5206))(__t__p0));\
	})

#define g_source_new(__p0, __p1) \
	({ \
		GSourceFuncs * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSource *(*)(GSourceFuncs *, guint ))*(void**)(__base - 4102))(__t__p0, __t__p1));\
	})

#define g_string_set_size(__p0, __p1) \
	({ \
		GString * __t__p0 = __p0;\
		gsize  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GString *(*)(GString *, gsize ))*(void**)(__base - 3124))(__t__p0, __t__p1));\
	})

#define g_key_file_set_list_separator(__p0, __p1) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		gchar  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GKeyFile *, gchar ))*(void**)(__base - 1216))(__t__p0, __t__p1));\
	})

#define g_io_channel_set_encoding(__p0, __p1, __p2) \
	({ \
		GIOChannel * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		GError ** __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GIOStatus (*)(GIOChannel *, const gchar *, GError **))*(void**)(__base - 3952))(__t__p0, __t__p1, __t__p2));\
	})

#define g_array_remove_index(__p0, __p1) \
	({ \
		GArray * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GArray *(*)(GArray *, guint ))*(void**)(__base - 76))(__t__p0, __t__p1));\
	})

#define g_log_default_handler(__p0, __p1, __p2, __p3) \
	({ \
		const gchar * __t__p0 = __p0;\
		GLogLevelFlags  __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		gpointer  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(const gchar *, GLogLevelFlags , const gchar *, gpointer ))*(void**)(__base - 1768))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_source_attach(__p0, __p1) \
	({ \
		GSource * __t__p0 = __p0;\
		GMainContext * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(GSource *, GMainContext *))*(void**)(__base - 4120))(__t__p0, __t__p1));\
	})

#define g_shell_quote(__p0) \
	({ \
		const gchar * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *))*(void**)(__base - 2638))(__t__p0));\
	})

#define g_type_interfaces(__p0, __p1) \
	({ \
		GType  __t__p0 = __p0;\
		guint * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GType *(*)(GType , guint *))*(void**)(__base - 5218))(__t__p0, __t__p1));\
	})

#define g_byte_array_append(__p0, __p1, __p2) \
	({ \
		GByteArray * __t__p0 = __p0;\
		const guint8 * __t__p1 = __p1;\
		guint  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GByteArray *(*)(GByteArray *, const guint8 *, guint ))*(void**)(__base - 202))(__t__p0, __t__p1, __t__p2));\
	})

#define g_queue_pop_tail_link(__p0) \
	({ \
		GQueue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GQueue *))*(void**)(__base - 2320))(__t__p0));\
	})

#define g_relation_print(__p0) \
	({ \
		GRelation * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GRelation *))*(void**)(__base - 2500))(__t__p0));\
	})

#define g_param_spec_ref_sink(__p0) \
	({ \
		GParamSpec * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(GParamSpec *))*(void**)(__base - 4672))(__t__p0));\
	})

#define g_value_unset(__p0) \
	({ \
		GValue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GValue *))*(void**)(__base - 5398))(__t__p0));\
	})

#define g_node_insert_before(__p0, __p1, __p2) \
	({ \
		GNode * __t__p0 = __p0;\
		GNode * __t__p1 = __p1;\
		GNode * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GNode *(*)(GNode *, GNode *, GNode *))*(void**)(__base - 1846))(__t__p0, __t__p1, __t__p2));\
	})

#define g_io_channel_set_buffer_size(__p0, __p1) \
	({ \
		GIOChannel * __t__p0 = __p0;\
		gsize  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GIOChannel *, gsize ))*(void**)(__base - 3934))(__t__p0, __t__p1));\
	})

#define g_io_channel_unref(__p0) \
	({ \
		GIOChannel * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GIOChannel *))*(void**)(__base - 3976))(__t__p0));\
	})

#define g_rand_int(__p0) \
	({ \
		GRand * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint32 (*)(GRand *))*(void**)(__base - 2410))(__t__p0));\
	})

#define g_array_remove_index_fast(__p0, __p1) \
	({ \
		GArray * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GArray *(*)(GArray *, guint ))*(void**)(__base - 82))(__t__p0, __t__p1));\
	})

#define g_list_position(__p0, __p1) \
	({ \
		GList * __t__p0 = __p0;\
		GList * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(GList *, GList *))*(void**)(__base - 1540))(__t__p0, __t__p1));\
	})

#define g_strsplit_set(__p0, __p1, __p2) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		gint  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar **(*)(const gchar *, const gchar *, gint ) G_GNUC_MALLOC)*(void**)(__base - 3034))(__t__p0, __t__p1, __t__p2));\
	})

#define g_utf8_get_char_validated(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		gssize  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gunichar (*)(const gchar *, gssize ))*(void**)(__base - 3454))(__t__p0, __t__p1));\
	})

#define g_enum_get_value(__p0, __p1) \
	({ \
		GEnumClass * __t__p0 = __p0;\
		gint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GEnumValue *(*)(GEnumClass *, gint ))*(void**)(__base - 4312))(__t__p0, __t__p1));\
	})

#define g_key_file_new() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GKeyFile *(*)())*(void**)(__base - 1204))());\
	})

#define g_unichar_to_utf8(__p0, __p1) \
	({ \
		gunichar  __t__p0 = __p0;\
		gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(gunichar , gchar *))*(void**)(__base - 3562))(__t__p0, __t__p1));\
	})

#define g_date_get_monday_week_of_year(__p0) \
	({ \
		const GDate * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(const GDate *))*(void**)(__base - 658))(__t__p0));\
	})

#define g_utf16_to_ucs4(__p0, __p1, __p2, __p3, __p4) \
	({ \
		const gunichar2 * __t__p0 = __p0;\
		glong  __t__p1 = __p1;\
		glong * __t__p2 = __p2;\
		glong * __t__p3 = __p3;\
		GError ** __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gunichar *(*)(const gunichar2 *, glong , glong *, glong *, GError **))*(void**)(__base - 3538))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_io_channel_new_file(__p0, __p1, __p2) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		GError ** __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GIOChannel *(*)(const gchar *, const gchar *, GError **))*(void**)(__base - 3886))(__t__p0, __t__p1, __t__p2));\
	})

#define g_quark_try_string(__p0) \
	({ \
		const gchar * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GQuark (*)(const gchar *))*(void**)(__base - 2122))(__t__p0));\
	})

#define g_key_file_load_from_file(__p0, __p1, __p2, __p3) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		GKeyFileFlags  __t__p2 = __p2;\
		GError ** __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GKeyFile *, const gchar *, GKeyFileFlags , GError **))*(void**)(__base - 1222))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_scanner_unexp_token(__p0, __p1, __p2, __p3, __p4, __p5, __p6) \
	({ \
		GScanner * __t__p0 = __p0;\
		GTokenType  __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		const gchar * __t__p3 = __p3;\
		const gchar * __t__p4 = __p4;\
		const gchar * __t__p5 = __p5;\
		gint  __t__p6 = __p6;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GScanner *, GTokenType , const gchar *, const gchar *, const gchar *, const gchar *, gint ))*(void**)(__base - 2626))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5, __t__p6));\
	})

#define g_array_sort_with_data(__p0, __p1, __p2) \
	({ \
		GArray * __t__p0 = __p0;\
		GCompareDataFunc  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GArray *, GCompareDataFunc , gpointer ))*(void**)(__base - 100))(__t__p0, __t__p1, __t__p2));\
	})

#define g_filename_from_utf8(__p0, __p1, __p2, __p3, __p4) \
	({ \
		const gchar * __t__p0 = __p0;\
		gssize  __t__p1 = __p1;\
		gsize * __t__p2 = __p2;\
		gsize * __t__p3 = __p3;\
		GError ** __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, gssize , gsize *, gsize *, GError **) G_GNUC_MALLOC)*(void**)(__base - 4066))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_hash_table_insert(__p0, __p1, __p2) \
	({ \
		GHashTable * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GHashTable *, gpointer , gpointer ))*(void**)(__base - 952))(__t__p0, __t__p1, __t__p2));\
	})

#define g_date_free(__p0) \
	({ \
		GDate * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GDate *))*(void**)(__base - 574))(__t__p0));\
	})

#define g_pattern_spec_equal(__p0, __p1) \
	({ \
		GPatternSpec * __t__p0 = __p0;\
		GPatternSpec * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GPatternSpec *, GPatternSpec *))*(void**)(__base - 2086))(__t__p0, __t__p1));\
	})

#define g_type_module_register_enum(__p0, __p1, __p2) \
	({ \
		GTypeModule * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const GEnumValue * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GType (*)(GTypeModule *, const gchar *, const GEnumValue *))*(void**)(__base - 5338))(__t__p0, __t__p1, __t__p2));\
	})

#define g_key_file_get_boolean_list(__p0, __p1, __p2, __p3, __p4) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		gsize * __t__p3 = __p3;\
		GError ** __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean *(*)(GKeyFile *, const gchar *, const gchar *, gsize *, GError **) G_GNUC_MALLOC)*(void**)(__base - 1360))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_key_file_to_data(__p0, __p1, __p2) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		gsize * __t__p1 = __p1;\
		GError ** __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(GKeyFile *, gsize *, GError **) G_GNUC_MALLOC)*(void**)(__base - 1240))(__t__p0, __t__p1, __t__p2));\
	})

#define g_io_channel_init(__p0) \
	({ \
		GIOChannel * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GIOChannel *))*(void**)(__base - 3880))(__t__p0));\
	})

#define g_slist_position(__p0, __p1) \
	({ \
		GSList * __t__p0 = __p0;\
		GSList * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(GSList *, GSList *))*(void**)(__base - 2776))(__t__p0, __t__p1));\
	})

#define g_queue_pop_head(__p0) \
	({ \
		GQueue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GQueue *))*(void**)(__base - 2224))(__t__p0));\
	})

#define g_node_push_allocator(__p0) \
	({ \
		GAllocator * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GAllocator *))*(void**)(__base - 1798))(__t__p0));\
	})

#define g_param_spec_int(__p0, __p1, __p2, __p3, __p4, __p5, __p6) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		gint  __t__p3 = __p3;\
		gint  __t__p4 = __p4;\
		gint  __t__p5 = __p5;\
		GParamFlags  __t__p6 = __p6;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(const gchar *, const gchar *, const gchar *, gint , gint , gint , GParamFlags ))*(void**)(__base - 4804))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5, __t__p6));\
	})

#define g_date_new() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GDate *(*)())*(void**)(__base - 556))());\
	})

#define g_unicode_canonical_ordering(__p0, __p1) \
	({ \
		gunichar * __t__p0 = __p0;\
		gsize  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(gunichar *, gsize ))*(void**)(__base - 3436))(__t__p0, __t__p1));\
	})

#define g_utf8_to_ucs4(__p0, __p1, __p2, __p3, __p4) \
	({ \
		const gchar * __t__p0 = __p0;\
		glong  __t__p1 = __p1;\
		glong * __t__p2 = __p2;\
		glong * __t__p3 = __p3;\
		GError ** __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gunichar *(*)(const gchar *, glong , glong *, glong *, GError **) G_GNUC_MALLOC)*(void**)(__base - 3526))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_ucs4_to_utf8(__p0, __p1, __p2, __p3, __p4) \
	({ \
		const gunichar * __t__p0 = __p0;\
		glong  __t__p1 = __p1;\
		glong * __t__p2 = __p2;\
		glong * __t__p3 = __p3;\
		GError ** __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gunichar *, glong , glong *, glong *, GError **) G_GNUC_MALLOC)*(void**)(__base - 3556))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_tree_height(__p0) \
	({ \
		GTree * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(GTree *))*(void**)(__base - 3292))(__t__p0));\
	})

#define g_signal_handler_unblock(__p0, __p1) \
	({ \
		gpointer  __t__p0 = __p0;\
		gulong  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(gpointer , gulong ))*(void**)(__base - 5020))(__t__p0, __t__p1));\
	})

#define g_value_set_pointer(__p0, __p1) \
	({ \
		GValue * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GValue *, gpointer ))*(void**)(__base - 5626))(__t__p0, __t__p1));\
	})

#define g_enum_get_value_by_name(__p0, __p1) \
	({ \
		GEnumClass * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GEnumValue *(*)(GEnumClass *, const gchar *))*(void**)(__base - 4318))(__t__p0, __t__p1));\
	})

#define g_node_insert_after(__p0, __p1, __p2) \
	({ \
		GNode * __t__p0 = __p0;\
		GNode * __t__p1 = __p1;\
		GNode * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GNode *(*)(GNode *, GNode *, GNode *))*(void**)(__base - 1852))(__t__p0, __t__p1, __t__p2));\
	})

#define g_rand_double_range(__p0, __p1, __p2) \
	({ \
		GRand * __t__p0 = __p0;\
		gdouble  __t__p1 = __p1;\
		gdouble  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gdouble (*)(GRand *, gdouble , gdouble ))*(void**)(__base - 2428))(__t__p0, __t__p1, __t__p2));\
	})

#define g_object_interface_find_property(__p0, __p1) \
	({ \
		gpointer  __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(gpointer , const gchar *))*(void**)(__base - 4432))(__t__p0, __t__p1));\
	})

#define g_value_get_param(__p0) \
	({ \
		const GValue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(const GValue *))*(void**)(__base - 4762))(__t__p0));\
	})

#define g_option_group_set_parse_hooks(__p0, __p1, __p2) \
	({ \
		GOptionGroup * __t__p0 = __p0;\
		GOptionParseFunc  __t__p1 = __p1;\
		GOptionParseFunc  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GOptionGroup *, GOptionParseFunc , GOptionParseFunc ))*(void**)(__base - 2038))(__t__p0, __t__p1, __t__p2));\
	})

#define g_rand_new() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GRand *(*)())*(void**)(__base - 2380))());\
	})

#define g_ascii_strtoull(__p0, __p1, __p2) \
	({ \
		const gchar * __t__p0 = __p0;\
		gchar ** __t__p1 = __p1;\
		guint  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint64 (*)(const gchar *, gchar **, guint ))*(void**)(__base - 2932))(__t__p0, __t__p1, __t__p2));\
	})

#define g_unichar_isprint(__p0) \
	({ \
		gunichar  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(gunichar ) G_GNUC_CONST)*(void**)(__base - 3346))(__t__p0));\
	})

#define g_child_watch_source_new(__p0) \
	({ \
		GPid  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSource *(*)(GPid ))*(void**)(__base - 4024))(__t__p0));\
	})

#define g_queue_push_head(__p0, __p1) \
	({ \
		GQueue * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GQueue *, gpointer ))*(void**)(__base - 2206))(__t__p0, __t__p1));\
	})

#define g_value_dup_param(__p0) \
	({ \
		const GValue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(const GValue *))*(void**)(__base - 4768))(__t__p0));\
	})

#define g_type_query(__p0, __p1) \
	({ \
		GType  __t__p0 = __p0;\
		GTypeQuery * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GType , GTypeQuery *))*(void**)(__base - 5236))(__t__p0, __t__p1));\
	})

#define g_value_take_string(__p0, __p1) \
	({ \
		GValue * __t__p0 = __p0;\
		gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GValue *, gchar *))*(void**)(__base - 5668))(__t__p0, __t__p1));\
	})

#define g_value_set_param(__p0, __p1) \
	({ \
		GValue * __t__p0 = __p0;\
		GParamSpec * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GValue *, GParamSpec *))*(void**)(__base - 4756))(__t__p0, __t__p1));\
	})

#define g_mem_chunk_reset(__p0) \
	({ \
		GMemChunk * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GMemChunk *))*(void**)(__base - 1714))(__t__p0));\
	})

#define g_hook_destroy(__p0, __p1) \
	({ \
		GHookList * __t__p0 = __p0;\
		gulong  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GHookList *, gulong ))*(void**)(__base - 1102))(__t__p0, __t__p1));\
	})

#define g_value_array_free(__p0) \
	({ \
		GValueArray * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GValueArray *))*(void**)(__base - 5422))(__t__p0));\
	})

#define g_type_plugin_use(__p0) \
	({ \
		GTypePlugin * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GTypePlugin *))*(void**)(__base - 5356))(__t__p0));\
	})

#define g_date_add_months(__p0, __p1) \
	({ \
		GDate * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GDate *, guint ))*(void**)(__base - 748))(__t__p0, __t__p1));\
	})

#define g_param_values_cmp(__p0, __p1, __p2) \
	({ \
		GParamSpec * __t__p0 = __p0;\
		const GValue * __t__p1 = __p1;\
		const GValue * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(GParamSpec *, const GValue *, const GValue *))*(void**)(__base - 4732))(__t__p0, __t__p1, __t__p2));\
	})

#define g_object_get_qdata(__p0, __p1) \
	({ \
		GObject * __t__p0 = __p0;\
		GQuark  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GObject *, GQuark ))*(void**)(__base - 4558))(__t__p0, __t__p1));\
	})

#define g_mem_chunk_new(__p0, __p1, __p2, __p3) \
	({ \
		const gchar * __t__p0 = __p0;\
		gint  __t__p1 = __p1;\
		gulong  __t__p2 = __p2;\
		gint  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GMemChunk *(*)(const gchar *, gint , gulong , gint ))*(void**)(__base - 1678))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_int_equal(__p0, __p1) \
	({ \
		gconstpointer  __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(gconstpointer , gconstpointer ))*(void**)(__base - 1042))(__t__p0, __t__p1));\
	})

#ifndef __cplusplus
#define g_log(__p0, __p1, ...) \
	({ \
		const gchar * __t__p0 = __p0;\
		GLogLevelFlags  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		(((void (*)(const gchar *, GLogLevelFlags , const gchar *, ...) G_GNUC_PRINTF (3, 4))*(void**)(__base - 4228))(__t__p0, __t__p1, __VA_ARGS__,({__asm volatile("mr 12,%0": :"r"(__base):"r12");0L;})));\
	})
#endif

#define g_param_spec_gtype(__p0, __p1, __p2, __p3, __p4) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		GType  __t__p3 = __p3;\
		GParamFlags  __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(const gchar *, const gchar *, const gchar *, GType , GParamFlags ))*(void**)(__base - 4912))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_slist_insert(__p0, __p1, __p2) \
	({ \
		GSList * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		gint  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSList *(*)(GSList *, gpointer , gint ))*(void**)(__base - 2698))(__t__p0, __t__p1, __t__p2));\
	})

#define g_dataset_id_set_data_full(__p0, __p1, __p2, __p3) \
	({ \
		gconstpointer  __t__p0 = __p0;\
		GQuark  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		GDestroyNotify  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(gconstpointer , GQuark , gpointer , GDestroyNotify ))*(void**)(__base - 538))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_source_set_callback(__p0, __p1, __p2, __p3) \
	({ \
		GSource * __t__p0 = __p0;\
		GSourceFunc  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		GDestroyNotify  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GSource *, GSourceFunc , gpointer , GDestroyNotify ))*(void**)(__base - 4168))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_slist_find_custom(__p0, __p1, __p2) \
	({ \
		GSList * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		GCompareFunc  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSList *(*)(GSList *, gconstpointer , GCompareFunc ))*(void**)(__base - 2770))(__t__p0, __t__p1, __t__p2));\
	})

#define g_node_find_child(__p0, __p1, __p2) \
	({ \
		GNode * __t__p0 = __p0;\
		GTraverseFlags  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GNode *(*)(GNode *, GTraverseFlags , gpointer ))*(void**)(__base - 1936))(__t__p0, __t__p1, __t__p2));\
	})

#define g_slist_reverse(__p0) \
	({ \
		GSList * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSList *(*)(GSList *))*(void**)(__base - 2746))(__t__p0));\
	})

#define g_date_set_julian(__p0, __p1) \
	({ \
		GDate * __t__p0 = __p0;\
		guint32  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GDate *, guint32 ))*(void**)(__base - 718))(__t__p0, __t__p1));\
	})

#define g_error_free(__p0) \
	({ \
		GError * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GError *))*(void**)(__base - 862))(__t__p0));\
	})

#define g_object_set_qdata(__p0, __p1, __p2) \
	({ \
		GObject * __t__p0 = __p0;\
		GQuark  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GObject *, GQuark , gpointer ))*(void**)(__base - 4564))(__t__p0, __t__p1, __t__p2));\
	})

#define g_main_context_default() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GMainContext *(*)())*(void**)(__base - 3640))());\
	})

#define g_scanner_cur_value(__p0) \
	({ \
		GScanner * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GTokenValue (*)(GScanner *))*(void**)(__base - 2566))(__t__p0));\
	})

#define g_value_get_int64(__p0) \
	({ \
		const GValue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint64 (*)(const GValue *))*(void**)(__base - 5560))(__t__p0));\
	})

#define g_param_spec_float(__p0, __p1, __p2, __p3, __p4, __p5, __p6) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		gfloat  __t__p3 = __p3;\
		gfloat  __t__p4 = __p4;\
		gfloat  __t__p5 = __p5;\
		GParamFlags  __t__p6 = __p6;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(const gchar *, const gchar *, const gchar *, gfloat , gfloat , gfloat , GParamFlags ))*(void**)(__base - 4858))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5, __t__p6));\
	})

#define g_clear_error(__p0) \
	({ \
		GError ** __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GError **))*(void**)(__base - 886))(__t__p0));\
	})

#define g_hook_get(__p0, __p1) \
	({ \
		GHookList * __t__p0 = __p0;\
		gulong  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GHook *(*)(GHookList *, gulong ))*(void**)(__base - 1132))(__t__p0, __t__p1));\
	})

#define g_object_set_valist(__p0, __p1, __p2) \
	({ \
		GObject * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		va_list  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GObject *, const gchar *, va_list ))*(void**)(__base - 4456))(__t__p0, __t__p1, __t__p2));\
	})

#define g_date_subtract_days(__p0, __p1) \
	({ \
		GDate * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GDate *, guint ))*(void**)(__base - 742))(__t__p0, __t__p1));\
	})

#define g_slist_sort(__p0, __p1) \
	({ \
		GSList * __t__p0 = __p0;\
		GCompareFunc  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSList *(*)(GSList *, GCompareFunc ))*(void**)(__base - 2806))(__t__p0, __t__p1));\
	})

#define g_async_queue_length_unlocked(__p0) \
	({ \
		GAsyncQueue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(GAsyncQueue *))*(void**)(__base - 334))(__t__p0));\
	})

#define g_unichar_toupper(__p0) \
	({ \
		gunichar  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gunichar (*)(gunichar ) G_GNUC_CONST)*(void**)(__base - 3394))(__t__p0));\
	})

#define g_idle_add_full(__p0, __p1, __p2, __p3) \
	({ \
		gint  __t__p0 = __p0;\
		GSourceFunc  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		GDestroyNotify  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(gint , GSourceFunc , gpointer , GDestroyNotify ))*(void**)(__base - 3802))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_scanner_cur_line(__p0) \
	({ \
		GScanner * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(GScanner *))*(void**)(__base - 2572))(__t__p0));\
	})

#define g_type_class_peek(__p0) \
	({ \
		GType  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GType ))*(void**)(__base - 5158))(__t__p0));\
	})

#define g_value_set_int64(__p0, __p1) \
	({ \
		GValue * __t__p0 = __p0;\
		gint64  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GValue *, gint64 ))*(void**)(__base - 5554))(__t__p0, __t__p1));\
	})

#define g_param_type_register_static(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		const GParamSpecTypeInfo * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GType (*)(const gchar *, const GParamSpecTypeInfo *))*(void**)(__base - 4780))(__t__p0, __t__p1));\
	})

#define g_slist_free_1(__p0) \
	({ \
		GSList * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GSList *))*(void**)(__base - 2680))(__t__p0));\
	})

#define g_completion_new(__p0) \
	({ \
		GCompletionFunc  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GCompletion *(*)(GCompletionFunc ))*(void**)(__base - 424))(__t__p0));\
	})

#define g_utf8_get_char(__p0) \
	({ \
		const gchar * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gunichar (*)(const gchar *))*(void**)(__base - 3448))(__t__p0));\
	})

#define g_value_set_char(__p0, __p1) \
	({ \
		GValue * __t__p0 = __p0;\
		gchar  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GValue *, gchar ))*(void**)(__base - 5470))(__t__p0, __t__p1));\
	})

#define g_atomic_int_get(__p0) \
	(((gint (*)(volatile gint *))*(void**)((long)(GLIB_BASE_NAME) - 364))(__p0))

#define g_slist_concat(__p0, __p1) \
	({ \
		GSList * __t__p0 = __p0;\
		GSList * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSList *(*)(GSList *, GSList *))*(void**)(__base - 2716))(__t__p0, __t__p1));\
	})

#define g_relation_destroy(__p0) \
	({ \
		GRelation * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GRelation *))*(void**)(__base - 2470))(__t__p0));\
	})

#define g_type_module_get_type() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GType (*)() G_GNUC_CONST)*(void**)(__base - 5302))());\
	})

#define g_date_add_years(__p0, __p1) \
	({ \
		GDate * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GDate *, guint ))*(void**)(__base - 760))(__t__p0, __t__p1));\
	})

#define g_strescape(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, const gchar *) G_GNUC_MALLOC)*(void**)(__base - 3016))(__t__p0, __t__p1));\
	})

#define g_queue_push_nth(__p0, __p1, __p2) \
	({ \
		GQueue * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		gint  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GQueue *, gpointer , gint ))*(void**)(__base - 2218))(__t__p0, __t__p1, __t__p2));\
	})

#define g_async_queue_unlock(__p0) \
	({ \
		GAsyncQueue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GAsyncQueue *))*(void**)(__base - 262))(__t__p0));\
	})

#define g_value_get_boxed(__p0) \
	({ \
		const GValue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(const GValue *))*(void**)(__base - 4294))(__t__p0));\
	})

#define g_dir_open(__p0, __p1, __p2) \
	({ \
		const gchar * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		GError ** __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GDir *(*)(const gchar *, guint , GError **))*(void**)(__base - 832))(__t__p0, __t__p1, __t__p2));\
	})

#define g_slist_length(__p0) \
	({ \
		GSList * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(GSList *))*(void**)(__base - 2794))(__t__p0));\
	})

#define g_queue_pop_head_link(__p0) \
	({ \
		GQueue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GQueue *))*(void**)(__base - 2314))(__t__p0));\
	})

#define g_hook_free(__p0, __p1) \
	({ \
		GHookList * __t__p0 = __p0;\
		GHook * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GHookList *, GHook *))*(void**)(__base - 1084))(__t__p0, __t__p1));\
	})

#define g_list_index(__p0, __p1) \
	({ \
		GList * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(GList *, gconstpointer ))*(void**)(__base - 1546))(__t__p0, __t__p1));\
	})

#define g_value_dup_boxed(__p0) \
	({ \
		const GValue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(const GValue *))*(void**)(__base - 4300))(__t__p0));\
	})

#define g_type_module_unuse(__p0) \
	({ \
		GTypeModule * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GTypeModule *))*(void**)(__base - 5314))(__t__p0));\
	})

#define g_source_set_callback_indirect(__p0, __p1, __p2) \
	({ \
		GSource * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		GSourceCallbackFuncs * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GSource *, gpointer , GSourceCallbackFuncs *))*(void**)(__base - 4174))(__t__p0, __t__p1, __t__p2));\
	})

#define g_tree_lookup_extended(__p0, __p1, __p2, __p3) \
	({ \
		GTree * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		gpointer * __t__p2 = __p2;\
		gpointer * __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GTree *, gconstpointer , gpointer *, gpointer *))*(void**)(__base - 3274))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_value_set_boxed(__p0, __p1) \
	({ \
		GValue * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GValue *, gconstpointer ))*(void**)(__base - 4282))(__t__p0, __t__p1));\
	})

#define g_param_spec_uint(__p0, __p1, __p2, __p3, __p4, __p5, __p6) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		guint  __t__p3 = __p3;\
		guint  __t__p4 = __p4;\
		guint  __t__p5 = __p5;\
		GParamFlags  __t__p6 = __p6;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(const gchar *, const gchar *, const gchar *, guint , guint , guint , GParamFlags ))*(void**)(__base - 4810))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5, __t__p6));\
	})

#define g_value_get_boolean(__p0) \
	({ \
		const GValue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(const GValue *))*(void**)(__base - 5500))(__t__p0));\
	})

#define g_source_get_id(__p0) \
	({ \
		GSource * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(GSource *))*(void**)(__base - 4156))(__t__p0));\
	})

#define g_hook_find_func(__p0, __p1, __p2) \
	({ \
		GHookList * __t__p0 = __p0;\
		gboolean  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GHook *(*)(GHookList *, gboolean , gpointer ))*(void**)(__base - 1150))(__t__p0, __t__p1, __t__p2));\
	})

#define g_key_file_get_string(__p0, __p1, __p2, __p3) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		GError ** __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(GKeyFile *, const gchar *, const gchar *, GError **) G_GNUC_MALLOC)*(void**)(__base - 1288))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_byte_array_prepend(__p0, __p1, __p2) \
	({ \
		GByteArray * __t__p0 = __p0;\
		const guint8 * __t__p1 = __p1;\
		guint  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GByteArray *(*)(GByteArray *, const guint8 *, guint ))*(void**)(__base - 208))(__t__p0, __t__p1, __t__p2));\
	})

#define g_value_set_static_boxed(__p0, __p1) \
	({ \
		GValue * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GValue *, gconstpointer ))*(void**)(__base - 4288))(__t__p0, __t__p1));\
	})

#define g_enum_register_static(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		const GEnumValue * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GType (*)(const gchar *, const GEnumValue *))*(void**)(__base - 4372))(__t__p0, __t__p1));\
	})

#define g_key_file_get_keys(__p0, __p1, __p2, __p3) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		gsize * __t__p2 = __p2;\
		GError ** __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar **(*)(GKeyFile *, const gchar *, gsize *, GError **) G_GNUC_MALLOC)*(void**)(__base - 1258))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_hash_table_foreach(__p0, __p1, __p2) \
	({ \
		GHashTable * __t__p0 = __p0;\
		GHFunc  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GHashTable *, GHFunc , gpointer ))*(void**)(__base - 988))(__t__p0, __t__p1, __t__p2));\
	})

#define g_unichar_isalnum(__p0) \
	({ \
		gunichar  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(gunichar ) G_GNUC_CONST)*(void**)(__base - 3310))(__t__p0));\
	})

#define g_byte_array_remove_index_fast(__p0, __p1) \
	({ \
		GByteArray * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GByteArray *(*)(GByteArray *, guint ))*(void**)(__base - 226))(__t__p0, __t__p1));\
	})

#define g_main_context_ref(__p0) \
	({ \
		GMainContext * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GMainContext *(*)(GMainContext *))*(void**)(__base - 3706))(__t__p0));\
	})

#define g_scanner_scope_remove_symbol(__p0, __p1, __p2) \
	({ \
		GScanner * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GScanner *, guint , const gchar *))*(void**)(__base - 2602))(__t__p0, __t__p1, __t__p2));\
	})

#define g_hash_table_new_full(__p0, __p1, __p2, __p3) \
	({ \
		GHashFunc  __t__p0 = __p0;\
		GEqualFunc  __t__p1 = __p1;\
		GDestroyNotify  __t__p2 = __p2;\
		GDestroyNotify  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GHashTable *(*)(GHashFunc , GEqualFunc , GDestroyNotify , GDestroyNotify ))*(void**)(__base - 940))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_ascii_strup(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		gssize  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, gssize ) G_GNUC_MALLOC)*(void**)(__base - 2980))(__t__p0, __t__p1));\
	})

#define g_rand_new_with_seed_array(__p0, __p1) \
	({ \
		const guint32 * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GRand *(*)(const guint32 *, guint ))*(void**)(__base - 2374))(__t__p0, __t__p1));\
	})

#define g_utf8_casefold(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		gssize  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, gssize ))*(void**)(__base - 3592))(__t__p0, __t__p1));\
	})

#define g_node_get_root(__p0) \
	({ \
		GNode * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GNode *(*)(GNode *))*(void**)(__base - 1870))(__t__p0));\
	})

#define g_signal_connect_closure_by_id(__p0, __p1, __p2, __p3, __p4) \
	({ \
		gpointer  __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		GQuark  __t__p2 = __p2;\
		GClosure * __t__p3 = __p3;\
		gboolean  __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gulong (*)(gpointer , guint , GQuark , GClosure *, gboolean ))*(void**)(__base - 4996))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_node_n_nodes(__p0, __p1) \
	({ \
		GNode * __t__p0 = __p0;\
		GTraverseFlags  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(GNode *, GTraverseFlags ))*(void**)(__base - 1864))(__t__p0, __t__p1));\
	})

#define g_io_channel_set_close_on_unref(__p0, __p1) \
	({ \
		GIOChannel * __t__p0 = __p0;\
		gboolean  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GIOChannel *, gboolean ))*(void**)(__base - 3946))(__t__p0, __t__p1));\
	})

#define g_file_error_quark() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GQuark (*)())*(void**)(__base - 892))());\
	})

#define g_date_get_year(__p0) \
	({ \
		const GDate * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GDateYear (*)(const GDate *))*(void**)(__base - 634))(__t__p0));\
	})

#define g_intern_static_string(__p0) \
	({ \
		const gchar * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *))*(void**)(__base - 4264))(__t__p0));\
	})

#define g_pointer_type_register_static(__p0) \
	({ \
		const gchar * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GType (*)(const gchar *))*(void**)(__base - 5656))(__t__p0));\
	})

#define g_queue_is_empty(__p0) \
	({ \
		GQueue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GQueue *))*(void**)(__base - 2158))(__t__p0));\
	})

#define g_slist_delete_link(__p0, __p1) \
	({ \
		GSList * __t__p0 = __p0;\
		GSList * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSList *(*)(GSList *, GSList *))*(void**)(__base - 2740))(__t__p0, __t__p1));\
	})

#define g_unichar_xdigit_value(__p0) \
	({ \
		gunichar  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(gunichar ) G_GNUC_CONST)*(void**)(__base - 3418))(__t__p0));\
	})

#define g_param_spec_enum(__p0, __p1, __p2, __p3, __p4, __p5) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		GType  __t__p3 = __p3;\
		gint  __t__p4 = __p4;\
		GParamFlags  __t__p5 = __p5;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(const gchar *, const gchar *, const gchar *, GType , gint , GParamFlags ))*(void**)(__base - 4846))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5));\
	})

#define g_type_default_interface_ref(__p0) \
	({ \
		GType  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GType ))*(void**)(__base - 5194))(__t__p0));\
	})

#define g_cache_key_foreach(__p0, __p1, __p2) \
	({ \
		GCache * __t__p0 = __p0;\
		GHFunc  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GCache *, GHFunc , gpointer ))*(void**)(__base - 412))(__t__p0, __t__p1, __t__p2));\
	})

#define g_relation_index(__p0, __p1, __p2, __p3) \
	({ \
		GRelation * __t__p0 = __p0;\
		gint  __t__p1 = __p1;\
		GHashFunc  __t__p2 = __p2;\
		GEqualFunc  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GRelation *, gint , GHashFunc , GEqualFunc ))*(void**)(__base - 2476))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_byte_array_remove_index(__p0, __p1) \
	({ \
		GByteArray * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GByteArray *(*)(GByteArray *, guint ))*(void**)(__base - 220))(__t__p0, __t__p1));\
	})

#define g_utf8_normalize(__p0, __p1, __p2) \
	({ \
		const gchar * __t__p0 = __p0;\
		gssize  __t__p1 = __p1;\
		GNormalizeMode  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, gssize , GNormalizeMode ))*(void**)(__base - 3598))(__t__p0, __t__p1, __t__p2));\
	})

#define g_option_context_set_main_group(__p0, __p1) \
	({ \
		GOptionContext * __t__p0 = __p0;\
		GOptionGroup * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GOptionContext *, GOptionGroup *))*(void**)(__base - 2020))(__t__p0, __t__p1));\
	})

#define g_ascii_strdown(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		gssize  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, gssize ) G_GNUC_MALLOC)*(void**)(__base - 2974))(__t__p0, __t__p1));\
	})

#define g_object_weak_ref(__p0, __p1, __p2) \
	({ \
		GObject * __t__p0 = __p0;\
		GWeakNotify  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GObject *, GWeakNotify , gpointer ))*(void**)(__base - 4522))(__t__p0, __t__p1, __t__p2));\
	})

#define g_value_dup_object(__p0) \
	({ \
		const GValue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GObject *(*)(const GValue *))*(void**)(__base - 4642))(__t__p0));\
	})

#define g_param_spec_steal_qdata(__p0, __p1) \
	({ \
		GParamSpec * __t__p0 = __p0;\
		GQuark  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GParamSpec *, GQuark ))*(void**)(__base - 4696))(__t__p0, __t__p1));\
	})

#define g_rand_copy(__p0) \
	({ \
		GRand * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GRand *(*)(GRand *))*(void**)(__base - 2392))(__t__p0));\
	})

#define g_try_realloc(__p0, __p1) \
	({ \
		gpointer  __t__p0 = __p0;\
		gulong  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(gpointer , gulong ))*(void**)(__base - 1672))(__t__p0, __t__p1));\
	})

#define g_mkstemp(__p0) \
	({ \
		gchar * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(gchar *))*(void**)(__base - 922))(__t__p0));\
	})

#define g_strdelimit(__p0, __p1, __p2) \
	({ \
		gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		gchar  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(gchar *, const gchar *, gchar ))*(void**)(__base - 2848))(__t__p0, __t__p1, __t__p2));\
	})

#define g_date_get_month(__p0) \
	({ \
		const GDate * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GDateMonth (*)(const GDate *))*(void**)(__base - 628))(__t__p0));\
	})

#define g_value_array_new(__p0) \
	({ \
		guint  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GValueArray *(*)(guint ))*(void**)(__base - 5416))(__t__p0));\
	})

#define g_queue_find(__p0, __p1) \
	({ \
		GQueue * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GQueue *, gconstpointer ))*(void**)(__base - 2188))(__t__p0, __t__p1));\
	})

#define g_hash_table_size(__p0) \
	({ \
		GHashTable * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(GHashTable *))*(void**)(__base - 1012))(__t__p0));\
	})

#define g_intern_string(__p0) \
	({ \
		const gchar * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *))*(void**)(__base - 4258))(__t__p0));\
	})

#define g_flags_get_value_by_nick(__p0, __p1) \
	({ \
		GFlagsClass * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GFlagsValue *(*)(GFlagsClass *, const gchar *))*(void**)(__base - 4342))(__t__p0, __t__p1));\
	})

#define g_main_context_unref(__p0) \
	({ \
		GMainContext * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GMainContext *))*(void**)(__base - 3730))(__t__p0));\
	})

#define g_io_channel_read_line_string(__p0, __p1, __p2, __p3) \
	({ \
		GIOChannel * __t__p0 = __p0;\
		GString * __t__p1 = __p1;\
		gsize * __t__p2 = __p2;\
		GError ** __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GIOStatus (*)(GIOChannel *, GString *, gsize *, GError **))*(void**)(__base - 3904))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_shell_unquote(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		GError ** __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, GError **))*(void**)(__base - 2644))(__t__p0, __t__p1));\
	})

#define g_main_context_get_poll_func(__p0) \
	({ \
		GMainContext * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GPollFunc (*)(GMainContext *))*(void**)(__base - 3670))(__t__p0));\
	})

#define g_tree_lookup(__p0, __p1) \
	({ \
		GTree * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GTree *, gconstpointer ))*(void**)(__base - 3268))(__t__p0, __t__p1));\
	})

#define g_value_get_long(__p0) \
	({ \
		const GValue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((glong (*)(const GValue *))*(void**)(__base - 5536))(__t__p0));\
	})

#define g_log_remove_handler(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(const gchar *, guint ))*(void**)(__base - 1762))(__t__p0, __t__p1));\
	})

#define g_option_group_new(__p0, __p1, __p2, __p3, __p4) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		gpointer  __t__p3 = __p3;\
		GDestroyNotify  __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GOptionGroup *(*)(const gchar *, const gchar *, const gchar *, gpointer , GDestroyNotify ))*(void**)(__base - 2032))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_log_set_default_handler(__p0, __p1) \
	({ \
		GLogFunc  __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GLogFunc (*)(GLogFunc , gpointer ))*(void**)(__base - 1774))(__t__p0, __t__p1));\
	})

#define g_date_set_month(__p0, __p1) \
	({ \
		GDate * __t__p0 = __p0;\
		GDateMonth  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GDate *, GDateMonth ))*(void**)(__base - 694))(__t__p0, __t__p1));\
	})

#define g_string_append(__p0, __p1) \
	({ \
		GString * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GString *(*)(GString *, const gchar *))*(void**)(__base - 3136))(__t__p0, __t__p1));\
	})

#define g_source_add_poll(__p0, __p1) \
	({ \
		GSource * __t__p0 = __p0;\
		GPollFD * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GSource *, GPollFD *))*(void**)(__base - 4180))(__t__p0, __t__p1));\
	})

#define g_dataset_id_remove_no_notify(__p0, __p1) \
	({ \
		gconstpointer  __t__p0 = __p0;\
		GQuark  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(gconstpointer , GQuark ))*(void**)(__base - 544))(__t__p0, __t__p1));\
	})

#define g_strdupv(__p0) \
	({ \
		gchar ** __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar **(*)(gchar **) G_GNUC_MALLOC)*(void**)(__base - 3052))(__t__p0));\
	})

#define g_byte_array_new() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GByteArray *(*)())*(void**)(__base - 184))());\
	})

#define g_queue_pop_tail(__p0) \
	({ \
		GQueue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GQueue *))*(void**)(__base - 2230))(__t__p0));\
	})

#define g_queue_foreach(__p0, __p1, __p2) \
	({ \
		GQueue * __t__p0 = __p0;\
		GFunc  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GQueue *, GFunc , gpointer ))*(void**)(__base - 2182))(__t__p0, __t__p1, __t__p2));\
	})

#define g_object_add_toggle_ref(__p0, __p1, __p2) \
	({ \
		GObject * __t__p0 = __p0;\
		GToggleNotify  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GObject *, GToggleNotify , gpointer ))*(void**)(__base - 4546))(__t__p0, __t__p1, __t__p2));\
	})

#define g_utf8_to_utf16(__p0, __p1, __p2, __p3, __p4) \
	({ \
		const gchar * __t__p0 = __p0;\
		glong  __t__p1 = __p1;\
		glong * __t__p2 = __p2;\
		glong * __t__p3 = __p3;\
		GError ** __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gunichar2 *(*)(const gchar *, glong , glong *, glong *, GError **) G_GNUC_MALLOC)*(void**)(__base - 3520))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_log_set_fatal_mask(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		GLogLevelFlags  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GLogLevelFlags (*)(const gchar *, GLogLevelFlags ))*(void**)(__base - 1786))(__t__p0, __t__p1));\
	})

#define g_source_get_current_time(__p0, __p1) \
	({ \
		GSource * __t__p0 = __p0;\
		GTimeVal * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GSource *, GTimeVal *))*(void**)(__base - 4192))(__t__p0, __t__p1));\
	})

#define g_utf8_find_next_char(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, const gchar *))*(void**)(__base - 3478))(__t__p0, __t__p1));\
	})

#define g_hash_table_steal(__p0, __p1) \
	({ \
		GHashTable * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GHashTable *, gconstpointer ))*(void**)(__base - 970))(__t__p0, __t__p1));\
	})

#define g_signal_connect_closure(__p0, __p1, __p2, __p3) \
	({ \
		gpointer  __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		GClosure * __t__p2 = __p2;\
		gboolean  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gulong (*)(gpointer , const gchar *, GClosure *, gboolean ))*(void**)(__base - 5002))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_node_children_foreach(__p0, __p1, __p2, __p3) \
	({ \
		GNode * __t__p0 = __p0;\
		GTraverseFlags  __t__p1 = __p1;\
		GNodeForeachFunc  __t__p2 = __p2;\
		gpointer  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GNode *, GTraverseFlags , GNodeForeachFunc , gpointer ))*(void**)(__base - 1906))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_main_loop_new(__p0, __p1) \
	({ \
		GMainContext * __t__p0 = __p0;\
		gboolean  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GMainLoop *(*)(GMainContext *, gboolean ))*(void**)(__base - 3766))(__t__p0, __t__p1));\
	})

#define g_scanner_get_next_token(__p0) \
	({ \
		GScanner * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GTokenType (*)(GScanner *))*(void**)(__base - 2548))(__t__p0));\
	})

#define g_malloc0(__p0) \
	({ \
		gulong  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(gulong ) G_GNUC_MALLOC)*(void**)(__base - 1648))(__t__p0));\
	})

#define g_completion_remove_items(__p0, __p1) \
	({ \
		GCompletion * __t__p0 = __p0;\
		GList * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GCompletion *, GList *))*(void**)(__base - 436))(__t__p0, __t__p1));\
	})

#define g_object_watch_closure(__p0, __p1) \
	({ \
		GObject * __t__p0 = __p0;\
		GClosure * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GObject *, GClosure *))*(void**)(__base - 4606))(__t__p0, __t__p1));\
	})

#define g_queue_push_tail(__p0, __p1) \
	({ \
		GQueue * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GQueue *, gpointer ))*(void**)(__base - 2212))(__t__p0, __t__p1));\
	})

#define g_object_class_override_property(__p0, __p1, __p2) \
	({ \
		GObjectClass * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GObjectClass *, guint , const gchar *))*(void**)(__base - 4420))(__t__p0, __t__p1, __t__p2));\
	})

#define g_strndup(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		gsize  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, gsize ) G_GNUC_MALLOC)*(void**)(__base - 2998))(__t__p0, __t__p1));\
	})

#define g_io_channel_read_line(__p0, __p1, __p2, __p3, __p4) \
	({ \
		GIOChannel * __t__p0 = __p0;\
		gchar ** __t__p1 = __p1;\
		gsize * __t__p2 = __p2;\
		gsize * __t__p3 = __p3;\
		GError ** __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GIOStatus (*)(GIOChannel *, gchar **, gsize *, gsize *, GError **))*(void**)(__base - 3898))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_date_set_dmy(__p0, __p1, __p2, __p3) \
	({ \
		GDate * __t__p0 = __p0;\
		GDateDay  __t__p1 = __p1;\
		GDateMonth  __t__p2 = __p2;\
		GDateYear  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GDate *, GDateDay , GDateMonth , GDateYear ))*(void**)(__base - 712))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_type_module_use(__p0) \
	({ \
		GTypeModule * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GTypeModule *))*(void**)(__base - 5308))(__t__p0));\
	})

#define g_hash_table_destroy(__p0) \
	({ \
		GHashTable * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GHashTable *))*(void**)(__base - 946))(__t__p0));\
	})

#ifndef __cplusplus
#define g_strdup_printf(...) \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		(((gchar *(*)(const gchar *, ...) G_GNUC_PRINTF (1, 2) G_GNUC_MALLOC)*(void**)(__base - 4234))(__VA_ARGS__,({__asm volatile("mr 12,%0": :"r"(__base):"r12");0L;})));\
	})
#endif

#define g_option_group_set_translation_domain(__p0, __p1) \
	({ \
		GOptionGroup * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GOptionGroup *, const gchar *))*(void**)(__base - 2068))(__t__p0, __t__p1));\
	})

#define g_main_context_wakeup(__p0) \
	({ \
		GMainContext * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GMainContext *))*(void**)(__base - 3742))(__t__p0));\
	})

#define g_malloc(__p0) \
	({ \
		gulong  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(gulong ) G_GNUC_MALLOC)*(void**)(__base - 1642))(__t__p0));\
	})

#define g_cclosure_new_object_swap(__p0, __p1) \
	({ \
		GCallback  __t__p0 = __p0;\
		GObject * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GClosure *(*)(GCallback , GObject *))*(void**)(__base - 4618))(__t__p0, __t__p1));\
	})

#define g_string_hash(__p0) \
	({ \
		const GString * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(const GString *))*(void**)(__base - 3106))(__t__p0));\
	})

#define g_object_get_property(__p0, __p1, __p2) \
	({ \
		GObject * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		GValue * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GObject *, const gchar *, GValue *))*(void**)(__base - 4474))(__t__p0, __t__p1, __t__p2));\
	})

#define g_utf8_strreverse(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		gssize  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, gssize ))*(void**)(__base - 3514))(__t__p0, __t__p1));\
	})

#define g_ascii_strcasecmp(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(const gchar *, const gchar *))*(void**)(__base - 2962))(__t__p0, __t__p1));\
	})

#define g_async_queue_ref(__p0) \
	({ \
		GAsyncQueue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GAsyncQueue *(*)(GAsyncQueue *))*(void**)(__base - 268))(__t__p0));\
	})

#define g_rand_double(__p0) \
	({ \
		GRand * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gdouble (*)(GRand *))*(void**)(__base - 2422))(__t__p0));\
	})

#define g_io_channel_write_unichar(__p0, __p1, __p2) \
	({ \
		GIOChannel * __t__p0 = __p0;\
		gunichar  __t__p1 = __p1;\
		GError ** __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GIOStatus (*)(GIOChannel *, gunichar , GError **))*(void**)(__base - 3988))(__t__p0, __t__p1, __t__p2));\
	})

#define g_datalist_id_remove_no_notify(__p0, __p1) \
	({ \
		GData ** __t__p0 = __p0;\
		GQuark  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GData **, GQuark ))*(void**)(__base - 496))(__t__p0, __t__p1));\
	})

#define g_log_set_always_fatal(__p0) \
	({ \
		GLogLevelFlags  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GLogLevelFlags (*)(GLogLevelFlags ))*(void**)(__base - 1792))(__t__p0));\
	})

#define g_date_clear(__p0, __p1) \
	({ \
		GDate * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GDate *, guint ))*(void**)(__base - 676))(__t__p0, __t__p1));\
	})

#define g_object_is_floating(__p0) \
	({ \
		gpointer  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(gpointer ))*(void**)(__base - 4498))(__t__p0));\
	})

#define g_hash_table_replace(__p0, __p1, __p2) \
	({ \
		GHashTable * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GHashTable *, gpointer , gpointer ))*(void**)(__base - 958))(__t__p0, __t__p1, __t__p2));\
	})

#define g_string_prepend_c(__p0, __p1) \
	({ \
		GString * __t__p0 = __p0;\
		gchar  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GString *(*)(GString *, gchar ))*(void**)(__base - 3166))(__t__p0, __t__p1));\
	})

#define g_object_add_weak_pointer(__p0, __p1) \
	({ \
		GObject * __t__p0 = __p0;\
		gpointer * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GObject *, gpointer *))*(void**)(__base - 4534))(__t__p0, __t__p1));\
	})

#define g_value_array_prepend(__p0, __p1) \
	({ \
		GValueArray * __t__p0 = __p0;\
		const GValue * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GValueArray *(*)(GValueArray *, const GValue *))*(void**)(__base - 5434))(__t__p0, __t__p1));\
	})

#define g_list_prepend(__p0, __p1) \
	({ \
		GList * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GList *, gpointer ))*(void**)(__base - 1450))(__t__p0, __t__p1));\
	})

#define g_date_valid_day(__p0) \
	({ \
		GDateDay  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GDateDay ) G_GNUC_CONST)*(void**)(__base - 586))(__t__p0));\
	})

#define g_slist_sort_with_data(__p0, __p1, __p2) \
	({ \
		GSList * __t__p0 = __p0;\
		GCompareDataFunc  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSList *(*)(GSList *, GCompareDataFunc , gpointer ))*(void**)(__base - 2812))(__t__p0, __t__p1, __t__p2));\
	})

#define g_key_file_get_locale_string(__p0, __p1, __p2, __p3, __p4) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		const gchar * __t__p3 = __p3;\
		GError ** __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(GKeyFile *, const gchar *, const gchar *, const gchar *, GError **) G_GNUC_MALLOC)*(void**)(__base - 1300))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_source_ref(__p0) \
	({ \
		GSource * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSource *(*)(GSource *))*(void**)(__base - 4108))(__t__p0));\
	})

#define g_queue_new() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GQueue *(*)())*(void**)(__base - 2146))());\
	})

#define g_enum_get_value_by_nick(__p0, __p1) \
	({ \
		GEnumClass * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GEnumValue *(*)(GEnumClass *, const gchar *))*(void**)(__base - 4324))(__t__p0, __t__p1));\
	})

#define g_value_get_uchar(__p0) \
	({ \
		const GValue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guchar (*)(const GValue *))*(void**)(__base - 5488))(__t__p0));\
	})

#define g_object_notify(__p0, __p1) \
	({ \
		GObject * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GObject *, const gchar *))*(void**)(__base - 4486))(__t__p0, __t__p1));\
	})

#define g_list_insert(__p0, __p1, __p2) \
	({ \
		GList * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		gint  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GList *, gpointer , gint ))*(void**)(__base - 1456))(__t__p0, __t__p1, __t__p2));\
	})

#define g_io_channel_get_buffered(__p0) \
	({ \
		GIOChannel * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GIOChannel *))*(void**)(__base - 3856))(__t__p0));\
	})

#define g_key_file_set_boolean(__p0, __p1, __p2, __p3) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		gboolean  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GKeyFile *, const gchar *, const gchar *, gboolean ))*(void**)(__base - 1318))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_hook_list_clear(__p0) \
	({ \
		GHookList * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GHookList *))*(void**)(__base - 1072))(__t__p0));\
	})

#define g_node_first_sibling(__p0) \
	({ \
		GNode * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GNode *(*)(GNode *))*(void**)(__base - 1954))(__t__p0));\
	})

#define g_type_interface_peek(__p0, __p1) \
	({ \
		gpointer  __t__p0 = __p0;\
		GType  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(gpointer , GType ))*(void**)(__base - 5182))(__t__p0, __t__p1));\
	})

#define g_key_file_set_locale_string(__p0, __p1, __p2, __p3, __p4) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		const gchar * __t__p3 = __p3;\
		const gchar * __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GKeyFile *, const gchar *, const gchar *, const gchar *, const gchar *))*(void**)(__base - 1306))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_signal_parse_name(__p0, __p1, __p2, __p3, __p4) \
	({ \
		const gchar * __t__p0 = __p0;\
		GType  __t__p1 = __p1;\
		guint * __t__p2 = __p2;\
		GQuark * __t__p3 = __p3;\
		gboolean  __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(const gchar *, GType , guint *, GQuark *, gboolean ))*(void**)(__base - 4954))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_signal_has_handler_pending(__p0, __p1, __p2, __p3) \
	({ \
		gpointer  __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		GQuark  __t__p2 = __p2;\
		gboolean  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(gpointer , guint , GQuark , gboolean ))*(void**)(__base - 4990))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_value_set_uchar(__p0, __p1) \
	({ \
		GValue * __t__p0 = __p0;\
		guchar  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GValue *, guchar ))*(void**)(__base - 5482))(__t__p0, __t__p1));\
	})

#define g_key_file_set_integer_list(__p0, __p1, __p2, __p3, __p4) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		gint * __t__p3 = __p3;\
		gsize  __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GKeyFile *, const gchar *, const gchar *, gint *, gsize ))*(void**)(__base - 1378))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_markup_parse_context_end_parse(__p0, __p1) \
	({ \
		GMarkupParseContext * __t__p0 = __p0;\
		GError ** __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GMarkupParseContext *, GError **))*(void**)(__base - 1612))(__t__p0, __t__p1));\
	})

#define g_value_set_object(__p0, __p1) \
	({ \
		GValue * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GValue *, gpointer ))*(void**)(__base - 4630))(__t__p0, __t__p1));\
	})

#define g_node_is_ancestor(__p0, __p1) \
	({ \
		GNode * __t__p0 = __p0;\
		GNode * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GNode *, GNode *))*(void**)(__base - 1876))(__t__p0, __t__p1));\
	})

#define g_node_last_sibling(__p0) \
	({ \
		GNode * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GNode *(*)(GNode *))*(void**)(__base - 1960))(__t__p0));\
	})

#define g_param_spec_get_qdata(__p0, __p1) \
	({ \
		GParamSpec * __t__p0 = __p0;\
		GQuark  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GParamSpec *, GQuark ))*(void**)(__base - 4678))(__t__p0, __t__p1));\
	})

#define g_rand_free(__p0) \
	({ \
		GRand * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GRand *))*(void**)(__base - 2386))(__t__p0));\
	})

#define g_uri_list_extract_uris(__p0) \
	({ \
		const gchar * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar **(*)(const gchar *) G_GNUC_MALLOC)*(void**)(__base - 4042))(__t__p0));\
	})

#define g_filename_to_utf8(__p0, __p1, __p2, __p3, __p4) \
	({ \
		const gchar * __t__p0 = __p0;\
		gssize  __t__p1 = __p1;\
		gsize * __t__p2 = __p2;\
		gsize * __t__p3 = __p3;\
		GError ** __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, gssize , gsize *, gsize *, GError **) G_GNUC_MALLOC)*(void**)(__base - 4078))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_signal_stop_emission(__p0, __p1, __p2) \
	({ \
		gpointer  __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		GQuark  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(gpointer , guint , GQuark ))*(void**)(__base - 4966))(__t__p0, __t__p1, __t__p2));\
	})

#define g_option_context_get_main_group(__p0) \
	({ \
		GOptionContext * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GOptionGroup *(*)(GOptionContext *))*(void**)(__base - 2026))(__t__p0));\
	})

#define g_signal_handlers_disconnect_matched(__p0, __p1, __p2, __p3, __p4, __p5, __p6) \
	({ \
		gpointer  __t__p0 = __p0;\
		GSignalMatchType  __t__p1 = __p1;\
		guint  __t__p2 = __p2;\
		GQuark  __t__p3 = __p3;\
		GClosure * __t__p4 = __p4;\
		gpointer  __t__p5 = __p5;\
		gpointer  __t__p6 = __p6;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(gpointer , GSignalMatchType , guint , GQuark , GClosure *, gpointer , gpointer ))*(void**)(__base - 5056))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5, __t__p6));\
	})

#define g_list_free_1(__p0) \
	({ \
		GList * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GList *))*(void**)(__base - 1438))(__t__p0));\
	})

#define g_date_valid(__p0) \
	({ \
		const GDate * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(const GDate *))*(void**)(__base - 580))(__t__p0));\
	})

#define g_unichar_break_type(__p0) \
	({ \
		gunichar  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GUnicodeBreakType (*)(gunichar ) G_GNUC_CONST)*(void**)(__base - 3430))(__t__p0));\
	})

#define g_value_array_insert(__p0, __p1, __p2) \
	({ \
		GValueArray * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		const GValue * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GValueArray *(*)(GValueArray *, guint , const GValue *))*(void**)(__base - 5446))(__t__p0, __t__p1, __t__p2));\
	})

#define g_param_spec_set_qdata(__p0, __p1, __p2) \
	({ \
		GParamSpec * __t__p0 = __p0;\
		GQuark  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GParamSpec *, GQuark , gpointer ))*(void**)(__base - 4684))(__t__p0, __t__p1, __t__p2));\
	})

#define g_filename_display_basename(__p0) \
	LP1(4050, gchar * G_GNUC_MALLOC, g_filename_display_basename, \
		const gchar *, __p0, syv, \
		, GLIB_BASE_NAME, 0, 0, 0, 0, 0, 0)

#define g_param_spec_object(__p0, __p1, __p2, __p3, __p4) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		GType  __t__p3 = __p3;\
		GParamFlags  __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(const gchar *, const gchar *, const gchar *, GType , GParamFlags ))*(void**)(__base - 4900))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_queue_peek_nth(__p0, __p1) \
	({ \
		GQueue * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GQueue *, guint ))*(void**)(__base - 2254))(__t__p0, __t__p1));\
	})

#define g_node_nth_child(__p0, __p1) \
	({ \
		GNode * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GNode *(*)(GNode *, guint ))*(void**)(__base - 1924))(__t__p0, __t__p1));\
	})

#define g_list_concat(__p0, __p1) \
	({ \
		GList * __t__p0 = __p0;\
		GList * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GList *, GList *))*(void**)(__base - 1474))(__t__p0, __t__p1));\
	})

#define g_source_get_context(__p0) \
	({ \
		GSource * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GMainContext *(*)(GSource *))*(void**)(__base - 4162))(__t__p0));\
	})

#define g_hash_table_lookup_extended(__p0, __p1, __p2, __p3) \
	({ \
		GHashTable * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		gpointer * __t__p2 = __p2;\
		gpointer * __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GHashTable *, gconstpointer , gpointer *, gpointer *))*(void**)(__base - 982))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_type_from_name(__p0) \
	({ \
		const gchar * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GType (*)(const gchar *))*(void**)(__base - 5122))(__t__p0));\
	})

#define g_list_find_custom(__p0, __p1, __p2) \
	({ \
		GList * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		GCompareFunc  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GList *, gconstpointer , GCompareFunc ))*(void**)(__base - 1534))(__t__p0, __t__p1, __t__p2));\
	})

#define g_filename_display_name(__p0) \
	({ \
		const gchar * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *) G_GNUC_MALLOC)*(void**)(__base - 4054))(__t__p0));\
	})

#define g_ucs4_to_utf16(__p0, __p1, __p2, __p3, __p4) \
	({ \
		const gunichar * __t__p0 = __p0;\
		glong  __t__p1 = __p1;\
		glong * __t__p2 = __p2;\
		glong * __t__p3 = __p3;\
		GError ** __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gunichar2 *(*)(const gunichar *, glong , glong *, glong *, GError **))*(void**)(__base - 3550))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_value_copy(__p0, __p1) \
	({ \
		const GValue * __t__p0 = __p0;\
		GValue * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(const GValue *, GValue *))*(void**)(__base - 5386))(__t__p0, __t__p1));\
	})

#define g_key_file_get_string_list(__p0, __p1, __p2, __p3, __p4) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		gsize * __t__p3 = __p3;\
		GError ** __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar **(*)(GKeyFile *, const gchar *, const gchar *, gsize *, GError **) G_GNUC_MALLOC)*(void**)(__base - 1336))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_byte_array_sort(__p0, __p1) \
	({ \
		GByteArray * __t__p0 = __p0;\
		GCompareFunc  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GByteArray *, GCompareFunc ))*(void**)(__base - 238))(__t__p0, __t__p1));\
	})

#define g_type_next_base(__p0, __p1) \
	({ \
		GType  __t__p0 = __p0;\
		GType  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GType (*)(GType , GType ))*(void**)(__base - 5140))(__t__p0, __t__p1));\
	})

#define g_list_push_allocator(__p0) \
	({ \
		GAllocator * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GAllocator *))*(void**)(__base - 1414))(__t__p0));\
	})

#define g_value_get_pointer(__p0) \
	({ \
		const GValue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(const GValue *))*(void**)(__base - 5632))(__t__p0));\
	})

#define g_list_length(__p0) \
	({ \
		GList * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(GList *))*(void**)(__base - 1564))(__t__p0));\
	})

#define g_scanner_input_text(__p0, __p1, __p2) \
	({ \
		GScanner * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		guint  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GScanner *, const gchar *, guint ))*(void**)(__base - 2542))(__t__p0, __t__p1, __t__p2));\
	})

#define g_timeout_source_new(__p0) \
	({ \
		guint  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSource *(*)(guint ))*(void**)(__base - 4096))(__t__p0));\
	})

#define g_utf8_find_prev_char(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, const gchar *))*(void**)(__base - 3484))(__t__p0, __t__p1));\
	})

#define g_value_set_double(__p0, __p1) \
	({ \
		GValue * __t__p0 = __p0;\
		gdouble  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GValue *, gdouble ))*(void**)(__base - 5590))(__t__p0, __t__p1));\
	})

#define g_slist_foreach(__p0, __p1, __p2) \
	({ \
		GSList * __t__p0 = __p0;\
		GFunc  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GSList *, GFunc , gpointer ))*(void**)(__base - 2800))(__t__p0, __t__p1, __t__p2));\
	})

#define g_value_set_uint(__p0, __p1) \
	({ \
		GValue * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GValue *, guint ))*(void**)(__base - 5518))(__t__p0, __t__p1));\
	})

#define g_int_hash(__p0) \
	({ \
		gconstpointer  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(gconstpointer ))*(void**)(__base - 1048))(__t__p0));\
	})

#define g_strnfill(__p0, __p1) \
	({ \
		gsize  __t__p0 = __p0;\
		gchar  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(gsize , gchar ) G_GNUC_MALLOC)*(void**)(__base - 3004))(__t__p0, __t__p1));\
	})

#define g_unichar_ispunct(__p0) \
	({ \
		gunichar  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(gunichar ) G_GNUC_CONST)*(void**)(__base - 3352))(__t__p0));\
	})

#define g_hook_unref(__p0, __p1) \
	({ \
		GHookList * __t__p0 = __p0;\
		GHook * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GHookList *, GHook *))*(void**)(__base - 1096))(__t__p0, __t__p1));\
	})

#define g_unichar_validate(__p0) \
	({ \
		gunichar  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(gunichar ))*(void**)(__base - 3574))(__t__p0));\
	})

#define g_type_register_fundamental(__p0, __p1, __p2, __p3, __p4) \
	({ \
		GType  __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const GTypeInfo * __t__p2 = __p2;\
		const GTypeFundamentalInfo * __t__p3 = __p3;\
		GTypeFlags  __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GType (*)(GType , const gchar *, const GTypeInfo *, const GTypeFundamentalInfo *, GTypeFlags ))*(void**)(__base - 5260))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_strreverse(__p0) \
	({ \
		gchar * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(gchar *))*(void**)(__base - 2872))(__t__p0));\
	})

#define g_unichar_tolower(__p0) \
	({ \
		gunichar  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gunichar (*)(gunichar ) G_GNUC_CONST)*(void**)(__base - 3400))(__t__p0));\
	})

#define g_param_spec_double(__p0, __p1, __p2, __p3, __p4, __p5, __p6) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		gdouble  __t__p3 = __p3;\
		gdouble  __t__p4 = __p4;\
		gdouble  __t__p5 = __p5;\
		GParamFlags  __t__p6 = __p6;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(const gchar *, const gchar *, const gchar *, gdouble , gdouble , gdouble , GParamFlags ))*(void**)(__base - 4864))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5, __t__p6));\
	})

#define g_unichar_digit_value(__p0) \
	({ \
		gunichar  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(gunichar ) G_GNUC_CONST)*(void**)(__base - 3412))(__t__p0));\
	})

#define g_date_days_between(__p0, __p1) \
	({ \
		const GDate * __t__p0 = __p0;\
		const GDate * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(const GDate *, const GDate *))*(void**)(__base - 796))(__t__p0, __t__p1));\
	})

#define g_param_spec_ref(__p0) \
	({ \
		GParamSpec * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(GParamSpec *))*(void**)(__base - 4654))(__t__p0));\
	})

#define g_signal_lookup(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		GType  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(const gchar *, GType ))*(void**)(__base - 4930))(__t__p0, __t__p1));\
	})

#define g_ptr_array_remove_index(__p0, __p1) \
	({ \
		GPtrArray * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GPtrArray *, guint ))*(void**)(__base - 130))(__t__p0, __t__p1));\
	})

#define g_type_interface_add_prerequisite(__p0, __p1) \
	({ \
		GType  __t__p0 = __p0;\
		GType  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GType , GType ))*(void**)(__base - 5278))(__t__p0, __t__p1));\
	})

#define g_str_hash(__p0) \
	({ \
		gconstpointer  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(gconstpointer ))*(void**)(__base - 1036))(__t__p0));\
	})

#define g_value_set_enum(__p0, __p1) \
	({ \
		GValue * __t__p0 = __p0;\
		gint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GValue *, gint ))*(void**)(__base - 4348))(__t__p0, __t__p1));\
	})

#define g_date_valid_year(__p0) \
	({ \
		GDateYear  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GDateYear ) G_GNUC_CONST)*(void**)(__base - 598))(__t__p0));\
	})

#define g_strlcat(__p0, __p1, __p2) \
	({ \
		gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		gsize  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gsize (*)(gchar *, const gchar *, gsize ))*(void**)(__base - 2884))(__t__p0, __t__p1, __t__p2));\
	})

#define g_type_add_interface_dynamic(__p0, __p1, __p2) \
	({ \
		GType  __t__p0 = __p0;\
		GType  __t__p1 = __p1;\
		GTypePlugin * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GType , GType , GTypePlugin *))*(void**)(__base - 5272))(__t__p0, __t__p1, __t__p2));\
	})

#define g_utf8_prev_char(__p0) \
	({ \
		const gchar * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *))*(void**)(__base - 3472))(__t__p0));\
	})

#define g_markup_parse_context_get_position(__p0, __p1, __p2) \
	({ \
		GMarkupParseContext * __t__p0 = __p0;\
		gint * __t__p1 = __p1;\
		gint * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GMarkupParseContext *, gint *, gint *))*(void**)(__base - 1624))(__t__p0, __t__p1, __t__p2));\
	})

#define g_list_remove_all(__p0, __p1) \
	({ \
		GList * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GList *, gconstpointer ))*(void**)(__base - 1486))(__t__p0, __t__p1));\
	})

#define g_node_find(__p0, __p1, __p2, __p3) \
	({ \
		GNode * __t__p0 = __p0;\
		GTraverseType  __t__p1 = __p1;\
		GTraverseFlags  __t__p2 = __p2;\
		gpointer  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GNode *(*)(GNode *, GTraverseType , GTraverseFlags , gpointer ))*(void**)(__base - 1888))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_cache_value_foreach(__p0, __p1, __p2) \
	({ \
		GCache * __t__p0 = __p0;\
		GHFunc  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GCache *, GHFunc , gpointer ))*(void**)(__base - 418))(__t__p0, __t__p1, __t__p2));\
	})

#define g_unichar_istitle(__p0) \
	({ \
		gunichar  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(gunichar ) G_GNUC_CONST)*(void**)(__base - 3376))(__t__p0));\
	})

#define g_signal_get_invocation_hint(__p0) \
	({ \
		gpointer  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSignalInvocationHint *(*)(gpointer ))*(void**)(__base - 4960))(__t__p0));\
	})

#define g_locale_from_utf8(__p0, __p1, __p2, __p3, __p4) \
	({ \
		const gchar * __t__p0 = __p0;\
		gssize  __t__p1 = __p1;\
		gsize * __t__p2 = __p2;\
		gsize * __t__p3 = __p3;\
		GError ** __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, gssize , gsize *, gsize *, GError **) G_GNUC_MALLOC)*(void**)(__base - 4030))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_date_new_julian(__p0) \
	({ \
		guint32  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GDate *(*)(guint32 ))*(void**)(__base - 568))(__t__p0));\
	})

#define g_key_file_free(__p0) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GKeyFile *))*(void**)(__base - 1210))(__t__p0));\
	})

#define g_printf_string_upper_bound(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		va_list  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gsize (*)(const gchar *, va_list ))*(void**)(__base - 1750))(__t__p0, __t__p1));\
	})

#define g_date_strftime(__p0, __p1, __p2, __p3) \
	({ \
		gchar * __t__p0 = __p0;\
		gsize  __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		const GDate * __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gsize (*)(gchar *, gsize , const gchar *, const GDate *))*(void**)(__base - 826))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_object_remove_weak_pointer(__p0, __p1) \
	({ \
		GObject * __t__p0 = __p0;\
		gpointer * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GObject *, gpointer *))*(void**)(__base - 4540))(__t__p0, __t__p1));\
	})

#define g_quark_from_string(__p0) \
	({ \
		const gchar * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GQuark (*)(const gchar *))*(void**)(__base - 2134))(__t__p0));\
	})

#define g_async_queue_try_pop(__p0) \
	({ \
		GAsyncQueue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GAsyncQueue *))*(void**)(__base - 304))(__t__p0));\
	})

#define g_slist_find(__p0, __p1) \
	({ \
		GSList * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSList *(*)(GSList *, gconstpointer ))*(void**)(__base - 2764))(__t__p0, __t__p1));\
	})

#define g_object_new_valist(__p0, __p1, __p2) \
	({ \
		GType  __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		va_list  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GObject *(*)(GType , const gchar *, va_list ))*(void**)(__base - 4450))(__t__p0, __t__p1, __t__p2));\
	})

#define g_node_pop_allocator() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)())*(void**)(__base - 1804))());\
	})

#define g_type_class_unref(__p0) \
	({ \
		gpointer  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(gpointer ))*(void**)(__base - 5170))(__t__p0));\
	})

#define g_option_context_get_ignore_unknown_options(__p0) \
	({ \
		GOptionContext * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GOptionContext *))*(void**)(__base - 1996))(__t__p0));\
	})

#define g_main_loop_is_running(__p0) \
	({ \
		GMainLoop * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GMainLoop *))*(void**)(__base - 3760))(__t__p0));\
	})

#define g_utf8_strncpy(__p0, __p1, __p2) \
	({ \
		gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		gsize  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(gchar *, const gchar *, gsize ))*(void**)(__base - 3496))(__t__p0, __t__p1, __t__p2));\
	})

#define g_list_delete_link(__p0, __p1) \
	({ \
		GList * __t__p0 = __p0;\
		GList * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GList *, GList *))*(void**)(__base - 1498))(__t__p0, __t__p1));\
	})

#define g_key_file_remove_key(__p0, __p1, __p2, __p3) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		GError ** __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GKeyFile *, const gchar *, const gchar *, GError **))*(void**)(__base - 1402))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_hook_prepend(__p0, __p1) \
	({ \
		GHookList * __t__p0 = __p0;\
		GHook * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GHookList *, GHook *))*(void**)(__base - 1114))(__t__p0, __t__p1));\
	})

#define g_queue_copy(__p0) \
	({ \
		GQueue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GQueue *(*)(GQueue *))*(void**)(__base - 2176))(__t__p0));\
	})

#define g_error_new_literal(__p0, __p1, __p2) \
	({ \
		GQuark  __t__p0 = __p0;\
		gint  __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GError *(*)(GQuark , gint , const gchar *))*(void**)(__base - 856))(__t__p0, __t__p1, __t__p2));\
	})

#define g_mem_chunk_destroy(__p0) \
	({ \
		GMemChunk * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GMemChunk *))*(void**)(__base - 1684))(__t__p0));\
	})

#define g_completion_clear_items(__p0) \
	({ \
		GCompletion * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GCompletion *))*(void**)(__base - 442))(__t__p0));\
	})

#define g_param_spec_set_qdata_full(__p0, __p1, __p2, __p3) \
	({ \
		GParamSpec * __t__p0 = __p0;\
		GQuark  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		GDestroyNotify  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GParamSpec *, GQuark , gpointer , GDestroyNotify ))*(void**)(__base - 4690))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_slist_index(__p0, __p1) \
	({ \
		GSList * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(GSList *, gconstpointer ))*(void**)(__base - 2782))(__t__p0, __t__p1));\
	})

#define g_object_set_property(__p0, __p1, __p2) \
	({ \
		GObject * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const GValue * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GObject *, const gchar *, const GValue *))*(void**)(__base - 4468))(__t__p0, __t__p1, __t__p2));\
	})

#define g_hook_first_valid(__p0, __p1) \
	({ \
		GHookList * __t__p0 = __p0;\
		gboolean  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GHook *(*)(GHookList *, gboolean ))*(void**)(__base - 1162))(__t__p0, __t__p1));\
	})

#define g_cache_insert(__p0, __p1) \
	({ \
		GCache * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GCache *, gpointer ))*(void**)(__base - 400))(__t__p0, __t__p1));\
	})

#define g_slist_remove_link(__p0, __p1) \
	({ \
		GSList * __t__p0 = __p0;\
		GSList * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSList *(*)(GSList *, GSList *))*(void**)(__base - 2734))(__t__p0, __t__p1));\
	})

#define g_date_clamp(__p0, __p1, __p2) \
	({ \
		GDate * __t__p0 = __p0;\
		const GDate * __t__p1 = __p1;\
		const GDate * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GDate *, const GDate *, const GDate *))*(void**)(__base - 814))(__t__p0, __t__p1, __t__p2));\
	})

#define g_main_context_remove_poll(__p0, __p1) \
	({ \
		GMainContext * __t__p0 = __p0;\
		GPollFD * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GMainContext *, GPollFD *))*(void**)(__base - 3718))(__t__p0, __t__p1));\
	})

#define g_byte_array_sort_with_data(__p0, __p1, __p2) \
	({ \
		GByteArray * __t__p0 = __p0;\
		GCompareDataFunc  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GByteArray *, GCompareDataFunc , gpointer ))*(void**)(__base - 244))(__t__p0, __t__p1, __t__p2));\
	})

#define g_string_equal(__p0, __p1) \
	({ \
		const GString * __t__p0 = __p0;\
		const GString * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(const GString *, const GString *))*(void**)(__base - 3100))(__t__p0, __t__p1));\
	})

#define g_node_new(__p0) \
	({ \
		gpointer  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GNode *(*)(gpointer ))*(void**)(__base - 1810))(__t__p0));\
	})

#define g_type_plugin_get_type() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GType (*)()	G_GNUC_CONST)*(void**)(__base - 5350))());\
	})

#define g_unichar_isspace(__p0) \
	({ \
		gunichar  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(gunichar ) G_GNUC_CONST)*(void**)(__base - 3358))(__t__p0));\
	})

#define g_unichar_isdefined(__p0) \
	({ \
		gunichar  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(gunichar ) G_GNUC_CONST)*(void**)(__base - 3382))(__t__p0));\
	})

#define g_param_spec_value_array(__p0, __p1, __p2, __p3, __p4) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		GParamSpec * __t__p3 = __p3;\
		GParamFlags  __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(const gchar *, const gchar *, const gchar *, GParamSpec *, GParamFlags ))*(void**)(__base - 4894))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_string_ascii_down(__p0) \
	({ \
		GString * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GString *(*)(GString *))*(void**)(__base - 3208))(__t__p0));\
	})

#define g_utf8_strdown(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		gssize  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, gssize ))*(void**)(__base - 3586))(__t__p0, __t__p1));\
	})

#define g_date_order(__p0, __p1) \
	({ \
		GDate * __t__p0 = __p0;\
		GDate * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GDate *, GDate *))*(void**)(__base - 820))(__t__p0, __t__p1));\
	})

#define g_queue_peek_head(__p0) \
	({ \
		GQueue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GQueue *))*(void**)(__base - 2242))(__t__p0));\
	})

#define g_param_spec_override(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		GParamSpec * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(const gchar *, GParamSpec *))*(void**)(__base - 4906))(__t__p0, __t__p1));\
	})

#define g_io_channel_set_buffered(__p0, __p1) \
	({ \
		GIOChannel * __t__p0 = __p0;\
		gboolean  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GIOChannel *, gboolean ))*(void**)(__base - 3940))(__t__p0, __t__p1));\
	})

#define g_param_spec_ulong(__p0, __p1, __p2, __p3, __p4, __p5, __p6) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		gulong  __t__p3 = __p3;\
		gulong  __t__p4 = __p4;\
		gulong  __t__p5 = __p5;\
		GParamFlags  __t__p6 = __p6;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(const gchar *, const gchar *, const gchar *, gulong , gulong , gulong , GParamFlags ))*(void**)(__base - 4822))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5, __t__p6));\
	})

#define g_node_child_index(__p0, __p1) \
	({ \
		GNode * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(GNode *, gpointer ))*(void**)(__base - 1948))(__t__p0, __t__p1));\
	})

#define g_file_open_tmp(__p0, __p1, __p2) \
	({ \
		const gchar * __t__p0 = __p0;\
		gchar ** __t__p1 = __p1;\
		GError ** __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(const gchar *, gchar **, GError **))*(void**)(__base - 928))(__t__p0, __t__p1, __t__p2));\
	})

#define g_nullify_pointer(__p0) \
	({ \
		gpointer * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(gpointer *))*(void**)(__base - 4216))(__t__p0));\
	})

#define g_async_queue_pop_unlocked(__p0) \
	({ \
		GAsyncQueue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GAsyncQueue *))*(void**)(__base - 298))(__t__p0));\
	})

#define g_key_file_load_from_data_dirs(__p0, __p1, __p2, __p3, __p4) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		gchar ** __t__p2 = __p2;\
		GKeyFileFlags  __t__p3 = __p3;\
		GError ** __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GKeyFile *, const gchar *, gchar **, GKeyFileFlags , GError **))*(void**)(__base - 1234))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_queue_get_length(__p0) \
	({ \
		GQueue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(GQueue *))*(void**)(__base - 2164))(__t__p0));\
	})

#define g_strcompress(__p0) \
	({ \
		const gchar * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *) G_GNUC_MALLOC)*(void**)(__base - 3010))(__t__p0));\
	})

#define g_option_group_free(__p0) \
	({ \
		GOptionGroup * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GOptionGroup *))*(void**)(__base - 2050))(__t__p0));\
	})

#define g_param_spec_flags(__p0, __p1, __p2, __p3, __p4, __p5) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		GType  __t__p3 = __p3;\
		guint  __t__p4 = __p4;\
		GParamFlags  __t__p5 = __p5;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(const gchar *, const gchar *, const gchar *, GType , guint , GParamFlags ))*(void**)(__base - 4852))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5));\
	})

#define g_array_new(__p0, __p1, __p2) \
	({ \
		gboolean  __t__p0 = __p0;\
		gboolean  __t__p1 = __p1;\
		guint  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GArray *(*)(gboolean , gboolean , guint ))*(void**)(__base - 34))(__t__p0, __t__p1, __t__p2));\
	})

#define g_option_group_set_error_hook(__p0, __p1) \
	({ \
		GOptionGroup * __t__p0 = __p0;\
		GOptionErrorFunc  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GOptionGroup *, GOptionErrorFunc ))*(void**)(__base - 2044))(__t__p0, __t__p1));\
	})

#define g_propagate_error(__p0, __p1) \
	({ \
		GError ** __t__p0 = __p0;\
		GError * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GError **, GError *))*(void**)(__base - 880))(__t__p0, __t__p1));\
	})

#define g_ptr_array_remove_fast(__p0, __p1) \
	({ \
		GPtrArray * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GPtrArray *, gpointer ))*(void**)(__base - 148))(__t__p0, __t__p1));\
	})

#define g_datalist_unset_flags(__p0, __p1) \
	({ \
		GData ** __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GData **, guint ))*(void**)(__base - 514))(__t__p0, __t__p1));\
	})

#define g_flags_complete_type_info(__p0, __p1, __p2) \
	({ \
		GType  __t__p0 = __p0;\
		GTypeInfo * __t__p1 = __p1;\
		const GFlagsValue * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GType , GTypeInfo *, const GFlagsValue *))*(void**)(__base - 4390))(__t__p0, __t__p1, __t__p2));\
	})

#define g_tree_nnodes(__p0) \
	({ \
		GTree * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(GTree *))*(void**)(__base - 3298))(__t__p0));\
	})

#define g_unichar_isdigit(__p0) \
	({ \
		gunichar  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(gunichar ) G_GNUC_CONST)*(void**)(__base - 3328))(__t__p0));\
	})

#define g_markup_parse_context_new(__p0, __p1, __p2, __p3) \
	({ \
		const GMarkupParser * __t__p0 = __p0;\
		GMarkupParseFlags  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		GDestroyNotify  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GMarkupParseContext *(*)(const GMarkupParser *, GMarkupParseFlags , gpointer , GDestroyNotify ))*(void**)(__base - 1594))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_source_set_closure(__p0, __p1) \
	({ \
		GSource * __t__p0 = __p0;\
		GClosure * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GSource *, GClosure *))*(void**)(__base - 5080))(__t__p0, __t__p1));\
	})

#define g_source_get_can_recurse(__p0) \
	({ \
		GSource * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GSource *))*(void**)(__base - 4150))(__t__p0));\
	})

#define g_tree_new(__p0) \
	({ \
		GCompareFunc  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GTree *(*)(GCompareFunc ))*(void**)(__base - 3220))(__t__p0));\
	})

#define g_io_channel_get_flags(__p0) \
	({ \
		GIOChannel * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GIOFlags (*)(GIOChannel *))*(void**)(__base - 3868))(__t__p0));\
	})

#define g_value_dup_string(__p0) \
	({ \
		const GValue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const GValue *))*(void**)(__base - 5620))(__t__p0));\
	})

#define g_array_free(__p0, __p1) \
	({ \
		GArray * __t__p0 = __p0;\
		gboolean  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(GArray *, gboolean ))*(void**)(__base - 46))(__t__p0, __t__p1));\
	})

#define g_strchug(__p0) \
	({ \
		gchar * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(gchar *))*(void**)(__base - 2950))(__t__p0));\
	})

#define g_list_nth_prev(__p0, __p1) \
	({ \
		GList * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GList *, guint ))*(void**)(__base - 1522))(__t__p0, __t__p1));\
	})

#define g_atomic_int_exchange_and_add(__p0, __p1) \
	(((gint (*)(gint *, gint ))*(void**)((long)(GLIB_BASE_NAME) - 340))(__p0, __p1))

#define g_stpcpy(__p0, __p1) \
	({ \
		gchar * __t__p0 = __p0;\
		const char * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(gchar *, const char *))*(void**)(__base - 3064))(__t__p0, __t__p1));\
	})

#define g_type_plugin_complete_interface_info(__p0, __p1, __p2, __p3) \
	({ \
		GTypePlugin * __t__p0 = __p0;\
		GType  __t__p1 = __p1;\
		GType  __t__p2 = __p2;\
		GInterfaceInfo * __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GTypePlugin *, GType , GType , GInterfaceInfo *))*(void**)(__base - 5374))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_io_channel_set_flags(__p0, __p1, __p2) \
	({ \
		GIOChannel * __t__p0 = __p0;\
		GIOFlags  __t__p1 = __p1;\
		GError ** __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GIOStatus (*)(GIOChannel *, GIOFlags , GError **))*(void**)(__base - 3958))(__t__p0, __t__p1, __t__p2));\
	})

#define g_async_queue_lock(__p0) \
	({ \
		GAsyncQueue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GAsyncQueue *))*(void**)(__base - 256))(__t__p0));\
	})

#define g_dataset_id_get_data(__p0, __p1) \
	({ \
		gconstpointer  __t__p0 = __p0;\
		GQuark  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(gconstpointer , GQuark ))*(void**)(__base - 532))(__t__p0, __t__p1));\
	})

#define g_completion_set_compare(__p0, __p1) \
	({ \
		GCompletion * __t__p0 = __p0;\
		GCompletionStrncmpFunc  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GCompletion *, GCompletionStrncmpFunc ))*(void**)(__base - 460))(__t__p0, __t__p1));\
	})

#define g_object_set_data_full(__p0, __p1, __p2, __p3) \
	({ \
		GObject * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		GDestroyNotify  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GObject *, const gchar *, gpointer , GDestroyNotify ))*(void**)(__base - 4594))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_flags_get_first_value(__p0, __p1) \
	({ \
		GFlagsClass * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GFlagsValue *(*)(GFlagsClass *, guint ))*(void**)(__base - 4330))(__t__p0, __t__p1));\
	})

#define g_rand_set_seed(__p0, __p1) \
	({ \
		GRand * __t__p0 = __p0;\
		guint32  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GRand *, guint32 ))*(void**)(__base - 2398))(__t__p0, __t__p1));\
	})

#define g_async_queue_pop(__p0) \
	({ \
		GAsyncQueue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GAsyncQueue *))*(void**)(__base - 292))(__t__p0));\
	})

#define g_node_traverse(__p0, __p1, __p2, __p3, __p4, __p5) \
	({ \
		GNode * __t__p0 = __p0;\
		GTraverseType  __t__p1 = __p1;\
		GTraverseFlags  __t__p2 = __p2;\
		gint  __t__p3 = __p3;\
		GNodeTraverseFunc  __t__p4 = __p4;\
		gpointer  __t__p5 = __p5;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GNode *, GTraverseType , GTraverseFlags , gint , GNodeTraverseFunc , gpointer ))*(void**)(__base - 1894))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5));\
	})

#define g_filename_to_uri(__p0, __p1, __p2) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		GError ** __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, const gchar *, GError **) G_GNUC_MALLOC)*(void**)(__base - 4072))(__t__p0, __t__p1, __t__p2));\
	})

#define g_pattern_match_simple(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(const gchar *, const gchar *))*(void**)(__base - 2104))(__t__p0, __t__p1));\
	})

#define g_object_class_list_properties(__p0, __p1) \
	({ \
		GObjectClass * __t__p0 = __p0;\
		guint * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec **(*)(GObjectClass *, guint *))*(void**)(__base - 4414))(__t__p0, __t__p1));\
	})

#define g_type_class_ref(__p0) \
	({ \
		GType  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GType ))*(void**)(__base - 5152))(__t__p0));\
	})

#define g_hash_table_new(__p0, __p1) \
	({ \
		GHashFunc  __t__p0 = __p0;\
		GEqualFunc  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GHashTable *(*)(GHashFunc , GEqualFunc ))*(void**)(__base - 934))(__t__p0, __t__p1));\
	})

#define g_async_queue_push_unlocked(__p0, __p1) \
	({ \
		GAsyncQueue * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GAsyncQueue *, gpointer ))*(void**)(__base - 286))(__t__p0, __t__p1));\
	})

#define g_value_array_sort_with_data(__p0, __p1, __p2) \
	({ \
		GValueArray * __t__p0 = __p0;\
		GCompareDataFunc  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GValueArray *(*)(GValueArray *, GCompareDataFunc , gpointer ))*(void**)(__base - 5464))(__t__p0, __t__p1, __t__p2));\
	})

#define g_logv(__p0, __p1, __p2, __p3) \
	({ \
		const gchar * __t__p0 = __p0;\
		GLogLevelFlags  __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		va_list  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(const gchar *, GLogLevelFlags , const gchar *, va_list ))*(void**)(__base - 1780))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_ptr_array_set_size(__p0, __p1) \
	({ \
		GPtrArray * __t__p0 = __p0;\
		gint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GPtrArray *, gint ))*(void**)(__base - 124))(__t__p0, __t__p1));\
	})

#define g_option_context_set_help_enabled(__p0, __p1) \
	({ \
		GOptionContext * __t__p0 = __p0;\
		gboolean  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GOptionContext *, gboolean ))*(void**)(__base - 1978))(__t__p0, __t__p1));\
	})

#define g_main_loop_ref(__p0) \
	({ \
		GMainLoop * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GMainLoop *(*)(GMainLoop *))*(void**)(__base - 3778))(__t__p0));\
	})

#define g_io_channel_read_chars(__p0, __p1, __p2, __p3, __p4) \
	({ \
		GIOChannel * __t__p0 = __p0;\
		gchar * __t__p1 = __p1;\
		gsize  __t__p2 = __p2;\
		gsize * __t__p3 = __p3;\
		GError ** __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GIOStatus (*)(GIOChannel *, gchar *, gsize , gsize *, GError **))*(void**)(__base - 3892))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_datalist_clear(__p0) \
	({ \
		GData ** __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GData **))*(void**)(__base - 478))(__t__p0));\
	})

#define g_date_subtract_months(__p0, __p1) \
	({ \
		GDate * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GDate *, guint ))*(void**)(__base - 754))(__t__p0, __t__p1));\
	})

#define g_blow_chunks() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)())*(void**)(__base - 1732))());\
	})

#define g_mem_chunk_alloc(__p0) \
	({ \
		GMemChunk * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GMemChunk *))*(void**)(__base - 1690))(__t__p0));\
	})

#define g_list_sort(__p0, __p1) \
	({ \
		GList * __t__p0 = __p0;\
		GCompareFunc  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GList *, GCompareFunc ))*(void**)(__base - 1576))(__t__p0, __t__p1));\
	})

#define g_date_set_parse(__p0, __p1) \
	({ \
		GDate * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GDate *, const gchar *))*(void**)(__base - 682))(__t__p0, __t__p1));\
	})

#define g_date_compare(__p0, __p1) \
	({ \
		const GDate * __t__p0 = __p0;\
		const GDate * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(const GDate *, const GDate *))*(void**)(__base - 802))(__t__p0, __t__p1));\
	})

#define g_string_prepend(__p0, __p1) \
	({ \
		GString * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GString *(*)(GString *, const gchar *))*(void**)(__base - 3160))(__t__p0, __t__p1));\
	})

#define g_date_get_iso8601_week_of_year(__p0) \
	({ \
		const GDate * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(const GDate *))*(void**)(__base - 670))(__t__p0));\
	})

#define g_queue_free(__p0) \
	({ \
		GQueue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GQueue *))*(void**)(__base - 2152))(__t__p0));\
	})

#define g_main_context_check(__p0, __p1, __p2, __p3) \
	({ \
		GMainContext * __t__p0 = __p0;\
		gint  __t__p1 = __p1;\
		GPollFD * __t__p2 = __p2;\
		gint  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(GMainContext *, gint , GPollFD *, gint ))*(void**)(__base - 3634))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_str_has_suffix(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(const gchar *, const gchar *))*(void**)(__base - 2908))(__t__p0, __t__p1));\
	})

#define g_queue_pop_nth_link(__p0, __p1) \
	({ \
		GQueue * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GQueue *, guint ))*(void**)(__base - 2326))(__t__p0, __t__p1));\
	})

#define g_io_channel_seek_position(__p0, __p1, __p2, __p3) \
	({ \
		GIOChannel * __t__p0 = __p0;\
		gint64  __t__p1 = __p1;\
		GSeekType  __t__p2 = __p2;\
		GError ** __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GIOStatus (*)(GIOChannel *, gint64 , GSeekType , GError **))*(void**)(__base - 3928))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_type_parent(__p0) \
	({ \
		GType  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GType (*)(GType ))*(void**)(__base - 5128))(__t__p0));\
	})

#define g_ascii_xdigit_value(__p0) \
	({ \
		gchar  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(gchar ) G_GNUC_CONST)*(void**)(__base - 2842))(__t__p0));\
	})

#define g_io_channel_get_buffer_condition(__p0) \
	({ \
		GIOChannel * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GIOCondition (*)(GIOChannel *))*(void**)(__base - 3844))(__t__p0));\
	})

#define g_utf8_strrchr(__p0, __p1, __p2) \
	({ \
		const gchar * __t__p0 = __p0;\
		gssize  __t__p1 = __p1;\
		gunichar  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, gssize , gunichar ))*(void**)(__base - 3508))(__t__p0, __t__p1, __t__p2));\
	})

#define g_source_remove_poll(__p0, __p1) \
	({ \
		GSource * __t__p0 = __p0;\
		GPollFD * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GSource *, GPollFD *))*(void**)(__base - 4186))(__t__p0, __t__p1));\
	})

#define g_ptr_array_free(__p0, __p1) \
	({ \
		GPtrArray * __t__p0 = __p0;\
		gboolean  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer *(*)(GPtrArray *, gboolean ))*(void**)(__base - 118))(__t__p0, __t__p1));\
	})

#define g_unichar_isgraph(__p0) \
	({ \
		gunichar  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(gunichar ) G_GNUC_CONST)*(void**)(__base - 3334))(__t__p0));\
	})

#define g_signal_new_valist(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7, __p8, __p9) \
	({ \
		const gchar * __t__p0 = __p0;\
		GType  __t__p1 = __p1;\
		GSignalFlags  __t__p2 = __p2;\
		GClosure * __t__p3 = __p3;\
		GSignalAccumulator  __t__p4 = __p4;\
		gpointer  __t__p5 = __p5;\
		GSignalCMarshaller  __t__p6 = __p6;\
		GType  __t__p7 = __p7;\
		guint  __t__p8 = __p8;\
		va_list  __t__p9 = __p9;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(const gchar *, GType , GSignalFlags , GClosure *, GSignalAccumulator , gpointer , GSignalCMarshaller , GType , guint , va_list ))*(void**)(__base - 4924))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5, __t__p6, __t__p7, __t__p8, __t__p9));\
	})

#define g_value_get_char(__p0) \
	({ \
		const GValue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar (*)(const GValue *))*(void**)(__base - 5476))(__t__p0));\
	})

#define g_datalist_id_get_data(__p0, __p1) \
	({ \
		GData ** __t__p0 = __p0;\
		GQuark  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GData **, GQuark ))*(void**)(__base - 484))(__t__p0, __t__p1));\
	})

#define g_param_spec_unref(__p0) \
	({ \
		GParamSpec * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GParamSpec *))*(void**)(__base - 4660))(__t__p0));\
	})

#define g_value_set_instance(__p0, __p1) \
	({ \
		GValue * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GValue *, gpointer ))*(void**)(__base - 5404))(__t__p0, __t__p1));\
	})

#define g_date_get_day_of_year(__p0) \
	({ \
		const GDate * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(const GDate *))*(void**)(__base - 652))(__t__p0));\
	})

#define g_tree_insert(__p0, __p1, __p2) \
	({ \
		GTree * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GTree *, gpointer , gpointer ))*(void**)(__base - 3244))(__t__p0, __t__p1, __t__p2));\
	})

#define g_utf8_strup(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		gssize  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, gssize ))*(void**)(__base - 3580))(__t__p0, __t__p1));\
	})

#define g_key_file_get_boolean(__p0, __p1, __p2, __p3) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		GError ** __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GKeyFile *, const gchar *, const gchar *, GError **))*(void**)(__base - 1312))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_type_interface_prerequisites(__p0, __p1) \
	({ \
		GType  __t__p0 = __p0;\
		guint * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GType *(*)(GType , guint *))*(void**)(__base - 5284))(__t__p0, __t__p1));\
	})

#define g_atomic_pointer_set(__p0, __p1) \
	(((void (*)(volatile gpointer *, gpointer ))*(void**)((long)(GLIB_BASE_NAME) - 382))(__p0, __p1))

#define g_tree_steal(__p0, __p1) \
	({ \
		GTree * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GTree *, gconstpointer ))*(void**)(__base - 3262))(__t__p0, __t__p1));\
	})

#define g_queue_remove_all(__p0, __p1) \
	({ \
		GQueue * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GQueue *, gconstpointer ))*(void**)(__base - 2272))(__t__p0, __t__p1));\
	})

#define g_allocator_new(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GAllocator *(*)(const gchar *, guint ))*(void**)(__base - 1738))(__t__p0, __t__p1));\
	})

#define g_param_spec_param(__p0, __p1, __p2, __p3, __p4) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		GType  __t__p3 = __p3;\
		GParamFlags  __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(const gchar *, const gchar *, const gchar *, GType , GParamFlags ))*(void**)(__base - 4876))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_tree_new_with_data(__p0, __p1) \
	({ \
		GCompareDataFunc  __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GTree *(*)(GCompareDataFunc , gpointer ))*(void**)(__base - 3226))(__t__p0, __t__p1));\
	})

#define g_object_interface_list_properties(__p0, __p1) \
	({ \
		gpointer  __t__p0 = __p0;\
		guint * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec **(*)(gpointer , guint *))*(void**)(__base - 4438))(__t__p0, __t__p1));\
	})

#define g_utf8_pointer_to_offset(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((glong (*)(const gchar *, const gchar *))*(void**)(__base - 3466))(__t__p0, __t__p1));\
	})

#define g_hook_list_marshal_check(__p0, __p1, __p2, __p3) \
	({ \
		GHookList * __t__p0 = __p0;\
		gboolean  __t__p1 = __p1;\
		GHookCheckMarshaller  __t__p2 = __p2;\
		gpointer  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GHookList *, gboolean , GHookCheckMarshaller , gpointer ))*(void**)(__base - 1198))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_io_channel_get_type() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GType (*)())*(void**)(__base - 5086))());\
	})

#define g_pattern_spec_new(__p0) \
	({ \
		const gchar * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GPatternSpec *(*)(const gchar *))*(void**)(__base - 2074))(__t__p0));\
	})

#define g_source_get_priority(__p0) \
	({ \
		GSource * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(GSource *))*(void**)(__base - 4138))(__t__p0));\
	})

#define g_child_watch_add_full(__p0, __p1, __p2, __p3, __p4) \
	({ \
		gint  __t__p0 = __p0;\
		GPid  __t__p1 = __p1;\
		GChildWatchFunc  __t__p2 = __p2;\
		gpointer  __t__p3 = __p3;\
		GDestroyNotify  __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(gint , GPid , GChildWatchFunc , gpointer , GDestroyNotify ))*(void**)(__base - 4018))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_completion_complete_utf8(__p0, __p1, __p2) \
	({ \
		GCompletion * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		gchar ** __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GCompletion *, const gchar *, gchar **))*(void**)(__base - 454))(__t__p0, __t__p1, __t__p2));\
	})

#define g_hash_table_remove(__p0, __p1) \
	({ \
		GHashTable * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GHashTable *, gconstpointer ))*(void**)(__base - 964))(__t__p0, __t__p1));\
	})

#define g_scanner_lookup_symbol(__p0, __p1) \
	({ \
		GScanner * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GScanner *, const gchar *))*(void**)(__base - 2620))(__t__p0, __t__p1));\
	})

#define g_node_insert(__p0, __p1, __p2) \
	({ \
		GNode * __t__p0 = __p0;\
		gint  __t__p1 = __p1;\
		GNode * __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GNode *(*)(GNode *, gint , GNode *))*(void**)(__base - 1840))(__t__p0, __t__p1, __t__p2));\
	})

#define g_param_spec_boolean(__p0, __p1, __p2, __p3, __p4) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		gboolean  __t__p3 = __p3;\
		GParamFlags  __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(const gchar *, const gchar *, const gchar *, gboolean , GParamFlags ))*(void**)(__base - 4798))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_string_truncate(__p0, __p1) \
	({ \
		GString * __t__p0 = __p0;\
		gsize  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GString *(*)(GString *, gsize ))*(void**)(__base - 3118))(__t__p0, __t__p1));\
	})

#define g_utf8_strchr(__p0, __p1, __p2) \
	({ \
		const gchar * __t__p0 = __p0;\
		gssize  __t__p1 = __p1;\
		gunichar  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, gssize , gunichar ))*(void**)(__base - 3502))(__t__p0, __t__p1, __t__p2));\
	})

#define g_node_child_position(__p0, __p1) \
	({ \
		GNode * __t__p0 = __p0;\
		GNode * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(GNode *, GNode *))*(void**)(__base - 1942))(__t__p0, __t__p1));\
	})

#define g_object_weak_unref(__p0, __p1, __p2) \
	({ \
		GObject * __t__p0 = __p0;\
		GWeakNotify  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GObject *, GWeakNotify , gpointer ))*(void**)(__base - 4528))(__t__p0, __t__p1, __t__p2));\
	})

#define g_direct_hash(__p0) \
	({ \
		gconstpointer  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(gconstpointer ) G_GNUC_CONST)*(void**)(__base - 1054))(__t__p0));\
	})

#define g_io_condition_get_type() \
	({ \
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GType (*)())*(void**)(__base - 5092))());\
	})

#define g_value_set_string(__p0, __p1) \
	({ \
		GValue * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GValue *, const gchar *))*(void**)(__base - 5602))(__t__p0, __t__p1));\
	})

#define g_node_copy(__p0) \
	({ \
		GNode * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GNode *(*)(GNode *))*(void**)(__base - 1834))(__t__p0));\
	})

#define g_key_file_remove_group(__p0, __p1, __p2) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		GError ** __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GKeyFile *, const gchar *, GError **))*(void**)(__base - 1408))(__t__p0, __t__p1, __t__p2));\
	})

#define g_str_has_prefix(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(const gchar *, const gchar *))*(void**)(__base - 2914))(__t__p0, __t__p1));\
	})

#define g_strrstr(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, const gchar *))*(void**)(__base - 2896))(__t__p0, __t__p1));\
	})

#define g_param_spec_unichar(__p0, __p1, __p2, __p3, __p4) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		gunichar  __t__p3 = __p3;\
		GParamFlags  __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(const gchar *, const gchar *, const gchar *, gunichar , GParamFlags ))*(void**)(__base - 4840))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_list_nth(__p0, __p1) \
	({ \
		GList * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GList *, guint ))*(void**)(__base - 1516))(__t__p0, __t__p1));\
	})

#define g_value_get_uint64(__p0) \
	({ \
		const GValue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint64 (*)(const GValue *))*(void**)(__base - 5572))(__t__p0));\
	})

#define g_date_subtract_years(__p0, __p1) \
	({ \
		GDate * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GDate *, guint ))*(void**)(__base - 766))(__t__p0, __t__p1));\
	})

#define g_ascii_strtod(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		gchar ** __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gdouble (*)(const gchar *, gchar **))*(void**)(__base - 2926))(__t__p0, __t__p1));\
	})

#define g_memdup(__p0, __p1) \
	({ \
		gconstpointer  __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(gconstpointer , guint ) G_GNUC_MALLOC)*(void**)(__base - 3022))(__t__p0, __t__p1));\
	})

#define g_key_file_set_string(__p0, __p1, __p2, __p3) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		const gchar * __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GKeyFile *, const gchar *, const gchar *, const gchar *))*(void**)(__base - 1294))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_slist_copy(__p0) \
	({ \
		GSList * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSList *(*)(GSList *))*(void**)(__base - 2752))(__t__p0));\
	})

#define g_get_charset(__p0) \
	({ \
		G_CONST_RETURN char ** __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(G_CONST_RETURN char **))*(void**)(__base - 3304))(__t__p0));\
	})

#define g_type_register_dynamic(__p0, __p1, __p2, __p3) \
	({ \
		GType  __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		GTypePlugin * __t__p2 = __p2;\
		GTypeFlags  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GType (*)(GType , const gchar *, GTypePlugin *, GTypeFlags ))*(void**)(__base - 5254))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_file_get_contents(__p0, __p1, __p2, __p3) \
	({ \
		const gchar * __t__p0 = __p0;\
		gchar ** __t__p1 = __p1;\
		gsize * __t__p2 = __p2;\
		GError ** __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(const gchar *, gchar **, gsize *, GError **))*(void**)(__base - 910))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_signal_handlers_block_matched(__p0, __p1, __p2, __p3, __p4, __p5, __p6) \
	({ \
		gpointer  __t__p0 = __p0;\
		GSignalMatchType  __t__p1 = __p1;\
		guint  __t__p2 = __p2;\
		GQuark  __t__p3 = __p3;\
		GClosure * __t__p4 = __p4;\
		gpointer  __t__p5 = __p5;\
		gpointer  __t__p6 = __p6;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint (*)(gpointer , GSignalMatchType , guint , GQuark , GClosure *, gpointer , gpointer ))*(void**)(__base - 5044))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5, __t__p6));\
	})

#define g_node_destroy(__p0) \
	({ \
		GNode * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GNode *))*(void**)(__base - 1816))(__t__p0));\
	})

#define g_source_remove_by_user_data(__p0) \
	({ \
		gpointer  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(gpointer ))*(void**)(__base - 4204))(__t__p0));\
	})

#define g_param_spec_int64(__p0, __p1, __p2, __p3, __p4, __p5, __p6) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		gint64  __t__p3 = __p3;\
		gint64  __t__p4 = __p4;\
		gint64  __t__p5 = __p5;\
		GParamFlags  __t__p6 = __p6;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(const gchar *, const gchar *, const gchar *, gint64 , gint64 , gint64 , GParamFlags ))*(void**)(__base - 4828))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5, __t__p6));\
	})

#define g_str_equal(__p0, __p1) \
	({ \
		gconstpointer  __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(gconstpointer , gconstpointer ))*(void**)(__base - 1030))(__t__p0, __t__p1));\
	})

#define g_strchomp(__p0) \
	({ \
		gchar * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(gchar *))*(void**)(__base - 2956))(__t__p0));\
	})

#define g_option_context_add_group(__p0, __p1) \
	({ \
		GOptionContext * __t__p0 = __p0;\
		GOptionGroup * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GOptionContext *, GOptionGroup *))*(void**)(__base - 2014))(__t__p0, __t__p1));\
	})

#define g_param_spec_string(__p0, __p1, __p2, __p3, __p4) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		const gchar * __t__p3 = __p3;\
		GParamFlags  __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(const gchar *, const gchar *, const gchar *, const gchar *, GParamFlags ))*(void**)(__base - 4870))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_queue_peek_tail(__p0) \
	({ \
		GQueue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GQueue *))*(void**)(__base - 2248))(__t__p0));\
	})

#define g_scanner_destroy(__p0) \
	({ \
		GScanner * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GScanner *))*(void**)(__base - 2524))(__t__p0));\
	})

#define g_slist_insert_sorted(__p0, __p1, __p2) \
	({ \
		GSList * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		GCompareFunc  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSList *(*)(GSList *, gpointer , GCompareFunc ))*(void**)(__base - 2704))(__t__p0, __t__p1, __t__p2));\
	})

#define g_slist_remove_all(__p0, __p1) \
	({ \
		GSList * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSList *(*)(GSList *, gconstpointer ))*(void**)(__base - 2728))(__t__p0, __t__p1));\
	})

#define g_string_insert_unichar(__p0, __p1, __p2) \
	({ \
		GString * __t__p0 = __p0;\
		gssize  __t__p1 = __p1;\
		gunichar  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GString *(*)(GString *, gssize , gunichar ))*(void**)(__base - 3196))(__t__p0, __t__p1, __t__p2));\
	})

#define g_main_context_iteration(__p0, __p1) \
	({ \
		GMainContext * __t__p0 = __p0;\
		gboolean  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gboolean (*)(GMainContext *, gboolean ))*(void**)(__base - 3676))(__t__p0, __t__p1));\
	})

#define g_byte_array_set_size(__p0, __p1) \
	({ \
		GByteArray * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GByteArray *(*)(GByteArray *, guint ))*(void**)(__base - 214))(__t__p0, __t__p1));\
	})

#define g_main_context_dispatch(__p0) \
	({ \
		GMainContext * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GMainContext *))*(void**)(__base - 3646))(__t__p0));\
	})

#define g_source_destroy(__p0) \
	({ \
		GSource * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GSource *))*(void**)(__base - 4126))(__t__p0));\
	})

#define g_hook_alloc(__p0) \
	({ \
		GHookList * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GHook *(*)(GHookList *))*(void**)(__base - 1078))(__t__p0));\
	})

#define g_slist_remove(__p0, __p1) \
	({ \
		GSList * __t__p0 = __p0;\
		gconstpointer  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSList *(*)(GSList *, gconstpointer ))*(void**)(__base - 2722))(__t__p0, __t__p1));\
	})

#define g_string_sized_new(__p0) \
	({ \
		gsize  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GString *(*)(gsize ))*(void**)(__base - 3088))(__t__p0));\
	})

#define g_object_set_qdata_full(__p0, __p1, __p2, __p3) \
	({ \
		GObject * __t__p0 = __p0;\
		GQuark  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		GDestroyNotify  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GObject *, GQuark , gpointer , GDestroyNotify ))*(void**)(__base - 4570))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_queue_peek_nth_link(__p0, __p1) \
	({ \
		GQueue * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GQueue *, guint ))*(void**)(__base - 2344))(__t__p0, __t__p1));\
	})

#define g_type_plugin_unuse(__p0) \
	({ \
		GTypePlugin * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GTypePlugin *))*(void**)(__base - 5362))(__t__p0));\
	})

#define g_list_insert_sorted(__p0, __p1, __p2) \
	({ \
		GList * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		GCompareFunc  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GList *, gpointer , GCompareFunc ))*(void**)(__base - 1462))(__t__p0, __t__p1, __t__p2));\
	})

#define g_value_array_sort(__p0, __p1) \
	({ \
		GValueArray * __t__p0 = __p0;\
		GCompareFunc  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GValueArray *(*)(GValueArray *, GCompareFunc ))*(void**)(__base - 5458))(__t__p0, __t__p1));\
	})

#define g_string_ascii_up(__p0) \
	({ \
		GString * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GString *(*)(GString *))*(void**)(__base - 3214))(__t__p0));\
	})

#define g_signal_stop_emission_by_name(__p0, __p1) \
	({ \
		gpointer  __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(gpointer , const gchar *))*(void**)(__base - 4972))(__t__p0, __t__p1));\
	})

#define g_value_array_get_nth(__p0, __p1) \
	({ \
		GValueArray * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GValue *(*)(GValueArray *, guint ))*(void**)(__base - 5410))(__t__p0, __t__p1));\
	})

#define g_markup_escape_text(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		gssize  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar *(*)(const gchar *, gssize ))*(void**)(__base - 1630))(__t__p0, __t__p1));\
	})

#define g_key_file_set_string_list(__p0, __p1, __p2, __p3, __p4) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		const gchar *const * __t__p3 = __p3;\
		gsize  __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GKeyFile *, const gchar *, const gchar *, const gchar *const *, gsize ))*(void**)(__base - 1342))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_tree_search(__p0, __p1, __p2) \
	({ \
		GTree * __t__p0 = __p0;\
		GCompareFunc  __t__p1 = __p1;\
		gconstpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GTree *, GCompareFunc , gconstpointer ))*(void**)(__base - 3286))(__t__p0, __t__p1, __t__p2));\
	})

#define g_array_sized_new(__p0, __p1, __p2, __p3) \
	({ \
		gboolean  __t__p0 = __p0;\
		gboolean  __t__p1 = __p1;\
		guint  __t__p2 = __p2;\
		guint  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GArray *(*)(gboolean , gboolean , guint , guint ))*(void**)(__base - 40))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_key_file_get_groups(__p0, __p1) \
	({ \
		GKeyFile * __t__p0 = __p0;\
		gsize * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar **(*)(GKeyFile *, gsize *) G_GNUC_MALLOC)*(void**)(__base - 1252))(__t__p0, __t__p1));\
	})

#define g_value_get_int(__p0) \
	({ \
		const GValue * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(const GValue *))*(void**)(__base - 5512))(__t__p0));\
	})

#define g_queue_link_index(__p0, __p1) \
	({ \
		GQueue * __t__p0 = __p0;\
		GList * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gint (*)(GQueue *, GList *))*(void**)(__base - 2350))(__t__p0, __t__p1));\
	})

#define g_queue_insert_sorted(__p0, __p1, __p2, __p3) \
	({ \
		GQueue * __t__p0 = __p0;\
		gpointer  __t__p1 = __p1;\
		GCompareDataFunc  __t__p2 = __p2;\
		gpointer  __t__p3 = __p3;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GQueue *, gpointer , GCompareDataFunc , gpointer ))*(void**)(__base - 2290))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define g_hash_table_find(__p0, __p1, __p2) \
	({ \
		GHashTable * __t__p0 = __p0;\
		GHRFunc  __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gpointer (*)(GHashTable *, GHRFunc , gpointer ))*(void**)(__base - 994))(__t__p0, __t__p1, __t__p2));\
	})

#define g_io_channel_ref(__p0) \
	({ \
		GIOChannel * __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GIOChannel *(*)(GIOChannel *))*(void**)(__base - 3922))(__t__p0));\
	})

#define g_param_spec_boxed(__p0, __p1, __p2, __p3, __p4) \
	({ \
		const gchar * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		const gchar * __t__p2 = __p2;\
		GType  __t__p3 = __p3;\
		GParamFlags  __t__p4 = __p4;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GParamSpec *(*)(const gchar *, const gchar *, const gchar *, GType , GParamFlags ))*(void**)(__base - 4882))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define g_value_init(__p0, __p1) \
	({ \
		GValue * __t__p0 = __p0;\
		GType  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GValue *(*)(GValue *, GType ))*(void**)(__base - 5380))(__t__p0, __t__p1));\
	})

#define g_type_module_set_name(__p0, __p1) \
	({ \
		GTypeModule * __t__p0 = __p0;\
		const gchar * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GTypeModule *, const gchar *))*(void**)(__base - 5320))(__t__p0, __t__p1));\
	})

#define g_slist_insert_before(__p0, __p1, __p2) \
	({ \
		GSList * __t__p0 = __p0;\
		GSList * __t__p1 = __p1;\
		gpointer  __t__p2 = __p2;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSList *(*)(GSList *, GSList *, gpointer ))*(void**)(__base - 2710))(__t__p0, __t__p1, __t__p2));\
	})

#define g_list_remove_link(__p0, __p1) \
	({ \
		GList * __t__p0 = __p0;\
		GList * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GList *(*)(GList *, GList *))*(void**)(__base - 1492))(__t__p0, __t__p1));\
	})

#define g_hook_list_invoke(__p0, __p1) \
	({ \
		GHookList * __t__p0 = __p0;\
		gboolean  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(GHookList *, gboolean ))*(void**)(__base - 1180))(__t__p0, __t__p1));\
	})

#define g_ascii_toupper(__p0) \
	({ \
		gchar  __t__p0 = __p0;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((gchar (*)(gchar ) G_GNUC_CONST)*(void**)(__base - 2830))(__t__p0));\
	})

#define g_slist_nth(__p0, __p1) \
	({ \
		GSList * __t__p0 = __p0;\
		guint  __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GSList *(*)(GSList *, guint ))*(void**)(__base - 2758))(__t__p0, __t__p1));\
	})

#define g_flags_register_static(__p0, __p1) \
	({ \
		const gchar * __t__p0 = __p0;\
		const GFlagsValue * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((GType (*)(const gchar *, const GFlagsValue *))*(void**)(__base - 4378))(__t__p0, __t__p1));\
	})

#define g_signal_list_ids(__p0, __p1) \
	({ \
		GType  __t__p0 = __p0;\
		guint * __t__p1 = __p1;\
		long __base = (long)(GLIB_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((guint *(*)(GType , guint *))*(void**)(__base - 4948))(__t__p0, __t__p1));\
	})

#endif /* !_PPCINLINE_GLIB_H */
