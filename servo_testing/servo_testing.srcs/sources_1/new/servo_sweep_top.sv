`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/05/2026 06:46:21 PM
// Design Name: 
// Module Name: servo_sweep_top
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

module servo_sweep_top #(
    parameter                CLK_HZ        = 100_000_000,
    parameter         [17:0] MIN_CYCLES    = 18'd100_000,   // 1.0 ms
    parameter         [17:0] MAX_CYCLES    = 18'd200_000,   // 2.0 ms
    parameter         [17:0] START_CYCLES  = 18'd150_000,   // 1.5 ms, center
    parameter         [17:0] STEP          = 18'd1500        // about 1 degree per frame
)(
    input  logic clk,         // 100 MHz system clock
    input  logic rst,         // pushbutton, active high
    input logic active,
    output logic servo_out,    // to the servo signal pin
    output logic led1,
    output logic led2
);
    logic [17:0] target_cycles;
    logic [17:0] pulse_cycles;
    logic        frame_tick;
 
    servo_sweep #(
        .MIN_CYCLES(MIN_CYCLES),
        .MAX_CYCLES(MAX_CYCLES)
    ) u_sweep (
        .clk, .rst,
        .current(pulse_cycles),
        .target(target_cycles)
    );
 
    ramp #(
        .STEP(STEP),
        .START(START_CYCLES)
    ) u_ramp (
        .clk, .rst,
        .tick(frame_tick),
        .active(active),
        .target(target_cycles),
        .current(pulse_cycles)
    );
 
    servo_test  #(
        .CLK_HZ(CLK_HZ)
    ) u_pwm (
        .clk, .rst,
        .pulse_cycles,
        .servo_out,
        .frame_tick
    );
    
    assign led1 = (pulse_cycles < 18'd150000);
    assign led2 = (pulse_cycles > 18'd150000);
    assign led3 = active ? 1'b1 : 1'b0;
endmodule
