// Width of a single card
CardWidth = 66;    
gCardWidths = [66,69];

// Height of a single card
CardHeight = 45;  

// Box Height
gBoxHeight = 48; 

// Size of each Card slot
gSlots = [[25,38,33],[13,16,13,26,24.8]];

// Number of rows of cards
Rows = 2;

// Slant the front of the box 
SlantFront = true;

// Labels for each card slot  (only recommended when Rows=1)
LLabels = ["Settlement", "Set & Town", "Town"];
RLabels = ["HomeSteads", "Market", "Events", "City", "Misc"];

// Size of botton cutout, % of width
Removal = 0.5;
AccessDepth = 0.3;

// Wall Thickness
gWT = 1.6;

// Roundness
$fn = 20;

function SumList(list, start, end) = (start == end) ? list[start] : list[start] + SumList(list, start+1, end);

module RCube(x,y,z,ipR=4) {
    translate([-x/2,-y/2,0]) hull(){
      translate([ipR,ipR,ipR]) sphere(ipR);
      translate([x-ipR,ipR,ipR]) sphere(ipR);
      translate([ipR,y-ipR,ipR]) sphere(ipR);
      translate([x-ipR,y-ipR,ipR]) sphere(ipR);
      translate([ipR,ipR,z-ipR]) sphere(ipR);
      translate([x-ipR,ipR,z-ipR]) sphere(ipR);
      translate([ipR,y-ipR,z-ipR]) sphere(ipR);
      translate([x-ipR,y-ipR,z-ipR]) sphere(ipR);
      }  
} 



Angle = (((gBoxHeight-gWT)/CardHeight) < 1) ? acos((gBoxHeight-gWT)/CardHeight) : 0;
  
//Wall space for tilted wall
gWS =  gWT / cos(Angle);
BoxWidth = CardWidth + 2*gWT;

SlotsAdj = [for (i = [0:len(gSlots[0])-1]) gSlots[0][i]/cos(Angle)];
ExtraLength = CardHeight * sin(Angle);
gBoxLength = SumList(SlotsAdj,0,len(SlotsAdj)-1) + ExtraLength + (len(gSlots)-1) * gWS+ 2*gWT +2;

// final dimensions 
echo(gBoxLength,BoxWidth, Angle);

//  Main Box
module Box(ipSlots,ipLabels,Placement,ipCardWidth) {

   lSlotsAdj = [for (i = [0:len(ipSlots)-1]) ipSlots[i]/cos(Angle)];
   lRailPlace = [for (i = [0:len(ipSlots)-1]) gWT-gBoxLength/2+SumList(lSlotsAdj,0,i)+gWS*i ];
   lLabelPlace = [for (i = [0:len(ipSlots)-1])  (i == 0) ? ((-gBoxLength/2)+lRailPlace[0])/2 + ExtraLength : (lRailPlace[i-1] + lRailPlace[i])/2 + ExtraLength];
       
   lBoxWidth = ipCardWidth + 2*gWT;
echo("ipSlots: ",ipSlots,lRailPlace,lBoxWidth);

   intersection() 
   {
     RCube(gBoxLength,lBoxWidth,gBoxHeight, 1);  
     difference() 
     {  
        union() 
        { 
           difference() 
           {    
              RCube(gBoxLength,lBoxWidth,gBoxHeight, 1);
                   
              // Hallow out the box  
              translate([gWT/2,0,gBoxHeight/2+gWT]) cube([gBoxLength-gWT,lBoxWidth-2*gWT,gBoxHeight], center=true);
                   
              // Add the names to both sides
              for(x=[0:len(ipSlots)-1]) { 
                    if (Placement=="Left") {     
                    translate ([lLabelPlace[x],-lBoxWidth/2+0.4,gBoxHeight-gWT])rotate([90,0,0]) linear_extrude(0.4) text(ipLabels[x], size = 4, spacing = 0.9, direction = "ttb",  font="Helvetica:style=Bold");}
                    if (Placement=="Right") {
                    translate ([lLabelPlace[x],lBoxWidth/2-0.4,gBoxHeight-gWT])rotate([90,0,180]) linear_extrude(5) text(ipLabels[x], size = 4, spacing = 0.9, direction = "ttb",  font="Helvetica:style=Bold");}
                 }  // end For
           }  // shell of box
              
           // add the dividers  
           for(x=[0:len(ipSlots)-1]) {  
              translate([lRailPlace[x]-0.2,0,gWT-CardHeight/2])  translate([1,0,CardHeight/2]) rotate([0,Angle,0]) translate([0,0,CardHeight/2]) cube([2, ipCardWidth, CardHeight],center=true);
           }
               
           // Add new front if configured
           if (SlantFront)
           {
               translate([-gBoxLength/2,0,gWT]) rotate([0,Angle,0]) translate([0,0,CardHeight/2]) cube([2, ipCardWidth, CardHeight],center=true);        
           } 
        } // End the union after here is substraction
              
        // create gap at top to access the cards
        AccessWidth = ipCardWidth * 0.4;
        hull(){
            translate([0,-AccessWidth/2+6,gBoxHeight+10]) rotate([0,90,0])cylinder(r=6,h=gBoxLength,center=true);;
            translate([0,AccessWidth/2-6,gBoxHeight+10]) rotate([0,90,0])cylinder(r=6,h=gBoxLength,center=true);;
            translate([0,-AccessWidth/2+6,gBoxHeight*(1-AccessDepth)])rotate([0,90,0])cylinder(r=6,h=gBoxLength,center=true);;
            translate([0,AccessWidth/2-6,gBoxHeight*(1-AccessDepth)])rotate([0,90,0])cylinder(r=6,h=gBoxLength,center=true);;
        } // hull
         
            translate([0,-AccessWidth/2-6,gBoxHeight-6])difference(){
               cube([gBoxLength,12,12], center = true);
               rotate([0,90,0])cylinder(r=6,h=gBoxLength,center=true);
                translate([0,-6,0])cube([gBoxLength,12,12], center = true);
                translate([0,0,-6])cube([gBoxLength,12,12], center = true);
            }
           translate([0,+AccessWidth/2+6,gBoxHeight-6]) difference(){
               cube([gBoxLength,12,12], center = true);
               rotate([0,90,0])cylinder(r=6,h=gBoxLength,center=true);
                translate([0,6,0])cube([gBoxLength,12,12], center = true);
                translate([0,0,-6])cube([gBoxLength,12,12], center = true);
            }
//           rotate([0,90,0]) triangle(6, 6, gBoxLength+10, center = true);
            
        // Remove some from the bottem to reduce plastic
        hull() {
            translate([gBoxLength/2-(lBoxWidth*Removal/2)-15,0,0]) sphere(r=(lBoxWidth*Removal)/2);
            translate([-gBoxLength/2+(lBoxWidth*Removal/2)+15,0,0]) sphere (r=(lBoxWidth*Removal)/2);
        }
           
        // If we have the slanted front remove part of the box
        if (SlantFront)
        {
           hull() { 
             translate([-gBoxLength/2-200,0,gWT]) rotate([0,Angle,0]) translate([0,0,CardHeight/2]) cube([2, ipCardWidth+10, CardHeight+2*gWT],center=true);
             translate([-gBoxLength/2-2,0,gWT]) rotate([0,Angle,0]) translate([0,0,CardHeight/2]) cube([2, ipCardWidth+10, CardHeight+2*gWT],center=true);
              }
        } // end slant
      } // end diff
   }  // Instersection
} // box Module

for(i=[0:Rows-1]) 
   {   
       // Kludge on the shifting, only works for 2 rows.
       translate([0,i*(SumList(gCardWidths,0,i)/2+gWT),0])
       if(i==0) Box(gSlots[i],LLabels,"Left",gCardWidths[i]);
       else if (i==Rows-1) Box(gSlots[i],RLabels,"Right",gCardWidths[i]);    
   }



