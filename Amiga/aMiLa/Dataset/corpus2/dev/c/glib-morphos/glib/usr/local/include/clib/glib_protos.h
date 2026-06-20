
#if 0

VOID GLib_SetExit(void (*func)(int));


/* This file is for cvinclude.pl usage and has no other purpose. */

/* Internal functions */
void g_return_if_fail_warning (const char *log_domain, const char *pretty_function, const char *expression);
void g_assert_warning         (const char *log_domain, const char *file, const int   line, const char *pretty_function, const char *expression);
gchar* g_intern_string            (const gchar *string);
gchar *g_intern_static_string     (const gchar *string);

/* Public functions */

GArray* g_array_new(gboolean zero_terminated, gboolean clear_, guint element_size);
GArray* g_array_sized_new         (gboolean          zero_terminated,gboolean          clear_,guint             element_size,guint             reserved_size);
gchar*  g_array_free              (GArray           *array,
				   gboolean          free_segment);
GArray* g_array_append_vals       (GArray           *array,
				   gconstpointer     data,
				   guint             len);
GArray* g_array_prepend_vals      (GArray           *array,
				   gconstpointer     data,
				   guint             len);
GArray* g_array_insert_vals       (GArray           *array,
				   guint             index_,
				   gconstpointer     data,
				   guint             len);
GArray* g_array_set_size          (GArray           *array,
				   guint             length);
GArray* g_array_remove_index      (GArray           *array,
				   guint             index_);
GArray* g_array_remove_index_fast (GArray           *array,
				   guint             index_);
GArray* g_array_remove_range      (GArray           *array,
				   guint             index_,
				   guint             length);
void    g_array_sort              (GArray           *array,
				   GCompareFunc      compare_func);
void    g_array_sort_with_data    (GArray           *array,
				   GCompareDataFunc  compare_func,
				   gpointer          user_data);
GPtrArray* g_ptr_array_new                (void);
GPtrArray* g_ptr_array_sized_new          (guint             reserved_size);
gpointer*  g_ptr_array_free               (GPtrArray        *array,
					   gboolean          free_seg);
void       g_ptr_array_set_size           (GPtrArray        *array,
					   gint              length);
gpointer   g_ptr_array_remove_index       (GPtrArray        *array,
					   guint             index_);
gpointer   g_ptr_array_remove_index_fast  (GPtrArray        *array,
					   guint             index_);
gboolean   g_ptr_array_remove             (GPtrArray        *array,
					   gpointer          data);
gboolean   g_ptr_array_remove_fast        (GPtrArray        *array,
					   gpointer          data);
void       g_ptr_array_remove_range       (GPtrArray        *array,
					   guint             index_,
					   guint             length);
void       g_ptr_array_add                (GPtrArray        *array,
					   gpointer          data);
void       g_ptr_array_sort               (GPtrArray        *array,
					   GCompareFunc      compare_func);
void       g_ptr_array_sort_with_data     (GPtrArray        *array,
					   GCompareDataFunc  compare_func,
					   gpointer          user_data);
void       g_ptr_array_foreach            (GPtrArray        *array,
					   GFunc             func,
					   gpointer          user_data);
GByteArray* g_byte_array_new               (void);
GByteArray* g_byte_array_sized_new         (guint             reserved_size);
guint8*     g_byte_array_free              (GByteArray       *array,
					    gboolean          free_segment);
GByteArray* g_byte_array_append            (GByteArray       *array,
					    const guint8     *data,
					    guint             len);
GByteArray* g_byte_array_prepend           (GByteArray       *array,
					    const guint8     *data,
					    guint             len);
GByteArray* g_byte_array_set_size          (GByteArray       *array,
					    guint             length);
GByteArray* g_byte_array_remove_index      (GByteArray       *array,
					    guint             index_);
GByteArray* g_byte_array_remove_index_fast (GByteArray       *array,
					    guint             index_);
GByteArray* g_byte_array_remove_range      (GByteArray       *array,
					    guint             index_,
					    guint             length);
void        g_byte_array_sort              (GByteArray       *array,
					    GCompareFunc      compare_func);
void        g_byte_array_sort_with_data    (GByteArray       *array,
					    GCompareDataFunc  compare_func,
					    gpointer          user_data);
GAsyncQueue*  g_async_queue_new                (void);
void          g_async_queue_lock               (GAsyncQueue *queue);
void          g_async_queue_unlock             (GAsyncQueue *queue);
GAsyncQueue*  g_async_queue_ref                (GAsyncQueue *queue);
void          g_async_queue_unref              (GAsyncQueue *queue);
void          g_async_queue_push               (GAsyncQueue *queue,
                                                gpointer     data);
void          g_async_queue_push_unlocked      (GAsyncQueue *queue,
                                                gpointer     data);
gpointer      g_async_queue_pop                (GAsyncQueue *queue);
gpointer      g_async_queue_pop_unlocked       (GAsyncQueue *queue);
gpointer      g_async_queue_try_pop            (GAsyncQueue *queue);
gpointer      g_async_queue_try_pop_unlocked   (GAsyncQueue *queue);
gpointer      g_async_queue_timed_pop          (GAsyncQueue *queue,
                                                GTimeVal    *end_time);
gpointer      g_async_queue_timed_pop_unlocked (GAsyncQueue *queue,
                                                GTimeVal    *end_time);
gint          g_async_queue_length             (GAsyncQueue *queue);
gint          g_async_queue_length_unlocked    (GAsyncQueue *queue);


gint     g_atomic_int_exchange_and_add         (gint     *atomic, 
						gint      val);
void     g_atomic_int_add                      (gint     *atomic, 
						gint      val);
gboolean g_atomic_int_compare_and_exchange     (gint     *atomic, 
						gint      oldval, 
						gint      newval);
gboolean g_atomic_pointer_compare_and_exchange (gpointer *atomic, 
						gpointer  oldval, 
						gpointer  newval);

gint     g_atomic_int_get                      (volatile gint  	  *atomic);
void     g_atomic_int_set                      (volatile gint  	  *atomic, gint               newval);
gpointer g_atomic_pointer_get                  (volatile gpointer *atomic);
void     g_atomic_pointer_set                  (volatile gpointer *atomic, gpointer           newval);

GCache*  g_cache_new           (GCacheNewFunc      value_new_func,
                                GCacheDestroyFunc  value_destroy_func,
                                GCacheDupFunc      key_dup_func,
                                GCacheDestroyFunc  key_destroy_func,
                                GHashFunc          hash_key_func,
                                GHashFunc          hash_value_func,
                                GEqualFunc         key_equal_func);
void     g_cache_destroy       (GCache            *cache);
gpointer g_cache_insert        (GCache            *cache,
                                gpointer           key);
void     g_cache_remove        (GCache            *cache,
                                gconstpointer      value);
void     g_cache_key_foreach   (GCache            *cache,
                                GHFunc             func,
                                gpointer           user_data);
void     g_cache_value_foreach (GCache            *cache,
                                GHFunc             func,
                                gpointer           user_data);

GCompletion* g_completion_new           (GCompletionFunc func);
void         g_completion_add_items     (GCompletion*    cmp,
                                         GList*          items);
void         g_completion_remove_items  (GCompletion*    cmp,
                                         GList*          items);
void         g_completion_clear_items   (GCompletion*    cmp);
GList*       g_completion_complete      (GCompletion*    cmp,
                                         const gchar*    prefix,
                                         gchar**         new_prefix);
GList*       g_completion_complete_utf8 (GCompletion  *cmp,
                                         const gchar*    prefix,
                                         gchar**         new_prefix);
void         g_completion_set_compare   (GCompletion *cmp,
				         GCompletionStrncmpFunc strncmp_func);
void         g_completion_free          (GCompletion*    cmp);

gchar* g_locale_to_utf8   (const gchar  *opsysstring,
			   gssize        len,            
			   gsize        *bytes_read,     
			   gsize        *bytes_written,  
			   GError      **error) G_GNUC_MALLOC;
gchar* g_locale_from_utf8 (const gchar  *utf8string,
			   gssize        len,            
			   gsize        *bytes_read,     
			   gsize        *bytes_written,  
			   GError      **error) G_GNUC_MALLOC;

gchar* g_filename_to_utf8   (const gchar  *opsysstring,
			     gssize        len,            
			     gsize        *bytes_read,     
			     gsize        *bytes_written,  
			     GError      **error) G_GNUC_MALLOC;
gchar* g_filename_from_utf8 (const gchar  *utf8string,
			     gssize        len,            
			     gsize        *bytes_read,     
			     gsize        *bytes_written,  
			     GError      **error) G_GNUC_MALLOC;

gchar *g_filename_from_uri (const gchar *uri,
			    gchar      **hostname,
			    GError     **error) G_GNUC_MALLOC;
  
gchar *g_filename_to_uri   (const gchar *filename,
			    const gchar *hostname,
			    GError     **error) G_GNUC_MALLOC;
gchar *g_filename_display_name (const gchar *filename) G_GNUC_MALLOC;
gboolean g_get_filename_charsets (G_CONST_RETURN gchar ***charsets);

gchar *g_filename_display_basename (const gchar *filename) G_GNUC_MALLOC;

gchar **g_uri_list_extract_uris (const gchar *uri_list) G_GNUC_MALLOC;

void      g_datalist_init                (GData          **datalist);
void      g_datalist_clear               (GData          **datalist);
gpointer  g_datalist_id_get_data         (GData          **datalist,
                                          GQuark           key_id);
void      g_datalist_id_set_data_full    (GData          **datalist,
                                          GQuark           key_id,
                                          gpointer         data,
                                          GDestroyNotify   destroy_func);
gpointer  g_datalist_id_remove_no_notify (GData          **datalist,
                                          GQuark           key_id);
void      g_datalist_foreach             (GData          **datalist,
                                          GDataForeachFunc func,
                                          gpointer         user_data);
void      g_dataset_destroy             (gconstpointer    dataset_location);
gpointer  g_dataset_id_get_data         (gconstpointer    dataset_location,
                                         GQuark           key_id);
void      g_dataset_id_set_data_full    (gconstpointer    dataset_location,
                                         GQuark           key_id,
                                         gpointer         data,
                                         GDestroyNotify   destroy_func);
gpointer  g_dataset_id_remove_no_notify (gconstpointer    dataset_location,
                                         GQuark           key_id);
void      g_dataset_foreach             (gconstpointer    dataset_location,
                                         GDataForeachFunc func,
                                         gpointer         user_data);

void     g_datalist_set_flags           (GData            **datalist, guint              flags);
void     g_datalist_unset_flags         (GData            **datalist, guint              flags);
guint    g_datalist_get_flags           (GData            **datalist);

GDate*       g_date_new                   (void);
GDate*       g_date_new_dmy               (GDateDay     day,
                                           GDateMonth   month,
                                           GDateYear    year);
GDate*       g_date_new_julian            (guint32      julian_day);
void         g_date_free                  (GDate       *date);
gboolean     g_date_valid                 (const GDate *date);
gboolean     g_date_valid_day             (GDateDay     day) G_GNUC_CONST;
gboolean     g_date_valid_month           (GDateMonth month) G_GNUC_CONST;
gboolean     g_date_valid_year            (GDateYear  year) G_GNUC_CONST;
gboolean     g_date_valid_weekday         (GDateWeekday weekday) G_GNUC_CONST;
gboolean     g_date_valid_julian          (guint32 julian_date) G_GNUC_CONST;
gboolean     g_date_valid_dmy             (GDateDay     day,
                                           GDateMonth   month,
                                           GDateYear    year) G_GNUC_CONST;
GDateWeekday g_date_get_weekday           (const GDate *date);
GDateMonth   g_date_get_month             (const GDate *date);
GDateYear    g_date_get_year              (const GDate *date);
GDateDay     g_date_get_day               (const GDate *date);
guint32      g_date_get_julian            (const GDate *date);
guint        g_date_get_day_of_year       (const GDate *date);
guint        g_date_get_monday_week_of_year (const GDate *date);
guint        g_date_get_sunday_week_of_year (const GDate *date);
guint        g_date_get_iso8601_week_of_year (const GDate *date);
void         g_date_clear                 (GDate       *date,
                                           guint        n_dates);
void         g_date_set_parse             (GDate       *date,
                                           const gchar *str);
void         g_date_set_time              (GDate       *date,
                                           GTime        time_);
void         g_date_set_month             (GDate       *date,
                                           GDateMonth   month);
void         g_date_set_day               (GDate       *date,
                                           GDateDay     day);
void         g_date_set_year              (GDate       *date,
                                           GDateYear    year);
void         g_date_set_dmy               (GDate       *date,
                                           GDateDay     day,
                                           GDateMonth   month,
                                           GDateYear    y);
void         g_date_set_julian            (GDate       *date,
                                           guint32      julian_date);
gboolean     g_date_is_first_of_month     (const GDate *date);
gboolean     g_date_is_last_of_month      (const GDate *date);
void         g_date_add_days              (GDate       *date,
                                           guint        n_days);
void         g_date_subtract_days         (GDate       *date,
                                           guint        n_days);
void         g_date_add_months            (GDate       *date,
                                           guint        n_months);
void         g_date_subtract_months       (GDate       *date,
                                           guint        n_months);
void         g_date_add_years             (GDate       *date,
                                           guint        n_years);
void         g_date_subtract_years        (GDate       *date,
                                           guint        n_years);
gboolean     g_date_is_leap_year          (GDateYear    year) G_GNUC_CONST;
guint8       g_date_get_days_in_month     (GDateMonth   month,
                                           GDateYear    year) G_GNUC_CONST;
guint8       g_date_get_monday_weeks_in_year  (GDateYear    year) G_GNUC_CONST;
guint8       g_date_get_sunday_weeks_in_year  (GDateYear    year) G_GNUC_CONST;
gint         g_date_days_between          (const GDate *date1,
					   const GDate *date2);
gint         g_date_compare               (const GDate *lhs,
                                           const GDate *rhs);
void         g_date_to_struct_tm          (const GDate *date,
                                           struct tm   *tm);

void         g_date_clamp                 (GDate *date,
					   const GDate *min_date,
					   const GDate *max_date);
void         g_date_order                 (GDate *date1, GDate *date2);
gsize        g_date_strftime              (gchar       *s,
                                           gsize        slen,
                                           const gchar *format,
                                           const GDate *date);


GDir    *                g_dir_open           (const gchar  *path,
					       guint         flags,
					       GError      **error);
G_CONST_RETURN gchar    *g_dir_read_name      (GDir         *dir);
void                     g_dir_rewind         (GDir         *dir);
void                     g_dir_close          (GDir         *dir);

GError*  g_error_new           (GQuark         domain,
                                gint           code,
                                const gchar   *format,
                                ...) G_GNUC_PRINTF (3, 4);

GError*  g_error_new_literal   (GQuark         domain,
                                gint           code,
                                const gchar   *message);

void     g_error_free          (GError        *error);
GError*  g_error_copy          (const GError  *error);
gboolean g_error_matches       (const GError  *error,
                                GQuark         domain,
                                gint           code);
void     g_set_error           (GError       **err,
                                GQuark         domain,
                                gint           code,
                                const gchar   *format,
                                ...) G_GNUC_PRINTF (4, 5);
void     g_propagate_error     (GError       **dest, GError        *src);
void     g_clear_error         (GError       **err);

GQuark     g_file_error_quark      (void);
GFileError g_file_error_from_errno (gint err_no);
gboolean g_file_test         (const gchar  *filename,
                              GFileTest     test);
gboolean g_file_get_contents (const gchar  *filename,
                              gchar       **contents,
                              gsize        *length,    
                              GError      **error);
gchar   *g_file_read_link    (const gchar  *filename,
			      GError      **error);
gint    g_mkstemp            (gchar        *tmpl);
gint    g_file_open_tmp      (const gchar  *tmpl,
			      gchar       **name_used,
			      GError      **error);

gchar *g_build_path     (const gchar *separator,
			 const gchar *first_element,
			 ...);
gchar *g_build_filename (const gchar *first_element, ...);

GHashTable* g_hash_table_new		   (GHashFunc	    hash_func,
					    GEqualFunc	    key_equal_func);
GHashTable* g_hash_table_new_full      	   (GHashFunc	    hash_func,
					    GEqualFunc	    key_equal_func,
					    GDestroyNotify  key_destroy_func,
					    GDestroyNotify  value_destroy_func);
void	    g_hash_table_destroy	   (GHashTable	   *hash_table);
void	    g_hash_table_insert		   (GHashTable	   *hash_table,
					    gpointer	    key,
					    gpointer	    value);
void        g_hash_table_replace           (GHashTable     *hash_table,
					    gpointer	    key,
					    gpointer	    value);
gboolean    g_hash_table_remove		   (GHashTable	   *hash_table,
					    gconstpointer   key);
gboolean    g_hash_table_steal             (GHashTable     *hash_table,
					    gconstpointer   key);
gpointer    g_hash_table_lookup		   (GHashTable	   *hash_table,
					    gconstpointer   key);
gboolean    g_hash_table_lookup_extended   (GHashTable	   *hash_table,
					    gconstpointer   lookup_key,
					    gpointer	   *orig_key,
					    gpointer	   *value);
void	    g_hash_table_foreach	   (GHashTable	   *hash_table,
					    GHFunc	    func,
					    gpointer	    user_data);
gpointer    g_hash_table_find	   (GHashTable	   *hash_table,
					    GHRFunc	    predicate,
					    gpointer	    user_data);
guint	    g_hash_table_foreach_remove	   (GHashTable	   *hash_table,
					    GHRFunc	    func,
					    gpointer	    user_data);
guint	    g_hash_table_foreach_steal	   (GHashTable	   *hash_table,
					    GHRFunc	    func,
					    gpointer	    user_data);
guint	    g_hash_table_size		   (GHashTable	   *hash_table);

GHashTable* g_hash_table_ref   		   (GHashTable 	   *hash_table);
void        g_hash_table_unref             (GHashTable     *hash_table);

gboolean g_str_equal (gconstpointer  v,
                      gconstpointer  v2);
guint    g_str_hash  (gconstpointer  v);

gboolean g_int_equal (gconstpointer  v,
                      gconstpointer  v2);
guint    g_int_hash  (gconstpointer  v);
guint    g_direct_hash  (gconstpointer  v) G_GNUC_CONST;
gboolean g_direct_equal (gconstpointer  v, gconstpointer  v2) G_GNUC_CONST;

void	 g_hook_list_init		(GHookList		*hook_list,
					 guint			 hook_size);
void	 g_hook_list_clear		(GHookList		*hook_list);
GHook*	 g_hook_alloc			(GHookList		*hook_list);
void	 g_hook_free			(GHookList		*hook_list,
					 GHook			*hook);
GHook *	 g_hook_ref			(GHookList		*hook_list,
					 GHook			*hook);
void	 g_hook_unref			(GHookList		*hook_list,
					 GHook			*hook);
gboolean g_hook_destroy			(GHookList		*hook_list,
					 gulong			 hook_id);
void	 g_hook_destroy_link		(GHookList		*hook_list,
					 GHook			*hook);
void	 g_hook_prepend			(GHookList		*hook_list,
					 GHook			*hook);
void	 g_hook_insert_before		(GHookList		*hook_list,
					 GHook			*sibling,
					 GHook			*hook);
void	 g_hook_insert_sorted		(GHookList		*hook_list,
					 GHook			*hook,
					 GHookCompareFunc	 func);
GHook*	 g_hook_get			(GHookList		*hook_list,
					 gulong			 hook_id);
GHook*	 g_hook_find			(GHookList		*hook_list,
					 gboolean		 need_valids,
					 GHookFindFunc		 func,
					 gpointer		 data);
GHook*	 g_hook_find_data		(GHookList		*hook_list,
					 gboolean		 need_valids,
					 gpointer		 data);
GHook*	 g_hook_find_func		(GHookList		*hook_list,
					 gboolean		 need_valids,
					 gpointer		 func);
GHook*	 g_hook_find_func_data		(GHookList		*hook_list,
					 gboolean		 need_valids,
					 gpointer		 func,
					 gpointer		 data);
GHook*	 g_hook_first_valid		(GHookList		*hook_list,
					 gboolean		 may_be_in_call);
GHook*	 g_hook_next_valid		(GHookList		*hook_list,
					 GHook			*hook,
					 gboolean		 may_be_in_call);
gint	 g_hook_compare_ids		(GHook			*new_hook,
					 GHook			*sibling);
void	 g_hook_list_invoke		(GHookList		*hook_list,
					 gboolean		 may_recurse);
void	 g_hook_list_invoke_check	(GHookList		*hook_list,
					 gboolean		 may_recurse);
void	 g_hook_list_marshal		(GHookList		*hook_list,
					 gboolean		 may_recurse,
					 GHookMarshaller	 marshaller,
					 gpointer		 marshal_data);
void	 g_hook_list_marshal_check	(GHookList *hook_list, gboolean		 may_recurse, GHookCheckMarshaller	 marshaller, gpointer		 marshal_data);
void        g_io_channel_init   (GIOChannel    *channel);
GIOChannel *g_io_channel_ref    (GIOChannel    *channel);
void        g_io_channel_unref  (GIOChannel    *channel);
GIOStatus g_io_channel_shutdown (GIOChannel      *channel,
				 gboolean         flush,
				 GError         **err);
guint     g_io_add_watch_full   (GIOChannel      *channel,
				 gint             priority,
				 GIOCondition     condition,
				 GIOFunc          func,
				 gpointer         user_data,
				 GDestroyNotify   notify);
GSource * g_io_create_watch     (GIOChannel      *channel,
				 GIOCondition     condition);
guint     g_io_add_watch        (GIOChannel      *channel,
				 GIOCondition     condition,
				 GIOFunc          func,
				 gpointer         user_data);
void                  g_io_channel_set_buffer_size      (GIOChannel   *channel,
							 gsize         size);
gsize                 g_io_channel_get_buffer_size      (GIOChannel   *channel);
GIOCondition          g_io_channel_get_buffer_condition (GIOChannel   *channel);
GIOStatus             g_io_channel_set_flags            (GIOChannel   *channel,
							 GIOFlags      flags,
							 GError      **error);
GIOFlags              g_io_channel_get_flags            (GIOChannel   *channel);
void                  g_io_channel_set_line_term        (GIOChannel   *channel,
							 const gchar  *line_term,
							 gint          length);
G_CONST_RETURN gchar* g_io_channel_get_line_term        (GIOChannel   *channel,
							 gint         *length);
void		      g_io_channel_set_buffered		(GIOChannel   *channel,
							 gboolean      buffered);
gboolean	      g_io_channel_get_buffered		(GIOChannel   *channel);
GIOStatus             g_io_channel_set_encoding         (GIOChannel   *channel,
							 const gchar  *encoding,
							 GError      **error);
G_CONST_RETURN gchar* g_io_channel_get_encoding         (GIOChannel   *channel);
void                  g_io_channel_set_close_on_unref	(GIOChannel   *channel,
							 gboolean      do_close);
gboolean              g_io_channel_get_close_on_unref	(GIOChannel   *channel);


GIOStatus   g_io_channel_flush            (GIOChannel   *channel,
					   GError      **error);
GIOStatus   g_io_channel_read_line        (GIOChannel   *channel,
					   gchar       **str_return,
					   gsize        *length,
					   gsize        *terminator_pos,
					   GError      **error);
GIOStatus   g_io_channel_read_line_string (GIOChannel   *channel,
					   GString      *buffer,
					   gsize        *terminator_pos,
					   GError      **error);
GIOStatus   g_io_channel_read_to_end      (GIOChannel   *channel,
					   gchar       **str_return,
					   gsize        *length,
					   GError      **error);
GIOStatus   g_io_channel_read_chars       (GIOChannel   *channel,
					   gchar        *buf,
					   gsize         count,
					   gsize        *bytes_read,
					   GError      **error);
GIOStatus   g_io_channel_read_unichar     (GIOChannel   *channel,
					   gunichar     *thechar,
					   GError      **error);
GIOStatus   g_io_channel_write_chars      (GIOChannel   *channel,
					   const gchar  *buf,
					   gssize        count,
					   gsize        *bytes_written,
					   GError      **error);
GIOStatus   g_io_channel_write_unichar    (GIOChannel   *channel,
					   gunichar      thechar,
					   GError      **error);
GIOStatus   g_io_channel_seek_position    (GIOChannel   *channel,
					   gint64        offset,
					   GSeekType     type,
					   GError      **error);
GIOChannel* g_io_channel_new_file         (const gchar  *filename,
					   const gchar  *mode,
					   GError      **error);
GQuark          g_io_channel_error_quark      (void);
GIOChannelError g_io_channel_error_from_errno (gint en);

GKeyFile *g_key_file_new                    (void);
void      g_key_file_free                   (GKeyFile             *key_file);
void      g_key_file_set_list_separator     (GKeyFile             *key_file,
					     gchar                 separator);
gboolean  g_key_file_load_from_file         (GKeyFile             *key_file,
					     const gchar          *file,
					     GKeyFileFlags         flags,
					     GError              **error);
gboolean  g_key_file_load_from_data         (GKeyFile             *key_file,
					     const gchar          *data,
					     gsize                 length,
					     GKeyFileFlags         flags,
					     GError              **error);
gboolean g_key_file_load_from_data_dirs    (GKeyFile             *key_file,
					     const gchar          *file,
					     gchar               **full_path,
					     GKeyFileFlags         flags,
					     GError              **error);
gchar    *g_key_file_to_data                (GKeyFile             *key_file,
					     gsize                *length,
					     GError              **error) G_GNUC_MALLOC;
gchar    *g_key_file_get_start_group        (GKeyFile             *key_file) G_GNUC_MALLOC;
gchar   **g_key_file_get_groups             (GKeyFile             *key_file,
					     gsize                *length) G_GNUC_MALLOC;
gchar   **g_key_file_get_keys               (GKeyFile             *key_file,
					     const gchar          *group_name,
					     gsize                *length,
					     GError              **error) G_GNUC_MALLOC;
gboolean  g_key_file_has_group              (GKeyFile             *key_file,
					     const gchar          *group_name);
gboolean  g_key_file_has_key                (GKeyFile             *key_file,
					     const gchar          *group_name,
					     const gchar          *key,
					     GError              **error);
gchar    *g_key_file_get_value              (GKeyFile             *key_file,
					     const gchar          *group_name,
					     const gchar          *key,
					     GError              **error) G_GNUC_MALLOC;
void      g_key_file_set_value              (GKeyFile             *key_file,
					     const gchar          *group_name,
					     const gchar          *key,
					     const gchar          *value);
gchar    *g_key_file_get_string             (GKeyFile             *key_file,
					     const gchar          *group_name,
					     const gchar          *key,
					     GError              **error) G_GNUC_MALLOC;
void      g_key_file_set_string             (GKeyFile             *key_file,
					     const gchar          *group_name,
					     const gchar          *key,
					     const gchar          *string);
gchar    *g_key_file_get_locale_string      (GKeyFile             *key_file,
					     const gchar          *group_name,
					     const gchar          *key,
					     const gchar          *locale,
					     GError              **error) G_GNUC_MALLOC;
void      g_key_file_set_locale_string      (GKeyFile             *key_file,
					     const gchar          *group_name,
					     const gchar          *key,
					     const gchar          *locale,
					     const gchar          *string);
gboolean  g_key_file_get_boolean            (GKeyFile             *key_file,
					     const gchar          *group_name,
					     const gchar          *key,
					     GError              **error);
void      g_key_file_set_boolean            (GKeyFile             *key_file,
					     const gchar          *group_name,
					     const gchar          *key,
					     gboolean              value);
gint      g_key_file_get_integer            (GKeyFile             *key_file,
					     const gchar          *group_name,
					     const gchar          *key,
					     GError              **error);
void      g_key_file_set_integer            (GKeyFile             *key_file,
					     const gchar          *group_name,
					     const gchar          *key,
					     gint                  value);
gchar   **g_key_file_get_string_list        (GKeyFile             *key_file,
					     const gchar          *group_name,
					     const gchar          *key,
					     gsize                *length,
					     GError              **error) G_GNUC_MALLOC;
void      g_key_file_set_string_list        (GKeyFile             *key_file,
					     const gchar          *group_name,
					     const gchar          *key,
					     const gchar * const   list[],
					     gsize                 length);
gchar   **g_key_file_get_locale_string_list (GKeyFile             *key_file,
					     const gchar          *group_name,
					     const gchar          *key,
					     const gchar          *locale,
					     gsize                *length,
					     GError              **error) G_GNUC_MALLOC;
void      g_key_file_set_locale_string_list (GKeyFile             *key_file,
					     const gchar          *group_name,
					     const gchar          *key,
					     const gchar          *locale,
					     const gchar * const   list[],
					     gsize                 length);
gboolean *g_key_file_get_boolean_list       (GKeyFile             *key_file,
					     const gchar          *group_name,
					     const gchar          *key,
					     gsize                *length,
					     GError              **error) G_GNUC_MALLOC;
void      g_key_file_set_boolean_list       (GKeyFile             *key_file,
					     const gchar          *group_name,
					     const gchar          *key,
					     gboolean              list[],
					     gsize                 length);
gint     *g_key_file_get_integer_list       (GKeyFile             *key_file,
					     const gchar          *group_name,
					     const gchar          *key,
					     gsize                *length,
					     GError              **error) G_GNUC_MALLOC;
void      g_key_file_set_integer_list       (GKeyFile             *key_file,
					     const gchar          *group_name,
					     const gchar          *key,
					     gint                  list[],
					     gsize                 length);
void      g_key_file_set_comment            (GKeyFile             *key_file,
                                             const gchar          *group_name,
                                             const gchar          *key,
                                             const gchar          *comment,
                                             GError              **error);
gchar    *g_key_file_get_comment            (GKeyFile             *key_file,
                                             const gchar          *group_name,
                                             const gchar          *key,
                                             GError              **error) G_GNUC_MALLOC;

void      g_key_file_remove_comment         (GKeyFile             *key_file,
                                             const gchar          *group_name,
                                             const gchar          *key,
					     GError              **error);
void      g_key_file_remove_key             (GKeyFile             *key_file,
					     const gchar          *group_name,
					     const gchar          *key,
					     GError              **error);
void      g_key_file_remove_group           (GKeyFile             *key_file, const gchar          *group_name, GError              **error);

void     g_list_push_allocator (GAllocator       *allocator);
void     g_list_pop_allocator  (void);
GList*   g_list_alloc          (void);
void     g_list_free           (GList            *list);
void     g_list_free_1         (GList            *list);
GList*   g_list_append         (GList            *list,
				gpointer          data);
GList*   g_list_prepend        (GList            *list,
				gpointer          data);
GList*   g_list_insert         (GList            *list,
				gpointer          data,
				gint              position);
GList*   g_list_insert_sorted  (GList            *list,
				gpointer          data,
				GCompareFunc      func);
GList*   g_list_insert_before  (GList            *list,
				GList            *sibling,
				gpointer          data);
GList*   g_list_concat         (GList            *list1,
				GList            *list2);
GList*   g_list_remove         (GList            *list,
				gconstpointer     data);
GList*   g_list_remove_all     (GList            *list,
				gconstpointer     data);
GList*   g_list_remove_link    (GList            *list,
				GList            *llink);
GList*   g_list_delete_link    (GList            *list,
				GList            *link_);
GList*   g_list_reverse        (GList            *list);
GList*   g_list_copy           (GList            *list);
GList*   g_list_nth            (GList            *list,
				guint             n);
GList*   g_list_nth_prev       (GList            *list,
				guint             n);
GList*   g_list_find           (GList            *list,
				gconstpointer     data);
GList*   g_list_find_custom    (GList            *list,
				gconstpointer     data,
				GCompareFunc      func);
gint     g_list_position       (GList            *list,
				GList            *llink);
gint     g_list_index          (GList            *list,
				gconstpointer     data);
GList*   g_list_last           (GList            *list);
GList*   g_list_first          (GList            *list);
guint    g_list_length         (GList            *list);
void     g_list_foreach        (GList            *list,
				GFunc             func,
				gpointer          user_data);
GList*   g_list_sort           (GList            *list,
				GCompareFunc      compare_func);
GList*   g_list_sort_with_data (GList            *list,
				GCompareDataFunc  compare_func,
				gpointer          user_data);
gpointer g_list_nth_data       (GList            *list, guint             n);

GMainContext *g_main_context_new       (void);
GMainContext *g_main_context_ref       (GMainContext *context);
void          g_main_context_unref     (GMainContext *context);
GMainContext *g_main_context_default   (void);

gboolean      g_main_context_iteration (GMainContext *context,
					gboolean      may_block);
gboolean      g_main_context_pending   (GMainContext *context);
GSource      *g_main_context_find_source_by_id              (GMainContext *context,
							     guint         source_id);
GSource      *g_main_context_find_source_by_user_data       (GMainContext *context,
							     gpointer      user_data);
GSource      *g_main_context_find_source_by_funcs_user_data (GMainContext *context,
 							     GSourceFuncs *funcs,
							     gpointer      user_data);
void     g_main_context_wakeup  (GMainContext *context);
gboolean g_main_context_acquire (GMainContext *context);
void     g_main_context_release (GMainContext *context);
gboolean g_main_context_wait    (GMainContext *context,
				 GCond        *cond,
				 GMutex       *mutex);

gboolean g_main_context_prepare  (GMainContext *context,
				  gint         *priority);
gint     g_main_context_query    (GMainContext *context,
				  gint          max_priority,
				  gint         *timeout_,
				  GPollFD      *fds,
				  gint          n_fds);
gint     g_main_context_check    (GMainContext *context,
				  gint          max_priority,
				  GPollFD      *fds,
				  gint          n_fds);
void     g_main_context_dispatch (GMainContext *context);

void      g_main_context_set_poll_func (GMainContext *context,
					GPollFunc     func);
GPollFunc g_main_context_get_poll_func (GMainContext *context);
void g_main_context_add_poll      (GMainContext *context,
				   GPollFD      *fd,
				   gint          priority);
void g_main_context_remove_poll   (GMainContext *context,
				   GPollFD      *fd);

int g_main_depth (void);
GMainLoop *g_main_loop_new        (GMainContext *context,
			    	   gboolean      is_running);
void       g_main_loop_run        (GMainLoop    *loop);
void       g_main_loop_quit       (GMainLoop    *loop);
GMainLoop *g_main_loop_ref        (GMainLoop    *loop);
void       g_main_loop_unref      (GMainLoop    *loop);
gboolean   g_main_loop_is_running (GMainLoop    *loop);
GMainContext *g_main_loop_get_context (GMainLoop    *loop);
GSource *g_source_new             (GSourceFuncs   *source_funcs,
				   guint           struct_size);
GSource *g_source_ref             (GSource        *source);
void     g_source_unref           (GSource        *source);

guint    g_source_attach          (GSource        *source,
				   GMainContext   *context);
void     g_source_destroy         (GSource        *source);

void     g_source_set_priority    (GSource        *source,
				   gint            priority);
gint     g_source_get_priority    (GSource        *source);
void     g_source_set_can_recurse (GSource        *source,
				   gboolean        can_recurse);
gboolean g_source_get_can_recurse (GSource        *source);
guint    g_source_get_id          (GSource        *source);

GMainContext *g_source_get_context (GSource       *source);

void g_source_set_callback          (GSource              *source,
				     GSourceFunc           func,
				     gpointer              data,
				     GDestroyNotify        notify);
void g_source_set_callback_indirect (GSource              *source,
				     gpointer              callback_data,
				     GSourceCallbackFuncs *callback_funcs);

void     g_source_add_poll         (GSource        *source,
				    GPollFD        *fd);
void     g_source_remove_poll      (GSource        *source,
				    GPollFD        *fd);

void     g_source_get_current_time (GSource        *source, GTimeVal       *timeval);
GSource *g_idle_source_new        (void);
GSource *g_child_watch_source_new (GPid pid);
GSource *g_timeout_source_new     (guint interval);
void g_get_current_time		        (GTimeVal	*result);
gboolean g_source_remove                     (guint          tag);
gboolean g_source_remove_by_user_data        (gpointer       user_data);
gboolean g_source_remove_by_funcs_user_data  (GSourceFuncs  *funcs,
					      gpointer       user_data);
guint    g_timeout_add_full     (gint            priority,
				 guint           interval,
				 GSourceFunc     function,
				 gpointer        data,
				 GDestroyNotify  notify);
guint    g_timeout_add          (guint           interval,
				 GSourceFunc     function,
				 gpointer        data);
guint    g_child_watch_add_full (gint            priority,
				 GPid            pid,
				 GChildWatchFunc function,
				 gpointer        data,
				 GDestroyNotify  notify);
guint    g_child_watch_add      (GPid            pid,
				 GChildWatchFunc function,
				 gpointer        data);
guint    g_idle_add             (GSourceFunc     function,
				 gpointer        data);
guint    g_idle_add_full        (gint            priority,
				 GSourceFunc     function,
				 gpointer        data,
				 GDestroyNotify  notify);

GMarkupParseContext *g_markup_parse_context_new   (const GMarkupParser *parser,
                                                   GMarkupParseFlags    flags,
                                                   gpointer             user_data,
                                                   GDestroyNotify       user_data_dnotify);
void                 g_markup_parse_context_free  (GMarkupParseContext *context);
gboolean             g_markup_parse_context_parse (GMarkupParseContext *context,
                                                   const gchar         *text,
                                                   gssize               text_len,  
                                                   GError             **error);
                                                   
gboolean             g_markup_parse_context_end_parse (GMarkupParseContext *context,
                                                       GError             **error);
G_CONST_RETURN gchar *g_markup_parse_context_get_element (GMarkupParseContext *context);

void                 g_markup_parse_context_get_position (GMarkupParseContext *context,
                                                          gint                *line_number,
                                                          gint                *char_number);

gchar* g_markup_escape_text (const gchar *text,
                             gssize       length);  

gchar *g_markup_printf_escaped (const char *format, ...) G_GNUC_PRINTF (1, 2);
gchar *g_markup_vprintf_escaped (const char *format, va_list     args);

gpointer g_malloc         (gulong	 n_bytes) G_GNUC_MALLOC;
gpointer g_malloc0        (gulong	 n_bytes) G_GNUC_MALLOC;
gpointer g_realloc        (gpointer	 mem,
			   gulong	 n_bytes);
void	 g_free	          (gpointer	 mem);
gpointer g_try_malloc     (gulong	 n_bytes) G_GNUC_MALLOC;
gpointer g_try_realloc    (gpointer	 mem, gulong	 n_bytes);

GMemChunk* g_mem_chunk_new     (const gchar *name,
				gint         atom_size,
				gulong       area_size,
				gint         type);
void       g_mem_chunk_destroy (GMemChunk   *mem_chunk);
gpointer   g_mem_chunk_alloc   (GMemChunk   *mem_chunk);
gpointer   g_mem_chunk_alloc0  (GMemChunk   *mem_chunk);
void       g_mem_chunk_free    (GMemChunk   *mem_chunk,
				gpointer     mem);
void       g_mem_chunk_clean   (GMemChunk   *mem_chunk);
void       g_mem_chunk_reset   (GMemChunk   *mem_chunk);
void       g_mem_chunk_print   (GMemChunk   *mem_chunk);
void       g_mem_chunk_info    (void);
void	   g_blow_chunks (void);
GAllocator* g_allocator_new   (const gchar  *name, guint         n_preallocs);
void        g_allocator_free  (GAllocator   *allocator);

gsize	g_printf_string_upper_bound (const gchar* format, va_list	  args);

guint           g_log_set_handler       (const gchar    *log_domain,
                                         GLogLevelFlags  log_levels,
                                         GLogFunc        log_func,
                                         gpointer        user_data);
void            g_log_remove_handler    (const gchar    *log_domain,
                                         guint           handler_id);
void            g_log_default_handler   (const gchar    *log_domain,
                                         GLogLevelFlags  log_level,
                                         const gchar    *message,
                                         gpointer        unused_data);
GLogFunc        g_log_set_default_handler (GLogFunc      log_func,
					   gpointer      user_data);
void            g_log                   (const gchar    *log_domain,
                                         GLogLevelFlags  log_level,
                                         const gchar    *format,
                                         ...) G_GNUC_PRINTF (3, 4);
void            g_logv                  (const gchar    *log_domain,
                                         GLogLevelFlags  log_level,
                                         const gchar    *format,
                                         va_list         args);
GLogLevelFlags  g_log_set_fatal_mask    (const gchar    *log_domain,
                                         GLogLevelFlags  fatal_mask);
GLogLevelFlags  g_log_set_always_fatal  (GLogLevelFlags  fatal_mask);

void     g_node_push_allocator  (GAllocator       *allocator);
void     g_node_pop_allocator   (void);
GNode*	 g_node_new		(gpointer	   data);
void	 g_node_destroy		(GNode		  *root);
void	 g_node_unlink		(GNode		  *node);
GNode*   g_node_copy_deep       (GNode            *node,
				 GCopyFunc         copy_func,
				 gpointer          data);
GNode*   g_node_copy            (GNode            *node);
GNode*	 g_node_insert		(GNode		  *parent,
				 gint		   position,
				 GNode		  *node);
GNode*	 g_node_insert_before	(GNode		  *parent,
				 GNode		  *sibling,
				 GNode		  *node);
GNode*   g_node_insert_after    (GNode            *parent,
				 GNode            *sibling,
				 GNode            *node); 
GNode*	 g_node_prepend		(GNode		  *parent,
				 GNode		  *node);
guint	 g_node_n_nodes		(GNode		  *root,
				 GTraverseFlags	   flags);
GNode*	 g_node_get_root	(GNode		  *node);
gboolean g_node_is_ancestor	(GNode		  *node,
				 GNode		  *descendant);
guint	 g_node_depth		(GNode		  *node);
GNode*	 g_node_find		(GNode		  *root,
				 GTraverseType	   order,
				 GTraverseFlags	   flags,
				 gpointer	   data);
void	 g_node_traverse	(GNode		  *root,
				 GTraverseType	   order,
				 GTraverseFlags	   flags,
				 gint		   max_depth,
				 GNodeTraverseFunc func,
				 gpointer	   data);
guint	 g_node_max_height	 (GNode *root);

void	 g_node_children_foreach (GNode		  *node,
				  GTraverseFlags   flags,
				  GNodeForeachFunc func,
				  gpointer	   data);
void	 g_node_reverse_children (GNode		  *node);
guint	 g_node_n_children	 (GNode		  *node);
GNode*	 g_node_nth_child	 (GNode		  *node,
				  guint		   n);
GNode*	 g_node_last_child	 (GNode		  *node);
GNode*	 g_node_find_child	 (GNode		  *node,
				  GTraverseFlags   flags,
				  gpointer	   data);
gint	 g_node_child_position	 (GNode		  *node,
				  GNode		  *child);
gint	 g_node_child_index	 (GNode		  *node,
				  gpointer	   data);

GNode*	 g_node_first_sibling	 (GNode		  *node);
GNode*	 g_node_last_sibling	 (GNode		  *node);

GOptionContext *g_option_context_new              (const gchar         *parameter_string);
void            g_option_context_free             (GOptionContext      *context);
void		g_option_context_set_help_enabled (GOptionContext      *context,
						   gboolean		help_enabled);
gboolean	g_option_context_get_help_enabled (GOptionContext      *context);
void		g_option_context_set_ignore_unknown_options (GOptionContext *context,
							     gboolean	     ignore_unknown);
gboolean        g_option_context_get_ignore_unknown_options (GOptionContext *context);

void            g_option_context_add_main_entries (GOptionContext      *context,
						   const GOptionEntry  *entries,
						   const gchar         *translation_domain);
gboolean        g_option_context_parse            (GOptionContext      *context,
						   gint                *argc,
						   gchar             ***argv,
						   GError             **error);

void          g_option_context_add_group      (GOptionContext *context,
					       GOptionGroup   *group);
void          g_option_context_set_main_group (GOptionContext *context,
					       GOptionGroup   *group);
GOptionGroup *g_option_context_get_main_group (GOptionContext *context);


GOptionGroup *g_option_group_new                    (const gchar        *name,
						     const gchar        *description,
						     const gchar        *help_description,
						     gpointer            user_data,
						     GDestroyNotify      destroy);
void	      g_option_group_set_parse_hooks	    (GOptionGroup       *group,
						     GOptionParseFunc    pre_parse_func,
						     GOptionParseFunc	 post_parse_func);
void	      g_option_group_set_error_hook	    (GOptionGroup       *group,
						     GOptionErrorFunc	 error_func);
void          g_option_group_free                   (GOptionGroup       *group);
void          g_option_group_add_entries            (GOptionGroup       *group,
						     const GOptionEntry *entries);
void          g_option_group_set_translate_func     (GOptionGroup       *group,
						     GTranslateFunc      func,
						     gpointer            data,
						     GDestroyNotify      destroy_notify);
void          g_option_group_set_translation_domain (GOptionGroup       *group,
						     const gchar        *domain);

GPatternSpec* g_pattern_spec_new       (const gchar  *pattern);
void          g_pattern_spec_free      (GPatternSpec *pspec);
gboolean      g_pattern_spec_equal     (GPatternSpec *pspec1,
					GPatternSpec *pspec2);
gboolean      g_pattern_match          (GPatternSpec *pspec,
					guint         string_length,
					const gchar  *string,
					const gchar  *string_reversed);
gboolean      g_pattern_match_string   (GPatternSpec *pspec,
					const gchar  *string);
gboolean      g_pattern_match_simple   (const gchar  *pattern, const gchar  *string);

guint	   g_spaced_primes_closest (guint num) G_GNUC_CONST;

void g_qsort_with_data (gconstpointer pbase, gint             total_elems, gsize            size, GCompareDataFunc compare_func, gpointer         user_data);

GQuark                g_quark_try_string         (const gchar *string);
GQuark                g_quark_from_static_string (const gchar *string);
GQuark                g_quark_from_string        (const gchar *string);
G_CONST_RETURN gchar* g_quark_to_string          (GQuark       quark) G_GNUC_CONST;

GQueue*  g_queue_new            (void);
void     g_queue_free           (GQueue           *queue);
gboolean g_queue_is_empty       (GQueue           *queue);
guint    g_queue_get_length     (GQueue           *queue);
void     g_queue_reverse        (GQueue           *queue);
GQueue * g_queue_copy           (GQueue           *queue);
void     g_queue_foreach        (GQueue           *queue,
				 GFunc             func,
				 gpointer          user_data);
GList *  g_queue_find           (GQueue           *queue,
				 gconstpointer     data);
GList *  g_queue_find_custom    (GQueue           *queue,
				 gconstpointer     data,
				 GCompareFunc      func);
void     g_queue_sort           (GQueue           *queue,
				 GCompareDataFunc  compare_func,
				 gpointer          user_data);

void     g_queue_push_head      (GQueue           *queue,
				 gpointer          data);
void     g_queue_push_tail      (GQueue           *queue,
				 gpointer          data);
void     g_queue_push_nth       (GQueue           *queue,
				 gpointer          data,
				 gint              n);
gpointer g_queue_pop_head       (GQueue           *queue);
gpointer g_queue_pop_tail       (GQueue           *queue);
gpointer g_queue_pop_nth        (GQueue           *queue,
				 guint             n);
gpointer g_queue_peek_head      (GQueue           *queue);
gpointer g_queue_peek_tail      (GQueue           *queue);
gpointer g_queue_peek_nth       (GQueue           *queue,
				 guint             n);
gint     g_queue_index          (GQueue           *queue,
				 gconstpointer     data);
void     g_queue_remove         (GQueue           *queue,
				 gconstpointer     data);
void     g_queue_remove_all     (GQueue           *queue,
				 gconstpointer     data);
void     g_queue_insert_before  (GQueue           *queue,
				 GList            *sibling,
				 gpointer          data);
void     g_queue_insert_after   (GQueue           *queue,
				 GList            *sibling,
				 gpointer          data);
void     g_queue_insert_sorted  (GQueue           *queue,
				 gpointer          data,
				 GCompareDataFunc  func,
				 gpointer          user_data);

void     g_queue_push_head_link (GQueue           *queue,
				 GList            *link_);
void     g_queue_push_tail_link (GQueue           *queue,
				 GList            *link_);
void     g_queue_push_nth_link  (GQueue           *queue,
				 gint              n,
				 GList            *link_);
GList*   g_queue_pop_head_link  (GQueue           *queue);
GList*   g_queue_pop_tail_link  (GQueue           *queue);
GList*   g_queue_pop_nth_link   (GQueue           *queue,
				 guint             n);
GList*   g_queue_peek_head_link (GQueue           *queue);
GList*   g_queue_peek_tail_link (GQueue           *queue);
GList*   g_queue_peek_nth_link  (GQueue           *queue,
				 guint             n);
gint     g_queue_link_index     (GQueue           *queue,
				 GList            *link_);
void     g_queue_unlink         (GQueue           *queue,
				 GList            *link_);
void     g_queue_delete_link    (GQueue           *queue, GList            *link_);

GRand*  g_rand_new_with_seed  (guint32  seed);
GRand*  g_rand_new_with_seed_array (const guint32 *seed,
				    guint seed_length);
GRand*  g_rand_new            (void);
void    g_rand_free           (GRand   *rand_);
GRand*  g_rand_copy           (GRand   *rand_);
void    g_rand_set_seed       (GRand   *rand_,
			       guint32  seed);
void	g_rand_set_seed_array (GRand   *rand_,
			       const guint32 *seed,
			       guint    seed_length);

guint32 g_rand_int            (GRand   *rand_);
gint32  g_rand_int_range      (GRand   *rand_,
			       gint32   begin,
			       gint32   end);
gdouble g_rand_double         (GRand   *rand_);
gdouble g_rand_double_range   (GRand   *rand_,
			       gdouble  begin,
			       gdouble  end);
void    g_random_set_seed     (guint32  seed);

guint32 g_random_int          (void);
gint32  g_random_int_range    (gint32   begin,
			       gint32   end);
gdouble g_random_double       (void);
gdouble g_random_double_range (gdouble  begin, gdouble  end);

GRelation* g_relation_new     (gint         fields);
void       g_relation_destroy (GRelation   *relation);
void       g_relation_index   (GRelation   *relation,
                               gint         field,
                               GHashFunc    hash_func,
                               GEqualFunc   key_equal_func);
void       g_relation_insert  (GRelation   *relation,
                               ...);
gint       g_relation_delete  (GRelation   *relation,
                               gconstpointer  key,
                               gint         field);
GTuples*   g_relation_select  (GRelation   *relation,
                               gconstpointer  key,
                               gint         field);
gint       g_relation_count   (GRelation   *relation,
                               gconstpointer  key,
                               gint         field);
gboolean   g_relation_exists  (GRelation   *relation,
                               ...);
void       g_relation_print   (GRelation   *relation);

void       g_tuples_destroy   (GTuples     *tuples);
gpointer   g_tuples_index     (GTuples     *tuples, gint         index_, gint         field);


GScanner*	g_scanner_new			(const GScannerConfig *config_templ);
void		g_scanner_destroy		(GScanner	*scanner);
void		g_scanner_input_file		(GScanner	*scanner,
						 gint		input_fd);
void		g_scanner_sync_file_offset	(GScanner	*scanner);
void		g_scanner_input_text		(GScanner	*scanner,
						 const	gchar	*text,
						 guint		text_len);
GTokenType	g_scanner_get_next_token	(GScanner	*scanner);
GTokenType	g_scanner_peek_next_token	(GScanner	*scanner);
GTokenType	g_scanner_cur_token		(GScanner	*scanner);
GTokenValue	g_scanner_cur_value		(GScanner	*scanner);
guint		g_scanner_cur_line		(GScanner	*scanner);
guint		g_scanner_cur_position		(GScanner	*scanner);
gboolean	g_scanner_eof			(GScanner	*scanner);
guint		g_scanner_set_scope		(GScanner	*scanner,
						 guint		 scope_id);
void		g_scanner_scope_add_symbol	(GScanner	*scanner,
						 guint		 scope_id,
						 const gchar	*symbol,
						 gpointer	value);
void		g_scanner_scope_remove_symbol	(GScanner	*scanner,
						 guint		 scope_id,
						 const gchar	*symbol);
gpointer	g_scanner_scope_lookup_symbol	(GScanner	*scanner,
						 guint		 scope_id,
						 const gchar	*symbol);
void		g_scanner_scope_foreach_symbol	(GScanner	*scanner,
						 guint		 scope_id,
						 GHFunc		 func,
						 gpointer	 user_data);
gpointer	g_scanner_lookup_symbol		(GScanner	*scanner,
						 const gchar	*symbol);
void		g_scanner_unexp_token		(GScanner	*scanner,
						 GTokenType	expected_token,
						 const gchar	*identifier_spec,
						 const gchar	*symbol_spec,
						 const gchar	*symbol_name,
						 const gchar	*message,
						 gint		 is_error);
void		g_scanner_error			(GScanner	*scanner,
						 const gchar	*format,
						 ...) G_GNUC_PRINTF (2,3);
void		g_scanner_warn			(GScanner	*scanner, const gchar	*format, ...) G_GNUC_PRINTF (2,3);

GQuark g_shell_error_quark (void);

gchar*   g_shell_quote      (const gchar   *unquoted_string);
gchar*   g_shell_unquote    (const gchar   *quoted_string,
                             GError       **error);
gboolean g_shell_parse_argv (const gchar   *command_line, gint          *argcp, gchar       ***argvp, GError       **error);


void     g_slist_push_allocator (GAllocator       *allocator);
void     g_slist_pop_allocator  (void);
GSList*  g_slist_alloc          (void);
void     g_slist_free           (GSList           *list);
void     g_slist_free_1         (GSList           *list);
GSList*  g_slist_append         (GSList           *list,
				 gpointer          data);
GSList*  g_slist_prepend        (GSList           *list,
				 gpointer          data);
GSList*  g_slist_insert         (GSList           *list,
				 gpointer          data,
				 gint              position);
GSList*  g_slist_insert_sorted  (GSList           *list,
				 gpointer          data,
				 GCompareFunc      func);
GSList*  g_slist_insert_before  (GSList           *slist,
				 GSList           *sibling,
				 gpointer          data);
GSList*  g_slist_concat         (GSList           *list1,
				 GSList           *list2);
GSList*  g_slist_remove         (GSList           *list,
				 gconstpointer     data);
GSList*  g_slist_remove_all     (GSList           *list,
				 gconstpointer     data);
GSList*  g_slist_remove_link    (GSList           *list,
				 GSList           *link_);
GSList*  g_slist_delete_link    (GSList           *list,
				 GSList           *link_);
GSList*  g_slist_reverse        (GSList           *list);
GSList*  g_slist_copy           (GSList           *list);
GSList*  g_slist_nth            (GSList           *list,
				 guint             n);
GSList*  g_slist_find           (GSList           *list,
				 gconstpointer     data);
GSList*  g_slist_find_custom    (GSList           *list,
				 gconstpointer     data,
				 GCompareFunc      func);
gint     g_slist_position       (GSList           *list,
				 GSList           *llink);
gint     g_slist_index          (GSList           *list,
				 gconstpointer     data);
GSList*  g_slist_last           (GSList           *list);
guint    g_slist_length         (GSList           *list);
void     g_slist_foreach        (GSList           *list,
				 GFunc             func,
				 gpointer          user_data);
GSList*  g_slist_sort           (GSList           *list,
				 GCompareFunc      compare_func);
GSList*  g_slist_sort_with_data (GSList           *list,
				 GCompareDataFunc  compare_func,
				 gpointer          user_data);
gpointer g_slist_nth_data       (GSList           *list, guint             n);

gchar                 g_ascii_tolower  (gchar        c) G_GNUC_CONST;
gchar                 g_ascii_toupper  (gchar        c) G_GNUC_CONST;

gint                  g_ascii_digit_value  (gchar    c) G_GNUC_CONST;
gint                  g_ascii_xdigit_value (gchar    c) G_GNUC_CONST;
gchar*	              g_strdelimit     (gchar	     *string,
					const gchar  *delimiters,
					gchar	      new_delimiter);
gchar*	              g_strcanon       (gchar        *string,
					const gchar  *valid_chars,
					gchar         substitutor);
G_CONST_RETURN gchar* g_strerror       (gint	      errnum) G_GNUC_CONST;
G_CONST_RETURN gchar* g_strsignal      (gint	      signum) G_GNUC_CONST;
gchar*	              g_strreverse     (gchar	     *string);
gsize	              g_strlcpy	       (gchar	     *dest,
					const gchar  *src,
					gsize         dest_size);
gsize	              g_strlcat        (gchar	     *dest,
					const gchar  *src,
					gsize         dest_size);
gchar *               g_strstr_len     (const gchar  *haystack,
					gssize        haystack_len,
					const gchar  *needle);
gchar *               g_strrstr        (const gchar  *haystack,
					const gchar  *needle);
gchar *               g_strrstr_len    (const gchar  *haystack,
					gssize        haystack_len,
					const gchar  *needle);

gboolean              g_str_has_suffix (const gchar  *str,
					const gchar  *suffix);
gboolean              g_str_has_prefix (const gchar  *str,
					const gchar  *prefix);
gdouble	              g_strtod         (const gchar  *nptr,
					gchar	    **endptr);
gdouble	              g_ascii_strtod   (const gchar  *nptr,
					gchar	    **endptr);
guint64		      g_ascii_strtoull (const gchar *nptr,
					gchar      **endptr,
					guint        base);
gchar *               g_ascii_dtostr   (gchar        *buffer,
					gint          buf_len,
					gdouble       d);
gchar *               g_ascii_formatd  (gchar        *buffer,
					gint          buf_len,
					const gchar  *format,
					gdouble       d);

gchar*                g_strchug        (gchar        *string);
gchar*                g_strchomp       (gchar        *string);
gint                  g_ascii_strcasecmp  (const gchar *s1,
					   const gchar *s2);
gint                  g_ascii_strncasecmp (const gchar *s1,
					   const gchar *s2,
					   gsize        n);
gchar*                g_ascii_strdown     (const gchar *str,
					   gssize       len) G_GNUC_MALLOC;
gchar*                g_ascii_strup       (const gchar *str,
					   gssize       len) G_GNUC_MALLOC;
gchar*	              g_strdup	       (const gchar *str) G_GNUC_MALLOC;
gchar*	              g_strdup_printf  (const gchar *format,
					...) G_GNUC_PRINTF (1, 2) G_GNUC_MALLOC;
gchar*	              g_strdup_vprintf (const gchar *format,
					va_list      args) G_GNUC_MALLOC;
gchar*	              g_strndup	       (const gchar *str,
					gsize        n) G_GNUC_MALLOC;  
gchar*	              g_strnfill       (gsize        length,  
					gchar        fill_char) G_GNUC_MALLOC;
gchar*	              g_strconcat      (const gchar *string1, ...) G_GNUC_MALLOC; /* NULL terminated */
gchar*                g_strjoin	       (const gchar  *separator,
					...) G_GNUC_MALLOC; /* NULL terminated */
gchar*                g_strcompress    (const gchar *source) G_GNUC_MALLOC;
gchar*                g_strescape      (const gchar *source,
					const gchar *exceptions) G_GNUC_MALLOC;

gpointer              g_memdup	       (gconstpointer mem,
					guint	       byte_size) G_GNUC_MALLOC;
gchar**	              g_strsplit       (const gchar  *string,
					const gchar  *delimiter,
					gint          max_tokens) G_GNUC_MALLOC;
gchar **	      g_strsplit_set   (const gchar *string,
					const gchar *delimiters,
					gint         max_tokens) G_GNUC_MALLOC;
gchar*                g_strjoinv       (const gchar  *separator,
					gchar       **str_array) G_GNUC_MALLOC;
void                  g_strfreev       (gchar       **str_array);
gchar**               g_strdupv        (gchar       **str_array) G_GNUC_MALLOC;
guint                 g_strv_length    (gchar       **str_array);

gchar*                g_stpcpy         (gchar        *dest,
                                        const char   *src);

G_CONST_RETURN gchar *g_strip_context  (const gchar *msgid, const gchar *msgval);


GString*     g_string_new	        (const gchar	 *init);
GString*     g_string_new_len           (const gchar     *init,
                                         gssize           len);   
GString*     g_string_sized_new         (gsize            dfl_size);  
gchar*	     g_string_free	        (GString	 *string,
					 gboolean	  free_segment);
gboolean     g_string_equal             (const GString	 *v,
					 const GString 	 *v2);
guint        g_string_hash              (const GString   *str);
GString*     g_string_assign            (GString	 *string,
					 const gchar	 *rval);
GString*     g_string_truncate          (GString	 *string,
					 gsize		  len);    
GString*     g_string_set_size          (GString         *string,
					 gsize            len);
GString*     g_string_insert_len        (GString         *string,
                                         gssize           pos,   
                                         const gchar     *val,
                                         gssize           len);  
GString*     g_string_append            (GString	 *string,
			                 const gchar	 *val);
GString*     g_string_append_len        (GString	 *string,
			                 const gchar	 *val,
                                         gssize           len);  
GString*     g_string_append_c          (GString	 *string,
					 gchar		  c);
GString*     g_string_append_unichar    (GString	 *string,
					 gunichar	  wc);
GString*     g_string_prepend           (GString	 *string,
					 const gchar	 *val);
GString*     g_string_prepend_c         (GString	 *string,
					 gchar		  c);
GString*     g_string_prepend_unichar   (GString	 *string,
					 gunichar	  wc);
GString*     g_string_prepend_len       (GString	 *string,
			                 const gchar	 *val,
                                         gssize           len);  
GString*     g_string_insert            (GString	 *string,
					 gssize		  pos,    
					 const gchar	 *val);
GString*     g_string_insert_c          (GString	 *string,
					 gssize		  pos,    
					 gchar		  c);
GString*     g_string_insert_unichar    (GString	 *string,
					 gssize		  pos,    
					 gunichar	  wc);
GString*     g_string_erase	        (GString	 *string,
					 gssize		  pos,
					 gssize		  len);
GString*     g_string_ascii_down        (GString	 *string);
GString*     g_string_ascii_up          (GString	 *string);
void         g_string_printf            (GString	 *string,const gchar	 *format,...);
void         g_string_append_printf     (GString	 *string, const gchar	 *format, ...);
GTree*   g_tree_new             (GCompareFunc      key_compare_func);
GTree*   g_tree_new_with_data   (GCompareDataFunc  key_compare_func,
                                 gpointer          key_compare_data);
GTree*   g_tree_new_full        (GCompareDataFunc  key_compare_func,
                                 gpointer          key_compare_data,
                                 GDestroyNotify    key_destroy_func,
                                 GDestroyNotify    value_destroy_func);
void     g_tree_destroy         (GTree            *tree);
void     g_tree_insert          (GTree            *tree,
                                 gpointer          key,
                                 gpointer          value);
void     g_tree_replace         (GTree            *tree,
                                 gpointer          key,
                                 gpointer          value);
void     g_tree_remove          (GTree            *tree,
                                 gconstpointer     key);
void     g_tree_steal           (GTree            *tree,
                                 gconstpointer     key);
gpointer g_tree_lookup          (GTree            *tree,
                                 gconstpointer     key);
gboolean g_tree_lookup_extended (GTree            *tree,
                                 gconstpointer     lookup_key,
                                 gpointer         *orig_key,
                                 gpointer         *value);
void     g_tree_foreach         (GTree            *tree,
                                 GTraverseFunc	   func,
                                 gpointer	   user_data);

gpointer g_tree_search          (GTree            *tree,
                                 GCompareFunc      search_func,
                                 gconstpointer     user_data);
gint     g_tree_height          (GTree            *tree);
gint     g_tree_nnodes          (GTree            *tree);

gboolean g_get_charset (G_CONST_RETURN char **charset);
gboolean g_unichar_isalnum   (gunichar c) G_GNUC_CONST;
gboolean g_unichar_isalpha   (gunichar c) G_GNUC_CONST;
gboolean g_unichar_iscntrl   (gunichar c) G_GNUC_CONST;
gboolean g_unichar_isdigit   (gunichar c) G_GNUC_CONST;
gboolean g_unichar_isgraph   (gunichar c) G_GNUC_CONST;
gboolean g_unichar_islower   (gunichar c) G_GNUC_CONST;
gboolean g_unichar_isprint   (gunichar c) G_GNUC_CONST;
gboolean g_unichar_ispunct   (gunichar c) G_GNUC_CONST;
gboolean g_unichar_isspace   (gunichar c) G_GNUC_CONST;
gboolean g_unichar_isupper   (gunichar c) G_GNUC_CONST;
gboolean g_unichar_isxdigit  (gunichar c) G_GNUC_CONST;
gboolean g_unichar_istitle   (gunichar c) G_GNUC_CONST;
gboolean g_unichar_isdefined (gunichar c) G_GNUC_CONST;
gboolean g_unichar_iswide    (gunichar c) G_GNUC_CONST;
gunichar g_unichar_toupper (gunichar c) G_GNUC_CONST;
gunichar g_unichar_tolower (gunichar c) G_GNUC_CONST;
gunichar g_unichar_totitle (gunichar c) G_GNUC_CONST;
gint g_unichar_digit_value (gunichar c) G_GNUC_CONST;

gint g_unichar_xdigit_value (gunichar c) G_GNUC_CONST;

GUnicodeType g_unichar_type (gunichar c) G_GNUC_CONST;

GUnicodeBreakType g_unichar_break_type (gunichar c) G_GNUC_CONST;


void g_unicode_canonical_ordering (gunichar *string,
				   gsize     len);
gunichar *g_unicode_canonical_decomposition (gunichar  ch,
					     gsize    *result_len) G_GNUC_MALLOC;
gunichar g_utf8_get_char           (const gchar  *p);
gunichar g_utf8_get_char_validated (const  gchar *p,
				    gssize        max_len);

gchar*   g_utf8_offset_to_pointer (const gchar *str,
                                   glong        offset);  
glong    g_utf8_pointer_to_offset (const gchar *str,      
				   const gchar *pos);
gchar*   g_utf8_prev_char         (const gchar *p);
gchar*   g_utf8_find_next_char    (const gchar *p,
				   const gchar *end);
gchar*   g_utf8_find_prev_char    (const gchar *str,
				   const gchar *p);

glong g_utf8_strlen (const gchar *p,  
		     gssize       max);        
gchar* g_utf8_strncpy (gchar       *dest,
		       const gchar *src,
		       gsize        n);
gchar* g_utf8_strchr  (const gchar *p,
		       gssize       len,
		       gunichar     c);
gchar* g_utf8_strrchr (const gchar *p,
		       gssize       len,
		       gunichar     c);
gchar* g_utf8_strreverse (const gchar *str,
			  gssize len);

gunichar2 *g_utf8_to_utf16     (const gchar      *str,
				glong             len,            
				glong            *items_read,     
				glong            *items_written,  
				GError          **error) G_GNUC_MALLOC;
gunichar * g_utf8_to_ucs4      (const gchar      *str,
				glong             len,            
				glong            *items_read,     
				glong            *items_written,  
				GError          **error) G_GNUC_MALLOC;
gunichar * g_utf8_to_ucs4_fast (const gchar      *str,
				glong             len,            
				glong            *items_written) G_GNUC_MALLOC; 
gunichar * g_utf16_to_ucs4     (const gunichar2  *str,
				glong             len,            
				glong            *items_read,     
				glong            *items_written,  
				GError          **error);
gchar*     g_utf16_to_utf8     (const gunichar2  *str,
				glong             len,            
				glong            *items_read,     
				glong            *items_written,  
				GError          **error);
gunichar2 *g_ucs4_to_utf16     (const gunichar   *str,
				glong             len,            
				glong            *items_read,     
				glong            *items_written,  
				GError          **error);
gchar*     g_ucs4_to_utf8      (const gunichar   *str,glong             len,            glong            *items_read,     glong            *items_written,  GError          **error) G_GNUC_MALLOC;
gint      g_unichar_to_utf8 (gunichar    c,gchar      *outbuf);
gboolean g_utf8_validate (const gchar  *str,gssize        max_len,  const gchar **end);
gboolean g_unichar_validate (gunichar ch);
gchar *g_utf8_strup   (const gchar *str,gssize       len);
gchar *g_utf8_strdown (const gchar *str,gssize       len);
gchar *g_utf8_casefold (const gchar *str,gssize       len);
gchar *g_utf8_normalize (const gchar   *str,gssize         len,GNormalizeMode mode);
gint   g_utf8_collate     (const gchar *str1,const gchar *str2);
gchar *g_utf8_collate_key (const gchar *str, gssize       len);
gboolean g_unichar_get_mirror_char (gunichar ch, gunichar *mirrored_ch);

void                  g_nullify_pointer    (gpointer    *nullify_location);

/*
 * @@@ gobject stuff @@@
 *
 * It is included to glib.library because creating gobject.library is too much work and pain.
 */

gpointer	g_boxed_copy			(GType		 boxed_type,
						 gconstpointer	 src_boxed);
void		g_boxed_free			(GType		 boxed_type,
						 gpointer	 boxed);
void		g_value_set_boxed		(GValue		*value,
						 gconstpointer	 v_boxed);
void		g_value_set_static_boxed	(GValue		*value,
						 gconstpointer	 v_boxed);
gpointer	g_value_get_boxed		(const GValue	*value);
gpointer	g_value_dup_boxed		(const GValue	*value);


/* --- convenience --- */
GType	g_boxed_type_register_static		(const gchar	*name,
						 GBoxedCopyFunc	 boxed_copy,
						 GBoxedFreeFunc	 boxed_free);

GEnumValue*	g_enum_get_value		(GEnumClass	*enum_class,
						 gint		 value);
GEnumValue*	g_enum_get_value_by_name	(GEnumClass	*enum_class,
						 const gchar	*name);
GEnumValue*	g_enum_get_value_by_nick	(GEnumClass	*enum_class,
						 const gchar	*nick);
GFlagsValue*	g_flags_get_first_value		(GFlagsClass	*flags_class,
						 guint		 value);
GFlagsValue*	g_flags_get_value_by_name	(GFlagsClass	*flags_class,
						 const gchar	*name);
GFlagsValue*	g_flags_get_value_by_nick	(GFlagsClass	*flags_class,
						 const gchar	*nick);
void            g_value_set_enum        	(GValue         *value,
						 gint            v_enum);
gint            g_value_get_enum        	(const GValue   *value);
void            g_value_set_flags       	(GValue         *value,
						 guint           v_flags);
guint           g_value_get_flags       	(const GValue   *value);



/* --- registration functions --- */
/* const_static_values is a NULL terminated array of enum/flags
 * values that is taken over!
 */
GType	g_enum_register_static	   (const gchar	      *name,
				    const GEnumValue  *const_static_values);
GType	g_flags_register_static	   (const gchar	      *name,
				    const GFlagsValue *const_static_values);
/* functions to complete the type information
 * for enums/flags implemented by plugins
 */
void	g_enum_complete_type_info  (GType	       g_enum_type,
				    GTypeInfo	      *info,
				    const GEnumValue  *const_values);
void	g_flags_complete_type_info (GType	       g_flags_type,
				    GTypeInfo	      *info,
				    const GFlagsValue *const_values);

GType       g_initially_unowned_get_type      (void);
void        g_object_class_install_property   (GObjectClass   *oclass,
					       guint           property_id,
					       GParamSpec     *pspec);
GParamSpec* g_object_class_find_property      (GObjectClass   *oclass,
					       const gchar    *property_name);
GParamSpec**g_object_class_list_properties    (GObjectClass   *oclass,
					       guint	      *n_properties);
void        g_object_class_override_property  (GObjectClass   *oclass,
					       guint           property_id,
					       const gchar    *name);

void        g_object_interface_install_property (gpointer     g_iface,
						 GParamSpec  *pspec);
GParamSpec* g_object_interface_find_property    (gpointer     g_iface,
						 const gchar *property_name);
GParamSpec**g_object_interface_list_properties  (gpointer     g_iface,
						 guint       *n_properties_p);

gpointer    g_object_new                      (GType           object_type,
					       const gchar    *first_property_name,
					       ...);
gpointer    g_object_newv		      (GType           object_type,
					       guint	       n_parameters,
					       GParameter     *parameters);
GObject*    g_object_new_valist               (GType           object_type,
					       const gchar    *first_property_name,
					       va_list         var_args);
void	    g_object_set                      (gpointer	       object,
					       const gchar    *first_property_name,
					       ...) G_GNUC_NULL_TERMINATED;
void        g_object_get                      (gpointer        object,
					       const gchar    *first_property_name,
					       ...) G_GNUC_NULL_TERMINATED;
gpointer    g_object_connect                  (gpointer	       object,
					       const gchar    *signal_spec,
					       ...) G_GNUC_NULL_TERMINATED;
void	    g_object_disconnect               (gpointer	       object,
					       const gchar    *signal_spec,
					       ...) G_GNUC_NULL_TERMINATED;
void        g_object_set_valist               (GObject        *object,
					       const gchar    *first_property_name,
					       va_list         var_args);
void        g_object_get_valist               (GObject        *object,
					       const gchar    *first_property_name,
					       va_list         var_args);
void        g_object_set_property             (GObject        *object,
					       const gchar    *property_name,
					       const GValue   *value);
void        g_object_get_property             (GObject        *object,
					       const gchar    *property_name,
					       GValue         *value);
void        g_object_freeze_notify            (GObject        *object);
void        g_object_notify                   (GObject        *object,
					       const gchar    *property_name);
void        g_object_thaw_notify              (GObject        *object);
gboolean    g_object_is_floating    	      (gpointer        object);
gpointer    g_object_ref_sink       	      (gpointer	       object);
gpointer    g_object_ref                      (gpointer        object);
void        g_object_unref                    (gpointer        object);
void	    g_object_weak_ref		      (GObject	      *object,
					       GWeakNotify     notify,
					       gpointer	       data);
void	    g_object_weak_unref		      (GObject	      *object,
					       GWeakNotify     notify,
					       gpointer	       data);
void        g_object_add_weak_pointer         (GObject        *object, 
                                               gpointer       *weak_pointer_location);
void        g_object_remove_weak_pointer      (GObject        *object, 
                                               gpointer       *weak_pointer_location);

void g_object_add_toggle_ref    (GObject       *object,
				 GToggleNotify  notify,
				 gpointer       data);
void g_object_remove_toggle_ref (GObject       *object,
				 GToggleNotify  notify,
				 gpointer       data);

gpointer    g_object_get_qdata                (GObject        *object,
					       GQuark          quark);
void        g_object_set_qdata                (GObject        *object,
					       GQuark          quark,
					       gpointer        data);
void        g_object_set_qdata_full           (GObject        *object,
					       GQuark          quark,
					       gpointer        data,
					       GDestroyNotify  destroy);
gpointer    g_object_steal_qdata              (GObject        *object,
					       GQuark          quark);
gpointer    g_object_get_data                 (GObject        *object,
					       const gchar    *key);
void        g_object_set_data                 (GObject        *object,
					       const gchar    *key,
					       gpointer        data);
void        g_object_set_data_full            (GObject        *object,
					       const gchar    *key,
					       gpointer        data,
					       GDestroyNotify  destroy);
gpointer    g_object_steal_data               (GObject        *object,
					       const gchar    *key);
void        g_object_watch_closure            (GObject        *object,
					       GClosure       *closure);
GClosure*   g_cclosure_new_object             (GCallback       callback_func,
					       GObject	      *object);
GClosure*   g_cclosure_new_object_swap        (GCallback       callback_func,
					       GObject	      *object);
GClosure*   g_closure_new_object              (guint           sizeof_closure,
					       GObject        *object);
void        g_value_set_object                (GValue         *value,
					       gpointer        v_object);
gpointer    g_value_get_object                (const GValue   *value);
GObject*    g_value_dup_object                (const GValue   *value);
gulong	    g_signal_connect_object           (gpointer	       instance,
					       const gchar    *detailed_signal,
					       GCallback       c_handler,
					       gpointer	       gobject,
					       GConnectFlags   connect_flags);

GParamSpec*	g_param_spec_ref		(GParamSpec    *pspec);
void		g_param_spec_unref		(GParamSpec    *pspec);
void		g_param_spec_sink		(GParamSpec    *pspec);
GParamSpec*	g_param_spec_ref_sink   	(GParamSpec    *pspec);
gpointer        g_param_spec_get_qdata		(GParamSpec    *pspec,
						 GQuark         quark);
void            g_param_spec_set_qdata		(GParamSpec    *pspec,
						 GQuark         quark,
						 gpointer       data);
void            g_param_spec_set_qdata_full	(GParamSpec    *pspec,
						 GQuark         quark,
						 gpointer       data,
						 GDestroyNotify destroy);
gpointer        g_param_spec_steal_qdata	(GParamSpec    *pspec,
						 GQuark         quark);
GParamSpec*     g_param_spec_get_redirect_target (GParamSpec   *pspec);

void		g_param_value_set_default	(GParamSpec    *pspec,
						 GValue	       *value);
gboolean	g_param_value_defaults		(GParamSpec    *pspec,
						 GValue	       *value);
gboolean	g_param_value_validate		(GParamSpec    *pspec,
						 GValue	       *value);
gboolean	g_param_value_convert		(GParamSpec    *pspec,
						 const GValue  *src_value,
						 GValue	       *dest_value,
						 gboolean	strict_validation);
gint		g_param_values_cmp		(GParamSpec    *pspec,
						 const GValue  *value1,
						 const GValue  *value2);
G_CONST_RETURN gchar*	g_param_spec_get_name	(GParamSpec    *pspec);
G_CONST_RETURN gchar*	g_param_spec_get_nick	(GParamSpec    *pspec);
G_CONST_RETURN gchar*	g_param_spec_get_blurb	(GParamSpec    *pspec);
void            g_value_set_param               (GValue	       *value,
						 GParamSpec    *param);
GParamSpec*     g_value_get_param               (const GValue  *value);
GParamSpec*     g_value_dup_param               (const GValue  *value);


void           g_value_take_param               (GValue        *value,
					         GParamSpec    *param);

GType	g_param_type_register_static	(const gchar		  *name,
					 const GParamSpecTypeInfo *pspec_info);

/* For registering builting types */
GType  _g_param_type_register_static_constant (const gchar              *name,
					       const GParamSpecTypeInfo *pspec_info,
					       GType                     opt_type);

GParamSpec*	g_param_spec_char	 (const gchar	 *name,
					  const gchar	 *nick,
					  const gchar	 *blurb,
					  gint8		  minimum,
					  gint8		  maximum,
					  gint8		  default_value,
					  GParamFlags	  flags);
GParamSpec*	g_param_spec_uchar	 (const gchar	 *name,
					  const gchar	 *nick,
					  const gchar	 *blurb,
					  guint8	  minimum,
					  guint8	  maximum,
					  guint8	  default_value,
					  GParamFlags	  flags);
GParamSpec*	g_param_spec_boolean	 (const gchar	 *name,
					  const gchar	 *nick,
					  const gchar	 *blurb,
					  gboolean	  default_value,
					  GParamFlags	  flags);
GParamSpec*	g_param_spec_int	 (const gchar	 *name,
					  const gchar	 *nick,
					  const gchar	 *blurb,
					  gint		  minimum,
					  gint		  maximum,
					  gint		  default_value,
					  GParamFlags	  flags);
GParamSpec*	g_param_spec_uint	 (const gchar	 *name,
					  const gchar	 *nick,
					  const gchar	 *blurb,
					  guint		  minimum,
					  guint		  maximum,
					  guint		  default_value,
					  GParamFlags	  flags);
GParamSpec*	g_param_spec_long	 (const gchar	 *name,
					  const gchar	 *nick,
					  const gchar	 *blurb,
					  glong		  minimum,
					  glong		  maximum,
					  glong		  default_value,
					  GParamFlags	  flags);
GParamSpec*	g_param_spec_ulong	 (const gchar	 *name,
					  const gchar	 *nick,
					  const gchar	 *blurb,
					  gulong	  minimum,
					  gulong	  maximum,
					  gulong	  default_value,
					  GParamFlags	  flags);
GParamSpec*	g_param_spec_int64	 (const gchar	 *name,
					  const gchar	 *nick,
					  const gchar	 *blurb,
					  gint64       	  minimum,
					  gint64       	  maximum,
					  gint64       	  default_value,
					  GParamFlags	  flags);
GParamSpec*	g_param_spec_uint64	 (const gchar	 *name,
					  const gchar	 *nick,
					  const gchar	 *blurb,
					  guint64	  minimum,
					  guint64	  maximum,
					  guint64	  default_value,
					  GParamFlags	  flags);
GParamSpec*    g_param_spec_unichar      (const gchar    *name,
				          const gchar    *nick,
				          const gchar    *blurb,
				          gunichar	  default_value,
				          GParamFlags     flags);
GParamSpec*	g_param_spec_enum	 (const gchar	 *name,
					  const gchar	 *nick,
					  const gchar	 *blurb,
					  GType		  enum_type,
					  gint		  default_value,
					  GParamFlags	  flags);
GParamSpec*	g_param_spec_flags	 (const gchar	 *name,
					  const gchar	 *nick,
					  const gchar	 *blurb,
					  GType		  flags_type,
					  guint		  default_value,
					  GParamFlags	  flags);
GParamSpec*	g_param_spec_float	 (const gchar	 *name,
					  const gchar	 *nick,
					  const gchar	 *blurb,
					  gfloat	  minimum,
					  gfloat	  maximum,
					  gfloat	  default_value,
					  GParamFlags	  flags);
GParamSpec*	g_param_spec_double	 (const gchar	 *name,
					  const gchar	 *nick,
					  const gchar	 *blurb,
					  gdouble	  minimum,
					  gdouble	  maximum,
					  gdouble	  default_value,
					  GParamFlags	  flags);
GParamSpec*	g_param_spec_string	 (const gchar	 *name,
					  const gchar	 *nick,
					  const gchar	 *blurb,
					  const gchar	 *default_value,
					  GParamFlags	  flags);
GParamSpec*	g_param_spec_param	 (const gchar	 *name,
					  const gchar	 *nick,
					  const gchar	 *blurb,
					  GType		  param_type,
					  GParamFlags	  flags);
GParamSpec*	g_param_spec_boxed	 (const gchar	 *name,
					  const gchar	 *nick,
					  const gchar	 *blurb,
					  GType		  boxed_type,
					  GParamFlags	  flags);
GParamSpec*	g_param_spec_pointer	 (const gchar	 *name,
					  const gchar	 *nick,
					  const gchar	 *blurb,
					  GParamFlags	  flags);
GParamSpec*	g_param_spec_value_array (const gchar	 *name,
					  const gchar	 *nick,
					  const gchar	 *blurb,
					  GParamSpec	 *element_spec,
					  GParamFlags	  flags);
GParamSpec*	g_param_spec_object	 (const gchar	 *name,
					  const gchar	 *nick,
					  const gchar	 *blurb,
					  GType		  object_type,
					  GParamFlags	  flags);
GParamSpec*     g_param_spec_override    (const gchar    *name,
					  GParamSpec     *overridden);
GParamSpec*	g_param_spec_gtype	 (const gchar	 *name,
					  const gchar	 *nick,
					  const gchar	 *blurb,
					  GType           is_a_type,
					  GParamFlags	  flags);

guint                 g_signal_newv         (const gchar        *signal_name,
					     GType               itype,
					     GSignalFlags        signal_flags,
					     GClosure           *class_closure,
					     GSignalAccumulator	 accumulator,
					     gpointer		 accu_data,
					     GSignalCMarshaller  c_marshaller,
					     GType               return_type,
					     guint               n_params,
					     GType              *param_types);
guint                 g_signal_new_valist   (const gchar        *signal_name,
					     GType               itype,
					     GSignalFlags        signal_flags,
					     GClosure           *class_closure,
					     GSignalAccumulator	 accumulator,
					     gpointer		 accu_data,
					     GSignalCMarshaller  c_marshaller,
					     GType               return_type,
					     guint               n_params,
					     va_list             args);
guint                 g_signal_new          (const gchar        *signal_name,
					     GType               itype,
					     GSignalFlags        signal_flags,
					     guint               class_offset,
					     GSignalAccumulator	 accumulator,
					     gpointer		 accu_data,
					     GSignalCMarshaller  c_marshaller,
					     GType               return_type,
					     guint               n_params,
					     ...);
void                  g_signal_emitv        (const GValue       *instance_and_params,
					     guint               signal_id,
					     GQuark              detail,
					     GValue             *return_value);
void                  g_signal_emit_valist  (gpointer            instance,
					     guint               signal_id,
					     GQuark              detail,
					     va_list             var_args);
void                  g_signal_emit         (gpointer            instance,
					     guint               signal_id,
					     GQuark              detail,
					     ...);
void                  g_signal_emit_by_name (gpointer            instance,
					     const gchar        *detailed_signal,
					     ...);
guint                 g_signal_lookup       (const gchar        *name,
					     GType               itype);
G_CONST_RETURN gchar* g_signal_name         (guint               signal_id);
void                  g_signal_query        (guint               signal_id,
					     GSignalQuery       *query);
guint*                g_signal_list_ids     (GType               itype,
					     guint              *n_ids);
gboolean	      g_signal_parse_name   (const gchar	*detailed_signal,
					     GType		 itype,
					     guint		*signal_id_p,
					     GQuark		*detail_p,
					     gboolean		 force_detail_quark);
GSignalInvocationHint* g_signal_get_invocation_hint (gpointer    instance);


/* --- signal emissions --- */
void	g_signal_stop_emission		    (gpointer		  instance,
					     guint		  signal_id,
					     GQuark		  detail);
void	g_signal_stop_emission_by_name	    (gpointer		  instance,
					     const gchar	 *detailed_signal);
gulong	g_signal_add_emission_hook	    (guint		  signal_id,
					     GQuark		  detail,
					     GSignalEmissionHook  hook_func,
					     gpointer	       	  hook_data,
					     GDestroyNotify	  data_destroy);
void	g_signal_remove_emission_hook	    (guint		  signal_id,
					     gulong		  hook_id);


/* --- signal handlers --- */
gboolean g_signal_has_handler_pending	      (gpointer		  instance,
					       guint		  signal_id,
					       GQuark		  detail,
					       gboolean		  may_be_blocked);
gulong	 g_signal_connect_closure_by_id	      (gpointer		  instance,
					       guint		  signal_id,
					       GQuark		  detail,
					       GClosure		 *closure,
					       gboolean		  after);
gulong	 g_signal_connect_closure	      (gpointer		  instance,
					       const gchar       *detailed_signal,
					       GClosure		 *closure,
					       gboolean		  after);
gulong	 g_signal_connect_data		      (gpointer		  instance,
					       const gchar	 *detailed_signal,
					       GCallback	  c_handler,
					       gpointer		  data,
					       GClosureNotify	  destroy_data,
					       GConnectFlags	  connect_flags);
void	 g_signal_handler_block		      (gpointer		  instance,
					       gulong		  handler_id);
void	 g_signal_handler_unblock	      (gpointer		  instance,
					       gulong		  handler_id);
void	 g_signal_handler_disconnect	      (gpointer		  instance,
					       gulong		  handler_id);
gboolean g_signal_handler_is_connected	      (gpointer		  instance,
					       gulong		  handler_id);
gulong	 g_signal_handler_find		      (gpointer		  instance,
					       GSignalMatchType	  mask,
					       guint		  signal_id,
					       GQuark		  detail,
					       GClosure		 *closure,
					       gpointer		  func,
					       gpointer		  data);
guint	 g_signal_handlers_block_matched      (gpointer		  instance,
					       GSignalMatchType	  mask,
					       guint		  signal_id,
					       GQuark		  detail,
					       GClosure		 *closure,
					       gpointer		  func,
					       gpointer		  data);
guint	 g_signal_handlers_unblock_matched    (gpointer		  instance,
					       GSignalMatchType	  mask,
					       guint		  signal_id,
					       GQuark		  detail,
					       GClosure		 *closure,
					       gpointer		  func,
					       gpointer		  data);
guint	 g_signal_handlers_disconnect_matched (gpointer		  instance,
					       GSignalMatchType	  mask,
					       guint		  signal_id,
					       GQuark		  detail,
					       GClosure		 *closure,
					       gpointer		  func,
					       gpointer		  data);


/* --- chaining for language bindings --- */
void	g_signal_override_class_closure	      (guint		  signal_id,
					       GType		  instance_type,
					       GClosure		 *class_closure);
void	g_signal_chain_from_overridden	      (const GValue      *instance_and_params,
					       GValue            *return_value);
gboolean g_signal_accumulator_true_handled (GSignalInvocationHint *ihint,
					    GValue                *return_accu,
					    const GValue          *handler_return,
					    gpointer               dummy);

void g_source_set_closure (GSource  *source,
			   GClosure *closure);

GType g_io_channel_get_type   (void);
GType g_io_condition_get_type (void);

void                  g_type_init                    (void);
void                  g_type_init_with_debug_flags   (GTypeDebugFlags  debug_flags);
G_CONST_RETURN gchar* g_type_name                    (GType            type);
GQuark                g_type_qname                   (GType            type);
GType                 g_type_from_name               (const gchar     *name);
GType                 g_type_parent                  (GType            type);
guint                 g_type_depth                   (GType            type);
GType                 g_type_next_base               (GType            leaf_type,
						      GType            root_type);
gboolean              g_type_is_a                    (GType            type,
						      GType            is_a_type);
gpointer              g_type_class_ref               (GType            type);
gpointer              g_type_class_peek              (GType            type);
gpointer              g_type_class_peek_static       (GType            type);
void                  g_type_class_unref             (gpointer         g_class);
gpointer              g_type_class_peek_parent       (gpointer         g_class);
gpointer              g_type_interface_peek          (gpointer         instance_class,
						      GType            iface_type);
gpointer              g_type_interface_peek_parent   (gpointer         g_iface);

gpointer              g_type_default_interface_ref   (GType            g_type);
gpointer              g_type_default_interface_peek  (GType            g_type);
void                  g_type_default_interface_unref (gpointer         g_iface);

/* g_free() the returned arrays */
GType*                g_type_children                (GType            type,
						      guint           *n_children);
GType*                g_type_interfaces              (GType            type,
						      guint           *n_interfaces);

/* per-type _static_ data */
void                  g_type_set_qdata               (GType            type,
						      GQuark           quark,
						      gpointer         data);
gpointer              g_type_get_qdata               (GType            type,
						      GQuark           quark);
void		      g_type_query		     (GType	       type,
						      GTypeQuery      *query);


GType g_type_register_static		(GType			     parent_type,
					 const gchar		    *type_name,
					 const GTypeInfo	    *info,
					 GTypeFlags		     flags);
GType g_type_register_static_simple     (GType                       parent_type,
					 const gchar                *type_name,
					 guint                       class_size,
					 GClassInitFunc              class_init,
					 guint                       instance_size,
					 GInstanceInitFunc           instance_init,
					 GTypeFlags	             flags);
  
GType g_type_register_dynamic		(GType			     parent_type,
					 const gchar		    *type_name,
					 GTypePlugin		    *plugin,
					 GTypeFlags		     flags);
GType g_type_register_fundamental	(GType			     type_id,
					 const gchar		    *type_name,
					 const GTypeInfo	    *info,
					 const GTypeFundamentalInfo *finfo,
					 GTypeFlags		     flags);
void  g_type_add_interface_static	(GType			     instance_type,
					 GType			     interface_type,
					 const GInterfaceInfo	    *info);
void  g_type_add_interface_dynamic	(GType			     instance_type,
					 GType			     interface_type,
					 GTypePlugin		    *plugin);
void  g_type_interface_add_prerequisite (GType			     interface_type,
					 GType			     prerequisite_type);
GType*g_type_interface_prerequisites    (GType                       interface_type,
					 guint                      *n_prerequisites);
void     g_type_class_add_private       (gpointer                    g_class,
                                         gsize                       private_size);
gpointer g_type_instance_get_private    (GTypeInstance              *instance,
                                         GType                       private_type);


GType    g_type_module_get_type       (void) G_GNUC_CONST;
gboolean g_type_module_use            (GTypeModule          *module);
void     g_type_module_unuse          (GTypeModule          *module);
void     g_type_module_set_name       (GTypeModule          *module,
                                       const gchar          *name);
GType    g_type_module_register_type  (GTypeModule          *module,
                                       GType                 parent_type,
                                       const gchar          *type_name,
                                       const GTypeInfo      *type_info,
                                       GTypeFlags            flags);
void     g_type_module_add_interface  (GTypeModule          *module,
                                       GType                 instance_type,
                                       GType                 interface_type,
                                       const GInterfaceInfo *interface_info);
GType    g_type_module_register_enum  (GTypeModule          *module,
                                       const gchar          *name,
                                       const GEnumValue     *const_static_values);
GType    g_type_module_register_flags (GTypeModule          *module,
                                       const gchar          *name,
                                       const GFlagsValue    *const_static_values);

GType	g_type_plugin_get_type			(void)	G_GNUC_CONST;
void	g_type_plugin_use			(GTypePlugin	 *plugin);
void	g_type_plugin_unuse			(GTypePlugin	 *plugin);
void	g_type_plugin_complete_type_info	(GTypePlugin     *plugin,
						 GType            g_type,
						 GTypeInfo       *info,
						 GTypeValueTable *value_table);
void	g_type_plugin_complete_interface_info	(GTypePlugin     *plugin,
						 GType            instance_type,
						 GType            interface_type,
						 GInterfaceInfo  *info);

GValue*         g_value_init	   	(GValue       *value,
					 GType         g_type);
void            g_value_copy    	(const GValue *src_value,
					 GValue       *dest_value);
GValue*         g_value_reset   	(GValue       *value);
void            g_value_unset   	(GValue       *value);
void		g_value_set_instance	(GValue	      *value,
					 gpointer      instance);

GValue*		g_value_array_get_nth	     (GValueArray	*value_array,
					      guint		 index_);
GValueArray*	g_value_array_new	     (guint		 n_prealloced);
void		g_value_array_free	     (GValueArray	*value_array);
GValueArray*	g_value_array_copy	     (const GValueArray *value_array);
GValueArray*	g_value_array_prepend	     (GValueArray	*value_array,
					      const GValue	*value);
GValueArray*	g_value_array_append	     (GValueArray	*value_array,
					      const GValue	*value);
GValueArray*	g_value_array_insert	     (GValueArray	*value_array,
					      guint		 index_,
					      const GValue	*value);
GValueArray*	g_value_array_remove	     (GValueArray	*value_array,
					      guint		 index_);
GValueArray*	g_value_array_sort	     (GValueArray	*value_array,
					      GCompareFunc	 compare_func);
GValueArray*	g_value_array_sort_with_data (GValueArray	*value_array,
					      GCompareDataFunc	 compare_func,
					      gpointer		 user_data);

void		      g_value_set_char		(GValue	      *value,
						 gchar	       v_char);
gchar		      g_value_get_char		(const GValue *value);
void		      g_value_set_uchar		(GValue	      *value,
						 guchar	       v_uchar);
guchar		      g_value_get_uchar		(const GValue *value);
void		      g_value_set_boolean	(GValue	      *value,
						 gboolean      v_boolean);
gboolean	      g_value_get_boolean	(const GValue *value);
void		      g_value_set_int		(GValue	      *value,
						 gint	       v_int);
gint		      g_value_get_int		(const GValue *value);
void		      g_value_set_uint		(GValue	      *value,
						 guint	       v_uint);
guint		      g_value_get_uint		(const GValue *value);
void		      g_value_set_long		(GValue	      *value,
						 glong	       v_long);
glong		      g_value_get_long		(const GValue *value);
void		      g_value_set_ulong		(GValue	      *value,
						 gulong	       v_ulong);
gulong		      g_value_get_ulong		(const GValue *value);
void		      g_value_set_int64		(GValue	      *value,
						 gint64	       v_int64);
gint64		      g_value_get_int64		(const GValue *value);
void		      g_value_set_uint64	(GValue	      *value,
						 guint64      v_uint64);
guint64		      g_value_get_uint64	(const GValue *value);
void		      g_value_set_float		(GValue	      *value,
						 gfloat	       v_float);
gfloat		      g_value_get_float		(const GValue *value);
void		      g_value_set_double	(GValue	      *value,
						 gdouble       v_double);
gdouble		      g_value_get_double	(const GValue *value);
void		      g_value_set_string	(GValue	      *value,
						 const gchar  *v_string);
void		      g_value_set_static_string (GValue	      *value,
						 const gchar  *v_string);
G_CONST_RETURN gchar* g_value_get_string	(const GValue *value);
gchar*		      g_value_dup_string	(const GValue *value);
void		      g_value_set_pointer	(GValue	      *value,
						 gpointer      v_pointer);
gpointer	      g_value_get_pointer	(const GValue *value);
GType		      g_gtype_get_type		(void);
void		      g_value_set_gtype	        (GValue	      *value,
						 GType         v_gtype);
GType	              g_value_get_gtype	        (const GValue *value);


/* Convenience for registering new pointer types */
GType                 g_pointer_type_register_static (const gchar *name);

/* debugging aid, describe value contents as string */
gchar*                g_strdup_value_contents   (const GValue *value);


void g_value_take_string		        (GValue		   *value,
						 gchar		   *v_string);

#endif