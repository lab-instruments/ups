
/*//////////////////////////////////////////////////////////////////
              -    FB Aka Heartman/Hearty 2016     -
              -   http://heartygfx.blogspot.com    -
              -       OpenScad Parametric Box      -
              -         CC BY-NC 3.0 License       -
////////////////////////////////////////////////////////////////////
12/02/2016 - Fixed minor bug
28/02/2016 - Added holes ventilation option
09/03/2016 - Added PCB feet support, fixed the shell artefact on export mode.

*/////////////////////////// - Info - //////////////////////////////

// All coordinates are starting as integrated circuit pins.
// From the top view :

//   CoordD           <---       CoordC
//                                 ^
//                                 ^
//                                 ^
//   CoordA           --->       CoordB


////////////////////////////////////////////////////////////////////


// Params

// -----------------------------------------------------------------------------
//  Box Dimensions
// -----------------------------------------------------------------------------
Length        = 254; // 10.0 in
Width         = 215; // ~8.5 in
Height        = 60;
Thick         = 2;//[2:5]

// -----------------------------------------------------------------------------
//  Box Options
// -----------------------------------------------------------------------------
// Filet Diameter
Filet         = 2;    // {0.1..12}
// Filet Smoothness
Resolution    = 50;   // {1..1000}
// Tolerance (Panel/Rails Gap)
m             = 0.9;
// Decorations to Ventilation Holes
Vent          = 1;// [0:No, 1:Yes]
// Decoration-Holes width (in mm)
Vent_Width    = 1.5;

// -----------------------------------------------------------------------------
//  PCB Feet
//    - All dimensions are from the center foot axis
// -----------------------------------------------------------------------------
// Low Left Corner X Position
PCBPosX       = 70;
// Low Left Corner Y Position
PCBPosY       = 60;
// PCB Length
PCBLength     = 50.1;
// PCB Width
PCBWidth      = 94.7;
// Feet Height
FootHeight    = 10;
// Foot Diameter
FootDia       = 8;
// Hole diameter
FootHole      = 3;

// -----------------------------------------------------------------------------
//  STL element to Export
// -----------------------------------------------------------------------------
// Top Shell
TShell        = 0; // {0:No, 1:Yes}
// Bottom Shell
BShell        = 0; // {0:No, 1:Yes}
// Front Panel
FPanL         = 0; // {0:No, 1:Yes}
// Back Panel
BPanL         = 1; // {0:No, 1:Yes}

// -----------------------------------------------------------------------------
//  Hidden
// -----------------------------------------------------------------------------
// Shell color
Couleur1        = "Orange";
// Panels color
Couleur2        = "OrangeRed";
// Thick X 2 - Making Decorations Thicker for Vents to go Through Shell
Dec_Thick       = Vent ? Thick*2 : Thick;
// Depth Decoration
Dec_Size        = Vent ? Thick*2 : 0.8;

// -----------------------------------------------------------------------------
//  Generic Rounded Box Module
// -----------------------------------------------------------------------------
module RoundBox($a=Length, $b=Width, $c=Height)
{
    $fn=Resolution;
    translate([0,Filet,Filet])
    {
        minkowski()
        {
            cube ([$a-(Length/2),$b-(2*Filet),$c-(2*Filet)], center = false);
            rotate([0,90,0])
            {
                cylinder(r=Filet,h=Length/2, center = false);
            }
        }
    }
} // RoundBox

// -----------------------------------------------------------------------------
//  Shell
// -----------------------------------------------------------------------------
module Shell()
{
    Thick = Thick*2;
    difference()
    {
        // Sides Decoration
        difference()
        {
            union()
            {
                // Substract Fileted Box
                difference()
                {
                    // Subtract Median Cube Slicer
                    difference()
                    {
                        union()
                        {
                            difference()
                            {
                                RoundBox();
                                translate([Thick/2,Thick/2,Thick/2])
                                {
                                    RoundBox($a=Length-Thick, $b=Width-Thick, $c=Height-Thick);
                                }
                            }
                            // Rails
                            difference()
                            {
                                // Rails
                                translate([Thick+m,Thick/2,Thick/2])
                                {
                                    RoundBox($a=Length-((2*Thick)+(2*m)), $b=Width-Thick, $c=Height-(Thick*2));
                                } // Rails
                                translate([((Thick+m/2)*1.55),Thick/2,Thick/2+0.1])
                                {
                                    RoundBox($a=Length-((Thick*3)+2*m), $b=Width-Thick, $c=Height-Thick);
                                }
                            }// Rails
                        } // Union
                        translate([-Thick,-Thick,Height/2])
                        {
                            cube([Length+100, Width+100, Height], center=false);
                        }
                    } // End Median cube slicer
                    translate([-Thick/2,Thick,Thick])
                    {
                        RoundBox($a=Length+Thick, $b=Width-Thick*2, $c=Height-Thick);
                    }
                }
                difference()
                {
                    union()
                    {
                        translate([3*Thick +5,Thick,Height/2])
                        {
                            rotate([90,0,0])
                            {
                                    $fn=6;
                                    cylinder(d=16,Thick/2);
                            }
                        }
                        translate([Length-((3*Thick)+5),Thick,Height/2])
                        {
                            rotate([90,0,0])
                            {
                                $fn=6;
                                cylinder(d=16,Thick/2);
                            }
                        }
                    }
                    translate([4,Thick+Filet,Height/2-57])
                    {
                        rotate([45,0,0])
                        {
                            cube([Length,40,40]);
                        }
                    }
                    translate([0,-(Thick*1.46),Height/2])
                    {
                        cube([Length,Thick*2,10]);
                    }
                } //Fin fixation box legs
            }

            union()
            {// outbox sides decorations
                for(i=[0:Thick:Length/4])
                {
                    // Ventilation holes part code submitted by Ettie - Thanks ;)
                    translate([10+i,-Dec_Thick+Dec_Size,1])
                    {
                        cube([Vent_Width,Dec_Thick,Height/4]);
                    }
                    translate([(Length-10) - i,-Dec_Thick+Dec_Size,1])
                    {
                        cube([Vent_Width,Dec_Thick,Height/4]);
                    }
                    translate([(Length-10) - i,Width-Dec_Size,1])
                    {
                        cube([Vent_Width,Dec_Thick,Height/4]);
                    }
                    translate([10+i,Width-Dec_Size,1])
                    {
                        cube([Vent_Width,Dec_Thick,Height/4]);
                    }
                }
            }
        }
        union()
        { //sides holes
            $fn=50;
            translate([3*Thick+5,20,Height/2+4])
            {
                rotate([90,0,0])
                {
                    cylinder(d=2,20);
                }
            }
            translate([Length-((3*Thick)+5),20,Height/2+4])
            {
                rotate([90,0,0])
                {
                    cylinder(d=2,20);
                }
            }
            translate([3*Thick+5,Width+5,Height/2-4])
            {
                rotate([90,0,0])
                {
                    cylinder(d=2,20);
                }
            }
            translate([Length-((3*Thick)+5),Width+5,Height/2-4])
            {
                rotate([90,0,0])
                {
                    cylinder(d=2,20);
                }
            }
        } // Side Holes
    }
}

// Foot with base
module foot(FootDia, FootHole, FootHeight)
{
    Filet=2;
    color(Couleur1)
    translate([0,0,Filet-1.5])
    difference()
    {
        difference()
        {
            cylinder(d=FootDia+Filet,FootHeight-Thick, $fn=100);
            rotate_extrude($fn=100)
            {
                translate([(FootDia+Filet*2)/2,Filet,0])
                {
                    minkowski()
                    {
                        square(10);
                        circle(Filet, $fn=100);
                    }
                }
            }
        }
        cylinder(d=FootHole,FootHeight+1, $fn=100);
    }
}

module Feet()
{
    // Board
    translate([3*Thick+2,Thick+5,FootHeight+(Thick/2)-0.5])
    {

        %square ([PCBLength+10,PCBWidth+10]);
        translate([PCBLength/2,PCBWidth/2,0.5])
        {
            color("Olive")
            %text("PCB", halign="center", valign="center", font="Arial black");
        }
    }

    // Feed
    translate([3*Thick+7,Thick+10,Thick/2])
    {
        foot(FootDia,FootHole,FootHeight);
    }
    translate([(3*Thick)+PCBLength+7,Thick+10,Thick/2])
    {
    foot(FootDia,FootHole,FootHeight);
    }
    translate([(3*Thick)+PCBLength+7,(Thick)+PCBWidth+10,Thick/2])
    {
        foot(FootDia,FootHole,FootHeight);
    }
    translate([3*Thick+7,(Thick)+PCBWidth+10,Thick/2])
    {
        foot(FootDia,FootHole,FootHeight);
    }
}

// Panel
module Panel(Length, Width, Thick, Filet)
{
    scale([0.5,1,1])
    minkowski()
    {
        cube([Thick,Width-(Thick*2+Filet*2+m),Height-(Thick*2+Filet*2+m)]);
        translate([0,Filet,Filet])
        rotate([0,90,0])
        cylinder(r=Filet,h=Thick, $fn=100);
    }
}

// Cylinder
module CylinderHole(OnOff, Cx, Cy, Cdia)
{
    if(OnOff==1)
    {
        translate([Cx,Cy,-1])
        {
            cylinder(d=Cdia,10, $fn=50);
        }
    }
}

// Text Panel
module LText(OnOff, Tx, Ty, Font, Size, Content)
{
    if(OnOff==1)
    {
        translate([Tx,Ty,Thick+0])
        {
            linear_extrude(height = 0.5)
            {
                text(Content, size=Size, font=Font);
            }
        }
    }
}

// Front Panel
module FPanL()
{
    // Settings
    FPH = (Height/2)-5;
    AIR = 6.2;
    BNC = 12.6;

    difference()
    {

        // Front Panel
        Panel(Length,Width,Thick,Filet);

        // Front Panel Holes
        rotate([90,0,90])
        {
            // Power Switch -- (On/Off, Xpos, Ypos, Diameter)
            CylinderHole(1, 180, FPH, 17.75);

            // Power LED -- (On/Off, Xpos, Ypos, Diameter)
            CylinderHole(1, 160, FPH, 6.85);

            // Air -- (On/Off, Xpos, Ypos, Diameter)
            CylinderHole(1, 130, FPH, AIR);
            CylinderHole(1, 115, FPH, AIR);
            CylinderHole(1, 100, FPH, AIR);
            CylinderHole(1,  85, FPH, AIR);

            // BNC
            CylinderHole(1,  55, FPH, BNC);
            CylinderHole(1,  30, FPH, BNC);

        }

        // Front Panel Text
        translate([-.5,0,0])
        {
            rotate([90,0,90])
            {
                LText(1, 10, 35, "Arial Black", 4, "VPS");
            }
        }
    }
}

// Front Panel
module BPanL()
{
    // Settings
    BPH = (Height/2)-5;
    USB_ETH = 20.60;

    difference()
    {

        // Back Panel
        Panel(Length,Width,Thick,Filet);

        // Back Panel Holes
        rotate([90,0,90])
        {
            // Ethernet -- (On/Off, Xpos, Ypos, Diameter)
            CylinderHole(1, 180, BPH, 20.60);

            // USB-B -- (On/Off, Xpos, Ypos, Diameter)
            CylinderHole(1, 130, BPH, 34.85);

            // USB-A -- (On/Off, Xpos, Ypos, Diameter)
            CylinderHole(1,  80, BPH, 25.15);

            // Power Input -- (On/Off, Xpos, Ypos, Diameter)
            CylinderHole(1, 45, BPH, 8);

            // Fuse -- (On/Off, Xpos, Ypos, Diameter)
            CylinderHole(1, 20, BPH, 12.65);

        }
    }
}

// Main Construction
if(TShell==1)
{
    color( Couleur1,1)
    {
        translate([0,Width,Height+0.2])
        {
            rotate([0,180,180])
            {
                Shell();
            }
        }
    }
}

if(BShell==1)
{
    color(Couleur1)
    {
        Shell();
    }
}

if (BShell==1)
{
    translate([PCBPosX,PCBPosY,0])
    {
        Feet();
    }
}

// Front Panel
if(FPanL==1)
{
    translate([Length-(Thick*2+m/2),Thick+m/2,Thick+m/2])
    {
        FPanL();
    }
}

// Back Panel
if(BPanL==1)
{
    color(Couleur2)
    {
        translate([Thick+m/2,Thick+m/2,Thick+m/2])
        {
            BPanL();
        }
    }
}
