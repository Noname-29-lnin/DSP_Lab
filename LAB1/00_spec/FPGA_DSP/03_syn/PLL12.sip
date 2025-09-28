set_global_assignment -entity "PLL12" -library "lib_PLL12" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "PLL12" -library "lib_PLL12" -name IP_TOOL_VERSION "24.1"
set_global_assignment -entity "PLL12" -library "lib_PLL12" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_PLL12" -name SPD_FILE [file join $::quartus(sip_path) "PLL12.spd"]

set_global_assignment -library "lib_PLL12" -name MISC_FILE [file join $::quartus(sip_path) "PLL12_sim/PLL12.vo"]
