`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Vladislav Rumiantsev
// 
// Create Date: 16.11.2016 14:28:43
// Design Name: Snake Game 2016
// Module Name: snake_wrapper
// Project Name: Snake_Game
// Target Devices: BASYS3 by Digilent
// Tool Versions: 2015.3
// Description: This project is aimed to present the famous Snake Game using Verilog HDL and VGA as output to the screen. 
//              The module snake_wrapper is designed to integrate all thye bits of the project.
//               
// 
// Dependencies: -random_num_gen.v
//               -VGA_module.v
//               -Score_counter(wrapper_new.v)
//               -Snake_control.v
//               -Master_state_machine.v
//               -Navigation_state_machine.v
// 
// Revision:20/11/2016
// Additional Comments: HOW TO PLAY
/////////////////////// To start the game, Right, Left, Down or Up button should be pressed.
/////////////////////// In order to choose timed game mode, SW15 should be set in the ON position.
/////////////////////// Once the game is finished, use SW0 to restart the game (do not forget to 
/////////////////////// set bach to the OFF position once the start screen appears).
///////////////////////
/////////////////////// CONTROLS
/////////////////////// UPWARDS   - BTNU
/////////////////////// DOWNWARDS - BTND
/////////////////////// RIGHT     - BTNR
/////////////////////// LEFT      - BTNL
/////////////////////// RESTART   - SW0
/////////////////////// TIMED MODE- SW15
/////////////////////// 
/////////////////////// TIMED GAME MODE
/////////////////////// In this mode player has 60 seconds to eat 10 targets.
/////////////////////// If the time is up, game is over.
/////////////////////// To exit this game mode, set the SW15 switch to the OFF position
/////////////////////// when in the starting screen.
// 
//////////////////////////////////////////////////////////////////////////////////


module snake_wrapper(
            input CLK,
            input RESET,
            input BTNU,
            input BTND,
            input BTNL,
            input BTNR,
            input GAME_IN,
            output [11:0] COLOUR_OUT,
            output HS,
            output VS,
            output [3:0] SEG_SELECT_OUT,
            output [7:0] DEC_OUT
             
    );
    // Connections between the modules
    wire [1:0] MSM_STATE;
    wire SCORE_WIN;
    
    wire [1:0] NAV_STATE;
    
    wire [7:0] TARGET_ADDR_H;
    wire [6:0] TARGET_ADDR_V;
    
    wire TARGET_REACHED;
    
    wire [11:0] COLOUR_OUTS;
    
    wire [9:0] ADDRH;
    wire [8:0] ADDRV;
    
    wire Timed_Mode;
    
    wire LOST;
    
    wire WIN;
    
    
    //Instantiating Master state machine
    Master_state_machine Master(
                            .BTNU(BTNU),
                            .BTND(BTND),
                            .BTNR(BTNR),
                            .BTNL(BTNL),
                            .CLK(CLK),
                            .RESET(RESET),
                            .SCORE_WIN(SCORE_WIN),
                            .LOST(LOST),
                            .WIN(WIN),
                            .MSM_STATE(MSM_STATE)
                            );
                            
    // Instantiating navigation system                        
    Navigation_state_machine Navigation(
                            .BTNU(BTNU),
                            .BTND(BTND),
                            .BTNR(BTNR),
                            .BTNL(BTNL),
                            .CLK(CLK),
                            .RESET(RESET),
                            .NAV_STATE(NAV_STATE)
                            );
    
    // Instantiating random number generator
    random_num_gen Target(
                            .RESET(RESET),
                            .CLK(CLK),
                            .TARGET_REACHED(TARGET_REACHED),
                            .TARGET_ADDR_H(TARGET_ADDR_H),
                            .TARGET_ADDR_V(TARGET_ADDR_V)
                            );
    
    // Instantiating Score counter                        
    Score_counter Score(
                            .RESET(RESET),
                            .CLK(CLK),
                            .TARGET_REACHED(TARGET_REACHED),
                            .SEG_SELECT_OUT(SEG_SELECT_OUT),
                            .DEC_OUT(DEC_OUT),
                            .SCORE_WIN(SCORE_WIN),
                            .Timed_Mode(Timed_Mode),
                            .MSM_STATE(MSM_STATE),
                            .LOST(LOST),
                            .WIN(WIN)
                            );
    
    // Instantiating VGA_control                        
    VGA_module VGA(
                            .COLOUR_IN(COLOUR_OUTS),
                            .CLK(CLK),
                            .HS(HS),
                            .VS(VS),
                            .ADDRH(ADDRH),
                            .ADDRY(ADDRV),
                            .COLOUR_OUT(COLOUR_OUT)
                            );
    
    // Instantiating Snake control                        
    Snake_control Control(
                            .MSM_STATE(MSM_STATE),
                            .NAV_STATE(NAV_STATE),
                            .TARGET_ADDR_H(TARGET_ADDR_H),
                            .TARGET_ADDR_V(TARGET_ADDR_V),
                            .ADDRH(ADDRH),
                            .ADDRY(ADDRV),
                            .COLOUR_OUT(COLOUR_OUTS),
                            .TARGET_REACHED(TARGET_REACHED),
                            .CLK(CLK),
                            .GAME_IN(GAME_IN),
                            .Timed_Mode(Timed_Mode),
                            .LOST(LOST),
                            .WIN(WIN),
                            .RESET(RESET)
                            );
                            
endmodule




