UDK3-PracticaFinal
==================

This demo was done with the UDK assets in two weeks ass a final exam.

Controls
--------
W............ADVANCE

A............LEFT

S............BACK

D............RIGHT

E............INTERACT

Z............CROUCH (HOLD)

SPACE........JUMP

CONTROL+1....FOLLOWPAWN CAMERA

CONTROL+2....DIABLOLIKE CAMERA

CONTROL+3....GEARS CAMERA

MOUSE WHEEL..ZOOM IN DIABLOLIKE AND FOLLOWPAWN CAMERAS

To exit the game press TAB and then write "exit" (without quotes) and then press Enter.

Functionality
-------------
Camera
- Added a camera archetype so the values are easily modified inside the editor.
- In the archetype you can select which camera type appears at the start of the level.
- You can switch the camera with Ctrl+1, Ctrl+2 and Ctrl+3 (Side y LateralSide are not allowed in this switch).
- Added camera collision with ingame objects, so if there is an object between the camera and the player, the camera changes its position in front of the object so there are no elements in between them.
- Smooth zoom.
- Side and LateralSide cameras so they are fully lateral, including lateral controls (advance with ‘D’ key instead of ‘W’).

The weapon has a laser point (a light), ammo and sound play.

Added subtitles that can be set in Kismet whenever we want (so the designer can write them and show them whenever he/she wants).

Added life functionality.

Added kismet functions (buy ammo, change camera, etc).

Walkthrough
-----------
An easy walktrough to see everything done can be read here:
https://docs.google.com/document/d/12wqMjZC4na7wNufVK1AH2c8oBZgGhVYUNFjmuJTyWz0/edit?usp=sharing

Installation
------------
To play this demo, you need UDK3 or Install it. To install it you need to download the installer, you can do it here:

https://www.dropbox.com/s/kwcjoc9lbbnzk15/UDKInstall-Final2013.exe

It may give an error while installing, but it runs correctly. After it is done, you can run the demo from "InstallDir\Binaries\Win32\UDK.exe"
