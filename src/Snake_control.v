`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Vladislav Rumiantsev
// 
// Create Date: 15.11.2016 20:03:02
// Design Name: Snake Game 2016
// Module Name: Snake_control
// Project Name: Snake_Game
// Target Devices: BASYS3 by Digilent
// Tool Versions: 2015.3
// Description: This is the main module of the project. It performs all the operation with snake and defines the coloures to be displayed.
//              Here the length of the snake is defined, target is coloured, win, lose and play interfaces are described.
//              It also controls the timer and determines whether the target has been reached by the snake. 
//              Finally, the snake growth is also done in this module.
// 
// Dependencies: -Score_counter.v
//               -VGA_module.v
//               -random_num_gen.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Snake_control(
                input       CLK,
                input       RESET,
                input [1:0] MSM_STATE,
                input [1:0] NAV_STATE,
                input [7:0] TARGET_ADDR_H,
                input [6:0] TARGET_ADDR_V,
                input [9:0] ADDRH,
                input [9:0] ADDRY,
                input       GAME_IN,
                input       LOST,
                input       WIN,
                output reg [11:0] COLOUR_OUT,
                output reg TARGET_REACHED,
                output reg Timed_Mode
    );
     
      parameter SnakeLength = 20;
      parameter SmallSnake = 2;
      parameter MaxX = 159;
      parameter MaxY = 119;
      
      parameter RED = 12'b000000001111;
      parameter BLUE = 12'b111100000000;
      parameter YELLOW = 12'b000011111111;
      parameter BLACK = 12'b000000000000;
    
      // registers to store the snake addresses
      reg [7:0] SnakeState_X [0 : SnakeLength - 1];
      reg [6:0] SnakeState_Y [0 : SnakeLength - 1];
      reg [4:0] SnakeVar;
      reg [15:0] FrameCount;
      
      wire TRIG_1;
      wire TRIGC;
      wire [11:0] ColourCount;
      wire [7:0] ADDRH_S;
      wire [6:0] ADDRV_S;
      
      integer i;
      
      initial begin
        TARGET_REACHED <= 0;
        Timed_Mode <= 0;
        SnakeVar <= SmallSnake;
      end
     
     
      // This is the counter that reduces the clock frequency and thus determines the snake speed
      Generic_counter # (.COUNTER_WIDTH(23),
                         .COUNTER_MAX(3999999)
                         )
                         FreqCounter (
                         .CLK(CLK),
                         .ENABLE_IN(1'b1),
                         .RESET(1'b0),
                         .TRIG_OUT(TRIG_1)
                         );
      
      // This counter determines the frequency of the colours to change on the main screen during the idle state                   
      Generic_counter # (.COUNTER_WIDTH(23),
                         .COUNTER_MAX(2999999)
                         )
                         ColourFreqCounter (
                         .CLK(CLK),
                         .ENABLE_IN(1'b1),
                         .RESET(1'b0),
                         .TRIG_OUT(TRIGC)
                         );                   
      
      // This counter goes through all of the possible colours in the range, being triggerd by the ColourFreqCounter
      Generic_counter # (.COUNTER_WIDTH(12),
                         .COUNTER_MAX(4094)
                         )
                         ColCounter (
                         .CLK(TRIGC),
                         .ENABLE_IN(1'b1),
                         .RESET(1'b0),
                         .COUNT(ColourCount)
                         );
      
      // This is the main part of the code. Here the screen behaviour is described for easch state
      // of the Master_state_machine module. In the idle state A label "PLAY" is displayed.
                         
      always@(posedge CLK) begin
            case (MSM_STATE)
                  2'b00:  begin
                         ///////////////////////Letter P//////////////////////
                     if((ADDRH >= 100 && ADDRH <= 110 && ADDRY >= 120 && ADDRY <= 360) ||
                        (ADDRH >= 110 && ADDRH <= 190 && ADDRY >= 120 && ADDRY <= 130) ||
                        (ADDRH >= 180 && ADDRH <= 190 && ADDRY >= 130 && ADDRY <= 200) ||
                        (ADDRH >= 110 && ADDRH <= 190 && ADDRY >= 200 && ADDRY <= 210) ||
                         ///////////////////////Letter L/////////////////////                  
                        (ADDRH >= 220 && ADDRH <= 230 && ADDRY >= 120 && ADDRY <= 360) ||
                        (ADDRH >= 230 && ADDRH <= 320 && ADDRY >= 350 && ADDRY <= 360) ||
                         ///////////////////////Letter A/////////////////////                   
                        (ADDRH >= 350 && ADDRH <= 360 && ADDRY >= 130 && ADDRY <= 360) ||
                        (ADDRH >= 360 && ADDRH <= 420 && ADDRY >= 120 && ADDRY <= 130) ||
                        (ADDRH >= 360 && ADDRH <= 420 && ADDRY >= 200 && ADDRY <= 210) ||
                        (ADDRH >= 420 && ADDRH <= 430 && ADDRY >= 130 && ADDRY <= 360) ||
                         ///////////////////////Letter Y//////////////////////                   
                        (ADDRH >= 460 && ADDRH <= 470 && ADDRY >= 120 && ADDRY <= 200) ||
                        (ADDRH >= 470 && ADDRH <= 530 && ADDRY >= 200 && ADDRY <= 210) ||
                        (ADDRH >= 530 && ADDRH <= 540 && ADDRY >= 120 && ADDRY <= 350) ||
                        (ADDRH >= 470 && ADDRH <= 530 && ADDRY >= 350 && ADDRY <= 360))
                                            
                        COLOUR_OUT <= ColourCount;
                        else
                        COLOUR_OUT <= BLACK;
                        
                        SnakeVar <= SmallSnake;
                        Timed_Mode <= 0;
                     end
                  
                  // Below the game itself is described. This applies only when the 
                  // Master_state_machine is in the state PLAY.
                                        
                  2'b01: begin   
                  
                     // If the address of the snake head corresponds to the address received from 
                     // the VGA_module, pixel is coloured in yellow do depict the snake head.
                                                    
                     if(ADDRH[9:2] == SnakeState_X[0] && ADDRY[8:2] == SnakeState_Y[0])
                     COLOUR_OUT <= YELLOW;           
                     
                     // If the address of the target corresponds to the address received from the 
                     // VGA_mpdule, it is coloured in red.
                                                                
                     else if(ADDRH[9:2] == TARGET_ADDR_H && ADDRY[8:2] == TARGET_ADDR_V)
                     COLOUR_OUT <= RED;

                     else 
                     COLOUR_OUT <= BLUE;

                     // This is the loop to colour the whole sanke length
                     // The region being coloured changes with the SnakeVar,
                     // a variable that represents the current snake length

                     for (i = 0; i < SnakeVar; i = i + 1) begin
                        if (ADDRH[9:2] == SnakeState_X[i] && ADDRY[8:2] == SnakeState_Y[i])
                        COLOUR_OUT <= YELLOW;
                     end
                     
                     // Every time the address of the head of the snake corresponds to the address
                     // of the target, TARGET_REACHED signal is generated.
                     // At the same time, the SnakeVAr increases to make the snake longer
                                        
                     if (SnakeState_X[1] == TARGET_ADDR_H && SnakeState_Y[1] == TARGET_ADDR_V) begin
                          TARGET_REACHED <= 1; 
                          if(SnakeVar < SnakeLength)
                          SnakeVar <= SnakeVar + 1; 
                     end 
                    
                     else
                          TARGET_REACHED <= 0;
                     
                     // This piece of code controls behaviour of the timer by resetting it
                     // if the user has won or lost the game.
                     // Timer is only activated if the GAME_IN signal is received (SW15).
                     
                           
                     if (MSM_STATE == 2'd1) begin     
                        if (GAME_IN)
                           Timed_Mode <= 1;
                        else if (LOST && GAME_IN)
                           Timed_Mode <= 0;
                        else if (WIN && GAME_IN)
                            Timed_Mode <= 0;
                     end
                     else if (GAME_IN == 0)
                        Timed_Mode <= 0;
                                              
                     end 
                                         
                   // Following is the code to make a colourful WIN screen                  
                                     
                   2'b10: begin

                       SnakeVar <= SmallSnake;
                       Timed_Mode <= 0;                 
                      if(ADDRY == 479) begin
                          FrameCount <= FrameCount + 1;  
                      end
                                        
                      if(ADDRY[8:0] > 240) begin
                          if(ADDRH > 320)
                              COLOUR_OUT <= FrameCount[15:8] + ADDRY[7:0] + ADDRH[7:0] -240 - 320;
                          else
                              COLOUR_OUT <= FrameCount[15:8] + ADDRY[7:0] - ADDRH[7:0] -240 + 320;
                      end
                      else begin
                          if(ADDRH > 320)
                              COLOUR_OUT <= FrameCount[15:8] - ADDRY[7:0] + ADDRH[7:0] + 240 - 320;
                          else
                              COLOUR_OUT <= FrameCount[15:8] - ADDRY[7:0] - ADDRH[7:0] + 240 + 320;
                      end
                    end
                    
                   // Red screen is displayed if the player lost
                    
                   2'b11:   begin
                    COLOUR_OUT <= RED;
                    SnakeVar <= SmallSnake;
                    Timed_Mode <= 0;
                    end
                    
                endcase     
              end    
              
      // At this point the snake itself is generated 
      // and its initial position is determined.
      
      genvar PixNo;
      generate 
        for (PixNo = 0; PixNo < SnakeLength - 1; PixNo = PixNo + 1)
            begin: PixShift
                always@(posedge CLK) begin
                    if(RESET) begin
                        SnakeState_X[PixNo+1] <= 80;
                        SnakeState_Y[PixNo+1] <= 100;
                    end
                    
                    else if (TRIG_1 == 1) begin
                        SnakeState_X[PixNo+1] <= SnakeState_X[PixNo];
                        SnakeState_Y[PixNo+1] <= SnakeState_Y[PixNo];
                    end
                end
           end
      endgenerate
      
      // Here the position of the snake head is determined after RESET signal was received
      // After that the direction of the snake is identified by checking the state of the
      // Navigation_state_machine
      
      always@(posedge CLK) begin
        if(RESET) begin
            SnakeState_X[0] <= 80;
            SnakeState_Y[0] <= 100;
        end
        
        else if (TRIG_1 == 1) begin
            case (NAV_STATE)
                // UP
                2'b00 :begin
                    if(SnakeState_Y[0] == 0)
                        SnakeState_Y[0] <= MaxY;
                    else
                        SnakeState_Y[0] <= SnakeState_Y[0] - 1;
                 end
                //RIGHT 
                2'b10 : begin
                    if(SnakeState_X[0] == MaxX)
                        SnakeState_X[0] <= 0;
                    else
                        SnakeState_X[0] <= SnakeState_X[0] + 1;
                    end 
                //LEFT 
                2'b01 : begin
                    if(SnakeState_X[0] == 0)
                        SnakeState_X[0] <= MaxX;
                    else
                        SnakeState_X[0] <= SnakeState_X[0] - 1;
                end
                //DOWN
                2'b11 :begin
                    if(SnakeState_Y[0] == MaxY)
                        SnakeState_Y[0] <= 0;
                    else
                        SnakeState_Y[0] <= SnakeState_Y[0] + 1;
                    end
                
             endcase
        end
       end 
       
endmodule
    
    
    

