`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/16/2024 07:38:38 PM
// Design Name: 
// Module Name: decode_world
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


module decode_world(
    input [3:0] BIN_IN,
    input DOT_IN,
    input [1:0] SEG_SELECT_IN,
    output reg [3:0] SEG_SELECT_OUT,
    output reg [7:0] HEX_OUT
    );
    always @(*)
        begin
            case(BIN_IN)
                4'b0000: HEX_OUT = 8'b11000000; // "0"
                4'b0001: HEX_OUT = 8'b11111001; // "1"
                4'b0010: HEX_OUT = 8'b10100100; // "2"
                4'b0011: HEX_OUT = 8'b10110000; // "3"
                4'b0100: HEX_OUT = 8'b10011001; // "4"
                4'b0101: HEX_OUT = 8'b10010010; // "5"
                4'b0110: HEX_OUT = 8'b10000010; // "6"
                4'b0111: HEX_OUT = 8'b11111000; // "7"
                4'b1000: HEX_OUT = 8'b10000000; // "8"
                4'b1001: HEX_OUT = 8'b10010000; // "9"
                default: HEX_OUT = 8'b11111111; // Blank or error
            endcase

        // Control the dot
            if (DOT_IN)
                HEX_OUT[7] = 1; // Set dot on
            else
                HEX_OUT[7] = 0; // Set dot off
    
            SEG_SELECT_OUT = SEG_SELECT_IN; // Control which segment is selected
        end
endmodule
