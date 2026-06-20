# FlappyAceWin

A flappy bird clone for the Amiga 500

Built using the Amiga C Engine. All in C.

The game is fully working, with the ADF in the root directory.

It is a little quirky, the collision detection is instant so if you hit a pipe you'll be flashed to the menu pretty quickly, And the text in the replay menu sometimes is chopped.

All game logic is within src/game.c with the menu in menu.c. There are headers included for functions I wanted to deal with high score saves but AmigaOS wasn't happy with writing to files inside a floppy for some reason and I just left it.

Here is a simpler link for downloading the ADF: https://nzjeux29.itch.io/flappy-ace 

![image](https://github.com/NZjeux26/FlappyAceWin/assets/91103932/69fb6058-175d-4f28-888a-6ff6a5a1f4fd)

