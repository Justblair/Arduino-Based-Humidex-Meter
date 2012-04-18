
// Outer Case Dimensions
// **********************************************

case_length 			= 120;
case_height 			= 20;
case_thickness			= 2;
case_corner_diameter 	= 10;

case_cutout_length		= 84;
case_cutout_width		= 60;

// Nut and bolt dimensions
// **********************************************

bolt_diameter			= 3;

// Sensor Dimensions
// **********************************************

dht11_length			= 10;
dht11_width				= 10;
dht11_height			= 10;
dht11_depth				= 6;

// 9V battery Size
// **********************************************

batt_height 			= 60;
batt_length				= 30;
batt_Width				= 17.5;

// LCD Dimensions
// **********************************************

LCD_board_height		= 1.6;
LCD_board_length		= 80;
LCD_board_width			= 36;
LCD_board_hole_diameter = 2.5;
LCD_board_hole_2edge	= 2.5;

LCD_display_length		= 71.2;
LCD_display_width		= 25.2;
LCD_display_height		= 8.6;
LCD_display_x_pos		= 4.95;
LCD_display_y_pos		= 5.7;


case_width 				= max(batt_Width, case_cutout_width)+case_thickness*2;

// Assemble the Enclosure Here
// **********************************************

case_lid();

difference(){
	case();
	translate([case_thickness+2, case_thickness+2, case_height-4]){
		LCD_board();
		LCD_display();
		LCD_board_holes();
	}
	translate([case_thickness, case_thickness, -1]){
		case_main_cutout();
	}
	translate ([
		case_length - batt_length - case_thickness,
		case_thickness,
		-1]){
			cube ([ batt_length, batt_height, batt_Width+1]);
	}
}

// Modules Go Here
// **********************************************
module LCD_display(){
	translate([
		LCD_display_x_pos, 
		LCD_board_width - LCD_display_y_pos - LCD_display_width, 
		LCD_board_height])
		cube ([LCD_display_length, LCD_display_width, LCD_display_height]);
}
module LCD_board_holes(){
	translate ([LCD_board_hole_2edge, LCD_board_hole_2edge, 4]) 
		cylinder (r=LCD_board_hole_diameter/2, h=10, center = true);
	translate ([LCD_board_length-LCD_board_hole_2edge, LCD_board_hole_2edge, 4]) 
		cylinder (r=LCD_board_hole_diameter/2, h=10, center = true);
	translate ([LCD_board_hole_2edge, LCD_board_width-LCD_board_hole_2edge, 4]) 
		cylinder (r=LCD_board_hole_diameter/2, h=10, center = true);
	translate ([LCD_board_length - LCD_board_hole_2edge, LCD_board_width-LCD_board_hole_2edge, 4]) 
		cylinder (r=LCD_board_hole_diameter/2, h=10, center = true);
}
module LCD_board(){
	cube ([LCD_board_length, LCD_board_width, LCD_board_height]);
}
module case_lid(){
	translate([0, case_width +case_corner_diameter+5, 0]){
		difference(){
			case();
			translate([
				-case_corner_diameter-1,
				-case_corner_diameter-1,
				-case_thickness])
					cube([
						case_length+case_corner_diameter*2, 
						case_width+case_corner_diameter*2, 
						case_height]);
		}
	}
}
module case(){
	translate([case_length/2, case_width/2, case_height/2]){
		difference (){
			union (){
				cube([case_length, case_width, case_height], center = true);
				translate ([case_length/2, case_width/2, 0]){
					corner();
					}
				translate ([-case_length/2, case_width/2, 0]){
					corner();
					}
				translate ([case_length/2, -case_width/2, 0]){
					corner();
					}
				translate ([-case_length/2, -case_width/2, 0]){
					corner();
					}
				}
				translate ([case_length/2, case_width/2, 0]){
					corner_holes();
					}
				translate ([-case_length/2, case_width/2, 0]){
					corner_holes();
					}
				translate ([case_length/2, -case_width/2, 0]){
					corner_holes();
					}
				translate ([-case_length/2, -case_width/2, 0]){
					corner_holes();
		}
	}
}
}
module case_main_cutout(){
	cube ([case_cutout_length, case_cutout_width, case_height-case_thickness+1]);
	translate([case_cutout_length,case_cutout_width/8,0] ){
		rotate([90,0,90])
			#cylinder (r = 4, h = 10, center = true, $fn = 20);
	}
	translate([case_cutout_length,case_cutout_width/8*7,0] ){
		rotate([90,0,90])
			#cylinder (r = 4, h = 10, center = true, $fn = 20);
	}
}
module corner(){
	difference(){
		cylinder (r = case_corner_diameter/2, h = case_height, center = true, $fn = 8);
	}
}
module corner_holes(){
	translate([0,0,-1])
		cylinder (r = bolt_diameter/2, h = case_height+5, center = true, $fn = 8);
}