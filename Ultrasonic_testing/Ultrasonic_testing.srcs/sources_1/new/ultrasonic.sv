`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2026 12:22:22 PM
// Design Name: 
// Module Name: ultrasonic
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


module ultrasonic #(
    parameter CLK_HZ = 100_000_000
)(
    input  logic        clk,
    input  logic        rst,
    input  logic        echo,      // from sensor (level-shifted!)
    output logic        trig,      // to sensor
    output logic        valid,      // 1-cycle pulse when dist_cm updates
    output logic        led
);
    localparam int TRIG_CYC   = CLK_HZ / 100_000;          // 10 us
    localparam int CYC_PER_CM = (CLK_HZ / 1_000_000) * 58; // 58 us
    localparam int TIMEOUT    = (CLK_HZ / 1000) * 30;      // 30 ms
    localparam int PERIOD     = (CLK_HZ / 1000) * 60;      // 60 ms cycle

    logic [15:0] dist_cm = 18'd0;

    typedef enum logic [1:0] {S_TRIG, S_WAIT, S_MEAS, S_COOL} state_t;
    state_t state;

    logic [1:0]  echo_s;        // synchronizer
    logic [23:0] cnt;           // phase timer
    logic [12:0] sub;           // counts clocks within one cm
    logic [15:0] cm;

    always_ff @(posedge clk) begin
        echo_s <= {echo_s[0], echo};
        valid  <= 1'b0;

        if (rst) begin
            state <= S_TRIG; cnt <= '0; sub <= '0; cm <= '0;
            trig <= 1'b0; dist_cm <= '0; echo_s <= '0;
        end else begin
            case (state)
                S_TRIG: begin
                    trig <= 1'b1;
                    cnt  <= cnt + 1;
                    if (cnt == TRIG_CYC - 1) begin
                        trig <= 1'b0; cnt <= '0; state <= S_WAIT;
                    end
                end

                S_WAIT: begin   // wait for echo to go high
                    cnt <= cnt + 1;
                    if (echo_s[1]) begin
                        cnt <= '0; sub <= '0; cm <= '0; state <= S_MEAS;
                    end else if (cnt == TIMEOUT) begin
                        cnt <= '0; state <= S_COOL;
                    end
                end

                S_MEAS: begin   // echo high: measure its width
                    cnt <= cnt + 1;
                    if (sub == CYC_PER_CM - 1) begin
                        sub <= '0; cm <= cm + 1;
                    end else begin
                        sub <= sub + 1;
                    end

                    if (!echo_s[1]) begin           // echo ended
                        dist_cm <= cm; valid <= 1'b1;
                        cnt <= '0; state <= S_COOL;
                    end else if (cnt == TIMEOUT) begin  // stuck high
                        cnt <= '0; state <= S_COOL;
                    end
                end

                S_COOL: begin   // idle between measurements
                    cnt <= cnt + 1;
                    if (cnt == PERIOD - 1) begin
                        cnt <= '0; state <= S_TRIG;
                    end
                end
            endcase
        end
    end
    
    assign led = (dist_cm < 16'd50);
endmodule
