# Blockbuster
Created By: Michael Shulman, [David Ansermino](https://github.com/ansermino/)

![](https://i.imgur.com/oSKZ4Su.png "Blockbuster")


This is an implementation of the classic Brick Breaker in NIOS assembly. This game has been tested on the Altera DE1. The controller for the game is the Lego controller documented [here](http://www-ug.eecg.utoronto.ca/desl/nios_devices_SoC/dev_newlegocontroller2.html), using two touch sensors for left and right movement. The VGA adapter on the DE1 is utilized for output.

## Features
- Multi-difficulty blocks
- Easily configurable block layouts
- Game win/loss and reset functionality
- Sounds
  - easily customizable sounds
  - multiple sounds can be played at the same time
  - sin wave was generated using Taylor series centered at pi/2
  - uses 15 offset fixed point arithmetic, with accurate no-overflow multiplication in 32 bit registers by splitting 32 bit operations into 16 bit operations.
