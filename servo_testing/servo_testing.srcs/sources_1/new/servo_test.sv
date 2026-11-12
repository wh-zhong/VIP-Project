`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2026 05:23:19 PM
// Design Name: 
// Module Name: servo_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module servo_test #(
    parameter CLK_HZ = 100_000_000
)(
    input  logic        clk,
    input  logic        rst,
    input  logic [17:0] pulse_cycles,   // pulse width in clock cycles
    output logic        servo_out,
    output logic        frame_tick
);
    localparam PERIOD = CLK_HZ / 50;    // 20 ms = 2,000,000 cycles at 100 MHz
 
    logic [20:0] count;                 // 21 bits holds up to 2,097,151
 
    always_ff @(posedge clk) begin
        if (rst || count == PERIOD - 1)
            count <= '0;
        else
            count <= count + 1'b1;
    end
 
    assign frame_tick = (count == PERIOD - 1);
 
    always_ff @(posedge clk)
        servo_out <= (count < pulse_cycles);
endmodule
