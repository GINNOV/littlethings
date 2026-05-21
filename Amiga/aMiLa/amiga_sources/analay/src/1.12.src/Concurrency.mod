(*
Copyright (c) 1994 - 1996 Marc Necker.

This file is part of Analay (v1.12).
http://www.analay.de

Analay is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License version 2
as published by the Free Software Foundation.

Analay is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Analay.  If not, see <https://www.gnu.org/licenses/>.
*)


(*-------------------------------------------------------------------------*)
(*                                                                         *)
(*  Amiga Oberon Interface Module: Concurrency        Date: 02-Nov-92      *)
(*                                                                         *)
(*   © 1992 by Fridtjof Siebert                                            *)
(*                                                                         *)
(*-------------------------------------------------------------------------*)

MODULE Concurrency;

IMPORT BT * := BasicTypes,
               Exec,
               OberonLib,
               Alerts,
               Strings,
       GC   := GarbageCollector,
               SYSTEM,
               Dos *;

TYPE
  Waiting   = POINTER TO WaitingDesc;
  Process * = POINTER TO ProcessDesc;

  ProcessProc * = PROCEDURE (data: BT.ANY): BT.ANY;

  ProcessDesc * = RECORD (BT.ANYDesc)
    next: Process;                (* internal link
                                   *)
    dosProcess-: Dos.ProcessPtr;  (* AmigaOS-Process structure of this
                                   * process
                                   *)
    done: BOOLEAN;                (* done=TRUE indicates that the process
                                   * has terminated and result is valid.
                                   *)
    data: BT.ANY;         (* data passed to this process
                                   *)
    result: BT.ANY;       (* Result of this process. Only valid if
                                   * done=TRUE.
                                   *)
    taskTrapData: OberonLib.TaskTrapData;
                                  (* New Process' Task.trapData will point
                                   * to this structure.
                                   *)
    mutator: GC.Mutator;          (* GC's mutator for this process
                                   *)
    proc: ProcessProc;            (* The main process procedure
                                   *)
    priority: SHORTINT;           (* New Process' priority
                                   *)
    waiting: Waiting;             (* Processes waiting for our termination
                                   *)
  END;

  WaitingDesc = RECORD (BT.ANYDesc)
    next: Waiting;                (* link waiting processes
                                   *)
    task: Exec.TaskPtr;           (* waiting task
                                   *)
  END;

VAR
  Processes: Process;

  FakeSegList: STRUCT  (* needed for OS1.3's CreateProc()
                        * (the compiler longword aligns this automatically)
                        *)
    length: LONGINT;
    next: Exec.BPTR;


    jmp: INTEGER;      (* JMP  StartProcess *)
    start: PROCEDURE;
  END;

  ProcessesSemaphore: Exec.SignalSemaphore;
                       (* Semaphore to access global variables of this
                        * module
                        *)

  ProcessName: POINTER TO ARRAY 80 OF CHAR;

  WakeUpSig: INTEGER;

  DefaultStackSize: LONGINT;

  ProcessInTrapData: INTEGER;     (*
                                   * Offset of Process in
                                   * TaskTrapData.user[]
                                   *)

PROCEDURE ChildHaltProc;

VAR
  p,q: Process;

CONST
  RTS = 4E75H;

BEGIN
  p := SYSTEM.VAL(Process,OberonLib.execBase.thisTask.trapData.user[ProcessInTrapData]);
  Exec.ObtainSemaphore(ProcessesSemaphore);
  Exec.Forbid;
  p.done := TRUE;
  WHILE p.waiting#NIL DO
    Exec.Signal(p.waiting.task,LONGSET{WakeUpSig});
    p.waiting := p.waiting.next;
  END;
  IF p=Processes THEN
    Processes := p.next
  ELSE
    q := Processes;
    WHILE q.next#p DO q := q.next END;
    q.next := p.next;
  END;
  Exec.ReleaseSemaphore(ProcessesSemaphore);
(* $IF GarbageCollector *)
  GC.RemMutator(p.mutator);
(* $END *)
  SYSTEM.SETREG(15,OberonLib.execBase.thisTask.trapData.oldSP);
  SYSTEM.INLINE(RTS);
END ChildHaltProc;


PROCEDURE Call(p: Process);
(*
 * Sets p's priority, calls p.proc and terminates this process.
 *)
BEGIN
  IF Exec.SetTaskPri(Exec.exec.thisTask,p.priority)=0 THEN END;
  p.result := p.proc(p.data);
  ChildHaltProc;
END Call;


VAR
  StartProcessProc: Process;


PROCEDURE StartProc;
(*
 * adds new mutator to GC and calls Call() to execute this process' procedure.
 *
 * $StackChk-
 *)

BEGIN
  StartProcessProc := SYSTEM.VAL(Process,OberonLib.execBase.thisTask.trapData.user[ProcessInTrapData]);

(* $IF GarbageCollector *)

    IF GC.AddMutator(StartProcessProc.mutator) THEN

(* $END *)

      Call(StartProcessProc);

(* $IF GarbageCollector *)

    ELSE

      StartProcessProc.done := TRUE;
      Processes := StartProcessProc.next;
                           (* because NewProcessX does a ReleaseSemaphore(ProcessesSemaphore)
                            * after it does Permit(), and this processes priority is 127,
                            * we are safe to modify the Processes-List.
                            *)

    END;

(* $END *)

END StartProc;


PROCEDURE StartProcess;
(*
 * Sets A5 and trapData.oldSP
 *
 * $StackChk-
 *)

BEGIN

  OberonLib.SetA5;

  (* $IF SmallData *)
    OberonLib.execBase.thisTask.trapData.oldSP := SYSTEM.REG(15);
  (* $ELSE *)
    OberonLib.execBase.thisTask.trapData.oldSP := SYSTEM.VAL(LONGINT,SYSTEM.REG(15))-4;
  (* $END *)

  StartProc;

END StartProcess;


(* ------  NewProcessX:  ------ *)


PROCEDURE NewProcessX * (proc: ProcessProc;
                         data: BT.ANY;
                         stackSize: LONGINT;
                         priority: SHORTINT): Process;
(*
 * Start proc as new concurrent process. data will be passed to proc as
 * procedure paramter.
 *
 * proc must be reentrant, ie. it must not access global variables or data
 * structures or call procedures that access global data while other
 * processes may access this data.
 *
 * To be save do not use any global variables within this routine.
 *
 * The new process will have a Stack that is stackSize bytes large. The new
 * process' task priority will be set to priority.
 *
 * This procedure is reentrant and may be called from any process to
 * create new child-processes.
 *
 *)

VAR
  newproc: Process;
  msg: Dos.ProcessId;

BEGIN

  NEW(newproc);

  newproc.taskTrapData := OberonLib.execBase.thisTask.trapData^;
  newproc.taskTrapData.mutator  := SYSTEM.ADR(newproc.mutator);
  newproc.taskTrapData.haltProc := ChildHaltProc;
  newproc.taskTrapData.user[ProcessInTrapData] := SYSTEM.VAL(SYSTEM.ADDRESS,newproc);
  newproc.data         := data;
  newproc.proc         := proc;
  IF priority=127 THEN DEC(priority) END;
  newproc.priority     := priority;
  newproc.done         := FALSE;

  Exec.ObtainSemaphore(ProcessesSemaphore);

    Exec.Forbid;

      IF Dos.dos.lib.version<37 THEN

        FakeSegList.length := 16;
        FakeSegList.next   := NIL;
        FakeSegList.jmp    := 4EF9U;        (* JMP abslong *)
        FakeSegList.start  := StartProcess;

        msg :=  Dos.CreateProc(ProcessName^,
                               127,
                               SYSTEM.ADR(FakeSegList.next),
                               stackSize);
        IF msg=NIL THEN
          newproc.dosProcess := NIL;
        ELSE
          newproc.dosProcess := SYSTEM.VAL(Dos.ProcessPtr,SYSTEM.VAL(LONGINT,msg)-SIZE(Exec.Task));
        END;

      ELSE

        newproc.dosProcess := Dos.CreateNewProcTags(
                                    Dos.npEntry    ,SYSTEM.VAL(SYSTEM.ADDRESS,StartProcess),
                                    Dos.npStackSize,stackSize,
                                    Dos.npName     ,ProcessName,
                                    Dos.npPriority ,127);

      END;

      IF newproc.dosProcess#NIL THEN
        newproc.dosProcess.task.trapData := SYSTEM.ADR(newproc.taskTrapData);
        newproc.dosProcess.task.trapCode := Exec.exec.thisTask.trapCode;
        newproc.next := Processes;
        Processes    := newproc;
      ELSE
        newproc := NIL;
      END;
  
    Exec.Permit;

(*
 * Because the new process' priority is 127, it will run now. It will add its
 * mutator to the GC and maintain a copy of a pointer to its Process-structure
 * in a local variable within Call(). Then it will set its priority to the
 * specified priority. So we are safe to return now, even if our caller
 * deletes the result, which else would be the only reference to the Process.
 *)

  Exec.ReleaseSemaphore(ProcessesSemaphore);

  RETURN newproc;

END NewProcessX;


(* ------  NewProcess:  ------ *)


PROCEDURE NewProcess * (proc: ProcessProc;
                        data: BT.ANY): Process;
(*
 * Start proc as new concurrent process. data will be passed to proc as
 * procedure paramter.
 *
 * proc must be reentrant, ie. it must not access global variables or data
 * structures or call procedures that access global data while other
 * processes may access this data.
 *
 * To be save do not use any global variables within this routine.
 *
 * The stackSize and priority will be inherited from this process.
 *
 * This procedure is reentrant and may be called from any process to
 * create new child-processes.
 *)

BEGIN
  RETURN NewProcessX(proc,
                     data,
                     DefaultStackSize,
                     Exec.exec.thisTask.node.pri);
END NewProcess;


(* ------  Wait:  ------ *)


PROCEDURE (p: Process) Wait * (): BT.ANY;

(*
 * Wait for process p to terminate. Returns its result.
 *)

VAR
  wait: Waiting;

BEGIN
  Exec.ObtainSemaphore(ProcessesSemaphore);
  IF ~ p.done THEN
    NEW(wait);
    wait.task := Exec.exec.thisTask;
    wait.next := p.waiting;
    p.waiting := wait;
    Exec.ReleaseSemaphore(ProcessesSemaphore);
    REPEAT
    UNTIL p.done OR (WakeUpSig IN Exec.Wait(LONGSET{WakeUpSig}));
  ELSE
    Exec.ReleaseSemaphore(ProcessesSemaphore);
  END;
  RETURN p.result;
END Wait;


(* ------  isRunning:  ------ *)


PROCEDURE (p: Process) isRunning * (): BOOLEAN;

(*
 * Check if p is still running.
 *)

BEGIN
  RETURN ~ p.done
END isRunning;


(* ------  WaitForAllProcesses:  ------ *)


PROCEDURE WaitForAllProcesses * ;
(*
 * Wait for all processes to terminate
 *)
VAR
  p: Process;
BEGIN
  LOOP
    Exec.ObtainSemaphore(ProcessesSemaphore);
    p := Processes;
    Exec.ReleaseSemaphore(ProcessesSemaphore);
    IF p=NIL THEN EXIT END;
    IF p.Wait()=NIL THEN END;
  END;
END WaitForAllProcesses;


(* ------  Init:  ------ *)


BEGIN

  Exec.InitSemaphore(ProcessesSemaphore);

  Processes := NIL;

  NEW(ProcessName);
  IF Exec.exec.thisTask.node.name#NIL THEN
    COPY(Exec.exec.thisTask.node.name^,ProcessName^);
  ELSE
    ProcessName^ := "Amiga Oberon";
  END;

  ProcessName[55] := 0X; (* Shrink ProcessName if it's too long *)
  Strings.Append(ProcessName^," background process");

  DefaultStackSize := OberonLib.OldSP.stackSize;

  WakeUpSig := Exec.AllocSignal(-1);
  ProcessInTrapData := OberonLib.AllocUser();
  IF (WakeUpSig<0) OR (ProcessInTrapData<0) THEN
    HALT(20)
  END;

CLOSE

  WaitForAllProcesses;

  IF WakeUpSig>=0 THEN Exec.FreeSignal(WakeUpSig) END;
  IF ProcessInTrapData>=0 THEN OberonLib.FreeUser(ProcessInTrapData) END;

END Concurrency.






