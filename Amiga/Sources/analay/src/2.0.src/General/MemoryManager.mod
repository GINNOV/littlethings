(*
Copyright (c) 1994 - 2000 Marc Necker.

This file is part of Analay (v2.0).
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


MODULE MemoryManager;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       l  : LinkedLists,
       m  : Multitasking,
       bt : BasicTypes,
       io,
       NoGuruRq;

VAR garbage : m.MTList;

PROCEDURE NodeToGarbage*(node:m.ShareAble);

BEGIN
  node.FreeUser(NIL);
  IF node.list#NIL THEN
    node.Remove;
  END;
  IF node IS m.Task THEN node(m.Task).Quitting; END;
  garbage.AddTail(node);
END NodeToGarbage;

PROCEDURE ListToGarbage*(list:l.List);

VAR node,next : l.Node;

BEGIN
  node:=list.head;
  WHILE node#NIL DO
    next:=node.next;
    NodeToGarbage(node(m.ShareAble));
    node:=next;
  END;
END ListToGarbage;

PROCEDURE Garbaged*(node:bt.ANY):BOOLEAN;
(* Returns TRUE if node is to be destructed soon (if node is in
   garbage list). *)

BEGIN
  WITH node: l.Node DO
    IF (node.list=NIL) OR (node.list=garbage) THEN
      RETURN TRUE;
    END;
  ELSE
  END;
  RETURN FALSE;
END Garbaged;

PROCEDURE ClearMemory*;

VAR node,node2 : l.Node;

BEGIN
  node:=garbage.head;
  WHILE node#NIL DO
    node2:=node.next;
    WITH node: m.ShareAble DO
      IF node.numtasks=0 THEN
        WITH node: m.LockAble DO
          IF ~node.locked THEN
            IF node IS m.Task THEN
              IF NOT(node(m.Task).ccprocess.isRunning()) THEN
                io.WriteString("Destructing Task...");
                node.Destruct;
                io.WriteString(" Done.\n");
              END;
            ELSE
              io.WriteString("Destructing LockAble...");
              node.Destruct;
              io.WriteString(" Done.\n");
            END;
          END;
        ELSE
          io.WriteString("Destructing ShareAble...");
          node.Destruct;
          io.WriteString(" Done.\n");
        END;
      END;
    ELSE
      io.WriteString("Destructing Node...");
      node.Destruct;
      io.WriteString(" Done.\n");
    END;
    node:=node2;
  END;
END ClearMemory;

BEGIN
  garbage:=m.Create();
CLOSE
  IF garbage#NIL THEN
    io.WriteString("CMM1\n");
    ClearMemory;
    io.WriteString("CMM2\n");
    garbage.Destruct;
    io.WriteString("CMM3\n");
  END;
    io.WriteString("CMM END\n");
END MemoryManager.

