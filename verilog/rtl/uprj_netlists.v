// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

// Include caravel global defines for the number of the user project IO pads 
`include "defines.v"
`define USE_POWER_PINS

`ifdef GL
    // Assume default net type to be wire because GL netlists don't have the wire definitions
    `default_nettype wire
    `include "gl/user_project_wrapper.v"
    `include "gl/subservient_wrapped.v"
    `include "gl/sky130_ef_sc_hd__fakediode_2.v"
`else
    `include "user_project_wrapper.v"
    `include "vlog_tb_utils.v"    
    `include "uart_decoder.v"
    `include "Matrix_FSM.v"
    `include "Matrix_Core.v"
    `include "Matrix_TOP.v"
    `include "servant_timer.v"
    `include "serv_alu.v"
    `include "serv_bufreg.v"
    `include "serv_csr.v"
    `include "serv_ctrl.v"
    `include "serv_decode.v"
    `include "serv_immdec.v"
    `include "serv_mem_if.v"
    `include "serv_rf_if.v"
    `include "serv_rf_ram_if.v"
    `include "serv_rf_ram.v"
    `include "serv_rf_top.v"
    `include "serv_state.v"
    `include "serv_top.v"
    `include "serving_arbiter.v"
    `include "serving_mux.v"
    `include "serving_ram.v"
    `include "serving.v"
    `include "subservient_debug_switch.v"
    `include "subservient_gpio.v"
    `include "subservient_ram.v"
    `include "subservient_rf_ram_if.v"
    `include "subservient_core.v"
    `include "subservient.v"
    `include "ff_ram.v"
    `include "subservient_wrapped.v"
`endif