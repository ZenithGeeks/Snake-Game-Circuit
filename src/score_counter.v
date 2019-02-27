`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Vladislav Rumiantsev
// 
// Create Date: 20.10.2016 09:10:58
// Design Name: Snake Game 2016
// Module Name: snake_wrapper
// Project Name: Snake_Game
// Target Devices: BASYS3 by Digilent
// Tool Versions: 2015.3 
// Description: This module is responsible for displaying the current score on the 7 segment display and
//               generating a signal once the score of 10 is reached. This signal is then used by 
//               the Master_state_machine module.
// Dependencies: none
// 
//////////////////////////////////////////////////////////////////////////////////


module Score_counter(
    input CLK,
    input RESET,
    input TARGET_REACHED,
    input Timed_Mode,
    input [1:0] MSM_STATE,
    output [3:0] SEG_SELECT_OUT,
    output [7:0] DEC_OUT,
    output reg LOST,
    output reg SCORE_WIN,
    output reg WIN
    );
    
    parameter timer = 6;
    
    wire [4:0] DecCountAndDOT0;
    wire [4:0] DecCountAndDOT1;
    wire [4:0] DecCountAndDOT2;
    wire [4:0] DecCountAndDOT3;
    
    
    wire [3:0] DecCount0;
    wire [3:0] DecCount1;
    wire [3:0] DecCount2;
    wire [3:0] DecCount3;
    
    wire Bit17TriggOut;
    wire [1:0] StrobeCount;
    
    wire TRIG1;
    wire TRIG_2;
    wire OneSec;
    
    wire [4:0] MuxOut;
    wire HalfCount; 
    
    reg STOP;
    
 
    
    // Tie each of the counter outputs with a single bit that represents the DOT state. 
    assign DecCountAndDOT2 = {1'b1, DecCount2};
    assign DecCountAndDOT3 = {1'b1, DecCount3};
    assign DecCountAndDOT0 = {1'b1, DecCount0};
    assign DecCountAndDOT1 = {1'b1, DecCount1};
    
    
    //Instantiate the MUX   
    Multiplexer_4way Mux4(
            .CONTROL(StrobeCount),
            .IN0(DecCountAndDOT0),
            .IN1(DecCountAndDOT1),
            .IN2(DecCountAndDOT2),
            .IN3(DecCountAndDOT3),
            .OUT(MuxOut)
            );
    
    // This is a counter that defines the refresh frequency of the displays        
    Generic_counter # (.COUNTER_WIDTH(17),
                       .COUNTER_MAX(99999)
                       )   
                       DispRefresh(
                       .CLK(CLK),
                       .RESET(1'b0),
                       .ENABLE_IN(1'b1),
                       .TRIG_OUT(Bit17TriggOut)
                       );
   
   // This is a counter that chooses the display to refresh. It is triggered by the trig_out of the 
   // DispRefresh                  
   Generic_counter # (.COUNTER_WIDTH(2),
                      .COUNTER_MAX(3)
                      )                 
                       StrobeCounter(
                       .CLK(CLK),
                       .RESET(1'b0),
                       .ENABLE_IN(Bit17TriggOut),
                       .COUNT(StrobeCount)
                      );
                      
   // This counter reducces the clock frequency by a factor of 2.               
   Generic_counter # (.COUNTER_WIDTH(2),
                      .COUNTER_MAX(1)
                      )                 
                      HalfCounter(
                      .CLK(CLK),
                      .RESET(1'b0),
                      .ENABLE_IN(1'b1),  
                      .TRIG_OUT(HalfCount)
                                            );                   
   
   // This is the counter that sets the value of the score from 0 to 9
   // It is incremented if TARGET_REACHED is received. I also added the 
   // second condition, because the rising edge of the clock occurs
   // twice during the TARGET_REACHED signal and this caused errors.                
   Generic_counter # (.COUNTER_WIDTH(4),
                       .COUNTER_MAX(9)
                      ) 
                     SecDecimal(
                     .CLK(CLK),
                     .RESET(RESET),
                     .ENABLE_IN(TARGET_REACHED && HalfCount),
                     .TRIG_OUT(TRIG1),
                     .COUNT(DecCount1)
                     );
                     
   // This counter is only incremented once the SecDecimal counter reaches 9
   // It is used to display value 10
                     
   Generic_counter # (.COUNTER_WIDTH(4),
                      .COUNTER_MAX(1)
                      ) 
                      FirstDecimal(
                      .CLK(CLK),
                      .RESET(RESET),
                      .ENABLE_IN(TRIG1),
                      .COUNT(DecCount0)
                      );
                      
   
    // Decode_the_world module must be instantiated to display the value
    // of score count on the 7-seg display.        
    decode_world Seg7(
                  .SEG_SELECT_IN(StrobeCount),
                  .BIN_IN(MuxOut[3:0]),
                  .DOT_IN(MuxOut[4]),
                  .SEG_SELECT_OUT(SEG_SELECT_OUT),
                  .HEX_OUT(DEC_OUT)
               );
    
    // When the score reaches 10, the SCORE_win signal is generated
    always@(posedge CLK) begin
        if (DecCount0 == 1)
            SCORE_WIN <= 1;
        else 
            SCORE_WIN <= 0;
    end    
               
    // Timer code
    // This part of code is designed to introduce a timer if a special game mode is chosen
    
    // This counter produces a trig out signal every second
    Generic_counter # (.COUNTER_WIDTH(28),
                           .COUNTER_MAX(99999999)
                           )   
                           OneSecond(
                           .CLK(CLK),
                           .RESET(RESET),
                           .ENABLE_IN(Timed_Mode && ~STOP && MSM_STATE == 2'd1),
                           .TRIG_OUT(OneSec)
                           );
    
    // This counter is incremented evey second and its value is displayed
    
    Generic_counter # (.COUNTER_WIDTH(4),
                       .COUNTER_MAX(9)
                      )                 
                       Seconds(
                      .CLK(CLK),
                      .RESET(RESET),
                      .ENABLE_IN(OneSec && Timed_Mode),
                      .TRIG_OUT(TRIG_2),
                      .COUNT(DecCount3)
                      );
          
    // This counter is incremented every 10 seconds

    Generic_counter # (.COUNTER_WIDTH(4),
                       .COUNTER_MAX(9)
                      ) 
                     DecSeconds(
                     .CLK(CLK),
                     .RESET(RESET),
                     .ENABLE_IN(TRIG_2),

                     .COUNT(DecCount2)
                     );   
          
    // The user loses if he or she does not manage to reach the score of 10 
    // within 60 seconds

    always@(posedge CLK) begin
        if (DecCount2 == timer && DecCount0 == 0) begin
        LOST <= 1; 
        WIN <= 0;
        STOP = 1;
        end
        else if(DecCount2 < timer && DecCount0 == 1) begin
        WIN <= 1;
        LOST <= 0;
        STOP <= 1;
        end


        // STOP signal is generated when the counter reaches either 60 sec or 
        // if the player won before the deadline
        if (Timed_Mode && MSM_STATE == 2'd1)
            STOP <= 0;
        else if (Timed_Mode == 0 && MSM_STATE == 2'd1)
            STOP <= 1;
        else if (Timed_Mode == 0)
            STOP <= 1;

        if (RESET) begin
        LOST <= 0;
        WIN <= 0;
        STOP <= 1;
        end
    end       
               
endmodule
