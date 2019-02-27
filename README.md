# Snake-Game
*Basic Snake Game developed in Verilog for BASYS3 board*

**Description:** 

This project is aimed to present the famous Snake Game using Verilog HDL and VGA as output to the screen. 
               
**Dependencies:** 
- random_num_gen.v
- VGA_module.v
- Score_counter(wrapper_new.v)
- Snake_control.v
- Master_state_machine.v
- Navigation_state_machine.v
 
**HOW TO PLAY**

To start the game, Right, Left, Down or Up button should be pressed. In order to choose timed game mode, SW15 should be set in the ON position. Once the game is finished, use SW0 to restart the game (do not forget to set bach to the OFF position once the start screen appears).

**CONTROLS**

* UPWARDS   - BTNU
* DOWNWARDS - BTND
* RIGHT     - BTNR
* LEFT      - BTNL
* RESTART   - SW0
* TIMED MODE- SW15

**TIMED GAME MODE**

In this mode player has 60 seconds to eat 10 targets. If the time is up, game is over. To exit this game mode, set the SW15 switch to the OFF position when in the starting screen.
