#ifndef TRACKER_AMIGA_APPLICATION_H
#define TRACKER_AMIGA_APPLICATION_H

#include "BasicTypes.h"

#include <exec/exec.h>
#include <intuition/intuition.h>
#include <workbench/startup.h>
#include <workbench/workbench.h>

#include <vampire/saga.h>
#include <vampire/vampire.h>

#include <proto/vampire.h>
#include <proto/Picasso96.h>
#include <proto/cybergraphics.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/graphics_protos.h>
#include <clib/keymap_protos.h>
#include <clib/timer_protos.h>
#include <clib/intuition_protos.h>
#include <clib/Picasso96_protos.h>
#include <clib/vampire_protos.h>
#include <clib/icon_protos.h>
#include <clib/gadtools_protos.h>

#include <hardware/intbits.h>

class Tracker;
class DisplayDevice_Amiga;
class PPScreen;
class PPEvent;
class AudioDriverInterface;

class AmigaApplication
{
public:
    enum AudioDriver {
        Paula = 0,
        Arne
    };

    enum AudioMixer {
        ResampleHW = 0,
        DirectOut,
        MixDown
    };
private:
    int                     cpuType;
    bool                    hasFPU;
    bool                    hasAMMX;
    bool                    useSAGA;
    bool                    isV4Core;
    bool                    useP96;
    bool                    useCGX;
    pp_uint32               bpp;
    bool                    noSplash;
    bool                    running;
    bool                    trackerStartUpFinished;
    char *                  loadFile;
    bool                    showAlert;
    LONG                    displayID;
    AudioDriver             audioDriver;
    AudioMixer              audioMixer;

    Tracker *               tracker;
    DisplayDevice_Amiga *   displayDevice;
    PPScreen *              trackerScreen;
    PPSize                  windowSize;
    PPSystemString          oldCwd;
    char                    currentTitle[256];
    char                    currentAlert[256];

    struct Window *         window;
    struct Screen *         screen;
    struct Screen *         pubScreen;
    struct Task *           task;

    struct Interrupt *      irqVerticalBlank;
    pp_int32                vbSignal;
    pp_uint32               vbMask;
    pp_uint32               vbCount;

    PPPoint                 mousePosition;
    PPPoint                 mouseLastClickPos;

    pp_uint32               mouseLeftSeconds;
    pp_uint32               mouseLeftMicros;
    bool                    mouseLeftDown;
    pp_uint32               mouseLeftVBStart;

    pp_uint32               mouseRightSeconds;
    pp_uint32               mouseRightMicros;
    bool                    mouseRightDown;
    pp_uint32               mouseRightVBStart;

    bool                    keyQualifierShiftPressed;
    bool                    keyQualifierCtrlPressed;
    bool                    keyQualifierAltPressed;

    int                     load(char * loadFile);
    void                    raiseEventSynchronized(PPEvent * event);
    void                    resetScreenAlert();

    void                    setMousePosition(pp_int32 x, pp_int32 y);

    static pp_int32         verticalBlankService(register AmigaApplication * that __asm("a1"));
    pp_int32                verticalBlank();
public:
    int                     start();
    void                    loop();
    int                     stop();

    bool                    isFullScreen() const { return displayID != -1; }
    bool                    isAMMX() const { return hasAMMX; }
    bool                    isSAGA() const { return useSAGA; }
    bool                    isV4() const { return isV4Core; }
    bool                    isP96() const { return useP96; }
    bool                    isCGX() const { return useCGX; }

    struct Screen *         getScreen() const;
    struct Window *         getWindow() const { return window; }

    const PPSize&           getWindowSize() const { return windowSize; }
    pp_uint32               getBpp() const { return bpp; }
    AudioDriverInterface *  createAudioDriver();
    AudioDriver             getAudioDriver() const { return audioDriver; }
    AudioMixer              getAudioMixer() const { return audioMixer; }

    void                    setRunning(bool running) { this->running = running; }
    void                    setCpuType(int cpuType) { this->cpuType = cpuType; }
	void                    setHasFPU(bool hasFPU) { this->hasFPU = hasFPU; }
	void                    setHasAMMX(bool hasAMMX) { this->hasAMMX = hasAMMX; }
    void                    setWindowSize(const PPSize& size) { this->windowSize = size; }
    void                    setBpp(pp_uint32 bpp) { this->bpp = bpp; }
    void                    setNoSplash(bool noSplash) { this->noSplash = noSplash; }
    void                    setLoadFile(char * loadFile) { this->loadFile = loadFile; }
    void                    setWindowTitle(const char * title);
    void                    setScreenAlert(const char * title);
    void                    setUseSAGA(bool useSAGA) { this->useSAGA = useSAGA; }
    void                    setIsV4Core(bool isV4Core) { this->isV4Core = isV4Core; }
    void                    setUseP96(bool useP96) { this->useP96 = useP96; }
    void                    setUseCGX(bool useCGX) { this->useCGX = useCGX; }
    void                    setAudioDriver(AudioDriver audioDriver) { this->audioDriver = audioDriver; }
    void                    setAudioMixer(AudioMixer audioMixer) { this->audioMixer = audioMixer; }
    void                    setDisplayID(LONG displayID) { this->displayID = displayID; }

    bool                    isShiftPressed() const { return keyQualifierShiftPressed; };
    bool                    isCtrlPressed() const { return keyQualifierCtrlPressed; };
    bool                    isAltPressed() const { return keyQualifierAltPressed; };

    AmigaApplication();
    ~AmigaApplication();
};

#endif /* TRACKER_AMIGA_APPLICATION_H */
