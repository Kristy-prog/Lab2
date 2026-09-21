include <BOSL2/std.scad>
include <BOSL2/screws.scad>

$fn = $preview ? 8 : 128;

// M5StickC (official dimensions)
function m5stick_dim() = [24, 48, 13.5];
function m5stick_screw_hole() = 2;
function m5stick_screw_hole_offset() = [16, 9.4];
function m5stick_zrounding() = 3;

// ODrive
od_hole_x = 38.5;
od_hole_y = 23.6;

// Screws
m2_d      = 2.2;
m3_pilot  = 4.0;
m3_depth  = 6.2;

// Dimensions
wall       = 2;
plate_h    = 4;
col_h_bot  = 18;
col_h_top  = 12;
col_d      = 12;
edge       = 7;
col_d_top  = 8;  

box_h = m5stick_dim()[2]/3 + wall;   // 6.5

plate_l = max(m5stick_dim()[0] + 2*edge, od_hole_x + 2*edge);
plate_w = max(m5stick_dim()[1] + 2*edge, od_hole_y + 2*edge);

m5_hole_y_spacing = 2*(m5stick_dim()[1]/2 - m5stick_screw_hole_offset()[1]);   // 29.2

// USB-C / Grove (standard values)
usb_w         = 9.0;      // USB-C width
usb_h         = 3.5;      // USB-C height
usb_y_center  = 0;        // centered

grove_w       = 10.0;     // Grove width
grove_h       = 5.0;      // Grove height
grove_y_dist  = 9.4;      // Grove distance from top edge 9.4 mm

// Top: M5StickC box (with cutouts)
module m5_box() {
    m5_l = m5stick_dim()[0];
    m5_w = m5stick_dim()[1];
    m5_h = m5stick_dim()[2];
    pocket_h = m5_h / 3;

    diff() cuboid([m5_l + 2*wall, m5_w, box_h], anchor=BOT, rounding=1) {

        // Pocket (to hold M5StickC)
        tag("remove") attach(TOP, TOP, inside=true)
            cuboid([m5_l, m5_w, pocket_h], anchor=BOTTOM,
                   rounding=m5stick_zrounding(), edges="Z");

        // M2 holes (front 2)
        tag("remove") fwd(m5_w/2 - m5stick_screw_hole_offset()[1])
            xcopies(m5stick_screw_hole_offset()[0], n=2)
                screw_hole(str("M", m5stick_screw_hole()), l=box_h);

        // M2 holes (back 2)
        tag("remove") back(m5_w/2 - m5stick_screw_hole_offset()[1])
            xcopies(m5stick_screw_hole_offset()[0], n=2)
                screw_hole(str("M", m5stick_screw_hole()), l=box_h);

        // USB-C cutout (bottom, centered)
        tag("remove") translate([0, 0, -box_h/2 - 0.1])
            cuboid([usb_w, 10, usb_h + 0.2], anchor=CENTER);

        // Grove cutout (left side, 9.4 mm from top edge)
        tag("remove") translate([-m5_l/2 - wall - 0.1,
                                  m5_w/2 - grove_y_dist,
                                  box_h/2 - 1])
            cuboid([wall + 0.2, grove_w, grove_h], anchor=CENTER);
    }
}

// Middle plate
module mid_plate() {
    cuboid([plate_l, plate_w, plate_h], anchor=BOT, rounding=1);
}

// Bottom: 4 columns (for ODrive)
module bottom_columns() {
    grid_copies(spacing=[od_hole_x, od_hole_y], n=[2,2])
        diff() cyl(d=col_d, h=col_h_bot, anchor=BOT) {   // ← col_d = 12
            tag("remove") attach(BOT, BOT, inside=true)
                cyl(d=m3_pilot, h=m3_depth, chamfer=-1.0, anchor=BOT);
        }
}

// Top: 4 columns (for M5StickC)
module top_columns() {
    grid_copies(spacing=[m5stick_screw_hole_offset()[0], m5_hole_y_spacing], n=[2,2])
        cyl(d=col_d_top, h=col_h_top, anchor=BOT);   // ← col_d_top = 8
}

// Assembly
module adapter() {
    difference() {
        union() {
            // Box (top)
            translate([0, 0, col_h_bot + plate_h + col_h_top])
                m5_box();

            // Top 4 columns
            translate([0, 0, col_h_bot + plate_h])
                top_columns();

            // Middle plate
            translate([0, 0, col_h_bot])
                mid_plate();

            // Bottom 4 columns
            bottom_columns();
        }

        // M2 holes: through box + top columns + middle plate
        translate([0, 0, col_h_bot + plate_h + col_h_top + box_h])
            grid_copies(spacing=[m5stick_screw_hole_offset()[0], m5_hole_y_spacing], n=[2,2])
                cyl(d=m2_d, h=col_h_top + plate_h + box_h + 1, anchor=TOP);
    }
}

adapter();