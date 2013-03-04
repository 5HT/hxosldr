{$G+}

{$I INT13}

var
  Data: array [0..511] of Byte;
  I: Word;
  F: file of Byte;
  Disk: Byte;
  
function Min(A,B: Longint): Longint;
begin
  if A < B then Min := A else Min := B;
end;

begin
  if ParamCount = 0 then begin
    Writeln('parameters: mbr <filename.ext>');
    Exit;
  end;
  Write('input disk: '); Readln(Disk);
  Assign(F,ParamStr(1)); Reset(F);
  ReadSector(Disk,0,0,1,Data);
  for I := 0 to Min(FileSize(F) - 1,445) do Read(F,Data[I]);
  WriteSector(Disk,0,0,1,Data);
  Close(F);
end.
