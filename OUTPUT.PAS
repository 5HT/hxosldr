procedure Write(S: string);
var
  Len: Byte absolute S;
  I,J,Attr,OldAttr: Byte;
  S1: String;
  C: Integer;
begin
  OldAttr := TextAttr;
  I := 0;
  while I < Len do
  begin
    Inc(I);
    J := I; S1[0] := #0;
    while (S[J] <> '\') and (J <= Len) do Inc(J);
    Move(S[I],S1[1],J-I); S1[0] := Char(J-I);
    System.Write(S1);
    I := J + 1; J := I;
    while (S[J] <> '\') and (J <= Len) do Inc(j);
    Move(S[i],S1[1],j-i); S1[0] := Char(j-i);
    I := J;
    if J < Len then begin
      if S1[0] = #0 then System.Write('\') else begin
        Val(S1,Attr,C);
        if C = 0 then TextAttr := Attr;
      end;
    end;
  end;
  TextAttr := OldAttr;
end;

procedure WriteLn(S : string);
begin
  Write(S);
  System.WriteLn;
end;
