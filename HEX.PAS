const
  HexDigits: array [0..15] of Char = '0123456789ABCDEF';

function HexByte(B: Byte): string;
begin
  HexByte[0] := #2;
  HexByte[1] := HexDigits[B shr 4];
  HexByte[2] := HexDigits[B and 15];
end;

function HexWord(W: Word): string;
begin
  HexWord := HexByte(Hi(W)) + HexByte(Lo(W));
end;

function HexLong(L: Longint): string;
begin
  HexLong := HexWord(L shr 16) + HexWord(L and $FFFF);
end;
