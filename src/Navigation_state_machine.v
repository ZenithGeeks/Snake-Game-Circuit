`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Vladislav Rumiantsev
// 
// Create Date: 15.11.2016 16:36:06
// Design Name: Snake Game 2016
// Module Name: Navigation_state_machine
// Project Name: Snake_Game
// Target Devices: BASYS3 
// Tool Versions: 2015.3
// Description: This module is designed to choose the direction of the movement of the snake based on the button inputs
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Navigation_state_machine(
                            input CLK,
                            input BTNR,
                            input BTNL,
                            input BTND,
                            input BTNU,
                            input RESET,
                            output [1:0] NAV_STATE
    );
    
    parameter UP = 2'd0;
    parameter LEFT = 2'd1;
    parameter RIGHT = 2'd2;
    parameter DOWN = 2'd3;
    
    reg [1:0] Curr_state;
    reg [1:0] Next_state;
            
    // Always make NAV_STATE equal to the current state        
    assign NAV_STATE = Curr_state;
    
    // default direction is set to upwards
            
    always@(posedge CLK or posedge RESET)
       begin
          if (RESET) 
               Curr_state <= 0;
          else 
               Curr_state <= Next_state;
       end
    
    // List the signals to be checked for the transition to the other state
    always@(Curr_state or BTNL or BTNU or BTNR or BTND or RESET) begin
                     
               case (Curr_state)
                         // State UP
                     UP    :begin
                         if (BTNL)
                               Next_state <= 2'd1;
                         else if (BTNR)
                               Next_state <= 2'd2;
                         else
                             Next_state <= Curr_state;
                         end
                          // State LEFT   
                     LEFT    :begin
                         if (BTNU)
                             Next_state <= 2'd0;
                         else if (BTND)
                             Next_state <= 2'd3;
                         else 
                             Next_state <= Curr_state; 
                     end
                          // State RIGHT            
                     RIGHT    :begin
                         if (BTNU)
                             Next_state <= 2'd0;
                         else if (BTND)
                             Next_state <= 2'd3;
                         else
                             Next_state <= Curr_state;
                     end
                          // State DOWN 
                     DOWN    :begin
                         if (BTNL)
                             Next_state <= 2'd1;
                         else if (BTNR)
                             Next_state <= 2'd2;
                         else
                             Next_state <= Curr_state;
                         end
              endcase              
        end          
    
    
endmodule
