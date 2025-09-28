set_global_assignment -entity "PLL1" -library "lib_PLL1" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "PLL1" -library "lib_PLL1" -name IP_TOOL_VERSION "24.1"
set_global_assignment -entity "PLL1" -library "lib_PLL1" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_PLL1" -name SPD_FILE [file join $::quartus(sip_path) "PLL1.spd"]

set_global_assignment -library "lib_PLL1" -name MISC_FILE [file join $::quartus(sip_path) "PLL1_sim/PLL1.vo"]
