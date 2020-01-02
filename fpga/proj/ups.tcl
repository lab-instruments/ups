# ------------------------------------------------------------------------------
#  UPS Xilinx Vivado Project Generator
# ------------------------------------------------------------------------------
# Set Reference Path Base
set ORIGIN "."

# Set the project name
set PROJ_NAME "ups"

# Set Script Name
set SCRIPT_NAME "ups.tcl"

# Set Board Name
set BOARD_NAME "CORA"

# Help Info
proc help {} {
    puts ""
    puts " Generate UPS Xilinx Project"
    puts " Syntax:"
    puts "   $SCRIPT_NAME"
    puts "   $SCRIPT_NAME -tclargs \[--origin_dir <path>\]"
    puts "   $SCRIPT_NAME -tclargs \[--project_name <name>\]"
    puts "   $SCRIPT_NAME -tclargs \[--board_name <name>\]"
    puts "   $SCRIPT_NAME -tclargs \[--help\]\n"
    puts "Usage:"
    puts "Name                   Description"
    puts "-------------------------------------------------------------------------"
    puts "\[--origin_dir <path>\]    Set the origin root path.\n"
    puts "\[--project_name <name>\]  Set project name.\n"
    puts "\[--board_name <name>\]    Set board.\n"
    puts "\[--help\]                 Print help information for this script.\n"
    puts "-------------------------------------------------------------------------\n"
    exit 0

}

if { $::argc > 0 } {
    for {set i 0} {$i < $::argc} {incr i} {
        set option [string trim [lindex $::argv $i]]
        switch -regexp -- $option {
            "--origin_dir"   { incr i; set ORIGIN [lindex $::argv $i] }
            "--project_name" { incr i; set PROJ_NAME [lindex $::argv $i] }
            "--board_name" { incr i; set BOARD_NAME [lindex $::argv $i] }
            "--help"         { help }
            default {
                if { [regexp {^-} $option] } {
                    puts "ERROR: Unknown option '$option' specified.\n"
                    return 1
                }
            }
        }
    }
}

# Check Board Name
if { ${BOARD_NAME} != "Z7" && ${BOARD_NAME} != "CORA" } {
    puts " Incorrect Board Name .. Exit"
    exit 1

}

# Set the Directory Path
set PROJ_PATH "[file normalize "$ORIGIN/ups"]"

# Create Project
# create_project ${PROJ_NAME} ./${PROJ_NAME} -part xc7z020clg400-1
create_project ${PROJ_NAME} ./${PROJ_NAME}

# Get the Project Directory
set PROJ_DIR [get_property directory [current_project]]

# Set Project Properties
set obj [current_project]

if { ${BOARD_NAME} == "Z7" } {
    set_property -name "board_part" -value "digilentinc.com:arty-z7-20:part0:1.0" -objects $obj
} else {
    set_property -name "board_part" -value "digilentinc.com:cora-z7-10:part0:1.0" -objects $obj
}
# set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
# set_property -name "dsa.accelerator_binary_content" -value "bitstream" -objects $obj
# set_property -name "dsa.accelerator_binary_format" -value "xclbin2" -objects $obj
# set_property -name "dsa.board_id" -value "arty-z7-20" -objects $obj
# set_property -name "dsa.description" -value "Vivado generated DSA" -objects $obj
# set_property -name "dsa.dr_bd_base_address" -value "0" -objects $obj
# set_property -name "dsa.emu_dir" -value "emu" -objects $obj
# set_property -name "dsa.flash_interface_type" -value "bpix16" -objects $obj
# set_property -name "dsa.flash_offset_address" -value "0" -objects $obj
# set_property -name "dsa.flash_size" -value "1024" -objects $obj
# set_property -name "dsa.host_architecture" -value "x86_64" -objects $obj
# set_property -name "dsa.host_interface" -value "pcie" -objects $obj
# set_property -name "dsa.num_compute_units" -value "60" -objects $obj
# set_property -name "dsa.platform_state" -value "pre_synth" -objects $obj
# set_property -name "dsa.uses_pr" -value "1" -objects $obj
# set_property -name "dsa.vendor" -value "xilinx" -objects $obj
# set_property -name "dsa.version" -value "0.0" -objects $obj
# set_property -name "enable_vhdl_2008" -value "1" -objects $obj
# set_property -name "ip_cache_permissions" -value "read write" -objects $obj
# set_property -name "ip_output_repo" -value "${PROJ_DIR}/${SCRIPT_NAME}.cache/ip" -objects $obj
# set_property -name "mem.enable_memory_map_generation" -value "1" -objects $obj
# set_property -name "sim.central_dir" -value "${PROJ_DIR}/${SCRIPT_NAME}.ip_user_files" -objects $obj
# set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $obj
# set_property -name "simulator_language" -value "Mixed" -objects $obj
# set_property -name "webtalk.activehdl_export_sim" -value "3" -objects $obj
# set_property -name "webtalk.ies_export_sim" -value "3" -objects $obj
# set_property -name "webtalk.modelsim_export_sim" -value "3" -objects $obj
# set_property -name "webtalk.questa_export_sim" -value "3" -objects $obj
# set_property -name "webtalk.riviera_export_sim" -value "3" -objects $obj
# set_property -name "webtalk.vcs_export_sim" -value "3" -objects $obj
# set_property -name "webtalk.xsim_export_sim" -value "3" -objects $obj
# set_property -name "webtalk.xsim_launch_sim" -value "134" -objects $obj
# set_property -name "xpm_libraries" -value "XPM_CDC XPM_FIFO XPM_MEMORY" -objects $obj

# Create 'sources_1' Fileset
if {[string equal [get_filesets -quiet sources_1] ""]} {
    create_fileset -srcset sources_1
}

# Set 'sources_1' Fileset
set obj [get_filesets sources_1]
set files [list                                                   \
    [file normalize "${ORIGIN}/../fpga/src/ups_ad.sv"]            \
    [file normalize "${ORIGIN}/../fpga/src/ups_axi.sv"]           \
    [file normalize "${ORIGIN}/../fpga/src/ups_ctrl.sv"]          \
    [file normalize "${ORIGIN}/../fpga/src/ups_da.sv"]            \
    [file normalize "${ORIGIN}/../fpga/src/ups_por.sv"]           \
    [file normalize "${ORIGIN}/../fpga/src/ups_zynq_wrapper.sv"]  \
    [file normalize "${ORIGIN}/../fpga/src/ups.sv"]               \
]
add_files -norecurse -fileset $obj $files

# Set File Properties
# set files [list                                          \
#     [file normalize "${ORIGIN}/../fpga/bd/ups_zynq.bd" ] \
# ]
# set imported_files [import_files -fileset sources_1 $files]

# Set 'sources_1' Fileset File Properties
set file "$ORIGIN/../fpga/src/ups_ad.sv"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "SystemVerilog" -objects $file_obj

set file "$ORIGIN/../fpga/src/ups_axi.sv"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "SystemVerilog" -objects $file_obj

set file "$ORIGIN/../fpga/src/ups_ctrl.sv"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "SystemVerilog" -objects $file_obj

set file "$ORIGIN/../fpga/src/ups_da.sv"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "SystemVerilog" -objects $file_obj

set file "$ORIGIN/../fpga/src/ups_por.sv"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "SystemVerilog" -objects $file_obj

set file "$ORIGIN/../fpga/src/ups_zynq_wrapper.sv"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "SystemVerilog" -objects $file_obj
set_property -name "used_in" -value "synthesis implementation" -objects $file_obj
set_property -name "used_in_simulation" -value "0" -objects $file_obj

set file "$ORIGIN/../fpga/src/ups.sv"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "SystemVerilog" -objects $file_obj

# Set 'sources_1' Fileset Block Diagram Properties
# set file "ups_zynq.bd"
# set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
# set_property -name "registered_with_manager" -value "1" -objects $file_obj
# set_property -name "used_in" -value "synthesis implementation" -objects $file_obj
# set_property -name "used_in_simulation" -value "0" -objects $file_obj

# Set 'sources_1' Top File
set obj [get_filesets sources_1]
set_property -name "top" -value "ups" -objects $obj

# Add ILA
set obj [get_filesets sources_1]
set files [list                                             \
    [file normalize "${ORIGIN}/../fpga/cores/adc_ila.xci" ] \
]
set imported_files [import_files -fileset sources_1 $files]

# Set 'sources_1' Fileset ILA Properties
set file "adc_ila/adc_ila.xci"
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "generate_files_for_reference" -value "0" -objects $file_obj
set_property -name "registered_with_manager" -value "1" -objects $file_obj
if { ![get_property "is_locked" $file_obj] } {
  set_property -name "synth_checkpoint_mode" -value "Singular" -objects $file_obj
}

# Source Block Diagram TCL File
if { ${BOARD_NAME} == "Z7" } {
    set bd [file normalize "${ORIGIN}/../fpga/bd/ups_zynq_z7.tcl"]
} else {
    set bd [file normalize "${ORIGIN}/../fpga/bd/ups_zynq_cora.tcl"]
}
source $bd

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

# Add/Import constrs file and set constrs file properties
if { ${BOARD_NAME} == "Z7" } {
    set file "[file normalize "$ORIGIN/../fpga/constraints/ups_z7.xdc"]"
    set file_imported [import_files -fileset constrs_1 [list $file]]
    set file "ups_z7.xdc"
    set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
    set_property -name "file_type" -value "XDC" -objects $file_obj
} else {
    set file "[file normalize "$ORIGIN/../fpga/constraints/ups_cora.xdc"]"
    set file_imported [import_files -fileset constrs_1 [list $file]]
    set file "ups_cora.xdc"
    set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
    set_property -name "file_type" -value "XDC" -objects $file_obj
}

# Set 'constrs_1' fileset properties
# set obj [get_filesets constrs_1]
# set_property -name "target_constrs_file" -value "[get_files *ups.xdc]" -objects $obj
# set_property -name "target_ucf" -value "[get_files *ups.xdc]" -objects $obj

# Create 'sim_1' fileset (if not found)
# if {[string equal [get_filesets -quiet sim_1] ""]} {
#   create_fileset -simset sim_1
# }

# Set 'sim_1' fileset properties
# set obj [get_filesets sim_1]
# set_property -name "top" -value "ups" -objects $obj
# set_property -name "top_lib" -value "xil_defaultlib" -objects $obj

# Create 'synth_1' run (if not found)
# if {[string equal [get_runs -quiet synth_1] ""]} {
#     create_run -name synth_1 -part xc7z020clg400-1 -flow {Vivado Synthesis 2018} -strategy "Vivado Synthesis Defaults" -report_strategy {No Reports} -constrset constrs_1
# } else {
#   set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
#   set_property flow "Vivado Synthesis 2018" [get_runs synth_1]
# }
# set obj [get_runs synth_1]
# set_property set_report_strategy_name 1 $obj
# set_property report_strategy {Vivado Synthesis Default Reports} $obj
# set_property set_report_strategy_name 0 $obj
# # Create 'synth_1_synth_report_utilization_0' report (if not found)
# if { [ string equal [get_report_configs -of_objects [get_runs synth_1] synth_1_synth_report_utilization_0] "" ] } {
#   create_report_config -report_name synth_1_synth_report_utilization_0 -report_type report_utilization:1.0 -steps synth_design -runs synth_1
# }
# set obj [get_report_configs -of_objects [get_runs synth_1] synth_1_synth_report_utilization_0]
# if { $obj != "" } {

# }
# set obj [get_runs synth_1]
# set_property -name "strategy" -value "Vivado Synthesis Defaults" -objects $obj

# Create 'impl_1' run (if not found)
# if {[string equal [get_runs -quiet impl_1] ""]} {
#     create_run -name impl_1 -part xc7z020clg400-1 -flow {Vivado Implementation 2018} -strategy "Vivado Implementation Defaults" -report_strategy {No Reports} -constrset constrs_1 -parent_run synth_1
# } else {
#   set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
#   set_property flow "Vivado Implementation 2018" [get_runs impl_1]
# }

launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1
