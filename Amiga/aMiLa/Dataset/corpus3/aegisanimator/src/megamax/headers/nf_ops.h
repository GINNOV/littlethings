#ifndef P
# define P(x) ()
#endif
#ifndef const
# define const
#endif
#ifndef __GNUC__
#  define __attribute__(x)
#endif

struct nf_ops
{
	long (*get_id) P((const char *));
	long (*call) P((long id, ...));
	long res[3];
};

#define NF_GET_ID(ops, feature) ((*ops->get_id)(feature))


#define NF_ID_NAME      "NF_NAME"
#define NF_ID_VERSION   "NF_VERSION"
#define NF_ID_STDERR    "NF_STDERR"
#define NF_ID_SHUTDOWN  "NF_SHUTDOWN"
#define NF_ID_DEBUG     "DEBUGPRINTF"
#define NF_ID_ETHERNET  "ETHERNET"
#define NF_ID_HOSTFS    "HOSTFS"
#define NF_ID_AUDIO     "AUDIO"
#define NF_ID_BOOTSTRAP "BOOTSTRAP"
#define NF_ID_CDROM     "CDROM"
#define NF_ID_CLIPBRD   "CLIPBRD"
#define NF_ID_JPEG      "JPEG"
#define NF_ID_OSMESA    "OSMESA"
#define NF_ID_PCI       "PCI"
#define NF_ID_FVDI      "fVDI"
#define NF_ID_USBHOST   "USBHOST"
#define NF_ID_XHDI      "XHDI"
#define NF_ID_SCSI      "NF_SCSIDRV"
#define NF_ID_HOSTEXEC  "HOSTEXEC"


struct nf_ops *nf_init P((void));
long nf_get_id P((const char *feature_name));
const char *nf_get_name P((char *buf, size_t bufsize));
const char *nf_get_fullname P((char *buf, size_t bufsize));
long nf_shutdown P((int mode));
int nf_debugprintf P((const char *fmt, ...)) __attribute__((__format__(__printf__, 1, 2)));
int nf_debugvprintf P((const char *fmt, va_list args));
long nf_exec P((const char *cmd));
long nf_execv P((long argc, const char *const *argv));
