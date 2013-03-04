@echo off
tasm.exe hxosldr.asm
tlink /t hxosldr.obj, hxosldr.bin
del *.map
del *.obj
del *.bak
tpc.exe hxosldr.pas
tpc.exe read.pas
tpc.exe write.pas
tpc.exe mbr.pas
copy hxosldr.exe HXOSLDR
copy hxosldr.bin HXOSLDR
copy hxosldr.3-0 HXOSLDR
