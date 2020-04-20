# Sega Genesis "HELLO, USA" Program
## Greetings!
This is my first attempt at making a Sega Genesis ROM and I thought that I'd share my code with you!
Currently, the ROM prints a pink background to the screen a la Bret Hart and prints the words, 
"HELLO, USA" is multiple colors. It looks awful, but I think it's a great start. I've commented my
code quite a bit to try to help anyone reading through it understand what's going on. It's simply
amazing just how many lines of code it takes to get something so simple working.

### What The Files Are
1. init.asm - This .asm file runs all of the initialization required to get the Genesis up and 
running so that we can actually execute code.

2. main.asm - This .asm file is our main code. This is the file you'll want to compile.

3. Ref.txt - This is some quick and dirty 68k Assembly reference I typed up. I'd recommend taking
a look at it if you're unfamiliar with 68k Assembly.

### How to Compile
You need a program called asm68k.exe, which I found on the Sonic Retro website. You then compile
like so: `asm68k.exe /p main.asm, main.bin`

### What Emulator Should I Run This In?
I personally use Exodus. BlastEm also seems to be a good choice.

### Will this run on the Mega EverDrive?
I don't know! You should try it for me!

Special thanks goes out to Matt at [Big Evil Corporation](https://blog.bigevilcorporation.co.uk) for
helping me get this far.