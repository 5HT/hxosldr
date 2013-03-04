function IsHexileLoader(Drive: Byte): Boolean;
var
  Bool: Boolean;
  Dump: SectorType;
  I: Byte;
const
  Hexile: array [0..6] of Char = 'HXOSLDR';
begin
  ReadSector(DiskProcess,0,0,1,Dump);
  Bool := True;
  for I := 0 to 6 do Bool := Bool and (Dump[$17+I]=Byte(Hexile[I]));
  IsHexileLoader := Bool;
end;

function IsConfigSector(Sector: SectorType): Boolean;
const
  OEMString: array [0..15] of Char = '$HEXILEOSLDRCFG$';
var
  Test: Boolean;
  I: Byte;
begin
  Test := True;
  for I := 0 to 15 do Test := Test and (Sector[I] = Byte(OEMString[I]));
  IsConfigSector := Test;
end;

function GetNumberOS(Sector: SectorType): Byte;
begin
  GetNumberOS := Sector[$12];
end;

function GetDefaultOS(Sector: SectorType): Byte;
begin
  GetDefaultOS := Sector[$10];
end;

function GetDefaultOSTime(Sector: SectorType): Byte;
begin
  GetDefaultOSTime := Sector[$11];
end;

function itoa(I: Integer): string; var S: string;
begin
  Str(I,S);
  itoa := S;
end;

procedure ReadConfig(var ArrayOS: ArrayOSType; Sector: SectorType);
var
  I,J: Shortint;
  TempOS: OSType;
  AbsoluteOS: array [0..SizeOf(OSType) - 1] of Byte absolute TempOS;
begin
  ArrayOS.NumberOS := GetNumberOS(Sector);
  ArrayOS.DefalutOS := GetDefaultOS(Sector);
  ArrayOS.DefalutOSTime := GetDefaultOSTime(Sector);
  for I := 0 to ArrayOS.NumberOS - 1 do begin
    for J := 0 to SizeOf(OSType) - 1 do AbsoluteOS[J] := Sector[$20+I*80+J];
    ArrayOS.Data[I] := TempOS;
  end;
end;

procedure WriteConfig(ArrayOS: ArrayOSType; var Sector: SectorType);
var
  I,J: Shortint;
  TempOS: OSType;
  AbsoluteOS: array [0..SizeOf(OSType) - 1] of Byte absolute TempOS;
const
  OEMString: array [0..15] of Char = '$HEXILEOSLDRCFG$';
begin
  FillChar(Sector,512,0);
  for I := 0 to 15 do Sector[I] := Byte(OEMString[I]);
  Sector[$10] := ArrayOS.DefalutOS;
  Sector[$11] := ArrayOS.DefalutOSTime;
  Sector[$12] := ArrayOS.NumberOS;
  for I := 0 to ArrayOS.NumberOS - 1 do begin
    TempOS := ArrayOS.Data[I];
    for J := 0 to SizeOf(OSType) - 1 do Sector[$20+I*80+J] := AbsoluteOS[J];
  end;
end;
