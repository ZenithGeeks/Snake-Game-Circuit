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
    input CLK,
    input RESET,
    input [1:0] MSM_STATE,
    input [1:0] NAV_STATE,
    input [7:0] TARGET_ADDR_H,
    input [7:0] horItemLoc,
    input [6:0] TARGET_ADDR_V,
    input [6:0] verItemLoc,
    input [9:0] ADDRH,
    input [9:0] ADDRY,
    input GAME_IN,
    input LOST,
    input WIN,
    output reg [11:0] COLOUR_OUT,
    output reg TARGET_REACHED,
    output reg Timed_Mode,
    output reg HitWall
    );
    parameter SnakeLength = 1000;
    parameter SmallSnake = 2;
    parameter MaxX = 79;
    parameter MaxY = 59;  
    parameter RED = 12'b111100000000;
    parameter BLUE = 12'b001100110011;
    parameter YELLOW = 12'b000011110000;
    parameter easyItemColor = 12'b111111110000;
    parameter hardItemColor = 12'b100000001000;
    parameter BLACK = 12'b000000000000;
    parameter horItemLocParam = 8'b00101010;
    parameter verItemLocParam = 7'b0011010;
    parameter easyRequirement = 2;
    parameter hardRequirement = 5;
    reg [7:0] SnakeState_X [0 : SnakeLength - 1];
    reg [6:0] SnakeState_Y [0 : SnakeLength - 1];
    reg [4:0] SnakeVar;
    reg [4:0] latestLength;
    reg [7:0] easyItemCounter;
    reg [15:0] FrameCount;
    reg [1:0] easyItemVisible;
    reg [7:0] dynamicHorLoc;
    reg [6:0] dynamicVerLoc;
    reg [7:0] randomSeed;
    reg [4:0] numTarget;
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
        easyItemVisible <= 0;
        easyItemCounter <= 0;
        latestLength <= SmallSnake;
        numTarget <= 0;
        HitWall <= 0;
        SnakeState_X[0] <= (MaxX / 3) + 5;
        SnakeState_Y[0] <= (MaxY / 3) + 5;
    end
    
    Generic_counter #(.COUNTER_WIDTH(23), .COUNTER_MAX(5000000))
    FreqCounter (.CLK(CLK), .ENABLE_IN(1'b1), .RESET(1'b0), .TRIG_OUT(TRIG_1));
    Generic_counter #(.COUNTER_WIDTH(23), .COUNTER_MAX(2999999))
    ColourFreqCounter (.CLK(CLK), .ENABLE_IN(1'b1), .RESET(1'b0), .TRIG_OUT(TRIGC));                   
    Generic_counter #(.COUNTER_WIDTH(12), .COUNTER_MAX(4094))
    ColCounter (.CLK(TRIGC), .ENABLE_IN(1'b1), .RESET(1'b0), .COUNT(ColourCount));
    
    always @(posedge CLK) begin
        if (RESET) begin
            randomSeed <= 8'd42;
        end
        /*else begin
            randomSeed <= randomSeed + 8'd1;
        end*/
    end
    
    always @(posedge CLK) begin
        case (MSM_STATE)
            2'b00:  begin
                //Letter P
                if((ADDRH >= 100 && ADDRH <= 110 && ADDRY >= 120 && ADDRY <= 360) ||
                    (ADDRH >= 110 && ADDRH <= 190 && ADDRY >= 120 && ADDRY <= 130) ||
                    (ADDRH >= 180 && ADDRH <= 190 && ADDRY >= 130 && ADDRY <= 200) ||
                    (ADDRH >= 110 && ADDRH <= 190 && ADDRY >= 200 && ADDRY <= 210) ||
                    //Letter L
                    (ADDRH >= 220 && ADDRH <= 230 && ADDRY >= 120 && ADDRY <= 360) ||
                    (ADDRH >= 230 && ADDRH <= 320 && ADDRY >= 350 && ADDRY <= 360) ||
                    //Letter A
                    (ADDRH >= 350 && ADDRH <= 360 && ADDRY >= 130 && ADDRY <= 360) ||
                    (ADDRH >= 360 && ADDRH <= 420 && ADDRY >= 120 && ADDRY <= 130) ||
                    (ADDRH >= 360 && ADDRH <= 420 && ADDRY >= 200 && ADDRY <= 210) ||
                    (ADDRH >= 420 && ADDRH <= 430 && ADDRY >= 130 && ADDRY <= 360) ||
                    //Letter Y
                    (ADDRH >= 460 && ADDRH <= 470 && ADDRY >= 120 && ADDRY <= 200) ||
                    (ADDRH >= 470 && ADDRH <= 530 && ADDRY >= 200 && ADDRY <= 210) ||
                    (ADDRH >= 530 && ADDRH <= 540 && ADDRY >= 120 && ADDRY <= 350) ||
                    (ADDRH >= 470 && ADDRH <= 530 && ADDRY >= 350 && ADDRY <= 360)) begin
                    COLOUR_OUT <= ColourCount;
                end
                else begin
                    COLOUR_OUT <= BLACK;
                    SnakeVar <= SmallSnake;
                    Timed_Mode <= 0;
                end
            end
            2'b01: begin
                if (RESET) begin
                    dynamicHorLoc <= randomSeed % MaxX;
                    dynamicVerLoc <= randomSeed % MaxY;
                    SnakeVar <= SmallSnake;
                    latestLength <= SmallSnake;
                    easyItemCounter <= 0;
                    easyItemVisible <= 0;
                    numTarget <= 0;
                end
                if (TARGET_REACHED) begin
                    dynamicHorLoc <= (randomSeed * 8'd3) % MaxX;
                    dynamicVerLoc <= (randomSeed * 7'd5) % MaxY;
                end
                else if (TRIG_1) begin
                    if (numTarget == easyRequirement) begin
                        easyItemVisible <= 1;
                    end
                    if (SnakeState_X[1] == dynamicHorLoc && SnakeState_Y[1] == dynamicVerLoc && easyItemVisible == 1) begin
                        latestLength <= SnakeVar;
                        SnakeVar <= SmallSnake;
                        easyItemVisible <= 0;
                        easyItemCounter <= 0;
                        numTarget <= 0;
                    end
                    if (!easyItemVisible && easyItemCounter < 200) begin
                        easyItemCounter <= easyItemCounter + 1;
                    end
                    else if (!easyItemVisible && easyItemCounter == 200) begin
                        dynamicHorLoc <= (randomSeed * 8'd3) % MaxX;
                        dynamicVerLoc <= (randomSeed * 7'd5) % MaxY;
                        SnakeVar <= SnakeVar + latestLength;
                        easyItemCounter <= 0;
                    end
                end
                if(HitWall) begin
                    COLOUR_OUT <= RED;
                    SnakeVar <= SmallSnake;
                    Timed_Mode <= 0;
                end
                else begin
                    if(ADDRH[9:3] == SnakeState_X[0] && ADDRY[8:3] == SnakeState_Y[0]) begin
                        COLOUR_OUT <= YELLOW;
                    end
                    else if(ADDRH[9:3] == TARGET_ADDR_H && ADDRY[8:3] == TARGET_ADDR_V) begin
                        COLOUR_OUT <= RED;
                    end
                    else if (ADDRH[9:3] == dynamicHorLoc && ADDRY[8:3] == dynamicVerLoc && easyItemVisible == 1) begin
                        COLOUR_OUT <= easyItemColor;
                    end
                    else begin
                        COLOUR_OUT <= BLUE;
                    end
                    for (i = 0; i < SnakeVar; i = i + 1) begin
                        if (ADDRH[9:3] == SnakeState_X[i] && ADDRY[8:3] == SnakeState_Y[i]) begin
                            COLOUR_OUT <= YELLOW;
                        end
                    end
                    if (SnakeState_X[1] == TARGET_ADDR_H && SnakeState_Y[1] == TARGET_ADDR_V) begin
                        TARGET_REACHED <= 1;
                        numTarget <= numTarget + 1;
                        easyItemVisible <= 1;
                        if(SnakeVar < SnakeLength) begin
                            SnakeVar <= SnakeVar + 1;
                        end
                    end
                    else begin
                        TARGET_REACHED <= 0;
                    end
                    if (MSM_STATE == 2'd1) begin
                        if (GAME_IN) begin
                            Timed_Mode <= 1;
                        end
                        else if (LOST && GAME_IN) begin
                            Timed_Mode <= 0;
                        end
                        else if (WIN && GAME_IN) begin
                            Timed_Mode <= 0;
                        end
                    end
                    else if (GAME_IN == 0) begin
                        Timed_Mode <= 0;
                    end
                end
            end
            2'b10: begin
                SnakeVar <= SmallSnake;
                Timed_Mode <= 0;                 
                if(ADDRY == 479) begin
                    FrameCount <= FrameCount + 1;  
                end
                if(ADDRY[8:0] > 240) begin
                    if(ADDRH > 320) begin
                        COLOUR_OUT <= FrameCount[15:8] + ADDRY[7:0] + ADDRH[7:0] -240 - 320;
                    end
                    else begin
                        COLOUR_OUT <= FrameCount[15:8] + ADDRY[7:0] - ADDRH[7:0] -240 + 320;
                    end
                end
                else begin
                    if(ADDRH > 320) begin
                        COLOUR_OUT <= FrameCount[15:8] - ADDRY[7:0] + ADDRH[7:0] + 240 - 320;
                    end
                    else begin
                        COLOUR_OUT <= FrameCount[15:8] - ADDRY[7:0] - ADDRH[7:0] + 240 + 320;
                    end
                end
            end
            2'b11: begin
                COLOUR_OUT <= RED;
                SnakeVar <= SmallSnake;
                Timed_Mode <= 0;
            end
        endcase
    end
    
    genvar PixNo;
    
    generate 
        for (PixNo = 0; PixNo < SnakeLength - 1; PixNo = PixNo + 1) begin: PixShift
            always @(posedge CLK) begin
                if(RESET) begin
                    SnakeState_X[PixNo+1] <= MaxX / 2;
                    SnakeState_Y[PixNo+1] <= MaxY / 2;
                end
                else if (TRIG_1 == 1) begin
                    SnakeState_X[PixNo+1] <= SnakeState_X[PixNo];
                    SnakeState_Y[PixNo+1] <= SnakeState_Y[PixNo];
                end
            end
        end
    endgenerate
    
    always @(posedge CLK) begin
        if (RESET) begin
            SnakeState_X[0] <= (MaxX / 3) + 5;
            SnakeState_Y[0] <= (MaxY / 3) + 5;
            HitWall <= 0;
        end
        else if (TRIG_1 == 1) begin
            HitWall <= 0;
        case (NAV_STATE)
            2'b00: if (SnakeState_Y[0] > 0) SnakeState_Y[0] <= SnakeState_Y[0] - 1; else HitWall <= 1; // UP
            2'b10: if (SnakeState_X[0] < MaxX) SnakeState_X[0] <= SnakeState_X[0] + 1; else HitWall <= 1; // RIGHT
            2'b01: if (SnakeState_X[0] > 0) SnakeState_X[0] <= SnakeState_X[0] - 1; else HitWall <= 1; // LEFT
            2'b11: if (SnakeState_Y[0] < MaxY) SnakeState_Y[0] <= SnakeState_Y[0] + 1; else HitWall <= 1; // DOWN
        endcase

        for (i = 1; i < SnakeVar; i = i + 1) begin
            if ((SnakeState_X[0] == SnakeState_X[i]) && (SnakeState_Y[0] == SnakeState_Y[i])) begin
                HitWall <= 1;
            end
        end
    end
end

    
endmodule
