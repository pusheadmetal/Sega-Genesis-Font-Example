# Sega Genesis Fonts Program
## Greetings!
In this repo is code to show you how to import an actual font into your game. It's not terribly advanced,
but it certainly looks a lot better than the previous example. It still prints "Hello, USA" to the screen,
but with a black background and a much better looking font style than before. I'll be adding more characters
to the font at a later date, so stay tuned.

### What The Files Are
1. init.asm - This .asm file runs all of the initialization required to get the Genesis up and 
running so that we can actually execute code.

2. main.asm - This .asm file is our main code. This is the file you'll want to compile.

3. tgl_font.bmp - This is a bitmap of our font. Every character is separated into an 8x8 square, although
some of them look smaller than that, it really does add up that way.

4. tgl_font.asm - This is the assembly conversion of tgl_font.bmp.

5. Ref.txt - This is some quick and dirty 68k Assembly reference I typed up. I'd recommend taking
a look at it if you're unfamiliar with 68k Assembly.

### How to Compile
You need a program called asm68k.exe, which I found on the Sonic Retro website. You then compile
like so: `asm68k.exe /p main.asm, main.bin`

### What If I Want To Make My Own Font?
Make sure each character is in an 8x8 square. I recommend hugging the left side of the sprite sheet
while keeping the bottom and right rows of pixels blank for legibility. Also, you're going to need
a particular program that converts .bmp into 68k assembly. You can grab that [here](http://gendev.spritesmind.net/page-b2t.html).

### What Emulator Should I Run This In?
I personally use Exodus. BlastEm also seems to be a good choice.

### Will this run on the Mega EverDrive?
I don't know! You should try it for me!

Special thanks goes out to Matt at [Big Evil Corporation](https://blog.bigevilcorporation.co.uk) for
helping me get this far.