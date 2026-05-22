struct Layout
{
   ULONG  Type;
   STRPTR Item;
   ULONG  Offset;
   STRPTR StrDef;
   ULONG  StrLen;
   LONG   NumDef;
};

METHOD IList_Load(Class *cl, Object *obj, Msg msg)
{
   APTR *Array;

   struct ConfigData *Config;
   struct Layout Layout[] =
   {
      {TYPE_LONG  , "Status    ", offsetof(IListNode, Status)  , NULL, 0       , 0},
      {TYPE_LONG  , "Priority  ", offsetof(IListNode, Priority), NULL, 0       , 0},
      {TYPE_STRING, "Title     ", offsetof(IListNode, Title)   , ""  , MAX_TEXT, 0},
      {TYPE_STRING, "Textfile  ", offsetof(IListNode, Textfile), ""  , PATH_LEN, 0},
      {TYPE_END   , NULL        , 0                            , NULL, 0       , 0}
   };

   Config = OpenConfig("PROGDIR:IssueTracker.cfg");

   if (Config == NULL)
   {
      return 0;
   }

   Array = ReadConfigArray(Config, "IList", Layout, sizeof(struct IListNode));

   if (Array)
   {
      DoMethod(obj, MUIM_List_Insert, Array, -1, MUIV_List_Insert_Bottom);
   }

   CloseConfig(Config);

   set(obj, MUIA_List_Active, MUIV_List_Active_Top);

   return 0;
}

APTR *ReadConfigArray(struct ConfigData *Config, STRPTR Section, struct Layout Layout[], ULONG StructSize)
{
   ULONG NumEntries = 0, SectionLen, i;
   ULONG *Mem, *Data, *MPtr, *DPtr;

   struct Layout *LPtr;
   struct Node *Worknode;

   SectionLen = strlen(Section);

   Worknode = Config->Cfglist->lh_Head;

   /* Scan the list for the section header */
   while (Worknode->ln_Succ)
   {
      if (ISSECTION(Worknode->ln_Name))
      {
         if (strncmp(Worknode->ln_Name + 1, Section, SectionLen) == 0)
         {
            Worknode = Worknode->ln_Succ;
            break;
         }
      }

      Worknode = Worknode->ln_Succ;
   }

   if (Worknode->ln_Succ == NULL)
   {
      return NULL;
   }

   /* Look for the NumEntries item and read it */
   if (strncmp(Worknode->ln_Name, "NumEntries", 10) == 0 &&
       STRCMP3(Worknode->ln_Name + 10, ' ', '=', ' ')
      )
   {
      NumEntries = strtoul(Worknode->ln_Name + 10 + 3, NULL, 10);
      if (NumEntries == ULONG_MAX)
      {
         NumEntries = 0;
      }
   }

   Worknode = Worknode->ln_Succ;

   if ((NumEntries == 0) || (Worknode->ln_Succ == NULL))
   {
      return NULL;
   }

   /* Alloc mem for both arrays (NumEntries + 1 for teminating NULL pointer)*/
   Mem = AllocVec(((NumEntries + 1) * sizeof(APTR)) + (NumEntries * StructSize), MEMF_ANY);
   if (Mem == NULL)
   {
      return NULL;
   }

   /* Find data area */
   Data = Mem + ((NumEntries + 1) * sizeof(APTR));

   MPtr = Mem;
   DPtr = Data;

   /*Set up pointer table */
   for (i = 0; i < NumEntries; i++)
   {
      *MPtr = (ULONG)DPtr;
      MPtr++;
      DPtr += StructSize;
   }
   *MPtr = NULL;

   /* Read the data and fill the data area with it */
   LPtr = Layout;

   for (i = 0; i < NumEntries; i++)
   {
      while (LPtr->Type != TYPE_END)
      {
         if ((Worknode->ln_Succ == NULL) || ISSECTION(Worknode->ln_Name))
         {
            /* Already reached the end, copy default */
            if (LPtr->Type == TYPE_STRING)
            {
               strncpy((char *)Data + LPtr->Offset, LPtr->StrDef, LPtr->StrLen);
            }
            else /* Type == TYPE_LONG */
            {
               *(Data + LPtr->Offset) = LPtr->NumDef;
            }
         }
         else
         {
            /* Read vaild entry */
            ULONG ItemLen;

            ItemLen = strlen(LPtr->Item);

            if(strncmp(Worknode->ln_Name, LPtr->Item, ItemLen) == 0 &&
               STRCMP3(Worknode->ln_Name + ItemLen, ' ', '=', ' ')
              )
            {
               if (LPtr->Type == TYPE_STRING)
               {
                  strncpy((char *)Data + LPtr->Offset, Worknode->ln_Name + ItemLen + 3, LPtr->StrLen);
               }
               else /* Type == TYPE_LONG */
               {
                  *(Data + LPtr->Offset) = strtol(Worknode->ln_Name + ItemLen + 3, NULL, 10);
               }

               Worknode = Worknode->ln_Succ;
            }
            else
            {
               if (LPtr->Type == TYPE_STRING)
               {
                  strncpy((char *)Data + LPtr->Offset, LPtr->StrDef, LPtr->StrLen);
               }
               else /* Type == TYPE_LONG */
               {
                  *(Data + LPtr->Offset) = LPtr->NumDef;
               }
            }
         }

         LPtr++;
      }

      LPtr = Layout;
      Data += StructSize;
   }

   /* Remember Array to free it in CloseConfig(); */
   Config->Array = Mem;

   return (APTR)Mem;
}

