
#include <exec/types.h>
#include <exec/execbase.h>
#include <exec/tasks.h>
#include <clib/exec_protos.h>
#include <pragmas/exec_sysbase_pragmas.h>

GLOBAL UBYTE patchStart;
GLOBAL UBYTE patchEnd;
GLOBAL UBYTE codeStart;
GLOBAL UBYTE codeEnd;

GLOBAL ULONG UCount_Offset;
GLOBAL ULONG SigBit_Offset;
GLOBAL ULONG Task_Offset;
GLOBAL ULONG RtsNop_Offset;

GLOBAL struct ExecBase *SysBase;
GLOBAL struct Library *LibBase;
GLOBAL ULONG LVO;
GLOBAL ULONG (*OldRoutine)();

/*
||
|| Remove the patch and free it's storage.
||
|| "patch" points to the beginning of the patches storage.
||
*/
LONG
remove( UBYTE *patch )
{
   UBYTE *pc;
   ULONG *ucount;
   ULONG *sigbit;
   struct Task **task;
   UWORD *rtsnop;
   UBYTE *vecBeg;
   UBYTE *vecEnd;
   struct Node *node;
   ULONG count;

   /*
   ||
   || Protect.
   ||
   */
   Forbid();

   /*
   ||
   || Replace our vector with the original.
   ||
   */
   SetFunction( LibBase, LVO, OldRoutine );

   /*
   ||
   || Calculate variable addresses.
   ||
   */
   ucount = ( ULONG * )        ( patch + UCount_Offset );
   sigbit = ( ULONG * )        ( patch + SigBit_Offset );
   task   = ( struct Task ** ) ( patch + Task_Offset   );
   rtsnop = ( UWORD *)         ( patch + RtsNop_Offset );

   /*
   ||
   || Calculate library vector start and end address.
   ||
   */
   vecBeg = ( (UBYTE *)LibBase ) + LVO;
   vecEnd = vecBeg + LIB_VECTSIZE;

   /*
   ||
   || Setup signaling info.
   ||
   */
   *sigbit = AllocSignal( -1 );
   *task = FindTask( NULL );

   /*
   ||
   || Count the number of tasks executing within our code.
   ||
   */
   for ( node = SysBase->TaskReady.lh_Head ; node->ln_Succ ; node = node->ln_Succ )
   {
      pc = (UBYTE *) *( (ULONG *) ( (struct Task *) node )->tc_SPReg );
      if ( ( pc >= vecBeg && pc < vecEnd )  ||
           ( pc >= &codeStart && pc < &codeEnd ) )
      {
         (*ucount)++;
      }
   }

   /*
   ||
   || Count the number of tasks executing within our code.
   ||
   */
   for ( node = SysBase->TaskWait.lh_Head ; node->ln_Succ ; node = node->ln_Succ )
   {
      pc = (UBYTE *) *( (ULONG *) ( (struct Task *) node )->tc_SPReg );
      if ( ( pc >= vecBeg && pc < vecEnd )  ||
           ( pc >= &codeStart && pc < &codeEnd ) )
      {
         (*ucount)++;
      }
   }

   /*
   ||
   || Cache use count.
   ||
   */
   count = *ucount;

   /*
   ||
   || Now change the RTS at the end of our routine to a NOP to activate
   || removal code.
   ||
   */
   *rtsnop = 0x4e71;

   /*
   ||
   || Flush the cache.
   ||
   */
   CacheClearU();

   /*
   ||
   || Enable task switching.
   ||
   */
   Permit();

   /*
   ||
   || Wait for the patch to signal us, only if the use count is not zero.
   ||
   */
   if ( count != 0 )
   {
      Wait( *sigbit );

      /*
      ||
      || Wait until the final patch exits.
      ||
      */
      do
      {
         /*
         ||
         || Wait a little bit.
         ||
         */
         Delay(50);

         /*
         ||
         || Initialize variable.
         ||
         */
         count = 0;

         /*
         ||
         || Count the number of tasks executing within our code.
         ||
         */
         for ( node = SysBase->TaskReady.lh_Head ; node->ln_Succ ; node = node->ln_Succ )
         {
            pc = (UBYTE *) *( (ULONG *) ( (struct Task *) node )->tc_SPReg );
            if ( ( pc >= vecBeg && pc < vecEnd )  ||
                 ( pc >= &codeStart && pc < &codeEnd ) )
            {
               count++;
            }
         }
   
         /*
         ||
         || Count the number of tasks executing within our code.
         ||
         */
         for ( node = SysBase->TaskWait.lh_Head ; node->ln_Succ ; node = node->ln_Succ )
         {
            pc = (UBYTE *) *( (ULONG *) ( (struct Task *) node )->tc_SPReg );
            if ( ( pc >= vecBeg && pc < vecEnd )  ||
                 ( pc >= &codeStart && pc < &codeEnd ) )
            {
               count++;
            } 
         }
      } while ( count != 0 );
   }

   /*
   ||
   || Free the signal.
   ||
   */
   FreeSignal( *sigbit );

   /*
   ||
   || Now free the patch storage.
   ||
   */
   FreeVec( patch );

   /*
   ||
   || We're done.
   ||
   */
   return 0;
}
