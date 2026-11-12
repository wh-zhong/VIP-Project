`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/05/2026 06:36:58 PM
// Design Name: 
// Module Name: ramp
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

module ramp #(
    parameter [17:0] STEP  = 18'd556,
    parameter [17:0] START = 18'd150_000    // 1.5 ms, center
)(
    input  logic        clk,
    input  logic        rst,
    input  logic        tick,               // frame_tick from servo_pwm
    input logic        active,
    input  logic [17:0] target,
    output logic [17:0] current
);
    always_ff @(posedge clk) begin
        if (rst)
            current <= START;
        else if (tick && active) begin
            if      (target > current + STEP) current <= current + STEP;
            else if (target + STEP < current) current <= current - STEP;
            else                              current <= target;  // land exactly
        end
    end
endmodule
