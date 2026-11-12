`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/05/2026 06:45:37 PM
// Design Name: 
// Module Name: servo_sweep
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


module servo_sweep #(
    parameter [17:0] MIN_CYCLES = 18'd100_000,   // 1.0 ms
    parameter [17:0] MAX_CYCLES = 18'd200_000    // 2.0 ms
)(
    input  logic        clk,
    input  logic        rst,
    input  logic [17:0] current,
    output logic [17:0] target
);
    always_ff @(posedge clk) begin
        if (rst)
            target <= MAX_CYCLES;
        else if (current == target)
            target <= (target == MAX_CYCLES) ? MIN_CYCLES : MAX_CYCLES;
    end
endmodule
