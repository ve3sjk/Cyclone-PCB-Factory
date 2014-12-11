// This file is part of Cyclone PCB Factory: an open-source 3D printable CNC machine for PCB manufacture
// http://reprap.org/wiki/Cyclone_PCB_Factory
// Original author: Carlosgs (http://carlosgs.es)
// License: CC BY-SA 4.0 (Attribution-ShareAlike 4.0 International, http://creativecommons.org/licenses/by-sa/4.0/)
// Designed with http://www.openscad.org/


// Original Endstop Board Holder
// Fits Endstop Assembly ?

// moved to separate module to accomodate differnt endstop switches

// TO DO:
//Create endstop for Highly VS-15 Med lengh Roller Swithes
//Should be able to select endstop type by model in config. h
// File when completed.

module endstop_holder(holes=false, plasticColor="blue", shortNuts=false) {
	boardX = 41;
	boardY = 16.05;
	boardZ = 1.62;
	
	holderX = 29;
	holderY = 8;
	holderZ = 6;
	
	screwWallSep = 2.75;
	
	if(holes) {
		translate([0,0,-boardZ]) {
			// PCB
			cube([boardX,boardY,boardZ+10]);
			// Endstop pins
			translate([6.2,6.5,-3])
				cube([13.5,5,3]);
			// Connector pins
			translate([26.7,3.5,-3])
				cube([3,7.8,3]);
		}
		translate([0,screwWallSep,3]) {
			translate([3.7,0,0])
				rotate([90,0,0])
					hole_for_screw(size=3,length=15,nutDepth=shortNuts?5:0,nutAddedLen=shortNuts?0:5,captiveLen=10,rot=90);
			translate([22.7,0,0])
				rotate([90,0,0])
					hole_for_screw(size=3,length=15,nutDepth=shortNuts?5:0,nutAddedLen=shortNuts?0:5,captiveLen=10,rot=90);
		}
	} else {
		color(plasticColor) translate([holderX/2,holderY/2,-holderZ/2-boardZ])
			bcube([holderX,holderY,holderZ], cr=2, cres=4);
		// PCB
		color("lightgrey") translate([0,0,-boardZ])
			%cube([boardX,boardY,boardZ]);
		// Endstop
		color("grey") translate([6.8,0,0])
			%cube([12.8,6.5,6.3]);
		color("lightgrey") translate([6.8+12.8-1,0,0])
			rotate([0,0,180+15])
				%cube([12.8,0.2,6.3]);
		// Screws
		translate([0,screwWallSep,3]) {
			translate([3.7,0,0])
				rotate([90,0,0])
					screw_and_nut(size=3,length=10,nutDepth=0, rot=90, echoPart=true);
			translate([22.7,0,0])
				rotate([90,0,0])
					screw_and_nut(size=3,length=10,nutDepth=0, rot=90, echoPart=true);
		}
	}
    }