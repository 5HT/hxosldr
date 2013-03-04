{
    INT 13 API (Low Level API):

    procedure ReadSector(Disk,Head,Sector: Byte; Track: Word; var Data);
    procedure WriteSector(Disk,Head,Sector: Byte; Track: Word; var Data);
}

procedure ReadSector(Disk,Head: Byte; Track: Word; Sector: Byte; var Data);
assembler;
asm
  les bx,Data; mov dh,Head; mov ax,Track; mov ch,al; shl ah,6;
  mov cl,0; or cl,ah; mov al,Sector; and cl,$c0; or cl,al; mov dl,Disk;
  mov ax,$0201; int $13;
end;

procedure WriteSector(Disk,Head: Byte; Track: Word; Sector: Byte; var Data);
assembler;
asm
  les bx,Data; mov dh,Head; mov ax,Track; mov ch,al; shl ah,6;
  mov cl,0; or cl,ah; mov al,Sector; and cl,$c0; or cl,al; mov dl,Disk;
  mov ax,$0301; int $13;
end;

function GetNumberOfDrives: Byte; assembler;
asm
  mov ah,8; mov dl,$80; int 13h; mov al,dl;
end;
