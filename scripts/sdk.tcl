
# Help Info
proc help {} {
    puts ""
    puts " Generate UPS SDK Xilinx Project"
    puts " Syntax:"
    puts "   $SCRIPT_NAME"
    puts "   $SCRIPT_NAME -tclargs \[--build_dir <path>\]"
    puts "   $SCRIPT_NAME -tclargs \[--help\]\n"
    puts "Usage:"
    puts "Name                   Description"
    puts "-------------------------------------------------------------------------"
    puts "\[--build_dir <path>\]     Set the build root path.\n"
    puts "\[--help\]                 Print help information for this script.\n"
    puts "-------------------------------------------------------------------------\n"
    exit 0

}

if { $::argc > 0 } {
    for {set i 0} {$i < $::argc} {incr i} {
        set option [string trim [lindex $::argv $i]]
        puts $option
        switch -regexp -- $option {
            "--build_dir" { incr i; set BUILD_DIR [lindex $::argv $i] }
            "--help" { help }
            default {
                if { [regexp {^-} $option] } {
                    exit 1
                }
            }
        }
    }
}

set hwspec ${BUILD_DIR}/hw.hdf

# Create workspace and import the project into
setws ${BUILD_DIR}

createhw -name hw -hwspec $hwspec

# Create arm fsbl
createapp -name fsbl -app {Zynq FSBL} -proc ps7_cortexa9_0 -hwproject hw -os standalone
configapp -app  fsbl define-compiler-symbols FSBL_DEBUG_INFO

# Clean and build all projects
projects -clean
projects -build
