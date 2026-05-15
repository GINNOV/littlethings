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
(*  Amiga Oberon Library Module: LinkedList           Date: 02-Nov-92      *)
(*                                                                         *)
(*   © 1992 by Fridtjof Siebert                                            *)
(*                                                                         *)
(*-------------------------------------------------------------------------*)

MODULE LinkedLists;

IMPORT
(* $IFNOT NoCheck *)
       Requests,
(* $END *)
       BT * := BasicTypes;


TYPE
  Node * = POINTER TO NodeDesc;
  List * = POINTER TO ListDesc;

  NodeDesc * = RECORD (BT.ANYDesc)
    next-,prev-: Node;
    list-: List;
  END;

  ListDesc* = RECORD (BT.COLLECTIONDesc);
    head-: Node;
    tail-: Node;
    remallowed: INTEGER;
    numElements: LONGINT;
  END;


PROCEDURE (node:Node) Init*;
END Init;

(* Copy and AllocNew have to be redefined! *)

PROCEDURE (node:Node) Copy*(node2:Node);
END Copy;

PROCEDURE (node:Node) AllocNew*():Node;

VAR node2 : Node;

BEGIN
  NEW(node2);
  RETURN node2;
END AllocNew;

PROCEDURE (node:Node) CopyNew*():Node;

VAR node2 : Node;

BEGIN
  node2:=node.AllocNew(); node2.Init;
  node.Copy(node2);
  RETURN node2;
END CopyNew;



PROCEDURE Create * (): List;
VAR
  list: List;
BEGIN
  NEW(list);
  RETURN list;
END Create;


PROCEDURE (list: List) AddHead*(n: Node);
BEGIN
(* $IFNOT NoCheck THEN *)
  IF n.list#NIL THEN Requests.Fail("LinkedLists: Element added to two lists!") END;
(* $END *)
  n.list := list;
  n.next := list.head;
  n.prev := NIL;
  IF n.next=NIL THEN list.tail   := n;
                ELSE n.next.prev := n END;
  list.head := n;
  INC(list.numElements);
END AddHead;


PROCEDURE (list: List) AddTail*(n: Node);
BEGIN
(* $IFNOT NoCheck THEN *)
  IF n.list#NIL THEN Requests.Fail("LinkedLists: Element added to two lists!") END;
(* $END *)
  n.list := list;
  n.prev := list.tail;
  n.next := NIL;
  IF n.prev=NIL THEN list.head   := n;
                ELSE n.prev.next := n END;
  list.tail := n;
  INC(list.numElements);
END AddTail;


PROCEDURE (n: Node) Remove*;
BEGIN
(* $IFNOT NoCheck THEN *)
  IF (n.list=NIL) THEN Requests.Fail("LinkedLists: Remove called with Element not added to a list!") END;
  IF (n.list.remallowed#0) THEN Requests.Fail("LinkedLists: Remove called within Do or DoBackward") END;
(* $END *)
  IF n.next#NIL THEN n.next.prev := n.prev ELSE n.list.tail := n.prev END;
  IF n.prev#NIL THEN n.prev.next := n.next ELSE n.list.head := n.next END;
  DEC(n.list.numElements);
  n.list := NIL;
END Remove;


PROCEDURE (list: List) RemHead*(): Node;
VAR n: Node;
BEGIN
  n := list.head;
  IF n#NIL THEN n.Remove END; 
  RETURN n;
END RemHead;


PROCEDURE (list: List) RemTail*(): Node;
VAR n: Node;
BEGIN
  n := list.tail;
  IF n#NIL THEN n.Remove END;
  RETURN n;
END RemTail;


PROCEDURE (x: Node) AddBefore*(n: Node);
(* fügt n vor x in die Liste ein *)

BEGIN
(* $IFNOT NoCheck THEN *)
  IF x.list=NIL THEN Requests.Fail("LinkedLists: AddBefore() called with Element not added to a list!") END;
  IF n.list#NIL THEN Requests.Fail("LinkedLists: Element added to two lists!") END;
(* $END *)
  n.prev := x.prev;
  n.next := x;
  x.prev := n;
  IF n.prev=NIL THEN x.list.head := n
                ELSE n.prev.next := n END;
  INC(x.list.numElements);
  n.list := x.list;
END AddBefore;


PROCEDURE (x: Node) AddBehind*(n: Node);
(* fügt n hinter x in die Liste ein *)

BEGIN
(* $IFNOT NoCheck THEN *)
  IF x.list=NIL THEN Requests.Fail("LinkedLists: AddBehind() called with Element not added to a list!") END;
  IF n.list#NIL THEN Requests.Fail("LinkedLists: Element added to two lists!") END;
(* $END *)
  n.next := x.next;
  n.prev := x;
  x.next := n;
  IF n.next=NIL THEN x.list.tail := n
                ELSE n.next.prev := n END;
  INC(x.list.numElements);
  n.list := x.list;
END AddBehind;


PROCEDURE (list: List) Add * (x: BT.ANY);  
(* add x to c.
 * depending on the implementation it is added at some point to the
 * collection.
 *)

BEGIN
  list.AddTail(x(Node));
END Add;


PROCEDURE (list: List) Remove * (x: BT.ANY);
(* removes x from c.
 *)

BEGIN
  x(Node).Remove;
END Remove;


PROCEDURE (list: List) nbElements * (): LONGINT;
(* returns the number of elements within c.
 *)
BEGIN
  RETURN list.numElements;
END nbElements;


PROCEDURE (list: List) Do * (p: BT.DoProc; par: BT.ANY);
(* calls p(x,par) for every element x stored within c.
 * par passes some additional information to p. par is not touched by Do.
 *)

VAR n: Node;
BEGIN
  INC(list.remallowed);
  n := list.head; WHILE n#NIL DO p(n,par); n := n.next END;
  DEC(list.remallowed);
END Do;


PROCEDURE (list: List) DoBackward*(p: BT.DoProc; par: BT.ANY);
VAR n: Node;
BEGIN
  INC(list.remallowed);
  n := list.tail; WHILE n#NIL DO p(n,par); n := n.prev END;
  DEC(list.remallowed);
END DoBackward;



(* Tools for lists      Marc Necker 1995 *)

(* $IFNOT GarbageCollector *)

PROCEDURE (node:Node) Destruct*;

BEGIN
  IF node.list#NIL THEN
    node.Remove;
  END;
  DISPOSE(node);
END Destruct;

(* $END *)

PROCEDURE (list:List) DestructNodes*;

VAR node,nextnode : Node;

BEGIN
  (* $IFNOT GarbageCollector *)
    node:=list.head;
    WHILE node#NIL DO
      nextnode:=node.next;
      node.Destruct;
      node:=nextnode;
    END;
  (* $END *)
END DestructNodes;


PROCEDURE (list:List) Destruct*;

BEGIN
  (* $IFNOT GarbageCollector *)
    list.DestructNodes;
    DISPOSE(list);
  (* $ELSE *)
    list:=NIL;
  (* $END *)
END Destruct;


PROCEDURE (list: List) Init*;    (* Adapted from original *)
BEGIN
  list.DestructNodes;
  list.head := NIL;
  list.tail := NIL;
  list.remallowed := 0;
  list.numElements := 0;
END Init;


PROCEDURE (list:List) Append*(list2:List);

(* Appends list to list2 *)

VAR node : Node;

BEGIN
  node:=list.head;
  WHILE node#NIL DO
    list2.AddTail(node.CopyNew());
    node:=node.next;
  END;
END Append;


PROCEDURE (list:List) Copy*(list2:List);

(* Copies list to list2 *)

BEGIN
  list2.Init;
  list.Append(list2);
END Copy;


PROCEDURE (list:List) CopyNew*():List;

VAR list2 : List;

BEGIN
  list2:=Create();
  list.Append(list2);
  RETURN list2;
END CopyNew;


PROCEDURE (list:List) GetNode*(num:LONGINT):Node;

VAR node : Node;

BEGIN
  node:=list.head;
  WHILE (num>0) AND (node#NIL) DO
    node:=node.next;
    DEC(num);
  END;
  RETURN node;
END GetNode;

PROCEDURE (list:List) GetNodeNumber*(node:Node):LONGINT;

VAR i     : LONGINT;
    node2 : Node;

BEGIN
  node2:=list.head;
  i:=0;
  WHILE (node2#NIL) AND (node2#node) DO
    INC(i);
    node2:=node2.next;
  END;
  IF node2=NIL THEN
    i:=-1;
  END;
  RETURN i;
END GetNodeNumber;


END LinkedLists.



