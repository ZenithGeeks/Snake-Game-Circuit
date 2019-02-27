`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.11.2016 16:09:42
// Design Name: 
// Module Name: Master_state_machine
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: This module controls whether to display a starting screen, snake game interface, win or lose.
// 
// Dependencies: -Snake_control.v
//               -Score_counter.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Master_state_machine(
    input BTNL,
    input BTNR,
    input BTNU,
    input BTND,
    input CLK,
    input RESET,
    input SCORE_WIN,
    input LOST,
    input WIN,
    output [1:0] MSM_STATE
    );
    
    parameter START = 2'd0;
    parameter PLAY = 2'd1;
    parameter WINNER = 2'd2;
    parameter LOSER = 2'd3;
    
    reg [1:0] Curr_state;
    reg [1:0] Next_state;
        
    initial begin
        Curr_state = 0;
    end
    
    //Amking MSM_STATE always equal to the Current state    
    assign MSM_STATE = Curr_state;
        
    always@(posedge CLK or posedge RESET)
       begin
          if (RESET) 
               Curr_state <= 0;
          else 
               Curr_state <= Next_state;
       end
    

         // List the signals to be checked for the state transition
         always@(Curr_state or BTNL or BTNU or BTNR or BTND or RESET or SCORE_WIN or LOST or WIN) begin
              
                  case (Curr_state)
                  
                      START    :begin
                          if (BTNL || BTNU || BTNR || BTND)
                              Next_state <= 2'd1;
                          else
                              Next_state <= Curr_state;
                      end
                      // transition to the win screen can be done
                      // either from the normal or timed mode
                      PLAY    :begin
                           if (SCORE_WIN || WIN)
                               Next_state <= 2'd2;
                           else if (LOST)
                               Next_state <= 2'd3;
                           else 
                               Next_state <= Curr_state; 
                      end
                               
                      WINNER    :begin
                           if (RESET)
                               Next_state <= 2'd0;
                           else
                               Next_state <= Curr_state;
                      end
                      
                      LOSER     :begin
                            if (RESET)
                               Next_state <= 2'd0;
                            else
                               Next_state <= Curr_state;
                      end
                 endcase              
           end        
endmodule
