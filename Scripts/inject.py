import struct,sys,os,shutil
p=sys.argv[1]; name='@rpath/CheatMenu.framework/CheatMenu'; b=bytearray(open(p,'rb').read())
magic,cpu,sub,filetype,ncmds,sizeofcmds,flags,res=struct.unpack_from('<IiiIIIII',b,0)
assert magic==0xfeedfacf and cpu==0x0100000c, 'Expected arm64 Mach-O'
raw=name.encode()+b'\0'; cmdsize=(24+len(raw)+7)&~7; cmd=bytearray(cmdsize)
struct.pack_into('<IIIIII',cmd,0,0xc,cmdsize,24,2,0x10000,0x10000);cmd[24:24+len(raw)]=raw
end=32+sizeofcmds
# Require header slack; Runner 2.4.1(363) has ~3.5 KB.
first=1<<60;o=32
for _ in range(ncmds):
 c,s=struct.unpack_from('<II',b,o)
 if c==0x19:
  ns=struct.unpack_from('<I',b,o+64)[0];so=o+72
  for __ in range(ns):
   off=struct.unpack_from('<I',b,so+48)[0]
   if off:first=min(first,off)
   so+=80
 o+=s
assert end+cmdsize<=first, 'Not enough Mach-O header slack'
b[end:end+cmdsize]=cmd
struct.pack_into('<I',b,16,ncmds+1);struct.pack_into('<I',b,20,sizeofcmds+cmdsize)
open(p,'wb').write(b)
