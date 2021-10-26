# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0

# Base Configurations. Don't Touch
# section begin
set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) subservient_wrapped
#section end

# User Configurations

## Source Verilog Files
set ::env(VERILOG_FILES) "\
	$script_dir/../../verilog/rtl/servant_timer.v \
	$script_dir/../../verilog/rtl/Matrix_Core.v \
	$script_dir/../../verilog/rtl/Matrix_FSM.v \
	$script_dir/../../verilog/rtl/Matrix_TOP.v \
	$script_dir/../../verilog/rtl/serv_alu.v \
	$script_dir/../../verilog/rtl/serv_bufreg.v \
	$script_dir/../../verilog/rtl/serv_csr.v \
	$script_dir/../../verilog/rtl/serv_ctrl.v \
	$script_dir/../../verilog/rtl/serv_decode.v \
	$script_dir/../../verilog/rtl/serv_immdec.v \
	$script_dir/../../verilog/rtl/serv_mem_if.v \
	$script_dir/../../verilog/rtl/serv_rf_if.v \
	$script_dir/../../verilog/rtl/serv_rf_ram_if.v \
	$script_dir/../../verilog/rtl/serv_rf_ram.v \
	$script_dir/../../verilog/rtl/serv_rf_top.v \
	$script_dir/../../verilog/rtl/serv_state.v \
	$script_dir/../../verilog/rtl/serv_top.v \
	$script_dir/../../verilog/rtl/serving_arbiter.v \
	$script_dir/../../verilog/rtl/serving_mux.v \
	$script_dir/../../verilog/rtl/serving_ram.v \
	$script_dir/../../verilog/rtl/serving.v \
	$script_dir/../../verilog/rtl/subservient_debug_switch.v \
	$script_dir/../../verilog/rtl/subservient_gpio.v \
	$script_dir/../../verilog/rtl/subservient_ram.v \
	$script_dir/../../verilog/rtl/subservient_rf_ram_if.v \
	$script_dir/../../verilog/rtl/subservient_core.v \
	$script_dir/../../verilog/rtl/ff_ram.v \
	$script_dir/../../verilog/rtl/subservient.v \
	$script_dir/../../verilog/rtl/subservient_wrapped.v"

## Clock configurations
set ::env(CLOCK_PORT) "wb_clk_i"
set ::env(CLOCK_PERIOD) "50"
set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 2000 2000"

set ::env(DIODE_INSERTION_STRATEGY) 3
set ::env(DESIGN_IS_CORE) 0
set ::env(GLB_RT_MAXLAYER) 5
set ::env(RUN_CVC) 0

set ::env(VDD_NETS) [list {vccd1}]
set ::env(GND_NETS) [list {vssd1}]


