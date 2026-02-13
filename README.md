# Smash For the Gameboy DMG

Smash is a fanmade remake of the well known nintendo game **Super Smash Bros.** 
The game is designed to work natively on the original Gameboy DMG from 1989. It's written completely in assembly and uses a makefile to compile it to Gameboy readable code. 

## How to play
A guide to compile the game is down below

### Where to play

To play youll need an emulator or a flash cartridge for a Gameboy. The easies is to download [Sameboy](https://sameboy.github.io/downloads/) emulator. Sameboy is a Gameboy DMG emulator that works on Mac, Windows and iPhone. 

For more ad advanced people the gameboy emulator; [Emulicious](https://emulicious.net/) offes a higher complexity and debugging functions. This works both on Mac and Windows though on Mac youll need to install java first to run it. 

### Movement (Depending on character used)

* DPAD UP       -   Jump
* DPAD DOWN     -   Fall Down
* DPAD LEFT     -   Go Left
* DPAD RIGHT    -   Go right

* Button A      -   Attack
* Button B      -   Special Attack

* Start         -   Start / Stop Game
* Select        -   Pause Game

### Combos  

* DPAD DOWN     +   BUTTON B    -   Defence
* DPAD DOWN     +   BUTTON A    -   Finishing Move

# FaQ

### Is it free
* Yes, it's free and open source for everyone.

### What's the technology behind
* Its 100% assembly for gameboy. 

### Is the developer assosiated with Epstein
* No


# How to compile

## What packages you need to compile

### RGBDS 

RGBDS is the package that we'll be using to compile the game. To download RGBDS you can follow [this](https://rgbds.gbdev.io/install) link or do the following commands for Mac users using homebrew:

```
brew install rgbds
````


### rgbasm

RGBASM is the assembler for compiling the code

### rgblink

RGBLINK is the linker 

### rgbfix

RGBFIX is thre for the ROM header fixer


### Finally compiling the game

While in the root of the project run the following command for when you compile it the first time:
```
make
````

If you change the code and in other files than the main.asm you'll need to run the following command to compile it
```
make rebuild
```

This will now compile the game and the result will be in the root of the project named SMASH.gb