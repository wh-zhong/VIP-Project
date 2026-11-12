`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2026 11:04:31 AM
// Design Name: 
// Module Name: tb_servo_sweep_top
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
 
// Self-checking testbench for servo_sweep_top.
//
// To keep simulation short, the design is run with a scaled-down clock:
//   1 MHz clock  -> 1 clock cycle = 1 us
//   20 ms frame  -> 20,000 cycles
//   1.0 ms pulse -> 1,000 cycles   (0 degrees)
//   2.0 ms pulse -> 2,000 cycles   (180 degrees)
//   STEP = 50 cycles per frame (about 9 degrees/frame, faster than the real
//   design so the sweep finishes quickly)
//
// What it checks:
//   1. Frame period is exactly FRAME_CYCLES clock cycles
//   2. Every pulse width is within [MIN, MAX]
//   3. Pulse width never changes by more than STEP between frames
//   4. The sweep reaches both the MIN and MAX ends
//   5. The sweep reverses direction at least 3 times
 
module tb_servo_sweep_top;
 
    // ---------------- Scaled parameters ----------------
    localparam int CLK_HZ        = 1_000_000;
    localparam int CLK_PERIOD_NS = 1_000_000_000 / CLK_HZ;   // 1000 ns
    localparam int FRAME_CYCLES  = CLK_HZ / 50;              // 20,000
    localparam int MIN_CYC       = 1000;
    localparam int MAX_CYC       = 2000;
    localparam int START_CYC     = 1500;
    localparam int STEP_CYC      = 50;
    localparam int NUM_PULSES    = 90;                       // pulses to observe
 
    // ---------------- DUT connections ----------------
    logic clk = 1'b0;
    logic rst = 1'b1;
    logic servo_out;
 
    servo_sweep_top #(
        .CLK_HZ       (CLK_HZ),
        .MIN_CYCLES   (MIN_CYC),
        .MAX_CYCLES   (MAX_CYC),
        .START_CYCLES (START_CYC),
        .STEP         (STEP_CYC)
    ) dut (
        .clk       (clk),
        .rst       (rst),
        .servo_out (servo_out)
    );
 
    // ---------------- Clock ----------------
    always #(CLK_PERIOD_NS / 2) clk = ~clk;
 
    // ---------------- Monitor state ----------------
    time t_rise     = 0;
    int  rise_count = 0;
    int  fall_count = 0;
    int  width      = 0;
    int  period     = 0;
    int  prev_width = 0;
    int  dir        = 0;
    int  last_dir   = 0;
    int  reversals  = 0;
    int  errors     = 0;
    bit  hit_max    = 1'b0;
    bit  hit_min    = 1'b0;
 
    // Frame period: time between rising edges of servo_out.
    // servo_out is already high during reset, so the first two rising edges
    // are skipped and the period check starts at the third.
    always @(posedge servo_out) begin
        rise_count++;
        if (rise_count >= 3) begin
            period = ($time - t_rise) / CLK_PERIOD_NS;
            if (period != FRAME_CYCLES) begin
                errors++;
                $display("ERROR: frame period = %0d cycles, expected %0d (t=%0t)",
                         period, FRAME_CYCLES, $time);
            end
        end
        t_rise = $time;
    end
 
    // Pulse width: time servo_out stays high. The first pulse includes the
    // reset time, so it is skipped.
    always @(negedge servo_out) begin
        fall_count++;
        width = ($time - t_rise) / CLK_PERIOD_NS;
 
        if (fall_count >= 2) begin
            $display("pulse %3d: %4d cycles (%0d us), angle ~ %3d deg",
                     fall_count, width, width * 1_000_000 / CLK_HZ,
                     (width - MIN_CYC) * 180 / (MAX_CYC - MIN_CYC));
 
            if (width < MIN_CYC || width > MAX_CYC) begin
                errors++;
                $display("ERROR: pulse width %0d outside [%0d, %0d]",
                         width, MIN_CYC, MAX_CYC);
            end
 
            if (fall_count >= 3) begin
                if ((width > prev_width ? width - prev_width : prev_width - width) > STEP_CYC) begin
                    errors++;
                    $display("ERROR: pulse width jumped from %0d to %0d (limit %0d)",
                             prev_width, width, STEP_CYC);
                end
 
                dir = (width > prev_width) ? 1 : (width < prev_width) ? -1 : 0;
                if (dir != 0) begin
                    if (last_dir != 0 && dir != last_dir) reversals++;
                    last_dir = dir;
                end
            end
 
            if (width == MAX_CYC) hit_max = 1'b1;
            if (width == MIN_CYC) hit_min = 1'b1;
            prev_width = width;
        end
    end
 
    // ---------------- Stimulus and final report ----------------
    initial begin
        rst = 1'b1;
        repeat (5) @(posedge clk);
        @(negedge clk);
        rst = 1'b0;
 
        wait (fall_count >= NUM_PULSES);
        @(posedge clk);
 
        $display("------------------------------------------------");
        $display("Pulses observed : %0d", fall_count);
        $display("Reached MAX end : %s", hit_max ? "yes" : "NO");
        $display("Reached MIN end : %s", hit_min ? "yes" : "NO");
        $display("Direction flips : %0d (need >= 3)", reversals);
        $display("Errors          : %0d", errors);
 
        if (errors == 0 && hit_max && hit_min && reversals >= 3)
            $display("RESULT: PASS");
        else
            $display("RESULT: FAIL");
 
        $finish;
    end
 
//    // Watchdog in case something stalls
//    initial begin
//        #(64'(NUM_PULSES + 10) * FRAME_CYCLES * CLK_PERIOD_NS);
//        $display("ERROR: simulation timed out");
//        $finish;
//    end
 
endmodule
