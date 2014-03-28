2048-CHIP8
==========

This is an implementation of the [2048 game](http://gabrielecirulli.github.io/2048/)
for the [CHIP-8](http://en.wikipedia.org/wiki/CHIP-8) virtual machine.

To build it, you need a CHIP-8 assembler, for example [Chip8 1.1](http://chip8.sourceforge.net/).

Instructions
------------
![Screenshot](http://i.imgur.com/VOW7Iyw.png)

Because of the low resolution of the CHIP-8 display, instead of using
powers of 2, this port simply uses digits from `0` to `9` to represent
tile values. This means two `0` tiles can fuse to form a `1` tile, two `1`
tiles can fuse to form a `2` tile, and so on. The objective, then, is to
fuse two `9` tiles.

The current version doesn't check for this victory condition yet, and
so two `9` tiles happily overflow to an `A` tile.

Controls are:

* `2` to slide up
* `8` to slide down
* `4` to slide left
* `6` to slide right
