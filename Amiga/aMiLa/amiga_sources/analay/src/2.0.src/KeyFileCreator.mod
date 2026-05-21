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


MODULE KeyFileCreator;

IMPORT d  : Dos,
       s  : SYSTEM,
       a  : Arguments,
       c  : Conversions,
       st : Strings,
       kf : KeyFiles,
       io,
       NoGuruRq;

VAR name,filename,
    string        : ARRAY 80 OF CHAR;
    keystr        : ARRAY 1024 OF CHAR;
    file          : d.FileHandlePtr;
    long          : LONGINT;
    len,numargs,
    userId        : INTEGER;
    bool,isOk     : BOOLEAN;

BEGIN
  numargs:=a.NumArgs();
  io.WriteString("Analay KeyFileCreator V1.0  © 1994 Marc Necker\n");
  io.WriteString("Adresse: ");
  IF numargs=0 THEN
    io.ReadString(name);
  ELSE
    a.GetArg(1,name);
    io.WriteString(name);
    io.WriteLn;
  END;
  io.WriteString("User-ID: ");
  IF numargs<=1 THEN
    bool:=io.ReadInt(long);
  ELSE
    a.GetArg(2,string);
    bool:=c.StringToInt(string,long);
    io.WriteInt(long,5);
    io.WriteLn;
  END;
  userId:=SHORT(long);
  io.WriteString("Schreibe nach: ");
  IF numargs<=2 THEN
    io.ReadString(filename);
  ELSE
    a.GetArg(3,filename);
    io.WriteString(filename);
    io.WriteLn;
  END;
  st.Append(filename,"Analay.keyfile");
  IF name[0]#0X THEN
    len:=kf.CreateKeyFile(keystr,name,userId);
    file:=d.Open(filename,d.newFile);
    long:=d.Write(file,keystr,len);
    bool:=d.Close(file);
  END;
  file:=d.Open(filename,d.oldFile);
  long:=d.Read(file,keystr,1024);
  bool:=kf.CheckKeyFile(isOk,keystr,name,userId);
  IF (bool) AND (kf.error) THEN
    io.WriteString("KeyFile OK!\n");
    io.WriteString("Länge: ");
    io.WriteInt(len,5);
    io.WriteString(" Bytes\n");
    io.WriteString("Adresse: ");
    io.WriteString(name);
    io.WriteLn;
    io.WriteString("User-ID: ");
    io.WriteInt(userId,5);
    io.WriteLn;
  ELSE
    io.WriteString("KeyFile ungültig!\n");
  END;
  bool:=d.Close(file);
END KeyFileCreator.

