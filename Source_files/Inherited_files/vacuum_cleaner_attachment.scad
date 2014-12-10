

dremel_accessory_diam = 20;
dremel_accesory_height = 15;

aspirator_thickness_thick = 2;
aspirator_thickness_slim = 1.5;
aspirator_thickness_screw = 4;

aspirator_tube_diam = 16+0.5;
aspirator_tube_holder_height = 15;

aspirator_hole_height = 20;
aspirator_hole_diam = 32.5-0.5;

dremel_accessory_tube_offset = 0;//dremel_accessory_diam-aspirator_tube_diam;
aspirator_tube_separation = aspirator_tube_diam+aspirator_thickness_screw*2+1.5;
dremel_accessory_hole_offset = 0;//dremel_accessory_diam-aspirator_hole_diam;

vacuum_cleaner_diam = 32.5;
vacuum_cleaner_tube_len = 40;

// Useful MCAD functions reference

//use <MCAD/motors.scad>
//stepper_motor_mount(nema_standard=17, slide_distance=10, $fn=40, mochup=true);

//use <MCAD/boxes.scad>
//roundedBox([10,20,30], radius=2, sidesonly=false, $fn=60);

//include <MCAD/stepper.scad>
//motor(Nema17, size=NemaMedium, dualAxis=false);


//use <MCAD/teardrop.scad>
//teardrop(radius=10, length=20, angle=90);

//use <MCAD/nuts_and_bolts.scad>
//nutHole(size=3, tolerance=0.5, proj=-1);
//boltHole(size=3, length=10, tolerance=0.5, proj=-1, $fn=40);

use <MCAD/teardrop.scad>
use <MCAD/nuts_and_bolts.scad>

module aspirator_accessory_2Dshape() {
	hull() {
		translate([aspirator_tube_separation/2,-dremel_accessory_tube_offset/2])
			circle(r=aspirator_thickness_thick+aspirator_tube_diam/2, h=dremel_accesory_height, $fn=60);
		translate([-aspirator_tube_separation/2,-dremel_accessory_tube_offset/2])
			circle(r=aspirator_thickness_thick+aspirator_tube_diam/2, h=dremel_accesory_height, $fn=60);
	}
}

module aspirator_accessory_filledshape() {
	linear_extrude(height=dremel_accesory_height,center=true)
		aspirator_accessory_2Dshape();
	hull() {
		translate([0,0,-dremel_accesory_height/2])
			linear_extrude(height=0.001,center=true)
				aspirator_accessory_2Dshape();
		translate([0,dremel_accessory_hole_offset/2,-dremel_accesory_height/2-aspirator_hole_height])
			linear_extrude(height=0.001,center=true)
				circle(r=aspirator_thickness_slim+aspirator_hole_diam/2, $fn=60);
	}
	hull() {
		translate([0,0,-dremel_accesory_height/2-aspirator_hole_height])
			linear_extrude(height=0.001,center=true)
				circle(r=aspirator_thickness_slim+aspirator_hole_diam/2, $fn=60);
		translate([0,0,-dremel_accesory_height/2-aspirator_hole_height-vacuum_cleaner_tube_len])
			linear_extrude(height=0.001,center=true)
				circle(r=aspirator_thickness_slim+vacuum_cleaner_diam/2, $fn=60);
	}
}

module aspirator_accessory_2Dholes() {
	translate([aspirator_tube_separation/2,-dremel_accessory_tube_offset/2])
		circle(r=aspirator_tube_diam/2, $fn=60);
	translate([-aspirator_tube_separation/2,-dremel_accessory_tube_offset/2])
		circle(r=aspirator_tube_diam/2, $fn=60);
}

module screwHole() {
	translate([0,-5,0])
		rotate([90,0,0])
		hull() {
		translate([0,0,20])
			nutHole(size=3, tolerance=0.5, proj=-1);
		nutHole(size=3, tolerance=0.5, proj=-1);
		}
	translate([0,aspirator_tube_diam/2,0])
		rotate([90,0,0])
			boltHole(size=3, length=30, tolerance=0.4, proj=-1, $fn=40);
}

module aspirator_accessory_holes() {
	linear_extrude(height=dremel_accesory_height+0.01,center=true)
		aspirator_accessory_2Dholes();
	hull() {
		translate([0,0,-dremel_accesory_height/2+0.01])
			linear_extrude(height=0.001,center=true)
				aspirator_accessory_2Dholes();
		translate([0,dremel_accessory_hole_offset/2,-dremel_accesory_height/2-aspirator_hole_height+1-0.01])
			linear_extrude(height=0.001,center=true)
				circle(r=aspirator_hole_diam/2, $fn=60);
	}
	hull() {
		translate([0,0,-dremel_accesory_height/2-aspirator_hole_height+0.01])
			linear_extrude(height=0.001,center=true)
				circle(r=aspirator_hole_diam/2, $fn=60);
		translate([0,0,-dremel_accesory_height/2-aspirator_hole_height-vacuum_cleaner_tube_len-0.01])
			linear_extrude(height=0.001,center=true)
				circle(r=vacuum_cleaner_diam/2, $fn=60);
	}
	translate([0,dremel_accessory_hole_offset/2,-dremel_accesory_height/2-aspirator_hole_height])
			linear_extrude(height=2+0.1,center=true)
				circle(r=aspirator_hole_diam/2, $fn=60);
	// Hole for the tightener
	cube([aspirator_tube_separation,2.5,dremel_accesory_height+0.01],center=true);
	// Holes for the nut/screws
	#screwHole();
}

difference() {
	aspirator_accessory_filledshape();
	aspirator_accessory_holes();
}
