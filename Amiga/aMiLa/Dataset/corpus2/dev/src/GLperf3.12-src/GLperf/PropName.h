/*
 *   (C) COPYRIGHT International Business Machines Corp. 1993
 *   All Rights Reserved
 *   Licensed Materials - Property of IBM
 *   US Government Users Restricted Rights - Use, duplication or
 *   disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

//
// Permission to use, copy, modify, and distribute this software and its
// documentation for any purpose and without fee is hereby granted, provided
// that the above copyright notice appear in all copies and that both that
// copyright notice and this permission notice appear in supporting
// documentation, and that the name of I.B.M. not be used in advertising
// or publicity pertaining to distribution of the software without specific,
// written prior permission. I.B.M. makes no representations about the
// suitability of this software for any purpose.  It is provided "as is"
// without express or implied warranty.
//
// I.B.M. DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING ALL
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL I.B.M.
// BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
// WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
// OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
// CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//
// Author:  John Spitzer, IBM AWS Graphics Systems (Austin)
//
*/

#define DrawBuffer              1000
#define ClearColor              1001
#define ClearDepthBuffer        1002
#define ClearColorBuffer        1003
#define ClearStencilBuffer      1004
#define ClearAccumBuffer 	1005
#define ClearIndex              1006
#define AlphaTest		1007
#define Antialias		1008
#define Aspect			1009
#define ClipObjs		1011
#define ColorData		1012
#define CullFace		1014
#define DepthMask		1015
#define DepthTest		1016
#define DirectRender		1017
#define Dither			1018
#define DrawableType		1019
#define DstBlendFunc		1020
#define ExecuteMode		1021
#define FacingBack		1022
#define FacingFront		1023
#define FeedbackType		1024
#define Fog			1025
#define LineStipple		1026
#define LineWidth		1027
#define LocalViewer		1029
#define LogicOp			1030
#define ColorMask		1031
#define NormalData		1032
#define PushPop			1033
#define PolygonSides		1034
#define TexComps		1035
#define ObjsPerBeginEnd		1036
#define Orientation		1037
#define PolygonStipple		1039
#define Size			1041
#define Projection		1042
#define RenderMode		1043
#define Scissor			1044
#define ShadeModel		1045
#define Shininess		1046
#define SrcBlendFunc		1047
#define StencilTest		1048
#define Iterations		1049
#define Objs			1050
#define Reps			1051
#define MinimumTime		1052
#define TexFunc			1053
#define TexGen			1054
#define TexMagFilter		1055
#define TexMinFilter		1056
#define TexWrapS		1057
#define TexWrapT		1058
#define TexTarget		1059
#define TexData			1060
#define TexLOD			1061
#define TransformType		1063
#define AcceptObjs		1064
#define RejectObjs		1065
#define TwoSided		1066
#define VisualType		1067
#define LoopUnroll              1069
#define LoopFuncPtrs   		1070
#define PointDraw               1071
#define PolygonModeFront	1072
#define PolygonModeBack		1073
#define ColorMaterialSide       1074
#define ColorMaterialMode       1075
#define WindowWidth             1076
#define WindowHeight            1077
#define InfiniteLights          1078
#define LocalLights             1079
#define TexWidth                1080
#define TexHeight               1081
#define TexBorder               1082
#define TwistsPerStrip          1083
#define DataAlignment           1084
#define ColorDim		1085
#define VertexDim		1086
#define AlphaRef 	 	1087
#define Blend		        1088
#define DepthOrder		1089
#define IndexMask		1090
#define TexDepth 		1091
#define RasterPosDim 		1092
#define ClipAmount 		1093
#define ClipMode 		1094
#define DrawOrder 		1095
#define DrawPixelsWidth 	1096
#define DrawPixelsHeight 	1097
#define ImageWidth 		1098
#define ImageHeight 		1099
#define ImageFormat 		1101
#define ImageType 		1102
#define ImageAlignment 		1103
#define ImageSwapBytes 		1104
#define ImageLSBFirst 		1105
#define MapColor 		1106
#define MapStencil 		1107
#define RedScale 		1108
#define RedBias 		1109
#define GreenScale 		1110
#define GreenBias 		1111
#define BlueScale 		1112
#define BlueBias 		1113
#define AlphaScale 		1114
#define AlphaBias 		1115
#define IndexShift		1116
#define IndexOffset 		1117
#define DepthScale 		1118
#define DepthBias 		1119
#define RtoRMapSize 		1120
#define GtoGMapSize 		1121
#define BtoBMapSize 		1122
#define AtoAMapSize 		1123
#define ItoRMapSize 		1124
#define ItoGMapSize 		1125
#define ItoBMapSize 		1126
#define ItoAMapSize 		1127
#define ItoIMapSize 		1128
#define StoSMapSize 		1129
#define PixelZoomX 		1130
#define PixelZoomY 		1131
#define CopyPixelsWidth 	1133
#define CopyPixelsHeight 	1134
#define CopyPixelsType 		1135
#define ReadBuffer 		1136
#define BitmapWidth 		1137
#define BitmapHeight 		1138
#define CharFont 		1139
#define CharsPerString 		1140
#define ReadPixelsWidth 	1141
#define ReadPixelsHeight	1142
#define ReadOrder		1143
#define TexImageWidth		1144
#define TexImageHeight		1145
#define TexImageDepth		1146
#define TexImageExtent 		1147
#define ImageDepth		1148
#define ImageExtent 		1149
#define SubTexImageWidth	1150
#define SubTexImageHeight	1151
#define SubTexImageDepth	1152
#define TexImageBorder		1153
#define TexImageTarget		1154
#define TexImageComps		1155
#define ResidentTexObjs		1156
#define TexImageSrc		1157
#define TexImageLevel		1158
#define TexImageBaseLevel	1159
#define TexImageMaximumLevel	1160
#define TexImageMipmap		1161
#define ConvolutionTarget	1162
#define ConvolutionInternalFormat 1163
#define ConvolutionWidth	1164
#define ConvolutionHeight	1165
#define ConvolutionRedScale	1166
#define ConvolutionRedBias	1167
#define ConvolutionGreenScale	1168
#define ConvolutionGreenBias	1169
#define ConvolutionBlueScale	1170
#define ConvolutionBlueBias	1171
#define ConvolutionAlphaScale	1172
#define ConvolutionAlphaBias	1173
#define ColorMatrixRed0		1174
#define ColorMatrixRed1		1175
#define ColorMatrixRed2		1176
#define ColorMatrixRed3		1177
#define ColorMatrixGreen0	1178
#define ColorMatrixGreen1	1179
#define ColorMatrixGreen2	1180
#define ColorMatrixGreen3	1181
#define ColorMatrixBlue0	1182
#define ColorMatrixBlue1	1183
#define ColorMatrixBlue2	1184
#define ColorMatrixBlue3	1185
#define ColorMatrixAlpha0	1186
#define ColorMatrixAlpha1	1187
#define ColorMatrixAlpha2	1188
#define ColorMatrixAlpha3	1189
#define ColorMatrixRedScale	1190
#define ColorMatrixRedBias	1191
#define ColorMatrixGreenScale	1192
#define ColorMatrixGreenBias	1193
#define ColorMatrixBlueScale	1194
#define ColorMatrixBlueBias	1195
#define ColorMatrixAlphaScale	1196
#define ColorMatrixAlphaBias	1197
#define ColorTable		1198
#define ColorTableWidth		1199
#define ColorTableInternalFormat 1200
#define PostConvolutionColorTable		1201
#define PostConvolutionColorTableWidth		1202
#define PostConvolutionColorTableInternalFormat 1203
#define PostColorMatrixColorTable		1204
#define PostColorMatrixColorTableWidth		1205
#define PostColorMatrixColorTableInternalFormat 1206
#define Histogram		1207
#define HistogramWidth		1208
#define HistogramInternalFormat 1209
#define HistogramSink 		1210
#define Minmax			1211
#define MinmaxInternalFormat 	1212
#define MinmaxSink 		1213
#define TexDetailWidth 		1214
#define TexDetailHeight 	1215
#define TexDetailLevel 		1216
#define TexDetailMode 		1217
#define TexWrapR 		1218
#define TexWrapQ 		1219
#define BlendEquation 		1220
#define TexExtent  		1221
#define PostTexFilterRedScale 	1222
#define PostTexFilterGreenScale	1223
#define PostTexFilterBlueScale 	1224
#define PostTexFilterAlphaScale	1225
#define PostTexFilterRedBias 	1226
#define PostTexFilterGreenBias 	1227
#define PostTexFilterBlueBias 	1228
#define PostTexFilterAlphaBias 	1229
#define TexColorTable		1230
#define TexColorTableWidth	1231
#define TexColorTableInternalFormat 1232
#define VertexArray 		1233
#define GLperfVersion 		1234
#define UserString 		1235
#define PrintModeDelta 		1236
#define PrintModeMicrosec	1237
#define PrintModePixels 	1238
#define PrintModeStateDelta 	1239
#define SpecularComponent 	1240
#define TestType 		1241
#define TexCompSelect 		1242
#define Multisample 		1243
#define FileName 		1244
#define ObjDraw 		1245
#define ScissorX 		1246
#define ScissorY 		1247
#define ScissorWidth 		1248
#define ScissorHeight 		1249
#define VertexArray11 		1250
#define DrawElements		1251
#define InterleavedData		1252
#define LockArrays		1253



/* Environment Info */

#define Month				2000
#define Day				2001
#define Year				2002
#define Host				2003
#define HostOperatingSystem		2004
#define HostOperatingSystemVersion	2005
#define HostVendor			2006
#define HostModel			2007
#define HostCPU				2008
#define HostMemorySize			2009
#define OpenGLVendor			2010
#define OpenGLVersion			2011
#define OpenGLExtensions		2012
#define OpenGLRenderer			2013
#define OpenGLClientVendor		2014
#define OpenGLClientVersion		2015
#define OpenGLClientExtensions		2016
#define GLUVersion			2017
#define GLUExtensions			2018
#define HostCPUCount			2019
#define HostPrimaryCacheSize		2020
#define HostSecondaryCacheSize		2021
#define WindowSystem			2022
#define DriverVersion			2023


/* Buffer Configuration Info */

#define DoubleBuffer			2100
#define Stereo				2101
#define Rgba				2102
#define IndexSize			2103
#define RedSize				2104
#define GreenSize			2105
#define BlueSize			2106
#define AlphaSize			2107
#define AccumRedSize			2108
#define AccumGreenSize			2109
#define AccumBlueSize			2110
#define AccumAlphaSize			2111
#define DepthSize			2112
#define StencilSize			2113
#define AuxBuffers			2114
#define FrameBufferLevel		2115
#define SampleBuffers			2116
#define SamplesPerPixel			2117

#define ScreenWidth			2200
#define ScreenHeight			2201

/* These two are used in the same way within the code, thus they have the same value */
#define VisualId			3000
#define PixelFormat			3000

#if defined(XWINDOWS)
#define OpenGLServerVendor		3001
#define OpenGLServerVersion		3002
#define OpenGLServerExtensions		3003
#define GLXVersion			3004
#define GLXExtensions			3005
#define SharedMemConnection		3006
#define ScreenNumber			3007
#define DisplayName			3008
#define VisualClass			3009
#endif

