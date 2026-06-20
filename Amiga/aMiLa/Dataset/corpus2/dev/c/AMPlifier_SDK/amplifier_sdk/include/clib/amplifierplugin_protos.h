#ifndef CLIB_AMPLIFIERPLUGIN_PROTOS_H
#define CLIB_AMPLIFIERPLUGIN_PROTOS_H

#ifdef __cplusplus
extern "C" {
#endif

struct PluginCtrl * PI_AddModuleA(struct TagItem *taglist);
void PI_RemModule(PluginCtrl *pctrl);

#ifdef __cplusplus
};
#endif

#endif
