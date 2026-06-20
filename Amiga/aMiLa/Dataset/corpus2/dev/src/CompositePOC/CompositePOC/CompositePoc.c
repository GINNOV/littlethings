#include "CompositePoc.h"
/*=================================================================*/
void DemoProg(void)
{							/* do the demo  */
BOOL DoSetTilePOC;
struct map3D *Map=&Engine.LevelMap;
float speed=1.0;

	DoSetTilePOC=FALSE;

	Engine.MovingX=Engine.MovingY=0.0;

	switch(Engine.VanillaKey)
	{
	case '/':	Engine.Zoom-=0.1;					break;
	case '*':	Engine.Zoom+=0.1;				break;

	case 'E':	
	case 'e':	Engine.Edit=!Engine.Edit;			break;

	case 'C':
	case 'c':	Engine.TileNum=GetTilePOC(Map,Map->MouseTilePosX,Map->MouseTilePosY);	break;

	case '6':	Engine.MovingX=+speed;			break;
	case '4':	Engine.MovingX=-speed;			break;
	case '2':	Engine.MovingY=+speed;			break;
	case '8':	Engine.MovingY=-speed;			break;
	case '-':	Engine.TileNum--; 					break;
	case '+':	Engine.TileNum++; 				break;

	case 27:	Engine.Closed=TRUE;				break;
	default:									break;
	}

	if(Engine.TileNum>=Map->TilesNb)
		Engine.TileNum=0;

	if(Engine.Edit)
	if(Engine.Drag)
		DoSetTilePOC=TRUE;

	if(!Engine.Edit)
	if(Engine.Drag)
		Engine.RotZ=Engine.EditX * 180.0; 

	if(!Engine.Edit)
	if(Engine.Push)
		Engine.RotZ2=Engine.EditX * 180.0; 

	if(Engine.Edit)
		Engine.RotZ=Engine.RotZ2=0.0; 


	if(!Engine.Edit)
	if(!Engine.Drag)
	if(!Engine.Push)
	if( (Engine.EditX*Engine.EditX+Engine.EditY*Engine.EditY) > (0.2*0.2) )
		{
		Engine.MovingX=Engine.EditX*speed;
		Engine.MovingY=Engine.EditY*speed;
		}

	if(!Engine.Edit)
	if(Engine.MovingX!=0.0)
		Engine.RotZ2=Engine.EditX * 45.0; 

	if(!Engine.Edit)
	if(Engine.MovingX!=0.0)
		Engine.RotZ=Engine.EditX * 30.0; 

	if(!Engine.GameStarted)
	if(Engine.MovingX!=0.0)
		Engine.GameStarted=TRUE;

	if(!Engine.GameStarted)
	if(Engine.MovingY!=0.0)
		Engine.GameStarted=TRUE;

	if(!Engine.GameStarted)
	if(Engine.VanillaKey)
		Engine.GameStarted=TRUE;

	Map->MapPosX=Map->MapPosX+Engine.MovingX;
	Map->MapPosY=Map->MapPosY+Engine.MovingY;

	if(DoSetTilePOC)
		SetTilePOC(Map,Map->MouseTilePosX,Map->MouseTilePosY,Engine.TileNum);
}
/*=================================================================*/
int main(int argc, char *argv[])
{
UBYTE TileNum;
ULONG x,y;
float HaloChange;
float xpos,ypos;
float shipxpos,shipypos;
UBYTE name[256];

	StartPOC("Composite POC - OS4",640,512,2.0);

	InitMapPOC(&Engine.TextMap,"bmp/fonts128x512.bmp",16,40,40,COMPOSITE_Plus);

	InitMapPOC(&Engine.LevelMap,"bmp/tiles_320X200X24.bmp",16,200,200,COMPOSITE_Src);
	LoadMapPOC("level1",&Engine.LevelMap);

	LoadTexturePOC(&cloudtex,"bmp/cloud_128X128X24.bmp");
	LumiToAlphaPOC(&cloudtex);
	SetSpritePOC(&cloud,128,128,&cloudtex,0,0,128,128,COMPOSITE_Plus);

	LoadTexturePOC(&shiptex,"bmp/ship_80X80X24.bmp");
	BlackToAlphaPOC(&shiptex);
	SetSpritePOC(&ship,80,80,&shiptex,0,0,80,80,COMPOSITE_Src_Over_Dest);

	LoadTexturePOC(&shadowtex,"bmp/shadow_80X80X24.bmp");
	BlackToAlphaPOC(&shadowtex);
	TranspAlphaPOC(&shadowtex,0.5);
	SetSpritePOC(&shadow,80,80,&shadowtex,0,0,80,80,COMPOSITE_Src_Over_Dest);

	LoadTexturePOC(&halotex,"bmp/halo_40X40X24.bmp");
	LumiToAlphaPOC(&halotex);
	SetSpritePOC(&halo,40,40,&halotex,0,0,40,40,COMPOSITE_Plus);

	while(!Engine.Closed)					/* is window Closed ? */
	{
		WindowEventsPOC();				

		ClearMapPOC(&Engine.TextMap);
		DrawMapPOC(&Engine.LevelMap);

		shipxpos=Engine.CenterX-(ship.large/2.0);
		shipypos=Engine.CenterY-(ship.high /2.0);
		SetAxisPOC(Engine.CenterX,Engine.CenterY);

		MoveSpritePOC(&shadow,Engine.RotZ2,shipxpos+10,shipypos+10,1.0);
		DrawSpritePOC(&shadow);

		HaloChange=Engine.Time % 20 ;
		HaloChange=HaloChange*(1.0/20.0) ;
		xpos=19.0-HaloChange*(halo.large/2.0);
		ypos=40.0-HaloChange*(halo.high/2.0);
		MoveSpritePOC(&halo,Engine.RotZ2,shipxpos+xpos,shipypos+ypos,1.0+HaloChange);
		DrawSpritePOC(&halo);

		MoveSpritePOC(&ship,Engine.RotZ2,shipxpos,shipypos,1.0);
		DrawSpritePOC(&ship);

		sprintf(name,"Player%d  Score%d",Engine.Player,Engine.Score);
		TextToMapPOC(&Engine.TextMap,0,0,name);

		if(Engine.Lifes==3)
		{sprintf(name,"Lifes%c%c%c",3,3,3); TextToMapPOC(&Engine.TextMap,0,1,name);}		/* use special char 3 = star */
		if(Engine.Lifes==2)
		{sprintf(name,"Lifes%c%c",3,3); TextToMapPOC(&Engine.TextMap,0,1,name);}	
		if(Engine.Lifes==1)
		{sprintf(name,"Lifes%c",3); TextToMapPOC(&Engine.TextMap,0,1,name);}	

		if(!Engine.GameStarted)
		{
		TextToMapPOC(&Engine.TextMap,0,3,"Composite P.O.C.");
		TextToMapPOC(&Engine.TextMap,0,4,"Alain Thellier");
		TextToMapPOC(&Engine.TextMap,0,5,"Paris - 2012");
		TextToMapPOC(&Engine.TextMap,0,7,"Ready ?");
		}

		if(Engine.Edit)
			TextToMapPOC(&Engine.TextMap,0,7,"Edit Mode");

		xpos=9; ypos=7;
		if(Engine.MovingX<0.0)
			SetTilePOC(&Engine.TextMap,xpos-1,ypos,7);	/* use special chars 7 8 9 10 = arrows */
		if(Engine.MovingX>0.0)
			SetTilePOC(&Engine.TextMap,xpos+1,ypos,8);
		if(Engine.MovingY<0.0)
			SetTilePOC(&Engine.TextMap,xpos,ypos-1,9);
		if(Engine.MovingY>0.0)
			SetTilePOC(&Engine.TextMap,xpos,ypos+1,10);


		DrawMapPOC(&Engine.TextMap);
		SwitchDisplayPOC();						/* copy to window */
		DemoProg();
	}

	SaveMapPOC("level1",&Engine.LevelMap);

panic:
	FreeTexturePOC(&shiptex);
	FreeTexturePOC(&shadowtex);
	FreeTexturePOC(&halotex);
	FreeTexturePOC(&cloudtex);
	ClosePOC();
	return 0;
}
/*================================================================*/


