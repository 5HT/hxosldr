{$G+,F+}

uses Crt;

type

  { SectorType }

  SectorType = array [0..511] of Byte;

  { OSType }

  OSType = record
    Name: array [0..73] of Char;
    NameLength: Byte;
    Disk: Byte;
    Head: Byte;
    Track: Word;
    Sector: Byte;
  end;

  { ArrayOSType }

  ArrayOSType = record
    Data: array [0..5] of OSType;
    NumberOS: Byte;
    DefalutOS: Byte;
    DefalutOSTime: Byte;
  end;

var
  Config: SectorType;           { Config Table }
  ArrayOS: ArrayOSType;         { Formated Config Table }
  DiskProcess: Byte;            { Current Processed Disk }

{$I INT13}
{$I API}
{$I HEX}
{$I OUTPUT}

procedure DisplayTable; var I,J: Shortint;
begin

  if ArrayOS.NumberOS = 0 then begin
    WriteLn('\12\There is no Operating Systems installed');
    Exit;
  end;

  for I := 0 to ArrayOS.NumberOS - 1 do begin
    Write('  \7\[\6\'+itoa(I+1)+'\7\] == ');
    for J := 3 to ArrayOS.Data[I].NameLength - 1 do Write('\7\'+ArrayOS.Data[I].Name[J]);
    System.Writeln;
  end;

end;

procedure Display;
begin

  WriteLn('\7\Config Table');

  System.Writeln;

  DisplayTable;

  System.Writeln;

  { Display HXOSLDR Status }

  if IsHexileLoader(DiskProcess) then begin
    Writeln('\7\Hexile OS Loader \14\IS\7\ Installed')
  end else begin
    Writeln('\7\Hexile OS Loader \12\IS NOT\7\ Installed');
  end;

end;

procedure Save; var Dump: SectorType;
begin

  WriteConfig(ArrayOS,Dump);
  WriteSector(DiskProcess,0,0,2,Dump);

  WriteLn('\3\Hexile Config Table saved to disk');

end;

function Select: Longint; var Temp: Longint;
begin

  DisplayTable;

  System.Writeln;

  { Check For Empty Table }

  if ArrayOS.NumberOS = 0 then begin
    Writeln('\7\You cannot select OS ''cause no one installed');
    Exit;
  end;

  { Select Code }

  repeat
    Write('\7\Select OS from \14\1\7\ up to \14\' + itoa(ArrayOS.NumberOS) +'\7\: ');
    Readln(Temp);
  until Temp in [1..ArrayOS.NumberOS];

  Select := Temp;

end;

function EditName(Number: Longint): string; var Name: string;
begin

  Write('Enter OS name: ');
  Readln(Name);
  EditName := itoa(Number) + '. ' + Name;

end;

procedure Edit; var Name: string; I: Byte; Selected: Longint;
begin

  Selected := Select;

  System.Writeln;

  Name := EditName(Selected);

  System.Writeln;

  for I := 1 to Length(Name) do ArrayOS.Data[Selected-1].Name[I-1] := Name[I];
  ArrayOS.Data[Selected-1].NameLength := Length(Name);

  TextAttr := 15;
  Writeln('\3\Name for OS number \14\' + itoa(Selected) + '\3\ already changed');
  TextAttr := 7;

  Save;

end;

procedure Add; var New: SectorType; I: Byte; Name: string;
begin

  { Check For Out Of Space }

  if ArrayOS.NumberOS = 6 then begin
    Writeln('\12\You cannot more install OS. You already have six');
    Exit;
  end;

  { Save New MBR }

  ReadSector(DiskProcess,0,0,1,New);
  Inc(ArrayOS.NumberOS);
  WriteSector(DiskProcess,0,0,2+ArrayOS.NumberOS,New);

  { Modify Config Table }

  FillChar(ArrayOS.Data[ArrayOS.NumberOS-1],80,0);

  { Modify MBR Position }

  ArrayOS.Data[ArrayOS.NumberOS-1].Disk   := $80;
  ArrayOS.Data[ArrayOS.NumberOS-1].Head   := 0;
  ArrayOS.Data[ArrayOS.NumberOS-1].Track  := 0;
  ArrayOS.Data[ArrayOS.NumberOS-1].Sector := 2+ArrayOS.NumberOS;

  { Modify Name }

  Name := EditName(ArrayOS.NumberOS);
  for I := 1 to Length(Name) do ArrayOS.Data[ArrayOS.NumberOS-1].Name[I-1] := Name[I];
  ArrayOS.Data[ArrayOS.NumberOS-1].NameLength := Length(Name);

  System.Writeln;

  Writeln('\3\Added new OS');

  Save;

end;

procedure Remove;
begin

  Dec(ArrayOS.NumberOS);

  Writeln('\3\OS number \14\' + itoa(ArrayOS.NumberOS+1) + '\3\ has been deleted');

  Save;

end;

procedure Drive; var Drive: Byte;
begin

  Write('\7\Input Drive from \14\1\7\ upto \14\' + itoa(GetNumberOfDrives) + '\7\: ');
  Readln(Drive);

  DiskProcess := $80 + Drive - 1;
  ReadSector(DiskProcess,0,0,2,Config);

  if not IsConfigSector(Config) then begin
    ArrayOS.NumberOS := 0;
    WriteConfig(ArrayOS,Config);
  end;

  ReadConfig(ArrayOS,Config);

  System.Writeln;

  Writeln('\3\Current Drive Changed To \14\0x' + HexByte(DiskProcess));

end;

procedure Install;
var
  Dump: array [0..511] of Byte;
  I: Word;
  F: file of Byte;

begin

  Assign(F,'hxosldr.bin'); Reset(F);
  ReadSector(DiskProcess,0,0,1,Dump);
  for I := 0 to FileSize(F) - 1 do Read(F,Dump[I]);
  WriteSector(DiskProcess,0,0,1,Dump);
  Close(F);

  Writeln('\3\Hexile OS Loader 3.0 have been installed');

end;

procedure Uninstall; var Dump,MBR: SectorType; I: Word; Selected: Byte;
begin

  Writeln('\7\OS to replace the HXOSLDR:');

  System.Writeln;

  Selected := Select;

  System.Writeln;

  ReadSector(DiskProcess,0,0,Selected+2,Dump);
  ReadSector(DiskProcess,0,0,1,MBR);
  for I := 0 to $1BD do MBR[I] := Dump[I];
  WriteSector(DiskProcess,0,0,1,MBR);

  Write('\3\Hexile OS Loader was replaced by \14\"');
  for I := 3 to ArrayOS.Data[Selected-1].NameLength - 1 do Write('\14\' + ArrayOS.Data[Selected-1].Name[I]);
  Writeln('\14\"\3\ OS');

end;

procedure Quit;
begin

  Writeln('\7\Copyright (c) 1998 Hexile');

end;

const Routines: array [1..8] of procedure = (Display,Edit,Add,Remove,Install,Uninstall,Drive,Quit);

function MainLoop: Boolean; var Choice: Byte;
begin

  repeat

    Writeln('  \11\-- Hexile OS Loader 3.5 Setup -- ');

    System.Writeln;

    Writeln('  \7\[\6\1\7\] == Display');
    Writeln('  \7\[\6\2\7\] == Edit');
    Writeln('  \7\[\6\3\7\] == Add');
    Writeln('  \7\[\6\4\7\] == Remove');
    Writeln('  \7\[\6\5\7\] == Install');
    Writeln('  \7\[\6\6\7\] == Uninstall');
    Writeln('  \7\[\6\7\7\] == Drive');
    Writeln('  \7\[\6\8\7\] == Quit');

    System.Writeln;

    Write('\7\Enter Your Choice: '); Readln(Choice);

    if Choice in [1..8] then begin
      System.Writeln;
      Routines[Choice];
      System.Writeln;
    end;

  until Choice = 8;

end;

begin

  System.Writeln;

  DiskProcess := $80;
  ReadSector(DiskProcess,0,0,2,Config);
  if not IsConfigSector(Config) then begin
    ArrayOS.NumberOS := 0;
    WriteConfig(ArrayOS,Config);
  end;
  ReadConfig(ArrayOS,Config);

  MainLoop;

end.

