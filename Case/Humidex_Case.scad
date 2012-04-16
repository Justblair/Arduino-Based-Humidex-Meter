case_length 	= 120;
case_width 		= 80;
case_height 	= 20;
case_thickness	= 2;

case_corner_diameter = 4;

dht11_lenght	= 10;
dht11_width		= 10;
dht_height		= 10;

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

	translate ([0,0,case_thickness]){
		cube([case_length - case_thickness, case_width - case_thickness, case_height - case_thickness], center = true);
	}
}

module corner(){
	cylinder (r = case_corner_diameter/2, h = case_height, center = true, $fn = 8);
}