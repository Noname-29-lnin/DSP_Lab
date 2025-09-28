set_global_assignment -entity "PLL_12M" -library "lib_PLL_12M" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "PLL_12M" -library "lib_PLL_12M" -name IP_TOOL_VERSION "24.1"
set_global_assignment -entity "PLL_12M" -library "lib_PLL_12M" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_PLL_12M" -name SPD_FILE [file join $::quartus(sip_path) "PLL_12M.spd"]

set_global_assignment -library "lib_PLL_12M" -name MISC_FILE [file join $::quartus(sip_path) "PLL_12M_sim/PLL_12M.vo"]
