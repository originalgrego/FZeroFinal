Hello and welcome to F-Zero Final v0.2!

Introduction:

F-Zero Final is a mod that brings all of the content from BS F-Zero Grand Prix 2 into the original F-Zero and enhances F-Zero to handle custom maps/leagues/backgrounds/palettes etc.  These changes lay the foundation for a level editor currently in development code named "FZEdit". 

New to version 0.2 is the ability to select the Grand Prix 2 vehicles (Press L or R during vehicle selection), complete with master mode endings for the original three leagues!

Legal:

This project is a collaboration between authors Gregory Lewandowski (Grego) and Richard Bukor (CatadorDeLatas).

Grand Prix 2 Master Ending Graphics were contributed by Alejandro

It is distributed under GNU General Public License v3: https://www.gnu.org/licenses/gpl-3.0.html

Please do not distribute this work without providing all source code and attribution as required.

Installation:

To apply the patch please place your F-Zero USA (CRC32 - 0xAA0E31DE) and Grand Prix 2 (CRC32 - 0xC4808858) roms (legally obtained of course) into a folder named SNES_ROMS exactly one directory up from the F-Zero Final project folder.

The folder structure should look as so on windows:

C:\Users\You\Directory\SNES_ROMS <- ROMs go here
C:\Users\You\Directory\F-Zero_Final <- Code and xkas.exe goes here

Your roms will need to be named F-Zero.sfc and F-Zero_Grand_Prix_2.sfc (or you will need to modify the projects batch files and source to handle your naming convention).

PLEASE MAKE SURE YOUR ROMS ARE NAMED PROPERLY! See FAQ/Help below.

Download XKAS v0.06 and place it in the project directory:

https://www.smwcentral.net/?p=section&a=details&id=4615

Running apply_patch.bat or .sh will apply the patch using XKAS v0.06. This process is non-destructive and will create a new rom file named F-Zero_Final.sfc.

If you are building on linux a recent version of Wine is required, you will also need to add the execute permission to the shell file: 

chmod +x ./apply_patch.sh

Bugs Fixed in v0.2:

	* SRAM records are incorrectly handled
	* Mute city iv has an incorrect horizon gradient

Enhancements to v0.1:

	* Expanded SRAM and fixed records handling for GP2/custom leagues
	* Horizon gradients are configurable by league
	* All course times are properly stored in SRAM
	* Added Grand Prix 2 vehicles to the roster
	* GP2 vehicles have custom master mode ending graphics
	
Known Bugs:

	* Track shortcut routines ignored for ace league
	* "Ghost" shows up in the menu when using GP2 vehicles in practice but is not selectable

TODO:

	* Integration with FZEdit for custom leagues/maps
	* Rewrite shortcut routines to use scalable algorithm, allowing for custom leagues
	* Make master mode endings work for Ace/Custom leagues
	* Implement configurable shortcut routines
	* Implement configurable explosive car chance tables
	* Fix records screen to handle all leagues
	* Fix alignment of hijack tables to allow for additional entries for custom leagues (partially done)
	* Split Grand Prix 2 rom to remove unnecessary ghost data (last 512k of gp2 is useless)
	* Improve documentation

?-----------------? FAQ/Help ?-----------------?

Common problems you may experience during installation include: 

Incorrect directory structure - Please see above explanation of directory structure.

Incorrect ROM files - Please make sure you are using F-Zero USA (CRC32 - 0xAA0E31DE) and Grand Prix 2 (CRC32 - 0xC4808858)

Incorrect file names - To verify your roms have the correct name and file extension in Windows you will need to:

	1.) Open a command prompt, type "cmd" into the run textbox in your start bar and hit enter
	2.) Type "cd C:\Users\You\Directory\SNES_ROMS" into the command prompt and hit enter, this will take you to your SNES_ROMS directory
	3.) Type "dir" and hit enter, showing you the files in the directory

Alternatively you can do this through the file explorer, in Windows 7 this is done as so:

	1.) Click the "Organize" drop down in the upper left corner of the file explorer window, choose "Folder and search options"
	2.) Click the "View" tab and uncheck the "Hide extensions for known file types" checkbox
	3.) Click apply and close the menu

?-----------------? FAQ/Help ?-----------------?
	