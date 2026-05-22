#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <errno.h>
#include <time.h>
#include <math.h>
#include "Env.h"
#include <malloc.h>
#include <gl/glaux.h>

static char *GetShortVendorName(char *input);
static int GetHostMemorySize(void);
static char *GetHostVendor(void);
static char *GetHostModel(void);
static char *GetHostCPU(void);
static char *GetHostOperatingSystem(void);
static char *GetHostOperatingSystemRelease(void);
static char *GetHostName(void);
static char *GetOpenGLClientVendor(void);
static char *GetOpenGLClientVersion(void);
static char *GetOpenGLClientExtensions(void);
static char *GetHostCPUCount(void);
static char *GetHostPrimaryCacheSize(void);
static char *GetHostSecondaryCacheSize(void);
static char *GetWindowSystem(void);
static char *GetDriverVersion(void);


/******************************************************************************
 *
 * StringSearch - search for pattern in string
 *
 * Description:
 *  StringSearch returns a pointer to the first occurance of pattern found in
 *  the subject or NULL if the pattern is not found. It implements the
 *  Knuth-Morris-Pratt pattern matching algorithm. If m is the length of the
 *  pattern and n is the length of the subject, the complexity of the KMP
 *  algorithm is (m+n), much better than the (m*n) complexity of the naive
 *  nested loop algorithm. - John Dennis
 *
 * Returns:
 *  pointer to the first occurance of pattern found the subject or NULL
 *
 * Side Effects:
 *  None
 *
 * Errors:
 *  None
 *
 * Revision History:
 *  Revision 0: Author: John R. Dennis Date: Thu Aug  4 15:49:59 1994
 *    Initial Release
 *
 *****************************************************************************/
char *
StringSearch(char *subject, char *pattern)
{
#define MAX_FLINK (256)
  int *flink, *dynamicFlink = NULL, staticFlink[MAX_FLINK];
  int patternLen = strlen(pattern);
  int subjectLen = strlen(subject);
  int found = 0;
  int i,j;

  if (patternLen > MAX_FLINK) {      /* -1 for NULL terminator */
    dynamicFlink = malloc(patternLen * sizeof(int));
    if (dynamicFlink == NULL) {
      fprintf(stderr, "malloc failure, line %d, file: %s, exiting...\n",
	      __LINE__, __FILE__);
      exit(1);
    }
    flink = dynamicFlink;
  }
  else {
    flink = staticFlink;
  }


  /* Step 1: Constuct Flowchart */
  flink[0] = -1;		       /* -1 == read next char */
  for(i = 1; i < patternLen; i++) {
    j = flink[i-1];
    while((j >= 0) && (pattern[j] != pattern[i-1])) {
      j = flink[j];
    }
    flink[i] = j+1;
  }

  /* Step 2: Scan Algorithm */
  for (i = j = 0; i < subjectLen; i++, j++) {
    while((j >= 0) && (pattern[j] != subject[i])) {
      j = flink[j];
    }
    if (j == patternLen-1) {
      found = 1;
      goto exit;
    }
  }

 exit:
  if (dynamicFlink != NULL) free(dynamicFlink);
  if (!found)
    return(NULL);
  else
    return(&subject[i-patternLen+1]);
#undef MAX_FLINK
}


/******************************************************************************
 *
 * GetShortVendorName - return short vendor string
 *
 * Description:
 *  some vendor strings are verbose. This function will return a shortest
 *  vendor name it can given an arbitrary vendor string. The returned string
 *  is allocated with malloc, it should be freed when no longer in use. The
 *  input string is not freed or modified by this function.
 *
 * Returns:
 *  pointer to allocated string
 *
 * Side Effects:
 *  string allocation, string should be freed when no longer needed.
 *
 * Errors:
 *  no errors, if function fails the string "unknown" is returned
 *
 * Revision History:
 *  Revision 0: Author: John R. Dennis Date: Mon Aug  8 16:30:53 1994
 *    Initial Release
 *
 *****************************************************************************/
static char *
GetShortVendorName(char *input)
{
  int i;
  char *s1 = NULL;              /* s1 is temp work string */
  char *s2 = NULL;              /* s2 is string to return */

  /* duplicate input string so that we can modify it */
  s1 = strdup(input);
  /* upcase string */
  for (i = 0; s1[i]; i++)
    if (islower(s1[i])) s1[i] = toupper(s1[i]);

  /* return a short name if possible, some vendor names are verbose */
  if (StringSearch(s1, "DEC") ||
      StringSearch(s1, "DECWINDOWS") ||
      StringSearch(s1, "Digital Equipment Corporation") ||
      StringSearch(s1, "DigitalEquipmentCorporation"))
    s2 = strdup("DEC");
  else if (StringSearch(s1, "SGI") ||
	   StringSearch(s1, "SILCON GRAPHICS"))
    s2 = strdup("SGI");
  else if (StringSearch(s1, "IBM") ||
	   StringSearch(s1, "INTERNATIONAL BUSINESS MACHINES"))
    s2 = strdup("IBM");
  else
    s2 = strdup(s1);

  free(s1);
  return(s2);
}


/******************************************************************************
 *
 * GetHostMemorySize - Return kilobytes of memory installed on host platform
 *
 * Description:
 *  Returns the number of kilobytes of memory installed on host platform
 *
 * Returns:
 *  kilobytes of host platform memory
 *
 * Side Effects:
 *  None
 *
 * Errors:
 *  return 0 if unable to determine memory configuration
 *
 * Revision History:
 *  Revision 0: Author: John R. Dennis Date: Thu Aug  4 15:55:19 1994
 *    Initial Release
 *
 *****************************************************************************/
static int
GetHostMemorySize(void)
{
  /* AvailMem */
  return (24 * 1024 * 1024) / 1024;
}


/******************************************************************************
 *
 * GetHostVendor - return string naming the system vendor
 *
 * Description:
 *  return the name of the system vendor as a string. This is to identify
 *  manufacturer of the system. The string is allocated with malloc, it should
 *  be freed when no longer in use.
 *
 * Returns:
 *  pointer to allocated string
 *
 * Side Effects:
 *  string allocation, string should be freed when no longer needed.
 *
 * Errors:
 *  no errors, if function fails the string "unknown" is returned
 *
 * Revision History:
 *  Revision 0: Author: John R. Dennis Date: Mon Aug  8 16:30:53 1994
 *    Initial Release
 *
 *****************************************************************************/
static char *
GetHostVendor(void)
{
  /* See if it's a DEC system */
  char *hostModel;

  hostModel = GetHostModel();
  if ( strstr(hostModel,"DEC") == hostModel)
  {
    free(hostModel);
    return(strdup("DEC"));
  }
  else
  {
    free(hostModel);
    return(strdup("unknown"));
  }
}


/******************************************************************************
 *
 * GetHostModel - return string naming the host model
 *
 * Description:
 * return string identifying the host platform's model designation. The string
 * is allocated with malloc, it should be freed when no longer in use.
 *
 * Returns:
 *  pointer to allocated string
 *
 * Side Effects:
 *  string allocation, string should be freed when no longer needed.
 *
 * Errors:
 *  no errors, if function fails the string "unknown" is returned
 *
 * Revision History:
 *  Revision 0: Author: John R. Dennis Date: Mon Aug  8 16:30:53 1994
 *    Initial Release
 *
 *****************************************************************************/
static char *
GetHostModel(void)
{
  return strdup("AmigaOS");
}


/******************************************************************************
 *
 * GetHostCPU - return string naming the host CPU
 *
 * Description:
 * return string identifying the host platform's CPU. The string
 * is allocated with malloc, it should be freed when no longer in use.
 *
 * Returns:
 *  pointer to allocated string
 *
 * Side Effects:
 *  string allocation, string should be freed when no longer needed.
 *
 * Errors:
 *  no errors, if function fails the string "unknown" is returned
 *
 * Revision History:
 *  Revision 0: Author: John R. Dennis Date: Mon Aug  8 16:30:53 1994
 *    Initial Release
 *
 *****************************************************************************/
static char *
GetHostCPU(void)
{
  return strdup("Motorola MC68030 (30MHz), MC68882 (30MHz)");
}


/******************************************************************************
 *
 * GetHostCPUCount - return string indicating number of host CPU's
 *
 * Description:
 * return string indicating number of host CPU's. The string "unknown" is
 * returned if the count is not determinable. The string is allocated with
 * malloc, it should be freed when no longer in use.
 *
 * Returns:
 *  pointer to allocated string
 *
 * Side Effects:
 *  string allocation, string should be freed when no longer needed.
 *
 * Errors:
 *  no errors, if function fails the string "unknown" is returned
 *
 * Revision History:
 *  Revision 0: Author: John R. Dennis Date: Mon Feb 27 14:18:41 EST 1995
 *    Initial Release
 *
 *****************************************************************************/
static char *
GetHostCPUCount(void)
{
  return(strdup("unknown"));
}

/******************************************************************************
 *
 * GetHostPrimaryCacheSize - return string indicating host's primary cache (KB)
 *
 * Description:
 * return string indicating the number of kilobytes of primary cache on the
 * host's CPU, or "unknown" if not determinable. The string
 * is allocated with malloc, it should be freed when no longer in use.
 *
 * Returns:
 *  pointer to allocated string
 *
 * Side Effects:
 *  string allocation, string should be freed when no longer needed.
 *
 * Errors:
 *  no errors, if function fails the string "unknown" is returned
 *
 * Revision History:
 *  Revision 0: Author: John R. Dennis Date: Mon Feb 27 14:18:41 EST 1995
 *    Initial Release
 *
 *****************************************************************************/
static char *
GetHostPrimaryCacheSize(void)
{
  return(strdup("0 KB"));
}

/******************************************************************************
 *
 * GetHostSecondaryCacheSize - return string indicating host's secondary cache (KB)
 *
 * Description:
 * return string indicating the number of kilobytes of secondary cache on the
 * host's CPU, or "unknown" if not determinable. The string
 * is allocated with malloc, it should be freed when no longer in use.
 *
 * Returns:
 *  pointer to allocated string
 *
 * Side Effects:
 *  string allocation, string should be freed when no longer needed.
 *
 * Errors:
 *  no errors, if function fails the string "unknown" is returned
 *
 * Revision History:
 *  Revision 0: Author: John R. Dennis Date: Mon Feb 27 14:18:41 EST 1995
 *    Initial Release
 *
 *****************************************************************************/
static char *
GetHostSecondaryCacheSize(void)
{
  return(strdup("0 KB"));
}

/******************************************************************************
 *
 * GetWindowSystem - return string naming the windowing system
 *
 * Description:
 * return string identifying the windowing system in use on the target
 * device. The string is allocated with malloc, it should be freed when no
 * longer in use.
 *
 * Returns:
 *  pointer to allocated string
 *
 * Side Effects:
 *  string allocation, string should be freed when no longer needed.
 *
 * Errors:
 *  no errors, if function fails the string "unknown" is returned
 *
 * Revision History:
 *  Revision 0: Author: John R. Dennis Date: Mon Aug  8 16:30:53 1994
 *    Initial Release
 *
 *****************************************************************************/
static char *
GetWindowSystem(void)
{
  return(strdup("MesaGL"));
}

/******************************************************************************
 *
 * GetDriverVersion - return string identifying the graphics driver
 *
 * Description:
 * Return string identifying the graphics driver version. If there is no
 * graphics driver than the string "NA" is returned. If a graphics driver
 * exists, but the function cannot identify it then the string "unknown" is
 * returned.  The string is allocated with malloc, it should be freed when no
 * longer in use.
 *
 * Returns:
 *  pointer to allocated string
 *
 * Side Effects:
 *  string allocation, string should be freed when no longer needed.
 *
 * Errors:
 *  no errors, if function fails the string "unknown" is returned
 *
 * Revision History:
 *  Revision 0: Author: John R. Dennis Date: Mon Feb 27 15:00:18 EST 1995
 *    Initial Release
 *
 *****************************************************************************/
static char *
GetDriverVersion(void)
{
  return(strdup("3.0"));
}

/******************************************************************************
 *
 * GetHostOperatingSystem - return string naming the host CPU operating system
 *
 * Description:
 *  return the type of the host operating system as a string. This is to
 *  identify what type of operating system this program is running under. The
 *  string is allocated with malloc, it should be freed when no longer in use.
 *
 * Returns:
 *  pointer to allocated string
 *
 * Side Effects:
 *  string allocation, string should be freed when no longer needed.
 *
 * Errors:
 *  no errors, if function fails the string "unknown" is returned
 *
 * Revision History:
 *  Revision 0: Author: John R. Dennis Date: Mon Aug  8 16:30:53 1994
 *    Initial Release
 *
 *****************************************************************************/
static char *
GetHostOperatingSystem(void)
{
  return(strdup("AmigaOS 3.1"));
}


/******************************************************************************
 *
 * GetHostOperatingSystemRelease - return string naming operating system release
 *
 * Description:
 *  return the release/version of the host operating system as a string. This
 *  is to identify what version of the operating system this program is
 *  running under. The string is allocated with malloc, it should be freed
 *  when no longer in use.
 *
 * Returns:
 *  pointer to allocated string
 *
 * Side Effects:
 *  string allocation, string should be freed when no longer needed.
 *
 * Errors:
 *  no errors, if function fails the string "unknown" is returned
 *
 * Revision History:
 *  Revision 0: Author: John R. Dennis Date: Mon Aug  8 16:30:53 1994
 *    Initial Release
 *
 *****************************************************************************/
static char *
GetHostOperatingSystemRelease(void)
{
  return(strdup("40.72"));
}


/******************************************************************************
 *
 * GetHostName - return string naming the host
 *
 * Description:
 *  return the name of this host as a string. This is to identify which
 *  platform this program is running on. The string is allocated with malloc,
 *  it should be freed when no longer in use.
 *
 * Returns:
 *  pointer to allocated string
 *
 * Side Effects:
 *  string allocation, string should be freed when no longer needed.
 *
 * Errors:
 *  no errors, if function fails the string "unknown" is returned
 *
 * Revision History:
 *  Revision 0: Author: John R. Dennis Date: Mon Aug  8 16:30:53 1994
 *    Initial Release
 *
 *****************************************************************************/
static char *
GetHostName(void)
{
  return(strdup("RamsesIII"));
}


/******************************************************************************
 *
 * GetDateTime - get the current month, day, year, hour, minute
 *
 * Description:
 *  Get the current  day, month, year, hour, minute. Each is a pointer to an
 *  integer. If the pointer is NULL then no value is returned for that
 *  parameter, otherwise an assignment is made to the integer pointed to by
 *  the parameter.
 *
 *  month:  in the range [1-12] 1=January, 12=December
 *  day:    in the range [1-31]
 *  year:   as a 4 digit number, e.g. 1994
 *  hour:   in the range [0-23]
 *  min:    in the range [0-59]
 *
 * Returns:
 *  0 for success, error code otherwise
 *
 * Side Effects:
 *  None
 *
 * Errors:
 *  return non-zero on failure
 *
 * Revision History:
 *  Revision 0: Author: John R. Dennis Date: Wed Aug 17 13:08:36 1994
 *    Initial Release
 *
 *****************************************************************************/

int
GetDateTime(int *month, int *day, int *year, int *hour, int *minute)
{
  time_t timeT;
  struct tm *timeTm;

  time(&timeT);
  timeTm = localtime(&timeT);
  if (timeTm == NULL) {
    fprintf(stderr, "Error calling localtime: %d\n", errno);
    return(errno);
  }
  if (month)  *month  = timeTm->tm_mon + 1;
  if (day)    *day    = timeTm->tm_mday;
  if (year)   *year   = timeTm->tm_year + 1900;
  if (hour)   *hour   = timeTm->tm_hour;
  if (minute) *minute = timeTm->tm_min;
  return(0);
}


/******************************************************************************
 *
 * GetOpenGLClientVendor - return string naming the client library vendor
 *
 * Description:
 *  return the name of the vendor supplying the OpenGL client library.  The
 *  string is allocated with malloc,it should be freed when no longer in use.
 *
 * Returns:
 *  pointer to allocated string
 *
 * Side Effects:
 *  string allocation, string should be freed when no longer needed.
 *
 * Errors:
 *  no errors, if function fails the string "unknown" is returned
 *
 * Revision History:
 *  Revision 0: Author: John R. Dennis Date: Mon Aug  8 16:30:53 1994
 *    Initial Release
 *
 *****************************************************************************/
static char *
GetOpenGLClientVendor(void)
{
  char *pstr;
  if (pstr = (char *)glGetString(GL_VENDOR))
    return(GetShortVendorName(pstr));
  else
    return(strdup("unknown"));
}


/******************************************************************************
 *
 * GetOpenGLClientVersion - return string naming the client library version
 *
 * Description:
 *  return the version of the OpenGL client library.  The string is allocated
 *  with malloc,it should be freed when no longer in use.
 *
 * Returns:
 *  pointer to allocated string
 *
 * Side Effects:
 *  string allocation, string should be freed when no longer needed.
 *
 * Errors:
 *  no errors, if function fails the string "unknown" is returned
 *
 * Revision History:
 *  Revision 0: Author: John R. Dennis Date: Mon Aug  8 16:30:53 1994
 *    Initial Release
 *
 *****************************************************************************/
static char *
GetOpenGLClientVersion(void)
{
  char *pstr;
  if (pstr = (char *)glGetString(GL_VERSION))
    return(strdup(pstr));
  else
    return(strdup("unknown"));
}


/******************************************************************************
 *
 * GetOpenGLClientExtensions - return string naming the client extensions
 *
 * Description:
 *  return the extensions supported in the OpenGL client library.  The string
 *  is allocated with malloc,it should be freed when no longer in use.
 *
 * Returns:
 *  pointer to allocated string
 *
 * Side Effects:
 *  string allocation, string should be freed when no longer needed.
 *
 * Errors:
 *  no errors, if function fails the string "unknown" is returned
 *
 * Revision History:
 *  Revision 0: Author: John R. Dennis Date: Mon Aug  8 16:30:53 1994
 *    Initial Release
 *
 *****************************************************************************/
static char *
GetOpenGLClientExtensions(void)
{
  char *pstr;
  if (pstr = (char *)glGetString(GL_EXTENSIONS))
    return(strdup(pstr));
  else
    return(strdup("unknown"));
}



/******************************************************************************
 *
 * GetEnvironment - return info about environment test was run in
 *
 * Description:
 *  This function fills in an environment info record with every pertinent
 *  piece of information about the condiditons under which the test was run.
 *
 * Returns:
 *  0 success, error code otherwise
 *
 * Side Effects:
 *  None
 *
 * Errors:
 *  errors generally only with bad configurations, too many to list
 *
 * Revision History:
 *  Revision 0: Author: John R. Dennis Date: Thu Aug 18 16:52:35 1994
 *    Initial Release
 *
 *****************************************************************************/

#include <intuition/intuition.h>
#include <intuition/screens.h>
#include <gl/amigamesa.h>

void
GetAOSEnvironment(EnvironmentInfo *info) {
  struct amigamesa_context *amesa;
  
  if(!(amesa = auxAOSContext()))
    return;
  
  info->windowWidth = amesa->window->GZZWidth;
  info->windowHeight = amesa->window->GZZHeight;
  info->screenWidth = amesa->Screen->Width;
  info->screenHeight = amesa->Screen->Height;
  
  info->bufConfig.doubleBuffer = amesa->visual->db_flag;
  info->bufConfig.stereo = -1;
  if(!(info->bufConfig.rgba = amesa->visual->rgb_flag)) {
    info->bufConfig.indexSize = amesa->visual->depth;

    info->bufConfig.redSize = -1;
    info->bufConfig.greenSize = -1;
    info->bufConfig.blueSize = -1;
    info->bufConfig.alphaSize = -1;
    info->bufConfig.accumRedSize = -1;
    info->bufConfig.accumGreenSize = -1;
    info->bufConfig.accumBlueSize = -1;
    info->bufConfig.accumAlphaSize = -1;
  }
  else {
    info->bufConfig.indexSize = -1;

    info->bufConfig.redSize = amesa->visual->gl_visual->RedBits;
    info->bufConfig.greenSize = amesa->visual->gl_visual->GreenBits;
    info->bufConfig.blueSize = amesa->visual->gl_visual->BlueBits;
    info->bufConfig.alphaSize = amesa->visual->gl_visual->AlphaBits;
    info->bufConfig.accumRedSize = amesa->visual->gl_visual->AccumBits;
    info->bufConfig.accumGreenSize = amesa->visual->gl_visual->AccumBits;
    info->bufConfig.accumBlueSize = amesa->visual->gl_visual->AccumBits;
    info->bufConfig.accumAlphaSize = amesa->visual->gl_visual->AccumBits;
  }

  info->bufConfig.depthSize = amesa->visual->gl_visual->DepthBits;
  info->bufConfig.stencilSize = amesa->visual->gl_visual->StencilBits;

  info->bufConfig.auxBuffers = 0;
}

int
GetEnvironment(EnvironmentInfo *info)
{
  GLenum windType;

  FreeEnvironmentData(info);

  GetDateTime(&info->month, &info->day, &info->year, NULL, NULL);
  info->host = GetHostName();
  info->hostOperatingSystem = GetHostOperatingSystem();
  info->hostOperatingSystemVersion = GetHostOperatingSystemRelease();
  info->hostVendor = GetHostVendor();
  info->hostModel = GetHostModel();
  info->hostCPU = GetHostCPU();
  info->hostCPUCount = GetHostCPUCount();
  info->hostPrimaryCacheSize = GetHostPrimaryCacheSize();
  info->hostSecondaryCacheSize = GetHostSecondaryCacheSize();
  info->windowSystem = GetWindowSystem();
  info->driverVersion = GetDriverVersion();
  info->hostMemorySize = GetHostMemorySize() / 1024; /* kilobytes to MB */
  info->glVendor = GetShortVendorName((char *)glGetString(GL_VENDOR));
  info->glVersion = strdup((char *)glGetString(GL_VERSION));
  info->glRenderer = strdup((char *)glGetString(GL_RENDERER));
  info->glExtensions = strdup((char *)glGetString(GL_EXTENSIONS));
  info->glClientVendor = GetOpenGLClientVendor();
  info->glClientVersion = GetOpenGLClientVersion();
  info->glClientExtensions = GetOpenGLClientExtensions();

#ifdef GLU_VERSION_1_1
  info->gluVersion = strdup((char *)gluGetString(GLU_VERSION));;
  info->gluExtensions = strdup((char *)gluGetString(GLU_EXTENSIONS));;
#else
  info->gluVersion = strdup("unknown");
  info->gluExtensions = strdup("unknown");
#endif

  GetAOSEnvironment(info);

#if defined(WIN32)
  /*
   * There is no direct rendering at this time.
   */
  info->directRender = FALSE;
#else
  /*
   * Direct rendering is a "request", not a guarantee. We need to check the
   * direct render bit for each test because the GL context is only set up
   * in the above conditional block. If we didn't check it for each test
   * then the value for direct rendering store in the test descriptor would
   * be the "request" value, not the actual value.
   */

  windType = auxGetDisplayMode();
  if (windType & AUX_DIRECT)
    info->directRender = TRUE;
  else
    info->directRender = FALSE;
#endif

	return (0);
}



/******************************************************************************
 *
 * FreeEnvironmentData - frees all dynamic data in EnvironmentInfo struct
 *
 * Description:
 *  Free all the dynamically allocated data in an EnvironmentInfo struct. Each
 *  pointer in the struct is assigned the value of NULL after its data has
 *  been freed. The struct itself is not freed.
 *
 * Returns:
 *  void
 *
 * Side Effects:
 *  free dynamically allocated memory
 *
 * Errors:
 *  None
 *
 * Revision History:
 *  Revision 0: Author: John R. Dennis Date: Tue Sep 13 17:31:19 1994
 *    Initial Release
 *
 *****************************************************************************/

void
FreeEnvironmentData(EnvironmentInfo *info)
{
  if (info->host != NULL) free(info->host);
  if (info->hostOperatingSystem != NULL) free(info->hostOperatingSystem);
  if (info->hostOperatingSystemVersion != NULL) free(info->hostOperatingSystemVersion);
  if (info->hostVendor != NULL) free(info->hostVendor);
  if (info->hostModel != NULL) free(info->hostModel);
  if (info->hostCPU != NULL) free(info->hostCPU);
  if (info->hostCPUCount != NULL) free(info->hostCPUCount);
  if (info->hostPrimaryCacheSize != NULL) free(info->hostPrimaryCacheSize);
  if (info->hostSecondaryCacheSize != NULL) free(info->hostSecondaryCacheSize);
  if (info->windowSystem != NULL) free(info->windowSystem);
  if (info->driverVersion != NULL) free(info->driverVersion);
  if (info->glVendor != NULL) free(info->glVendor);
  if (info->glVersion != NULL) free(info->glVersion);
  if (info->glRenderer != NULL) free(info->glRenderer);
  if (info->glExtensions != NULL) free(info->glExtensions);
  if (info->glClientVendor != NULL) free(info->glClientVendor);
  if (info->glClientVersion != NULL) free(info->glClientVersion);
  if (info->glClientExtensions != NULL) free(info->glClientExtensions);
  if (info->gluVersion != NULL) free(info->gluVersion);
  if (info->gluExtensions != NULL) free(info->gluExtensions);
  NullEnvironmentData(info);
}


/******************************************************************************
 *
 * NullEnvironmentData - sets all dynamic data ptrs in EnvironmentInfo to NULL
 *
 * Description:
 *  Sets all the pointers to dynamically allocated data in an EnvironmentInfo
 *  struct to NULL. The data pointed to by the pointers are not freed, use the
 *  function FreeEnvironmentData for that purpose.
 *
 * Returns:
 *  void
 *
 * Side Effects:
 *  None
 *
 * Errors:
 *  None
 *
 * Revision History:
 *  Revision 0: Author: John R. Dennis Date: Tue Sep 13 17:31:19 1994
 *    Initial Release
 *
 *****************************************************************************/

void
NullEnvironmentData(EnvironmentInfo *info)
{
    info->host = NULL;
    info->hostOperatingSystem = NULL;
    info->hostOperatingSystemVersion = NULL;
    info->hostVendor = NULL;
    info->hostModel = NULL;
    info->hostCPU = NULL;
    info->hostCPUCount = NULL;
    info->hostPrimaryCacheSize = NULL;
    info->hostSecondaryCacheSize = NULL;
    info->windowSystem = NULL;
    info->driverVersion = NULL;
    info->glVendor = NULL;
    info->glVersion = NULL;
    info->glRenderer = NULL;
    info->glExtensions = NULL;
    info->glClientVendor = NULL;
    info->glClientVersion = NULL;
    info->glClientExtensions = NULL;
    info->gluVersion = NULL;
    info->gluExtensions = NULL;
}



/******************************************************************************
 *
 * PrintEnvironment - print contents of EnvironmentInfo struct
 *
 * Description:
 *  Print the contents of EnvironmentInfo struct. The stream parameter Points
 *  to a FILE structure specifying an open stream to which output will be
 *  written. The title parameter is a pointer to a string which will be output
 *  before any of the EnvironmentInfo data is output, The title string may be
 *  NULL in which case no title string will be written. The leader parameter
 *  is a pointer to a string which will be output before each field in the
 *  EnvironmentInfo struct. The nameWidth parameter is an integer parameter
 *  specifying how pad the name of each field. This can be used to cause the
 *  values to line up in a column. A positive value left justifies, a negative
 *  value right justifies. The suffix parameter is a pointer to a string which
 *  will be output after all of the EnvironmentInfo data is output, The suffix
 *  string may be NULL in which case no suffix string will be written.
 *
 * Returns:
 *  void
 *
 * Side Effects:
 *  file stream output
 *
 * Errors:
 *  None
 *
 * Revision History:
 *  Revision 0: Author: John R. Dennis Date: Wed Sep 14 09:02:57 1994
 *    Initial Release
 *
 *****************************************************************************/

void
PrintEnvironment(FILE *stream, EnvironmentInfo *info, char *title,
                 char *leader, int nameWidth, char *suffix)
{
  if (title) fprintf(stream, "%s", title);

  fprintf(stream, "%s%*s%d\n", leader, nameWidth,
         "Month", info->month);
  fprintf(stream, "%s%*s%d\n", leader, nameWidth,
         "Day", info->day);
  fprintf(stream, "%s%*s%d\n", leader, nameWidth,
         "Year", info->year);
  fprintf(stream, "%s%*s%s\n", leader, nameWidth,
         "Host", info->host);
  fprintf(stream, "%s%*s%s\n", leader, nameWidth,
         "Operating System", info->hostOperatingSystem);
  fprintf(stream, "%s%*s%s\n", leader, nameWidth,
         "Operating System Version", info->hostOperatingSystemVersion);
  fprintf(stream, "%s%*s%s\n", leader, nameWidth,
         "Host Vendor", info->hostVendor);
  fprintf(stream, "%s%*s%s\n", leader, nameWidth,
         "Host Model", info->hostModel);
  fprintf(stream, "%s%*s%s\n", leader, nameWidth,
         "Host CPU", info->hostCPU);
  fprintf(stream, "%s%*s%s\n", leader, nameWidth,
         "Host CPU Count", info->hostCPUCount);
  fprintf(stream, "%s%*s%d\n", leader, nameWidth,
         "Host Memory Size (MB)", info->hostMemorySize);
  fprintf(stream, "%s%*s%s\n", leader, nameWidth,
         "Host Primary Cache Size (KB)", info->hostPrimaryCacheSize);
  fprintf(stream, "%s%*s%s\n", leader, nameWidth,
         "Host Secondary Cache Size (KB)", info->hostSecondaryCacheSize);
  fprintf(stream, "%s%*s%s\n", leader, nameWidth,
         "Window System", info->windowSystem);
  fprintf(stream, "%s%*s%s\n", leader, nameWidth,
          "Driver Version", info->driverVersion);
  fprintf(stream, "%s%*s%s\n", leader, nameWidth,
         "OpenGL Vendor", info->glVendor);
  fprintf(stream, "%s%*s%s\n", leader, nameWidth,
         "OpenGL Version", info->glVersion);
  fprintf(stream, "%s%*s%s\n", leader, nameWidth,
         "OpenGL Extensions", info->glExtensions);
  fprintf(stream, "%s%*s%s\n", leader, nameWidth,
         "OpenGL Renderer", info->glRenderer);
  fprintf(stream, "%s%*s%s\n", leader, nameWidth,
         "OpenGL Client Vendor", info->glClientVendor);
  fprintf(stream, "%s%*s%s\n", leader, nameWidth,
         "OpenGL Client Version", info->glClientVersion);
  fprintf(stream, "%s%*s%s\n", leader, nameWidth,
         "OpenGL Client Extensions", info->glClientExtensions);
  fprintf(stream, "%s%*s%s\n", leader, nameWidth,
         "GLU Version", info->gluVersion);
  fprintf(stream, "%s%*s%s\n", leader, nameWidth,
         "GLU Extensions", info->gluExtensions);
  fprintf(stream, "%s%*s%s\n", leader, nameWidth,
         "Direct Rendering", info->directRender ? "True" : "False");
  fprintf(stream, "%s%*s%s\n", leader, nameWidth,
         "Double Buffer", info->bufConfig.doubleBuffer ? "True" : "False");
  fprintf(stream, "%s%*s%s\n", leader, nameWidth,
         "Stereo", info->bufConfig.stereo ? "True" : "False");
  fprintf(stream, "%s%*s%s\n", leader, nameWidth,
         "RGBA", info->bufConfig.rgba ? "True" : "False");
  fprintf(stream, "%s%*s%d\n", leader, nameWidth,
         "Color Index Size", info->bufConfig.indexSize);
  fprintf(stream, "%s%*s%d\n", leader, nameWidth,
         "Red Size", info->bufConfig.redSize);
  fprintf(stream, "%s%*s%d\n", leader, nameWidth,
         "Green Size", info->bufConfig.greenSize);
  fprintf(stream, "%s%*s%d\n", leader, nameWidth,
         "Blue Size", info->bufConfig.blueSize);
  fprintf(stream, "%s%*s%d\n", leader, nameWidth,
         "Alpha Size", info->bufConfig.alphaSize);
  fprintf(stream, "%s%*s%d\n", leader, nameWidth,
         "Accum Red Size", info->bufConfig.accumRedSize);
  fprintf(stream, "%s%*s%d\n", leader, nameWidth,
         "Accum Green Size", info->bufConfig.accumGreenSize);
  fprintf(stream, "%s%*s%d\n", leader, nameWidth,
         "Accum Blue Size", info->bufConfig.accumBlueSize);
  fprintf(stream, "%s%*s%d\n", leader, nameWidth,
         "Accum Alpha Size", info->bufConfig.accumAlphaSize);
  fprintf(stream, "%s%*s%d\n", leader, nameWidth,
         "Depth Size", info->bufConfig.depthSize);
  fprintf(stream, "%s%*s%d\n", leader, nameWidth,
         "Stencil Size", info->bufConfig.stencilSize);
  fprintf(stream, "%s%*s%d\n", leader, nameWidth,
         "Auxiliary Buffer Count", info->bufConfig.auxBuffers);
  fprintf(stream, "%s%*s%d\n", leader, nameWidth,
         "Frame BufferLevel", info->bufConfig.level);
  fprintf(stream, "%s%*s%d\n", leader, nameWidth,
         "Window Width (pixels)", info->windowWidth);
  fprintf(stream, "%s%*s%d\n", leader, nameWidth,
         "Window Height (pixels)", info->windowHeight);
  fprintf(stream, "%s%*s%d\n", leader, nameWidth,
         "Screen Width (pixels)", info->screenWidth);
  fprintf(stream, "%s%*s%d\n", leader, nameWidth,
         "Screen Height (pixels)", info->screenHeight);
  if (suffix) fprintf(stream, "%s", suffix);
}

