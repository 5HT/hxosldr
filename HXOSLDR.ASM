			.model  tiny
			.code
			org     100h
start:

;
; Self copy from 0000:7C00 to 0000:7A000
; and give it execution
;
			xor     ax,ax
			mov     es,ax
			mov     ds,ax
			mov     si,7c00h
			mov     di,7a00h
			cld
			mov     cx,100h
			rep     movsw
			db      0eah
			dw      normal - 100h + 7a00h
			dw      0
			db	'HXOSLDR'
normal:

;
; Load the $HEXILEOSLDRCFG$ into 0000:7800 to process with it
; Format of $HEXILEOSLDRCFG$ :
; Offset	Size	Contents
; -------------	-------	-----------------------------------
; 0x0000.......	16.....	Sector Name........................
; 0x0010.......	16.....	Config Table For All OS's..........
; 0x0020.......	64.....	First OS Name......................
; 0x006B.......	1......	First OS Name Length...............
; 0x006C.......	4......	Native MBR Address for First OS....
; 0x0070.......	64.....	Second OS Name.....................
; 0x00BB.......	1......	Second OS Name Length..............
; 0x00BC.......	4......	Native MBR Address for Second OS...
; And so on ...
;
			xor	ax,ax
			mov	es,ax
			mov	bx,07800h
			mov	ax,0201h
			mov	cx,2
			mov	dx,80h
			int	13h
;
; Init Text Mode
;
			mov	ax,3
			int	10h
;
; Clear Cursor
;	
			mov	ah,1
			mov	cx,2000h
			int	10h
;
; Calculate NumberOS
;			
			xor	ax,ax
			mov	al,[bx+12h]
			mov	NumberOS - 100h + 7a00h,ax
;
; Draw Lines
;
			mov	ax,1300h
			mov	dl,4
			mov	dh,4
			mov	bh,0
			mov	bl,7
			mov	bp,7820h
			xor	cx,cx
			xor	si,si
next:
			inc	si
			mov	cl,[bp+4ah]
			int	10h
			add	bp,50h
			inc	dh
			cmp	si,NumberOS - 100h + 7a00h
			jb	next
;
; Draw Copyright
;
			mov	dh,2
			mov	bp,offset Copy - 100h + 7a00h
			mov	cx,CopyLength - 100h + 7a00h
			mov	bl,0fh
			int	10h
;
; Handle The Keyboard
;

looping:			
			mov     ah,0
			int     16h
			sub     al,30h
			cmp	al,1
			jb	looping
			cmp	al,byte ptr NumberOS - 100h + 7a00h
			ja	looping
			dec	al
			mov     es:[7810h],al
;
; Interface End + Reinit Text Mode
;
			mov	ax,3
			int	10h
;
; Get default OS and calculate the sector of it NATIVE MBR
;
			mov	bx,7820h
			mov	cl,[bx-10h] ; cl - current OS
			mov	DefaultOS - 100h + 7a00h,cl
			mov	al,80
			mul	cl
			add	bx,ax
;
; Load [Disk:Head:Track:Sector] Address from $HEXILEOSLDRCFG$
; to internal area
;
			mov	al,[bx+4bh]
			mov	Disk - 100h + 7a00h,al
			mov	al,[bx+4ch]
			mov	Head - 100h + 7a00h,al
			mov	ax,[bx+4dh]
			mov	Track - 100h + 7a00h,ax
			mov	al,[bx+4fh]
			mov	Sector - 100h + 7a00h,al
;			
; Read System MBR into 0000:7600
;
			xor	ax,ax
			mov	es,ax
			mov	bx,07600h
			mov	ax,0201h
			mov	cx,1
			mov	dx,80h
			int	13h
;
; Read Needed Native OS MBR
;
			xor     ax,ax
			mov     bx,07c00h
			mov     es,ax
			mov     dh,Head - 100h + 7a00h
			mov     ax,Track - 100h + 7a00h
			mov     ch,al
			shl     ah,6
			mov     cl,0
			or      cl,ah
			mov     al,Sector - 100h + 7a00h
			and     cl,0c0h
			or      cl,al
			mov     dl,Disk - 100h + 7a00h
			mov     ax,0201h
			int     13h
;
; Copy from Navive OS MBR Boot Flags into System MBR
;
			mov	si,7c00h
			mov	di,7600h
			mov	al,[si+1beh]
			mov	[di+1beh],al
			mov	al,[si+1ceh]
			mov	[di+1ceh],al
			mov	al,[si+1deh]
			mov	[di+1deh],al
			mov	al,[si+1eeh]
			mov	[di+1eeh],al
;
; Save 0000:7600 to System MBR (Directly to Disk)
;
			xor	ax,ax
			mov	es,ax
			mov	bx,07600h
			mov	ax,0301h
			mov	cx,1
			mov	dx,80h
			int	13h
;
; Give control to 0000:7C00
;
			db      0eah
			dw      7c00h
			dw      0

NumberOS		dw	0
DefaultOS		db	0
Disk                    db      0
Head                    db      0
Track                   dw      0
Sector                  db      0
Copy			db	'Hexile OS Loader 3.0'
CopyLength		dw	$-Copy
			end     start
