Hello and welcome to F-Zero Final v0.1!

Introduction:

F-Zero Final is a mod that brings all of the content from BS F-Zero Grand Prix 2 into the original F-Zero and enhances F-Zero to handle custom maps/leagues/backgrounds/palettes etc.  These changes lay the foundation for a level editor currently in development code named "FZEdit".

Legal:

This project is a collaboration between authors Gregory Lewandowski (Grego) and Richard Bukor (CatadorDeLatas).

It is distributed under GNU General Public License v3: https://www.gnu.org/licenses/gpl-3.0.html

Please do not distribute this work without providing all source code and attribution as required.

Installation:

To apply the patch please place your F-Zero USA and Grand Prix 2 roms (legally obtained of course) into a folder named SNES_ROMS exactly one directory up from the F-Zero Final project folder.

Your roms will need to be named F-Zero.sfc and F-Zero_Grand_Prix_2.sfc (or you will need to modify the projects batch files and source to handle your naming convention).

Download XKAS v0.06 and place it in the project directory:

https://www.romhacking.net/utilities/269/
https://www.smwcentral.net/?p=section&a=details&id=4615

Running apply_patch.bat or .sh will apply the patch using XKAS v0.06. This process is non-destructive and will create a new rom file named F-Zero_Final.sfc.

If you are building on linux a recent version of Wine is required, you will also need to add the execute permission to the shell file: 

chmod +x ./apply_patch.sh

Known Bugs:

	* SRAM records are incorrectly handled, as a result ace league reuses knight leagues SRAM record locations.
	* Mute city iv has an incorrect horizon gradient
	* Track shortcut routines ignored for ace league

TODO:

	* Implement configurable horizon tables
	* Implement configurable shortcut routines
	* Implement configurable explosive car chance tables
	* Expand SRAM and fix records handling for GP2/custom leagues
	* Fix records screen to handle all leagues
	* Add Grand Prix 2 vehicles to the roster
	* Fix alignment of hijack tables to allow for additional entries for custom leagues (partially done)
	* Split Grand Prix 2 rom to remove unnecessary ghost data (last 512k of gp2 is useless)
