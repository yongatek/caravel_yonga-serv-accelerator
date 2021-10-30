/*
 * SPDX-FileCopyrightText: 2021 Klas Nordmark
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 */

 `default_nettype none

 `timescale 1ns/1ps

 `include "uprj_netlists.v"
 `include "caravel_netlists.v"
 `include "spiflash.v"
 `include "tbuart.v"

 module subservient_test_tb;

    reg clock;
    reg RSTB;
    reg CSB;
    reg power1, power2;
    reg power3, power4;

    wire HIGH;
    wire LOW;
    wire TRI;
    assign HIGH = 1'b1;
    assign LOW = 1'b0;
    assign TRI = 1'bz;

    wire gpio;

    wire uart_tx;
    wire [37:0] mprj_io;
 

    wire flash_csb;
    wire flash_clk;
    wire flash_io0;
    wire flash_io1;

    wire VDD3V3 = power1;
    wire VDD1V8 = power2;
    wire USER_VDD3V3 = power3;
	wire USER_VDD1V8 = power4;
    wire VSS = 1'b0;


    always #10 clock <= (clock == 1'b0);

    initial begin
        clock = 0;
    end

    initial begin
        $dumpfile("subservient_test.vcd");
        $dumpvars(0, subservient_test_tb);
    end

    // Reset Operation
    initial begin
        RSTB <= 1'b0;
        CSB  <= 1'b1;       // Force CSB high
        #2000;
        RSTB <= 1'b1;       // Release reset
        #170000;
        CSB = 1'b0;         // CSB can be released
    end

    initial begin		// Power-up sequence
        power1 <= 1'b0;
        power2 <= 1'b0;
        power3 <= 1'b0;
        power4 <= 1'b0;
        #100;
	power1 <= 1'b1;
	#100;
	power2 <= 1'b1;
	#100;
	power3 <= 1'b1;
	#100;
	power4 <= 1'b1;
    end

    // GPIO Check
    initial begin
        forever begin
            @(negedge clock);
            case (mprj_io[37:36])
                2'b10:begin
                    #100;
                    $display("\nFAIL: Error bit is checked\n");
                    $fflush;
                    $finish;
                end
                2'b01:begin
                    #100;
                    $display("\PASSED: \\(^o^)/ \n");
                    $fflush;
                    $finish;
                end
            endcase
        end
    end

    
    caravel dut (
        .vddio	  (VDD3V3),
        .vssio	  (VSS),
        .vdda	  (VDD3V3),
        .vssa	  (VSS),
        .vccd	  (VDD1V8),
        .vssd	  (VSS),
        .vdda1    (USER_VDD3V3),
        .vdda2    (USER_VDD3V3),
        .vssa1	  (VSS),
        .vssa2	  (VSS),
        .vccd1	  (USER_VDD1V8),
        .vccd2	  (USER_VDD1V8),
        .vssd1	  (VSS),
        .vssd2	  (VSS),
        .clock	  (clock),
        .gpio     (gpio),
        .mprj_io  (mprj_io),
        .flash_csb(flash_csb),
        .flash_clk(flash_clk),
        .flash_io0(flash_io0),
        .flash_io1(flash_io1),
        .resetb	  (RSTB)
    );

    spiflash #(
        .FILENAME("subservient_test.hex")
    ) spiflash (
        .csb(flash_csb),
        .clk(flash_clk),
        .io0(flash_io0),
        .io1(flash_io1),
        .io2(),         // not used
        .io3()          // not used
    );

 endmodule
