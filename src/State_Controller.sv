`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: LockEEd 
// Engineer: Isaac Hurt
// 
// Create Date: 11/02/2026 08:41:18 PM
// Design Name: 
// Module Name: State Controller
// Project Name: Ultrasonic Sensing Small Object Launched
// Target Devices: Xilinx Spartan 7
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


module State_Controller(
    input logic clk, // Entire Project will run off of One Clock
    input logic n_rst, 
    input logic btn, // Will be used to activate sequencing
    input logic target_found, // Will be inputted to by the Ultrasonic Interpreter
    output logic seek_enable, // Will be sent to the SEEKING module to begin its processing
    output logic engage_enable // Will be sent to ENGAGE MODULE
    );
    
    typedef enum logic{ // These States Relate to what Module will be active
         SEEKING,
         ENGAGE
       } turret_state;
       
    turret_state current_state, next_state;
    
    // Will be used to signal a reset
    logic started; // This tells me to wait for btn, 0 denotes arming stage, 1 sets sequence in motion
    
    
    // State Machine Control Logic
    always_comb begin: state_switch_logic
        next_state = current_state;
        //  State Switching Logic
        case (current_state)
            SEEKING: begin
                if(started && target_found)
                    next_state = ENGAGE;    
            end
            ENGAGE: begin
                next_state = ENGAGE; // State is returned to 0 when n_rst is called in always ff
            end  
          // ARMING state is considered whenever btn is not triggered and start equals 1'b0  
         endcase
      end
       
    // This is where our current state is really stored     
    always_ff @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin // If reset is called, reset all values to default state
            current_state <= SEEKING; // It's state is in seeking, but is only acted upon when started equals 1'b1
            started  <= 1'b0;
        end else begin 
            current_state <= next_state;
            if(btn) begin
                started <= 1'b1;
            end
        end
    end
    
    always_comb begin: state_action_logic 
        seek_enable = 1'b0;
        engage_enable = 1'b0;
        // State Enacting Logic
        case (current_state) 
            SEEKING: seek_enable = started;
            ENGAGE: engage_enable = 1'b1;
        endcase
    end    
endmodule
