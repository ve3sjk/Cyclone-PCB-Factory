// This file is part of Cyclone PCB Factory: an open-source 3D printable CNC machine for PCB manufacture
// http://reprap.org/wiki/Cyclone_PCB_Factory
// Original author: Carlosgs (http://carlosgs.es)
// License: CC BY-SA 4.0 (Attribution-ShareAlike 4.0 International, http://creativecommons.org/licenses/by-sa/4.0/)
// Designed with http://www.openscad.org/

// ---------- NOTES FOR A PROPER RENDERING IN OPENSCAD -----------
//   First of all, make sure you are using the latest version of OpenScad (>= 2014.05.31)
//   Then, it is important to change a default setting. Go to: Edit --> Preferences --> Advanced
//   And increase "Turn off rendering at 2000 elements" to a larger number like 20000
// -------------------------------------------------------------

// ---------- GENERATING THE STL FILES  ------------------------
//   In OpenScad, it is possible to preview designs (F5 key) or to render them (F6 key)
//   to be able to export them as STL files ready for 3D printing.
//   Please note that some parts will only be present in the preview, but not in the
//   final render. This is normal, as they are used only as a reference and do not need
//   to be 3D printed.
//   
//   The main file that needs to be opened with OpenScad is Cyclone.scad (this document).
//   From here, it is possible to select most of the parts, using the root modifier (!).
//   Place it before a function to exclusively render that subtree. When used, for instance, as
//      !Cyclone_Y_frontFrame();
//   it will show only the frontal Y axis frame. Rendering it with F6 will output only
//   that part, which will be ready to be exported as STL.
//   
//   It is also possible to generate larger STL files that contain multiple elements,
//   and afterwards split them. This can be achieved with a software like Cura, that
//   also allows easy rotation and positioning of the models for printing.
//   To split STLs in Cura: right click over the part --> "split into parts"
// -------------------------------------------------------------



// Increase the resolution of default shapes
$fa = 5; // Minimum angle for fragments [degrees]
$fs = 0.5; // Minimum fragment size [mm]

// Load necessary libraries
use <libs/obiscad/obiscad/vector.scad>
use <libs/obiscad/obiscad/attach.scad>
use <libs/obiscad/obiscad/bcube.scad>
use <libs/standard_parts.scad>
use <libs/MCAD/materials.scad>

// Functions for animations. Quick and dirty implementation, will need some cleanup
animated_parts_number = 10;
animated_timePerPart = 1/animated_parts_number;
function animationBump(tbegin,tend,t=$t%1) = ((t >= tbegin) && (t <= tend)) ? (1+sin((t-tbegin)*360/(tend-tbegin)-90)) : 0;
function animatePart(n,dist=30,overlap=animated_timePerPart*0.25) = dist*animationBump((n-1)*animated_timePerPart-overlap,n*animated_timePerPart+overlap);


// Parameters for the bottom base
base_size_X			= 304.8 + animatePart(1,overlap=0);
base_size_Y			= 261.62 + animatePart(2);
base_thickness		= 8;
base_corner_radius	= 20;
base_corner_res		= 0;
foot_offset = 25;


// Parameters for the axes sizes
axes_Xsmooth_rodLen	= 250 + animatePart(1,overlap=0);
axes_Ysmooth_rodLen	= 210 + animatePart(2);
axes_Zsmooth_rodLen	= 110 + animatePart(3);

axes_Xthreaded_rodLen	= axes_Xsmooth_rodLen+50;
axes_Ythreaded_rodLen	= axes_Ysmooth_rodLen-10;
axes_Zthreaded_rodLen	= 90;

axes_Xsmooth_rodD	= 8.5 + animatePart(4,dist=5);
axes_Ysmooth_rodD	= 8.5 + animatePart(4,dist=5);
axes_Zsmooth_rodD	= 8.2 + animatePart(4,dist=5);

axes_Xthreaded_rodD	= 8.5 + animatePart(4,dist=5);
axes_Ythreaded_rodD	= 8.5 + animatePart(4,dist=5);
axes_Zthreaded_rodD	= 8.5 + animatePart(4,dist=5);

// Parameters for the axes reference position
// Note: The reference coordinates are centered like this:
// Y axis reference is the Y smooth rod end, BACK of RIGHT FRAME
// X axis reference is the frontal X smooth rod end, RIGHT FRAME
// Z axis reference is the Z threaded rod, at the height of the Z nut, and relative to the X reference
axes_Yreference_height	= 40 + animatePart(5);
axes_Xreference_height	= 74 + animatePart(6); // relative to Y reference
axes_Zreference_height	= -3 + animatePart(7) + animatePart(9); // relative to X reference

axes_Xreference_posY	= -81-animatePart(8)-animatePart(9); // relative to Y reference. Moves the X axis towards the front of the machine
axes_Zreference_posY	= 14; // relative to X reference. Positions Z rods between the Y rods

axes_Y_threaded_height = 30 + animatePart(5);

axes_Ysmooth_separation	= 165 + animatePart(1,overlap=0);
axes_Xsmooth_separation = 40 + animatePart(9);
axes_Zsmooth_separation = 40 + animatePart(10,overlap=0);


// Carriage positions (for rendering)
axes_Xcarriage_pos = axes_Xsmooth_rodLen/2+sin($t*360)*axes_Xsmooth_rodLen/3;
axes_Ycarriage_pos = axes_Ysmooth_rodLen/2+sin($t*360)*axes_Ysmooth_rodLen/4.1;
axes_Zcarriage_pos = axes_Zsmooth_rodLen/2+sin($t*360)*axes_Zsmooth_rodLen/8;




// Parameters for the workbed
Ycarriage_linearBearingSeparation = 50;
workbed_size_X			= axes_Ysmooth_separation+50;
workbed_size_Y			= Ycarriage_linearBearingSeparation+70;
workbed_thickness		= 8+3;
workbed_separation_from_Y_smooth_rod = 10;


// Part colors
blueColor = [0.3,0.6,0.9];
redColor = [0.8,0.3,0.3];
yellowColor = [0.9,0.9,0.1];
blackColor = [0.2,0.2,0.2];
color_movingPart = yellowColor+[0.1,0.1,0.1];
color_stillPart = yellowColor;


// Calculations
axes_Xreference_posX	= (axes_Ysmooth_separation-axes_Xsmooth_rodLen)/2; // relative to Y reference
axes_Y_smoothThreaded_verticalSeparation = axes_Yreference_height-axes_Y_threaded_height;

axes_ZthreadedReference_posY = axes_Xsmooth_separation-axes_Zreference_posY-axes_Zreference_posY; // Relative to X carriage reference

// Activate/Deactivate rendering auxiliary references (LCS axis, etc)
draw_references = false;
render_DXF_base = false;
render_DXF_workbed = false;
render_bases_outline = false; // Toggle for rendering outline DXFs
DXF_offset = 0.4; // Needed to adjust the tolerance of the laser cutter

//Screw size - M3, M4, etc (integers only), at the moment only M3 and M4 will work.
Y_frontFrame_footScrewSize = 3;
Y_backFrame_footScrewSize = 3;
Y_rightSmoothRodIdler_footScrewSize = 3;
X_Frame_footScrewSize = 3;

Y_nutHolder_screwSize = 3;
Y_singleLinearBearingHolder_screwSize = 3;
Y_PCBholder_screwSize = 3;

X_carriage_screwSize = 3;

Y_rightSmoothRodIdler_rodScrewSize = 3;
X_Frame_rodScrewSize = 3; 


// Include Cyclone parts
include <Cycl_X_carriage.scad>
include <Cycl_Z_carriage.scad>
include <Cycl_X_frames.scad>
include <Cycl_Y_carriage.scad>
include <Cycl_Y_frames.scad>


// This small module is used to select if an object is rendered as a 2D plane or as a 3D object
module render_2D_or_3D() {
	if(render_DXF_base) {
		offset(delta = DXF_offset) projection(cut = true) children();
	} else children();
}

// BEGIN ASSEMBLING THE DESIGN
render_2D_or_3D() {
	if(draw_references) %frame();

	// Main base for the machine
	beveledBase([base_size_X,base_size_Y,base_thickness], radius=base_corner_radius, res=base_corner_res, echoPart=true, renderPart=render_bases_outline);


	// A4 paper sheet for reference
	color([1,1,1, 0.2]) standard_paperSheet_A4(echoPart=true);


	// Cyclone foot stands
	translate([0,0,-base_thickness]) {
		translate([base_size_X/2-foot_offset,base_size_Y/2-foot_offset])
			rubberFoot(echoPart=true);
		translate([-base_size_X/2+foot_offset,base_size_Y/2-foot_offset])
			rubberFoot(echoPart=true);
		translate([-base_size_X/2+foot_offset,-base_size_Y/2+foot_offset])
			rubberFoot(echoPart=true);
		translate([base_size_X/2-foot_offset,-base_size_Y/2+foot_offset])
			rubberFoot(echoPart=true);
	}



	// TRANSLATE REFERENCE POSITION to the RIGHT frame, Y smooth rod end
	translate([-axes_Ysmooth_separation/2,axes_Ysmooth_rodLen/2,axes_Yreference_height]) {
		if(draw_references) %frame();

		// Draw right Y smooth rod
		rotate([0,0,180]) standard_rod(diam=axes_Ysmooth_rodD, length=axes_Ysmooth_rodLen, threaded=false, echoPart=true);
	
		Cyclone_X_rightFrame();
	
	
		// TRANSLATE REFERENCE POSITION to the LEFT frame, Y smooth rod end
		translate([axes_Ysmooth_separation,0,0]) {
			if(draw_references) %frame();
		
			// Draw right Y smooth rod
			rotate([0,0,180]) standard_rod(diam=axes_Ysmooth_rodD, length=axes_Ysmooth_rodLen, threaded=false, echoPart=true);
		
			Cyclone_X_leftFrame();
		}
	
	
		// TRANSLATE REFERENCE POSITION to the right frame, X lower smooth rod end
		translate([axes_Xreference_posX,axes_Xreference_posY,axes_Xreference_height]) {
			if(draw_references) %frame();
		
			// Draw bottom X smooth rod
			rotate([0,0,-90]) standard_rod(diam=axes_Xsmooth_rodD, length=axes_Xsmooth_rodLen, threaded=false, echoPart=true);
			// Draw X threaded rod
			translate([-(axes_Xthreaded_rodLen-axes_Xsmooth_rodLen)/2,axes_Xsmooth_separation,0])
				rotate([0,0,-90]) standard_rod(diam=axes_Xthreaded_rodD, length=axes_Xthreaded_rodLen, threaded=true, echoPart=true);
			// Draw top X smooth rod
			translate([0,axes_Xsmooth_separation,axes_Xsmooth_separation])
				rotate([0,0,-90]) standard_rod(diam=axes_Xsmooth_rodD, length=axes_Xsmooth_rodLen, threaded=false, echoPart=true);
		
		
			// TRANSLATE REFERENCE POSITION to the X carriage (centered), X lower smooth rod
			translate([axes_Xcarriage_pos,0,0]) {
				if(draw_references) %frame();
				
				Cyclone_X_carriage();
				
				// TRANSLATE REFERENCE POSITION to the Z axis origin (right smooth rod)
				translate([-axes_Zsmooth_separation/2,axes_Zreference_posY,axes_Zreference_height]) {
					if(draw_references) %frame();
				
					// Draw Z smooth rod (right)
					rotate([90,0,0]) standard_rod(diam=axes_Zsmooth_rodD, length=axes_Zsmooth_rodLen, threaded=false, echoPart=true);
					// Draw Z smooth rod (left)
					translate([axes_Zsmooth_separation,0,0])
						rotate([90,0,0]) standard_rod(diam=axes_Zsmooth_rodD, length=axes_Zsmooth_rodLen, threaded=false, echoPart=true);
					// Draw Z threaded rod
					translate([axes_Zsmooth_separation/2,axes_ZthreadedReference_posY,0])
						rotate([90,0,0]) standard_rod(diam=axes_Zthreaded_rodD, length=axes_Zthreaded_rodLen, threaded=true, echoPart=true);
					
					// TRANSLATE REFERENCE POSITION to the Z axis reference
						translate([0,0,axes_Zcarriage_pos]) {
							if(draw_references) %frame();
						
							Cyclone_Z_carriage();
						}
				}
			}
		}
	
	}
	
	
	
	translate([axes_Xsmooth_rodLen/2,0,0])
		control_board(plasticColor=color_stillPart);
	
	
	
	
	// TRANSLATE REFERENCE POSITION to the FRONT RIGHT Y rod idler, Y smooth rod end
	translate([-axes_Ysmooth_separation/2,-axes_Ysmooth_rodLen/2,axes_Yreference_height]) {
		if(draw_references) %frame();
	
		Cyclone_Y_rightSmoothRodIdler();
	}
	
	// TRANSLATE REFERENCE POSITION to the FRONT LEFT Y rod idler, Y smooth rod end
	translate([axes_Ysmooth_separation/2,-axes_Ysmooth_rodLen/2,axes_Yreference_height]) {
		if(draw_references) %frame();
	
		Cyclone_Y_leftSmoothRodIdler();
	}


	// TRANSLATE REFERENCE POSITION to the FRONT Y frame, Y threaded rod end
	translate([0,-axes_Ythreaded_rodLen/2,axes_Y_threaded_height]) {
		if(draw_references) %frame();
	
		// Draw Y threaded rod
		standard_rod(diam=axes_Ythreaded_rodD, length=axes_Ythreaded_rodLen, threaded=true, echoPart=true);
	
		Cyclone_Y_frontFrame();
	
	
		// TRANSLATE REFERENCE POSITION to the BACK Y frame, Y threaded rod end
		translate([0,axes_Ythreaded_rodLen,0]) {
			if(draw_references) %frame();
		
			Cyclone_Y_backFrame();
		}
	}


	// TRANSLATE REFERENCE POSITION to the CENTERED Y carriage nut, Y threaded rod
	translate([0,-axes_Ysmooth_rodLen/2+axes_Ycarriage_pos,axes_Y_threaded_height]) {
		if(draw_references) %frame();
		
		if(render_DXF_workbed)
			Cyclone_Y_carriage(); // Render carriage exclusively
		else Cyclone_Y_carriage();
	}
}


