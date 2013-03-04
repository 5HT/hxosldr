{$G+}

{$I INT13}

var
  Data: array [0..511] of Byte;
  I: Word;
  F: file of Byte;
  Sector: Byte;
  Disk: Byte;

begin
  if ParamCount = 0 then begin
    Writeln('parameters: read <filename.ext>');
    Exit;
  end;
  Write('input disk: '); Readln(Disk);
  Assign(F,ParamStr(1)); Rewrite(F);
  Write('input sector: '); Readln(Sector);
  ReadSector(Disk,0,0,Sector,Data);
  for I := 0 to 511 do Write(F,Data[I]);
  Close(F);
end.
