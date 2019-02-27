`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Vladislav Rumiantsev
// 
// Create Date: 24.10.2016 12:06:23
// Design Name: Snake Game 2016
// Module Name: VGA_module
// Project Name: Snake_Game
// Target Devices: BASYS3 by Digilent
// Tool Versions: 2015.3
// Description: 
// This a module to control the VGA data transmission. It takes the input COLOUR_IN from the wrapper module and transmitts it to the
// screen if the pixel address is within the range of the screen
// Dependencies: Generic_counter.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module VGA_module(
    input CLK,
    input [11:0] COLOUR_IN,
    output reg [11:0] COLOUR_OUT,
    output reg HS,
    output reg VS,
    output reg [9:0] ADDRH,
    output reg [8:0] ADDRY
    );
    
    // stating all the wire connections
    wire  TRIG_1;
    wire  HorTriggOut;
    wire  VerticalTriggOut;
    wire  [9:0] HorCount;
    wire  [9:0] VerticalCount;
    wire  [11:0] COLOUR_IN;
   
    //Time in vertical lines
    parameter VertTimeToPulseWidthEnd   = 10'd2;
    parameter VertTimeToBackPorchEnd    = 10'd31;
    parameter VertTimeToDisplayTimeEnd  = 10'd511;
    parameter VertTimeToFrontPorchEnd   = 10'd521;
    
    //Time in Front Horizontal Lines
    parameter HorzTimeToPulseWidthEnd   = 10'd96;
    parameter HorzTimeToBackPorchEnd    = 10'd144;
    parameter HorzTimeToDisplayTimeEnd  = 10'd784;
    parameter HorzTimeToFrontPorchEnd   = 10'd800;
    
    // This is a counter to reduce the frequency from 100MHz to 25MHz for screen refresh
    
    Generic_counter # (.COUNTER_WIDTH(2),
                       .COUNTER_MAX(3)
                       )
                       FreqCounter (
                       .CLK(CLK),
                       .ENABLE_IN(1'b1),
                       .RESET(1'b0),
                       .TRIG_OUT(TRIG_1)
                       );
    
    // This is a counter to count the horizontal pixel position
    
    Generic_counter # (.COUNTER_WIDTH(10),
                       .COUNTER_MAX(799)
                       )
                       HorizCounter (
                       .CLK(CLK),
                       .ENABLE_IN(TRIG_1),
                       .RESET(1'b0),
                       .TRIG_OUT(HorTriggOut),
                       .COUNT(HorCount)
                       );
                       
     // This is a counter to count the vertical pixel position                  
                       
     Generic_counter # (.COUNTER_WIDTH(10),
                        .COUNTER_MAX(520)
                       )
                       VerticalCounter (
                       .CLK(CLK),
                       .ENABLE_IN(HorTriggOut),
                       .RESET(1'b0),
                       .COUNT(VerticalCount)
                       );
               
     
     // Horizontal syncronization signal is generated if the horizontal count value is greater than 
     // Horizontal Time to pulse width end
                    
     always@( posedge CLK) begin
          if (HorCount < HorzTimeToPulseWidthEnd)
          HS <= 0;
          else 
          HS <= 1;
     end
     
     // Horizontal syncronization signal is generated if the horizontal count value is greater than 
     // Horizontal Time to pulse width end
     
     always@(posedge CLK) begin
          if (VerticalCount < VertTimeToPulseWidthEnd)
          VS <= 0;
          else 
          VS <= 1;
     end
     
     // If the horizontal and vertical counts are within the dispaly range (we are reducing it from 800x521 to 640x480) then the 
     // the input colour is transmitted to screen; otherwise, colour is not transmitted and set to default -- black
     
     always@( posedge CLK) begin
          if (HorCount < HorzTimeToDisplayTimeEnd && HorCount > HorzTimeToBackPorchEnd 
          && VerticalCount < VertTimeToDisplayTimeEnd && VerticalCount > VertTimeToBackPorchEnd)
          COLOUR_OUT <= COLOUR_IN;    
               
          else 
          COLOUR_OUT <= 0;          
      end      
          
     // If the horizontal count is within the range, then its value is assigned to the horizontal address
     // subtracting the offset  value (144 pixels)
     // Otherwise, address is set to 0      
           
     always@(posedge CLK) begin
          if (HorCount < HorzTimeToDisplayTimeEnd && HorCount > HorzTimeToBackPorchEnd)
                ADDRH <= HorCount - HorzTimeToBackPorchEnd;
          else 
                ADDRH <= 0;      
     end           
     
     // If the vertical count is within the range, then its value is assigned to the vertical address
     // subtracting the offset  value (31 pixels)
     // Otherwise, address is set to 0 
     
     always@(posedge CLK) begin           
          if ( VerticalCount < VertTimeToDisplayTimeEnd && VerticalCount > VertTimeToBackPorchEnd)
                 ADDRY <= VerticalCount - VertTimeToBackPorchEnd;
          else 
                 ADDRY <= 0;
     end
                
endmodule
