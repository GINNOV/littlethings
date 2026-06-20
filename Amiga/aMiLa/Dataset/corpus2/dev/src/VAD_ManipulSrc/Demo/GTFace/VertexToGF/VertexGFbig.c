#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <math.h>
#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/asl.h>
#include <libraries/asl.h>
#include <intuition/intuition.h>

#define SIGNUM(x) (x ? (x/labs(x)) : 0)

#define MAKE_ID(a,b,c,d)	\
	((ULONG) (a)<<24 | (ULONG) (b)<<16 | (ULONG) (c)<<8 | (ULONG) (d))

#define ID_FORM MAKE_ID('F','O','R','M')
#define ID_3DDD MAKE_ID('3','D','D','D')
#define ID_OBJE MAKE_ID('O','B','J','E')
#define ID_NAME MAKE_ID('N','A','M','E')
#define ID_TYPE MAKE_ID('T','Y','P','E')
#define ID_HAND MAKE_ID('H','A','N','D')
#define ID_VERT MAKE_ID('V','E','R','T')
#define ID_EDGE MAKE_ID('E','D','G','E')
#define ID_FACE MAKE_ID('F','A','C','E')

typedef
  struct ChunkHeader
  {
    ULONG Id;
    ULONG Size;
  } CHUNK_HEADER;

typedef
  struct IFFHeader
  {
    ULONG IffId;
    ULONG IffSize;
    ULONG IffTypeId;
  } IFF_HEADER;

typedef
  struct Vertex
  {
    LONG x;
    LONG y;
    LONG z;
  } VERTEX;

typedef
  struct Point3D
  {
    WORD x;
    WORD y;
    WORD z;
    ULONG Normal;
    DOUBLE NormalX;
    DOUBLE NormalY;
    DOUBLE NormalZ;
    ULONG NormalCntr;
  } POINT3D;

typedef
  struct Line
  {
    ULONG Point1;
    ULONG Point2;
    UWORD pad0, pad1, pad2;
    ULONG pad3;
  } LINE;

typedef
  struct Face
  {
    ULONG Line1;
    ULONG Line2;
    ULONG Line3;
    UWORD Flags;
  } FACE;

typedef
  struct Normal
  {
    WORD VectorX;
    WORD VectorY;
    WORD VectorZ;
    WORD pad;
  } NORMAL;

typedef
  struct Mem3DDD
  {
    VERTEX *Vertex;
    POINT3D *Point3D;
    LINE *Line;
    FACE *Face;
    NORMAL *Normal;
    ULONG PointsNumber;
    ULONG LinesNumber;
    ULONG FacesNumber;
    ULONG NormalsNumber;
  } MEM3DDD;

char ObjName[256];

char __stdiowin[] = "CON:320/131/320/120/";

struct NewWindow FrontNewWindow =
{
  0, 11, 640, 240, 0, 1, 0, WFLG_DEPTHGADGET | WFLG_NOCAREREFRESH |
  WFLG_SMART_REFRESH, NULL, NULL, (STRPTR)"Front view", NULL,
  NULL, 0, 0, 0, 0, WBENCHSCREEN
};

struct NewWindow RightNewWindow =
{
  0, 11, 640, 240, 0, 1, 0, WFLG_DEPTHGADGET | WFLG_NOCAREREFRESH |
  WFLG_SMART_REFRESH, NULL, NULL, (STRPTR)"Right view", NULL,
  NULL, 0, 0, 0, 0, WBENCHSCREEN
};

struct NewWindow UpNewWindow =
{
  0, 11, 640, 240, 0, 1, 0, WFLG_DEPTHGADGET | WFLG_NOCAREREFRESH |
  WFLG_SMART_REFRESH, NULL, NULL, (STRPTR)"Up view", NULL,
  NULL, 0, 0, 0, 0, WBENCHSCREEN
};

struct Window *FrontWindow;
struct Window *RightWindow;
struct Window *UpWindow;

struct RastPort *FrontRP;
struct RastPort *RightRP;
struct RastPort *UpRP;

#define R3DDD_OK          0L
#define R3DDD_No3DDD      1L
#define R3DDD_ErrorStruct 2L
#define R3DDD_NoMem       3L

ULONG Read3DDD(FILE *Handle, MEM3DDD *mem)
{
IFF_HEADER IffHeader;
CHUNK_HEADER ChunkHeader;
ULONG i, j;
LONG c;
ULONG Type;
UBYTE ByteAux[3];
UWORD WordAux[3];

  if(fread(&IffHeader, 1, sizeof(IFF_HEADER), Handle) != sizeof(IFF_HEADER))
    return R3DDD_No3DDD;

  if((IffHeader.IffId != ID_FORM) && (IffHeader.IffTypeId != ID_3DDD))
    return R3DDD_No3DDD;

  IffHeader.IffSize -= 4L;

  do
  {
    if(fread(&ChunkHeader, 1, sizeof(CHUNK_HEADER), Handle)
       != sizeof(CHUNK_HEADER))
      return R3DDD_ErrorStruct;

    IffHeader.IffSize -= 8L;

    switch(ChunkHeader.Id)
    {
      case ID_OBJE:
        ChunkHeader.Size = 0L;
        break;

      case ID_NAME:

        printf("Object name: ");
        j = 0;

        for(i=ChunkHeader.Size; i; i--)
          if((c=fgetc(Handle)) != EOF)
          {
            if(c)
            {
              ObjName[j] = c;
              j++;
            }
            else
              ObjName[j] = '\0';

            putchar(c);
          }
          else
            return R3DDD_ErrorStruct;

        printf("\n\n");

        break;

      case ID_TYPE:

        if((fread(&Type, 4, 1, Handle)) != 1)
          return R3DDD_ErrorStruct;

        break;

      case ID_HAND:

        if((fread(&mem->PointsNumber, 16, 1, Handle)) != 1)
          return R3DDD_ErrorStruct;

        printf("Points: %ld  Lines: %ld  Faces: %ld\n\n",
                mem->PointsNumber, mem->LinesNumber,
                mem->FacesNumber);

        if(!(mem->Point3D = (POINT3D *)calloc(mem->PointsNumber, sizeof(POINT3D))))
          return R3DDD_NoMem;

        if(!(mem->Vertex = (VERTEX *)calloc(mem->PointsNumber, sizeof(VERTEX))))
          return R3DDD_NoMem;

        if(!(mem->Line = (LINE *)calloc(mem->LinesNumber, sizeof(LINE))))
          return R3DDD_NoMem;

        if(!(mem->Face = (FACE *)calloc(mem->FacesNumber, sizeof(FACE))))
          return R3DDD_NoMem;

        if(!(mem->Normal = (NORMAL *)calloc(mem->FacesNumber, sizeof(NORMAL))))
          return R3DDD_NoMem;

        break;

      case ID_VERT:

        if((fread(mem->Vertex, sizeof(VERTEX), mem->PointsNumber, Handle))
           != mem->PointsNumber)
          return R3DDD_ErrorStruct;

        break;

      case ID_EDGE:

        if(Type)
        {
          for(i=0; i<mem->LinesNumber; i++)
            if((fread(ByteAux, sizeof(UBYTE), 2, Handle)) == 2)
            {
              mem->Line[i].Point1 = (ULONG)ByteAux[0]-1;
              mem->Line[i].Point2 = (ULONG)ByteAux[1]-1;
            }
            else
              return R3DDD_ErrorStruct;
        }
        else
        {
          for(i=0; i<mem->LinesNumber; i++)
            if((fread(WordAux, sizeof(UWORD), 2, Handle)) == 2)
            {
              mem->Line[i].Point1 = (ULONG)WordAux[0]-1;
              mem->Line[i].Point2 = (ULONG)WordAux[1]-1;
            }
            else
              return R3DDD_ErrorStruct;
        }

        break;

      case ID_FACE:

        if(Type)
        {
          for(i=0; i<mem->FacesNumber; i++)
            if((fread(ByteAux, sizeof(UBYTE), 3, Handle)) == 3)
            {
              mem->Face[i].Line1 = (ULONG)ByteAux[0]-1;
              mem->Face[i].Line2 = (ULONG)ByteAux[1]-1;
              mem->Face[i].Line3 = (ULONG)ByteAux[2]-1;
            }
            else
              return R3DDD_ErrorStruct;
        }
        else
        {
          for(i=0; i<mem->FacesNumber; i++)
            if((fread(WordAux, sizeof(UWORD), 3, Handle)) == 3)
            {
              mem->Face[i].Line1 = (ULONG)WordAux[0]-1;
              mem->Face[i].Line2 = (ULONG)WordAux[1]-1;
              mem->Face[i].Line3 = (ULONG)WordAux[2]-1;
            }
            else
              return R3DDD_ErrorStruct;
        }

        break;

      default:
        if((fseek(Handle, ChunkHeader.Size, SEEK_CUR) != 0)
           && (IffHeader.IffSize != ChunkHeader.Size))
          return R3DDD_ErrorStruct;
    }
    IffHeader.IffSize -= ChunkHeader.Size;

  } while(IffHeader.IffSize > 0L);

  return R3DDD_OK;
}


VOID Free3DDD(MEM3DDD *mem)
{

  if(mem->Vertex)
    free((VOID *)mem->Vertex);

  if(mem->Point3D)
    free((VOID *)mem->Point3D);

  if(mem->Line)
    free((VOID *)mem->Line);

  if(mem->Face)
    free((VOID *)mem->Face);

  if(mem->Normal)
    free((VOID *)mem->Normal);
}


VOID RenderObject(MEM3DDD *Mem3DDD)
{
POINT3D *Points;
FACE *Faces;
LONG i;

  Points = Mem3DDD->Point3D;
  Faces = Mem3DDD->Face;

// front

  SetDrMd(FrontRP, JAM1);
  SetAPen(FrontRP, 1);

  for(i=0; i<(Mem3DDD->FacesNumber); i++)
  {
    Move(FrontRP, (Points[Faces[i].Line1].x<<1)+320,
         125-Points[Faces[i].Line1].y);
    Draw(FrontRP, (Points[Faces[i].Line2].x<<1)+320,
         125-Points[Faces[i].Line2].y);
    Draw(FrontRP, (Points[Faces[i].Line3].x<<1)+320,
         125-Points[Faces[i].Line3].y);
    Draw(FrontRP, (Points[Faces[i].Line1].x<<1)+320,
         125-Points[Faces[i].Line1].y);
  }

  Move(FrontRP, 312, 19);
  Text(FrontRP, "Up", 2);
  Move(FrontRP, 304, 235);
  Text(FrontRP, "Down", 4);
  Move(FrontRP, 594, 184);
  Text(FrontRP, "Right", 5);
  Move(FrontRP, 6, 184);
  Text(FrontRP, "Left", 4);

// right

  SetDrMd(RightRP, JAM1);
  SetAPen(RightRP, 1);

  for(i=0; i<(Mem3DDD->FacesNumber); i++)
  {
    Move(RightRP, 320-(Points[Faces[i].Line1].z<<1),
         125-Points[Faces[i].Line1].y);
    Draw(RightRP, 320-(Points[Faces[i].Line2].z<<1),
         125-Points[Faces[i].Line2].y);
    Draw(RightRP, 320-(Points[Faces[i].Line3].z<<1),
         125-Points[Faces[i].Line3].y);
    Draw(RightRP, 320-(Points[Faces[i].Line1].z<<1),
         125-Points[Faces[i].Line1].y);
  }

  Move(RightRP, 312, 19);
  Text(RightRP, "Up", 2);
  Move(RightRP, 304, 235);
  Text(RightRP, "Down", 4);
  Move(RightRP, 602, 184);
  Text(RightRP, "Back", 4);
  Move(RightRP, 6, 184);
  Text(RightRP, "Front", 5);

// up

  SetDrMd(UpRP, JAM1);
  SetAPen(UpRP, 1);

  for(i=0; i<(Mem3DDD->FacesNumber); i++)
  {
    Move(UpRP, (Points[Faces[i].Line1].x<<1)+320,
         125+Points[Faces[i].Line1].z);
    Draw(UpRP, (Points[Faces[i].Line2].x<<1)+320,
         125+Points[Faces[i].Line2].z);
    Draw(UpRP, (Points[Faces[i].Line3].x<<1)+320,
         125+Points[Faces[i].Line3].z);
    Draw(UpRP, (Points[Faces[i].Line1].x<<1)+320,
         125+Points[Faces[i].Line1].z);
  }

  Move(UpRP, 304, 19);
  Text(UpRP, "Back", 4);
  Move(UpRP, 300, 235);
  Text(UpRP, "Front", 5);
  Move(UpRP, 594, 184);
  Text(UpRP, "Right", 5);
  Move(UpRP, 6, 184);
  Text(UpRP, "Left", 4);

}


VOID main(VOID)
{
struct FileRequester *FileReq;
char FileName[256];
FILE *FileHandle;
ULONG state;
MEM3DDD Mem3DDD;
DOUBLE MinX, MaxX, MinY, MaxY, MinZ, MaxZ;
LONG AuxMinX, AuxMaxX, AuxMinY, AuxMaxY, AuxMinZ, AuxMaxZ;
LONG i, j, tmp;
FLOAT FloatTmp;
DOUBLE ScaleFactor;
ULONG Point1, Point2, Point3;
LONG NormalX, NormalY, NormalZ;
LONG NormalsNumber;
POINT3D *Points;
FACE *Faces;
LONG Pen0, Pen1, Pen2, Pen3;
struct ColorMap *cm;
struct Screen *ws;

  if(!(FileReq = AllocAslRequestTags(ASL_FileRequest, TAG_DONE)))
  {
    printf("Can't open ASL requester!\n");
    exit(0);
  }

  WBenchToFront();
  if(AslRequestTags(FileReq, ASLFR_PubScreenName, NULL,
                             ASLFR_SleepWindow, TRUE,
                             ASLFR_TitleText, "Load Vertex binary file!",
                             ASLFR_PositiveText, "Load",
                             ASLFR_NegativeText, "Cancel",
                             TAG_DONE))
  {
    strcpy(&FileName[0], FileReq->fr_Drawer);
    if(FileName[strlen(FileName)-1] != ':')
    {
      FileName[strlen(FileName)+1] = '\0';
      FileName[strlen(FileName)] = '/';
    }
    strcpy(&FileName[strlen(FileName)], FileReq->fr_File);
  }

  if(FileHandle = fopen((char const *)&FileName, "r"))
  {
    if(state = Read3DDD(FileHandle, &Mem3DDD))
    {
      switch(state)
      {
        case R3DDD_No3DDD:
          printf("This file isn't IFF 3DDD (Vertex binary file)!\n");
          break;

        case R3DDD_ErrorStruct:
          printf("I/O error or error in IFF structure!\n");
          break;

        case R3DDD_NoMem:
          printf("Not enought memory!\n");
          break;
      }

      fclose(FileHandle);
      Free3DDD(&Mem3DDD);
      FreeAslRequest(FileReq);
      exit(0);
    }
    fclose(FileHandle);
  }
  else
  {
    printf("Can't open file: %s\n", &FileName);
    FreeAslRequest(FileReq);
    exit(0);
  }

  AuxMinX = 0x7fffffff;
  AuxMaxX = 0x80000000;
  AuxMinY = 0x7fffffff;
  AuxMaxY = 0x80000000;
  AuxMinZ = 0x7fffffff;
  AuxMaxZ = 0x80000000;

  for(i=0; i<Mem3DDD.PointsNumber; i++)
  {
    tmp = Mem3DDD.Vertex[i].x;

    if( tmp < AuxMinX)
      AuxMinX = tmp;

    if( tmp > AuxMaxX)
      AuxMaxX = tmp;

    tmp = Mem3DDD.Vertex[i].y;

    if( tmp < AuxMinY)
      AuxMinY = tmp;

    if( tmp > AuxMaxY)
      AuxMaxY = tmp;

    tmp = Mem3DDD.Vertex[i].z;

    if( tmp < AuxMinZ)
      AuxMinZ = tmp;

    if( tmp > AuxMaxZ)
      AuxMaxZ = tmp;
  }

  MinX = ((DOUBLE)AuxMinX)/65536.0;
  MaxX = ((DOUBLE)AuxMaxX)/65536.0;
  MinY = ((DOUBLE)AuxMinY)/65536.0;
  MaxY = ((DOUBLE)AuxMaxY)/65536.0;
  MinZ = ((DOUBLE)AuxMinZ)/65536.0;
  MaxZ = ((DOUBLE)AuxMaxZ)/65536.0;

  printf("MinX = %f  MaxX = %f\n", MinX, MaxX);
  printf("MinY = %f  MaxY = %f\n", MinY, MaxY);
  printf("MinZ = %f  MaxZ = %f\n", MinZ, MaxZ);

  printf("Enter scale factor: ");
  scanf("%f", &FloatTmp);
  fflush(stdin);
  ScaleFactor = FloatTmp;

  for(i=0; i<Mem3DDD.PointsNumber; i++)
  {
    Mem3DDD.Point3D[i].x = (WORD)(((DOUBLE)Mem3DDD.Vertex[i].x)
                                          /65536.0*ScaleFactor);

    Mem3DDD.Point3D[i].y = (WORD)(((DOUBLE)Mem3DDD.Vertex[i].y)
                                          /65536.0*ScaleFactor);

    Mem3DDD.Point3D[i].z = (WORD)(((DOUBLE)Mem3DDD.Vertex[i].z)
                                          /65536.0*ScaleFactor);
  }

  if(!(FrontWindow = OpenWindow(&FrontNewWindow)))
  {
    printf("Can't open window!\n");

    FreeAslRequest(FileReq);

    Free3DDD(&Mem3DDD);
    printf("All done!\n");
    exit(0);
  }

  FrontRP = FrontWindow->RPort;

  if(!(RightWindow = OpenWindow(&RightNewWindow)))
  {
    printf("Can't open window!\n");

    CloseWindow(FrontWindow);

    FreeAslRequest(FileReq);

    Free3DDD(&Mem3DDD);
    printf("All done!\n");
    exit(0);
  }

  RightRP = RightWindow->RPort;

  if(!(UpWindow = OpenWindow(&UpNewWindow)))
  {
    printf("Can't open window!\n");

    CloseWindow(FrontWindow);
    CloseWindow(RightWindow);

    FreeAslRequest(FileReq);

    Free3DDD(&Mem3DDD);
    printf("All done!\n");
    exit(0);
  }

  UpRP = UpWindow->RPort;

  RenderObject(&Mem3DDD);

  Points = Mem3DDD.Point3D;
  Faces = Mem3DDD.Face;

#define IND 2

  ws = (struct Screen *)OpenWorkBench();
  cm = ws->ViewPort.ColorMap;

//  Pen0 = ObtainBestPen(cm, 0xffffffff, 0x00000000, 0x00000000, TAG_DONE);
//  Pen1 = ObtainBestPen(cm, 0x00000000, 0xffffffff, 0x00000000, TAG_DONE);
//  Pen2 = ObtainBestPen(cm, 0x00000000, 0x00000000, 0xffffffff, TAG_DONE);
//  Pen3 = ObtainBestPen(cm, 0xffffffff, 0xffffffff, 0xffffffff, TAG_DONE);

  Pen0 = ObtainPen(cm, -1, 0xff000000, 0x00000000, 0x00000000, 0L);
  Pen1 = ObtainPen(cm, -1, 0x00000000, 0xff000000, 0x00000000, 0L);
  Pen2 = ObtainPen(cm, -1, 0x00000000, 0x00000000, 0xff000000, 0L);
  Pen3 = ObtainPen(cm, -1, 0xff000000, 0xff000000, 0xff000000, 0L);

  for(i=0; i<Mem3DDD.FacesNumber; i++)
  {
  LONG xA, yA, zA, xB, yB, zB, nX, nY, nZ;
  DOUBLE NorX, NorY, NorZ, NorLength;

    Point1 = Faces[i].Line2;
    Point2 = Faces[i].Line1;
    Point3 = Faces[i].Line3;
   
    xA = Mem3DDD.Point3D[Point2].x - Mem3DDD.Point3D[Point1].x;
    yA = Mem3DDD.Point3D[Point2].y - Mem3DDD.Point3D[Point1].y;
    zA = Mem3DDD.Point3D[Point2].z - Mem3DDD.Point3D[Point1].z;
    xB = Mem3DDD.Point3D[Point3].x - Mem3DDD.Point3D[Point1].x;
    yB = Mem3DDD.Point3D[Point3].y - Mem3DDD.Point3D[Point1].y;
    zB = Mem3DDD.Point3D[Point3].z - Mem3DDD.Point3D[Point1].z;

    NorX = (DOUBLE)(yA*zB-yB*zA);
    NorY = (DOUBLE)(xB*zA-xA*zB);
    NorZ = (DOUBLE)(xA*yB-xB*yA);

    NorLength = sqrt(NorX*NorX
                   + NorY*NorY
                   + NorZ*NorZ);

    NorX *= 20.0 / NorLength;
    NorY *= 20.0 / NorLength;
    NorZ *= 20.0 / NorLength;

    nX = Points[Point1].x + (LONG)NorX;
    nY = Points[Point1].y + (LONG)NorY;
    nZ = Points[Point1].z + (LONG)NorZ;

    SetAPen(FrontRP, Pen0);
    DrawEllipse(FrontRP, (Points[Point2].x<<1)+320,
               125-Points[Point2].y, IND<<1, IND);
    SetAPen(FrontRP, Pen1);
    DrawEllipse(FrontRP, (Points[Point1].x<<1)+320,
               125-Points[Point1].y, IND<<1, IND);
    SetAPen(FrontRP, Pen2);
    DrawEllipse(FrontRP, (Points[Point3].x<<1)+320,
               125-Points[Point3].y, IND<<1, IND);
    SetAPen(FrontRP, Pen3);
    Move(FrontRP, (Points[Point1].x<<1)+320,
               125-Points[Point1].y);
    Draw(FrontRP, (nX<<1)+320, 125-nY);

    SetAPen(RightRP, Pen0);
    DrawEllipse(RightRP, 320-(Points[Point2].z<<1),
               125-Points[Point2].y, IND<<1, IND);
    SetAPen(RightRP, Pen1);
    DrawEllipse(RightRP, 320-(Points[Point1].z<<1),
               125-Points[Point1].y, IND<<1, IND);
    SetAPen(RightRP, Pen2);
    DrawEllipse(RightRP, 320-(Points[Point3].z<<1),
               125-Points[Point3].y, IND<<1, IND);
    SetAPen(RightRP, Pen3);
    Move(RightRP, 320-(Points[Point1].z<<1),
               125-Points[Point1].y);
    Draw(RightRP, 320-(nZ<<1), 125-nY);

    SetAPen(UpRP, Pen0);
    DrawEllipse(UpRP, (Points[Point2].x<<1)+320,
         125+Points[Point2].z, IND<<1, IND);
    SetAPen(UpRP, Pen1);
    DrawEllipse(UpRP, (Points[Point1].x<<1)+320,
         125+Points[Point1].z, IND<<1, IND);
    SetAPen(UpRP, Pen2);
    DrawEllipse(UpRP, (Points[Point3].x<<1)+320,
         125+Points[Point3].z, IND<<1, IND);
    SetAPen(UpRP, Pen3);
    Move(UpRP, (Points[Point1].x<<1)+320,
               125+Points[Point1].z);
    Draw(UpRP, (nX<<1)+320, 125+nZ);

    printf("Face %d Seq:%d %d %d (0-ok,1-rev) ", i, Point2,
           Point1, Point3);
    scanf("%d", &tmp);
    fflush(stdin);

    if(tmp == 2)
      i -= 2;

    if(tmp == 3)
      break;

    if(tmp == 1)
    {
      tmp = Faces[i].Line2;
      Faces[i].Line2 = Faces[i].Line3;
      Faces[i].Line3 = tmp;
    }

    SetAPen(FrontRP,0);
    RectFill(FrontRP, 4, 11, 635, 237);
    SetAPen(RightRP,0);
    RectFill(RightRP, 4, 11, 635, 237);
    SetAPen(UpRP,0);
    RectFill(UpRP, 4, 11, 635, 237);

    RenderObject(&Mem3DDD);

  }

  ReleasePen(cm, Pen0);
  ReleasePen(cm, Pen1);
  ReleasePen(cm, Pen2);
  ReleasePen(cm, Pen3);

  for(i=0; i<Mem3DDD.FacesNumber; i++)
  {
  LONG xA, yA, zA, xB, yB, zB;
  DOUBLE NorX, NorY, NorZ, NorLength;

    Point1 = Mem3DDD.Face[i].Line2;
    Point2 = Mem3DDD.Face[i].Line1;
    Point3 = Mem3DDD.Face[i].Line3;
    xA = Mem3DDD.Point3D[Point2].x - Mem3DDD.Point3D[Point1].x;
    yA = Mem3DDD.Point3D[Point2].y - Mem3DDD.Point3D[Point1].y;
    zA = Mem3DDD.Point3D[Point2].z - Mem3DDD.Point3D[Point1].z;
    xB = Mem3DDD.Point3D[Point3].x - Mem3DDD.Point3D[Point1].x;
    yB = Mem3DDD.Point3D[Point3].y - Mem3DDD.Point3D[Point1].y;
    zB = Mem3DDD.Point3D[Point3].z - Mem3DDD.Point3D[Point1].z;

    NorX = (DOUBLE)(yA*zB-yB*zA);
    NorY = (DOUBLE)(xB*zA-xA*zB);
    NorZ = (DOUBLE)(xA*yB-xB*yA);

    NorLength = sqrt(NorX*NorX
                   + NorY*NorY
                   + NorZ*NorZ);

    NorX /= NorLength;
    NorY /= NorLength;
    NorZ /= NorLength;

    Mem3DDD.Point3D[Point1].NormalX += NorX;
    Mem3DDD.Point3D[Point1].NormalY += NorY;
    Mem3DDD.Point3D[Point1].NormalZ += NorZ;
    Mem3DDD.Point3D[Point1].NormalCntr++;

    Mem3DDD.Point3D[Point2].NormalX += NorX;
    Mem3DDD.Point3D[Point2].NormalY += NorY;
    Mem3DDD.Point3D[Point2].NormalZ += NorZ;
    Mem3DDD.Point3D[Point2].NormalCntr++;

    Mem3DDD.Point3D[Point3].NormalX += NorX;
    Mem3DDD.Point3D[Point3].NormalY += NorY;
    Mem3DDD.Point3D[Point3].NormalZ += NorZ;
    Mem3DDD.Point3D[Point3].NormalCntr++;
  }

  NormalsNumber = 0;

  for(i=0; i<Mem3DDD.PointsNumber; i++)
  {
    NormalX = (LONG)(Mem3DDD.Point3D[i].NormalX*64.0/
              (DOUBLE)Mem3DDD.Point3D[i].NormalCntr);
    NormalY = (LONG)(Mem3DDD.Point3D[i].NormalY*64.0/
              (DOUBLE)Mem3DDD.Point3D[i].NormalCntr);
    NormalZ = (LONG)(Mem3DDD.Point3D[i].NormalZ*64.0/
              (DOUBLE)Mem3DDD.Point3D[i].NormalCntr);

    for(j=0; j<NormalsNumber; j++)
      if((NormalX == Mem3DDD.Normal[j].VectorX)
         && (NormalY == Mem3DDD.Normal[j].VectorY)
         && (NormalZ == Mem3DDD.Normal[j].VectorZ))
      {
        Mem3DDD.Point3D[i].Normal = j;
        break;
      }

    if(j == NormalsNumber)
    {
      Mem3DDD.Normal[j].VectorX = (WORD)NormalX;
      Mem3DDD.Normal[j].VectorY = (WORD)NormalY;
      Mem3DDD.Normal[j].VectorZ = (WORD)NormalZ;
      Mem3DDD.Point3D[i].Normal = j;
      NormalsNumber++;
    }
  }

  printf("Normals: %d\n", NormalsNumber);

  for(i=0; i<Mem3DDD.FacesNumber; i++)
  {
  ULONG Cntr[3];
  LONG tmp2;

    Point1 = Mem3DDD.Face[i].Line1;
    Point2 = Mem3DDD.Face[i].Line2;
    Point3 = Mem3DDD.Face[i].Line3;

    for(j=0; j<Mem3DDD.LinesNumber; j++)
      if(((Mem3DDD.Line[j].Point1 == Point1)
         && (Mem3DDD.Line[j].Point2 == Point2))
         || ((Mem3DDD.Line[j].Point1 == Point2)
         && (Mem3DDD.Line[j].Point2 == Point1)))
      {
        Mem3DDD.Face[i].Line1 = j;
        if((Mem3DDD.Line[j].Point1 == Point1)
           && (Mem3DDD.Line[j].Point2 == Point2))
          Cntr[0] = 1;
        else
          Cntr[0] = 0;
        break;
      }

    for(j=0; j<Mem3DDD.LinesNumber; j++)
      if(((Mem3DDD.Line[j].Point1 == Point2)
         && (Mem3DDD.Line[j].Point2 == Point3))
         || ((Mem3DDD.Line[j].Point1 == Point3)
         && (Mem3DDD.Line[j].Point2 == Point2)))
      {
        Mem3DDD.Face[i].Line2 = j;
        if((Mem3DDD.Line[j].Point1 == Point2)
           && (Mem3DDD.Line[j].Point2 == Point3))
          Cntr[1] = 1;
        else
          Cntr[1] = 0;
        break;
      }

    for(j=0; j<Mem3DDD.LinesNumber; j++)
      if(((Mem3DDD.Line[j].Point1 == Point3)
         && (Mem3DDD.Line[j].Point2 == Point1))
         || ((Mem3DDD.Line[j].Point1 == Point1)
         && (Mem3DDD.Line[j].Point2 == Point3)))
      {
        Mem3DDD.Face[i].Line3 = j;
        if((Mem3DDD.Line[j].Point1 == Point3)
           && (Mem3DDD.Line[j].Point2 == Point1))
          Cntr[2] = 1;
        else
          Cntr[2] = 0;
        break;
      }

    tmp2 = 0;

    while(!Cntr[0])
    {
      tmp = Mem3DDD.Face[i].Line1;
      Mem3DDD.Face[i].Line1 = Mem3DDD.Face[i].Line2;
      Mem3DDD.Face[i].Line2 = Mem3DDD.Face[i].Line3;
      Mem3DDD.Face[i].Line3 = tmp;

      tmp = Cntr[0];
      Cntr[0] = Cntr[1];
      Cntr[1] = Cntr[2];
      Cntr[2] = tmp;
      tmp2++;
      if(tmp2 == 3)
      {
        printf("Face %d damage!\n", i);
        break;
      }
    }
  }

  WBenchToFront();
  if(AslRequestTags(FileReq, ASLFR_PubScreenName, NULL,
                             ASLFR_SleepWindow, TRUE,
                             ASLFR_TitleText, "Save GF data source file!",
                             ASLFR_PositiveText, "Save",
                             ASLFR_NegativeText, "Cancel",
                             TAG_DONE))
  {
    strcpy(&FileName[0], FileReq->fr_Drawer);
    if(FileName[strlen(FileName)-1] != ':')
    {
      FileName[strlen(FileName)+1] = '\0';
      FileName[strlen(FileName)] = '/';
    }
    strcpy(&FileName[strlen(FileName)], FileReq->fr_File);

    if(FileHandle = fopen((char const *)&FileName, "w"))
    {
      fprintf(FileHandle, "%s_P\t=\t%d\n", ObjName, Mem3DDD.PointsNumber);
      fprintf(FileHandle, "%s_L\t=\t%d\n", ObjName, Mem3DDD.LinesNumber);
      fprintf(FileHandle, "%s_F\t=\t%d\n", ObjName, Mem3DDD.FacesNumber);
      fprintf(FileHandle, "%s_N\t=\t%d\n", ObjName, NormalsNumber);
      fprintf(FileHandle, "\n%s\n", ObjName);

      fprintf(FileHandle, "%s_Object\n\t\tDC.W\t0,0,0,0,0,0\n", ObjName);
      fprintf(FileHandle, "\t\tDC.W\t%s_P-1,%s_L-1\n", ObjName, ObjName);
      fprintf(FileHandle, "\t\tDC.W\t%s_F-1,%s_N-1\n", ObjName, ObjName);
      fprintf(FileHandle, "\t\tDC.L\t%s_Points3D-%s,NULL\n", ObjName,
              ObjName);
      fprintf(FileHandle, "\t\tDC.L\t%s_Lines-%s,%s_Faces-%s\n", ObjName,
              ObjName, ObjName, ObjName);
      fprintf(FileHandle, "\t\tDC.L\t%s_Normals-%s,NULL\n", ObjName,
              ObjName);

      fprintf(FileHandle,"%s_Points3D\n", ObjName);
      for(i=0; i<Mem3DDD.PointsNumber; i++)
        fprintf(FileHandle, "\t\tDC.W\t%d,%d,%d\n\t\tDC.L\t%d\n",
                Mem3DDD.Point3D[i].x, Mem3DDD.Point3D[i].y,
                Mem3DDD.Point3D[i].z, Mem3DDD.Point3D[i].Normal);

      fprintf(FileHandle,"%s_Lines\n", ObjName);
      for(i=0; i<Mem3DDD.LinesNumber; i++)
        fprintf(FileHandle, "\t\tDC.L\t%d,%d\n\t\tDCB.B\tl_SIZEOF-8\n",
                Mem3DDD.Line[i].Point1, Mem3DDD.Line[i].Point2);

      fprintf(FileHandle,"%s_Faces\n", ObjName);
      for(i=0; i<Mem3DDD.FacesNumber; i++)
        fprintf(FileHandle, "\t\tDC.L\t%d,%d,%d\n\t\tDC.W\t1\n",
                Mem3DDD.Face[i].Line1, Mem3DDD.Face[i].Line2,
                Mem3DDD.Face[i].Line3);

      fprintf(FileHandle,"%s_Normals\n", ObjName);
      for(i=0; i<NormalsNumber; i++)
        fprintf(FileHandle, "\t\tDC.W\t%d,%d,%d\n",
                Mem3DDD.Normal[i].VectorX, Mem3DDD.Normal[i].VectorY,
                Mem3DDD.Normal[i].VectorZ);

      fclose(FileHandle);
    }
  }

  CloseWindow(UpWindow);
  CloseWindow(RightWindow);
  CloseWindow(FrontWindow);

  FreeAslRequest(FileReq);

  Free3DDD(&Mem3DDD);
  printf("All done!\n");
  exit(0);
}
