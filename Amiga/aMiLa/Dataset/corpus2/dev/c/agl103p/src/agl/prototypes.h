/* border.c */
void drawborder(long id,long button);
void line3d(long wid,long c1,long c2,long x1,long y1,long xy2,long vertical);
void agl_box(long wid,long c1,long c2,long x1,long y1,long x2,long y2,long fill,long inverse);
void agl_text(long wid,long c,long x,long y,char *string);

/* clip.c */
void scrmask(Screencoord left,Screencoord right,Screencoord bottom,Screencoord top);
void getscrmask(Screencoord *left,Screencoord *right,Screencoord *bottom,Screencoord *top);
void activate_clipping(long wid);
void deactivate_clipping(long wid);
void unclip_window(struct Window *window);
struct Region *clip_window(struct Window *window,long minx,long miny,long maxx,long maxy);

/* matrix.c */
void init_matrices(void);
void reset_matrix_pointers(void);
void pushmatrix(void);
void popmatrix(void);
void mmode(short mode);
long getmmode(void);
void getmatrix(Matrix  m);
void loadmatrix(Matrix  m);
void multmatrix(Matrix  m);
long is_one_to_one(Matrix m);
void perspective(long angle,float aspect,float near,float far);
void ortho(float left,float right,float bottom,float top,float near,float far);
void ortho2(float left,float right,float bottom,float top);
void viewport(Screencoord left,Screencoord right,Screencoord bottom,Screencoord top);
long viewport_aligned(void);
void v2i(long lvert[2]);
void v3i(long lvert[3]);
void v2s(short svert[2]);
void v3s(short svert[3]);
void v2f(float fvert2[2]);
void v3f(float vert[3]);
void translate(float fx,float fy,float fz);
void rot(float angle,long axis);
void scale(float sx,float sy,float sz);

/* mice.c */
long start_gameport(void);
void stop_gameport(void);
void send_read_request(void);
void set_trigger_conditions(void);
long set_controller_type(BYTE type);
void free_gameport(void);
void flush_buffer(void);
long gameport_event(long *device,short *state,short *dx,short *dy);

/* poly.c */
void recti(long x1,long y1,long x2,long y2);
void rectfi(long x1,long y1,long x2,long y2);
void rects(short x1,short y1,short x2,short y2);
void rectfs(short x1,short y1,short x2,short y2);
void rect(float x1,float y1,float x2,float y2);
void rectf(float x1,float y1,float x2,float y2);
void rectvert(float x1,float y1,float x2,float y2,long line);
void bgnpoint(void);
void endpoint(void);
void bgnline(void);
void endline(void);
void bgnpolygon(void);
void endpolygon(void);
void render_vertex(short vert[2]);
void mapcolor(long m,long r,long g,long b);
void getmcolor(long m,long *r,long *g,long *b);
void color(long c);
long getcolor(void);
void clear(void);

/* que.c */
void qinit(void);
void tie(long dev,long valuator1,long valuator2);
void qdevice(long dev);
void unqdevice(long dev);
long isqueued(long dev);
void qenter(long dev,short val);
long qtest(void);
void delay(void);
long qread(short *data);
void qreset(void);
long getvaluator(long val);
long getbutton(long num);
void clear_buttons(long init);
void update_queue(short waitid);
void qenter_tie(long device,short data);
void quekeys(USHORT code,short inside);
short is_inside(long wid,short x,short y,short border);
short border_edge(long wid,short x,short y);
void border_action(long wid,short ox,short oy,short middle);
void do_move_and_resize(long wid,long movefirst,long movex,long movey,long sizex,long sizey);
void move_and_resize(long wid,long movefirst,long movex,long movey,long sizex,long sizey);
void clear_void(long wid,short x,short y);

/* rgb.c */
void initialize_RGB(void);
void c3f(float rgb[3]);
float index_dist(short index,float rgb[3]);
void create_pattern(UWORD *pattern,float rgb[3]);
void activate_pattern(UWORD *pattern);

/* sprite.c */
void create_mousesprite(void);
void move_mousesprite(long mx,long my);
void free_mousesprite(void);

/* text.c */
void cmov2i(long sx,long sy);
void cmovi(long sx,long sy,long sz);
void cmov2s(short sx,short sy);
void cmovs(short sx,short sy,short sz);
void cmov2(float fx,float fy);
void cmov(float fx,float fy,float fz);
void charstr(char *string);
void getcpos(short *cx,short *cy);

/* window.c */
void gversion(char *string);
long getgdesc(long inquiry);
void foreground(void);
void cmode(void);
void RGBmode(void);
void doublebuffer(void);
void singlebuffer(void);
long getdisplaymode(void);
void clone_new_bitmap(void);
void gconfig(void);
void swapbuffers(void);
void set_rasterport(void);
void winpush(void);
void winpop(void);
long winget(void);
void winset(long wid);
short get_dimensions(long wid,long whole,long *x,long *y,long *lenx,long *leny);
void sleep(long seconds);
void minsize(long x,long y);
void maxsize(long x,long y);
void prefposition(long x1,long x2,long y1,long y2);
void prefsize(long x,long y);
void noborder(void);
void winposition(long x1,long x2,long y1,long y2);
void winmove(long orgx,long orgy);
void wintitle(char *name);
void getsize(long *x,long *y);
void getorigin(long *x,long *y);
long winopen(char *title);
void gexit(void);
void winclose(long wid);
void initialize_nextwindow(void);
long AGLconfig(short screenx,short screeny,short bitplanes);
void gfxinit(void);
void GL_error(char *message);

