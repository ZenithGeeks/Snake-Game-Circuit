`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Vladislav Rumiantsev
// 
// Create Date: 14.11.2016 09:25:20
// Design Name: Snake Game 2016
// Module Name: random_num_gen
// Project Name: Snake_Game
// Target Devices: BASYS3 by Digilent
// Tool Versions: 2015.3
// Description: the aim of this module is to generate two random numbers each time the target is reached by the snake. 
//              Once it happens, the two generated numbers will act as the x and y coordinates for the new target.
// 
// Dependencies: none
// 
// Revision 0.01 - File Created
// 
//////////////////////////////////////////////////////////////////////////////////


module random_num_gen(
    input RESET,
    input CLK,
    input TARGET_REACHED,
    output reg [7:0] TARGET_ADDR_H,
    output reg [7:0] horItemLoc,
    output reg [6:0] TARGET_ADDR_V,
    output reg [6:0] verItemLoc
    );
    
    reg [7:0] LFSR_1;
    reg [6:0] LFSR_2;
    wire R_INPUT_1 = (LFSR_1[3] ~^ (LFSR_1[4] ~^ (LFSR_1[5] ~^ LFSR_1[7])));
    wire R_INPUT_2 = LFSR_2[6] ~^ LFSR_2[5];
    parameter maxX = 79;
    parameter maxY = 59;
    
    initial begin
        LFSR_1 = 8'b00001000;
        TARGET_ADDR_H = 8'b01010000;
        LFSR_2 = 7'b0001000;
        TARGET_ADDR_V = 7'b0111100;
        horItemLoc = 8'b00101010;
        verItemLoc = 7'b0011010;
    end
    
    always @(posedge CLK) begin
        if(RESET) begin
            LFSR_1 <= 8'b00000000;
        end
        else begin
            LFSR_1[7] <= LFSR_1[6];
            LFSR_1[6] <= LFSR_1[5];
            LFSR_1[5] <= LFSR_1[4];
            LFSR_1[4] <= LFSR_1[3];
            LFSR_1[3] <= LFSR_1[2];
            LFSR_1[2] <= LFSR_1[1];
            LFSR_1[1] <= LFSR_1[0];
            LFSR_1[0] <= R_INPUT_1;
        end
    end
    
    always @(posedge CLK) begin
        if(RESET) begin
            LFSR_2 <= 7'b0000000;
        end
        else begin
            LFSR_2[6] <= LFSR_2[5];
            LFSR_2[5] <= LFSR_2[4];
            LFSR_2[4] <= LFSR_2[3];
            LFSR_2[3] <= LFSR_2[2];
            LFSR_2[2] <= LFSR_2[1];
            LFSR_2[1] <= LFSR_2[0];
            LFSR_2[0] <= R_INPUT_2;
        end
     end
     
     always @(posedge CLK) begin
        if (TARGET_REACHED) begin
            if (LFSR_1 < 80) begin
                TARGET_ADDR_H <= LFSR_1;
            end
            else begin
                TARGET_ADDR_H <= maxX / 3;
            end
            if(LFSR_2 < 60) begin
                TARGET_ADDR_V <= LFSR_2;
            end
            else begin
                TARGET_ADDR_V <= maxY / 3;
            end
        end
        else if (RESET) begin
            TARGET_ADDR_H <= maxX / 3;
            TARGET_ADDR_V <= maxY / 3;
        end
    end
endmodule
