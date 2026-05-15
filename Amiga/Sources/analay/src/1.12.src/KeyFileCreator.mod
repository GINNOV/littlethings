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


MODULE KeyFileCreator;

IMPORT d  : Dos,
       s  : SYSTEM,
       st : Strings,
       kf : KeyFiles,
       io,
       NoGuruRq;

VAR name,filename : ARRAY 80 OF CHAR;
    keystr        : ARRAY 1024 OF CHAR;
    file          : d.FileHandlePtr;
    long          : LONGINT;
    len           : INTEGER;
    bool,isOk     : BOOLEAN;

BEGIN
  io.WriteString("Analay KeyFileCreator V0.9  © 1994 Marc Necker\n");
  io.WriteString("Adresse: ");
  io.ReadString(name);
  io.WriteString("Schreibe nach: ");
  io.ReadString(filename);
  st.Append(filename,"Analay.keyfile");
  IF name[0]#0X THEN
    len:=kf.CreateKeyFile(keystr,name);
    file:=d.Open(filename,d.newFile);
    long:=d.Write(file,keystr,len);
    bool:=d.Close(file);
  END;
  file:=d.Open(filename,d.oldFile);
  long:=d.Read(file,keystr,1024);
  bool:=kf.CheckKeyFile(isOk,keystr,name);
  IF bool THEN
    io.WriteString("KeyFile OK!\n");
    io.WriteString("Länge: ");
    io.WriteInt(len,5);
    io.WriteString(" Bytes\n");
    io.WriteString("Adresse: ");
    io.WriteString(name);
    io.WriteLn;
  ELSE
    io.WriteString("KeyFile ungültig!\n");
  END;
  bool:=d.Close(file);
END KeyFileCreator.

