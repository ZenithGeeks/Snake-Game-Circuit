`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.10.2016 10:42:07
// Design Name: 
// Module Name: WRAPPER
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: This is a top module for the Colour_the_world project. It connects the vga_control module with 
// the extra_features module.
// As a result, there is a letter V displayed on the screen and 4 squares in the corners of the screen. Al the 
// objects are moving. Moreover, the moving objects are changing colours evry second. The background colour is 
// controlled by the switches on the board.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module WRAPPER_VGA(
    input [11:0] COLOUR_IN,
    input CLK,
    input [1:0] MSM_State,
    output HS,
    output [11:0] COLOUR_OUT,
    output VS
    //output [3:0] VGA_FIN_OUT
    );
    
    // showing connections between VGA_module and extra_features
    wire [9:0] ADDRH;
    wire [9:0] ADDRY;
    wire [11:0] ColourOutX;
    reg TimerTrig;
    reg [3:0] VGA_FIN_OUT;
    
//    always@(posedge CLK) begin
//    if (MSM_State == 2'b11)
//    TimerTrig <= 1;
//    else
//    TimerTrig <= 0;
//    end
    
    // Instantiating the VGA controller module
    VGA_module vga_interface(
              .CLK(CLK),
              .COLOUR_IN(COLOUR_IN),
              .COLOUR_OUT(COLOUR_OUT),
              .HS(HS),
              .VS(VS),
              .ADDRH(ADDRH),
              .ADDRY(ADDRY)
              );
              
//     extra_features ColourPosition(
//              .CLK(CLK),
//              .COLOUR_IN(COLOUR_IN),
//              .X(ADDRH),
//              .Y(ADDRY),
//              .ColourOutX(ColourOutX),
//              .MSM_STATE(MSM_STATE)
//              );
     
//     Generic_counter # (.COUNTER_WIDTH(30),
//                        .COUNTER_MAX(500000000)
//                        )
//                        TimerCounter (
//                        .CLK(CLK),
//                        .ENABLE_IN(TimerTrig),
//                        .RESET(1'b0),
//                        .COUNT(TimerCount)
//                        );
                        
//     always@(posedge CLK) begin                   
//     if (TimerCount == 500000000)
//     VGA_FIN_OUT <= 4'h3;
//     else 
//     VGA_FIN_OUT <= 4'h0;
//     end
     
   endmodule