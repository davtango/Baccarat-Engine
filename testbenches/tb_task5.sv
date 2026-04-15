`define INITIAL_STATE 4'b0000
`define DEAL_CARD_2 4'b0001
`define DEAL_CARD_3 4'b0010
`define DEAL_CARD_4 4'b0011
`define COMPARE_SCORE_FOR_DEAL 4'b0100
`define GAME_OVER 4'b0101
`define DEAL_PLAYER_3RD 4'b0110
`define DEAL_BANKER_3RD 4'b0111
`define COMPARE_PLAYER_3RD 4'b1000

`timescale 1 ns / 1 ps

module tb_task5();

    logic TB_CLOCK_50;
    logic [3:0] TB_KEY;
    logic [9:0] TB_LEDR;
    logic [6:0] TB_HEX5;
    logic [6:0] TB_HEX4;
    logic [6:0] TB_HEX3;
    logic [6:0] TB_HEX2;
    logic [6:0] TB_HEX1;
    logic [6:0] TB_HEX0;

    logic [3:0] TB_pcard1;
    logic [3:0] TB_newcard; // newcard from dealcard.sv
    logic TB_dp_slow_clock;
    logic TB_dp_resetb;
    logic TB_dp_dealcard_CLOCK_50;


    task5 task5(.CLOCK_50(TB_CLOCK_50), .KEY(TB_KEY), .LEDR(TB_LEDR),
                .HEX5(TB_HEX5), .HEX4(TB_HEX4), .HEX3(TB_HEX3),
                .HEX2(TB_HEX2), .HEX1(TB_HEX1), .HEX0(TB_HEX0));


    logic [3:0] TB_current_state;
    assign TB_current_state = task5.sm.current_state;

    assign TB_pcard1 = task5.dp.pcard1;
    assign TB_dp_slow_clock = task5.dp.slow_clock;

    assign TB_dp_dealcard_CLOCK_50 = task5.dp.dealcard.clock;
    assign TB_newcard = task5.dp.dealcard.new_card;
    assign TB_dp_resetb = task5.dp.dealcard.resetb;

    //Toggle the clock forever (this is given by the last bit in the TB_KEY)
    initial begin
        TB_KEY = 4'b0000;
        TB_CLOCK_50 = 0;
        forever begin
            TB_KEY[0] = 1; // TB_KEY[0] = 0; 
            #10;
            TB_KEY[0] = 0;
            #10;
        end
    end


    initial begin

        //TEST #1 - Player gets a card and Banker gets a card ------------------------------------------------

        //Reset the game (we used negedge because the button is low when pressed)
        @(negedge TB_KEY[0]) TB_KEY[3] = 1'b0; 
        TB_CLOCK_50 = 0;
        #1;
        TB_CLOCK_50 = 1;
        @(posedge TB_KEY[0]);
        @(negedge TB_KEY[0]) TB_KEY[3] = 1'b1;

        //Cycle the fast clock 4 times to get a 5 from deal hand
        repeat (4) begin
            TB_CLOCK_50 = 0;
            #1;
            TB_CLOCK_50 = 1;
            #1;
        end

        //Wait until state transition and confirm card + state matches
        @(posedge TB_KEY[0]) #1;

        assert( TB_current_state == `DEAL_CARD_2)
            else $error( "Test #1 Failed. Current state is not DEAL_CARD_2. State is %b", TB_current_state); 
        assert( TB_HEX0 == 7'b001_0010) //5
            else $error( "Test #2 Failed. Output is not 5. Output is %b", TB_HEX0); 
        assert( TB_LEDR[3:0] == 5) //score is 5
            else $error( "Test #3 Failed. Output is not 5. Output is %b", TB_LEDR[3:0]); 
        assert ( task5.dp.dealcard.new_card == 5)
            else $error( "Test #A Failed. newcard is not 5. newcard is %b", task5.dp.dealcard.new_card); 
        assert ( task5.sm.slow_clock == 1)
            else $error( "Test #B Failed. newcard is not 5. newcard is %b", task5.sm.slow_clock); 

        //Cycle the fast clock 2 times to get a 7 from deal hand
        repeat (2) begin
            TB_CLOCK_50 = 0;
            #1;
            TB_CLOCK_50 = 1;
            #1;
        end

        @(posedge TB_KEY[0]) #1;
        assert( TB_current_state == `DEAL_CARD_3)
            else $error( "Test #4 Failed. Current state is not DEAL_CARD_3. State is %b", TB_current_state); 
        assert( TB_HEX3 == 7'b111_1000) //7
            else $error( "Test #5 Failed. Output is not 7. Output is %b", TB_HEX3); 
        assert( TB_LEDR[7:4] == 7) //score is 7
            else $error( "Test #6 Failed. Output is not 7. Output is %b", TB_LEDR[7:4]); 

        //Cycle the fast clock 3 times to get a 10 from deal hand
        repeat (3) begin
            TB_CLOCK_50 = 0;
            #1;
            TB_CLOCK_50 = 1;
            #1;
        end

        @(posedge TB_KEY[0]) #1;
        assert( TB_current_state == `DEAL_CARD_4)
            else $error( "Test #7 Failed. Current state is not DEAL_CARD_4. State is %b", TB_current_state); 
        assert( TB_HEX1 == 7'b100_0000) //10
            else $error( "Test #8 Failed. Output is not 10. Output is %b", TB_HEX1); 
        assert( TB_LEDR[3:0] == 5) //score is still 5
            else $error( "Test #9 Failed. Output is not 5. Output is %b", TB_LEDR[3:0]);

        //Cycle the fast clock 1 times to get a J from deal hand
        repeat (1) begin
            TB_CLOCK_50 = 0;
            #1;
            TB_CLOCK_50 = 1;
            #1;
        end
        
        //Check we have cycled into the next state
        @(posedge TB_KEY[0]) #1;
        assert( TB_current_state == `COMPARE_SCORE_FOR_DEAL)
            else $error( "Test #10 Failed. Current state is not COMPARE_SCORE_FOR_DEAL. State is %b", TB_current_state); 
        assert( TB_HEX4 == 7'b110_0001) //J
            else $error( "Test #11 Failed. Output is not 7. Output is %b", TB_HEX4); 
        assert( TB_LEDR[7:4] == 7) //score is still 7
            else $error( "Test #12 Failed. Output is not 7. Output is %b", TB_LEDR[7:4]);


        //Cycle the fast clock 3 times to get an A from deal hand
        repeat (3) begin
            TB_CLOCK_50 = 0;
            #1;
            TB_CLOCK_50 = 1;
            #1;
        end

        //Players score is a 5 (5 + 0) so they get a third card
        @(posedge TB_KEY[0]) #1;
        assert( TB_current_state == `DEAL_PLAYER_3RD)
            else $error( "Test #9 Failed. Current state is not DEAL_PLAYER_3RD. State is %b", TB_current_state); 

        //Check we are in the correct state and that outputs are correct
        @(posedge TB_KEY[0]) #1;
        assert( TB_current_state == `COMPARE_PLAYER_3RD)
            else $error( "Test #13 Failed. Current state is not COMPARE_PLAYER_3RD. State is %b", TB_current_state); 
        assert( TB_HEX2 == 7'b000_1000) //A
            else $error( "Test #14 Failed. Current output is not TB_HEX2. Output is %b", TB_HEX2); 
        assert( TB_LEDR[3:0] == 6) //score is 5 + 1
            else $error( "Test #15 Failed. Output is not 6. Output is %b", TB_LEDR[3:0]);


        //Bankers score is a 7 (7 + 0) so they do not get a third card, Player wins
        @(posedge TB_KEY[0]) #1;
        assert( TB_current_state == `GAME_OVER)
            else $error( "Test #16 Failed. Current state is not GAME_OVER. State is %b", TB_current_state); 
        assert( TB_LEDR[8] == 0 && TB_LEDR[9] == 1)
            else $error( "Test #17 Failed. Current output is not Banker wins. Output is %b", TB_LEDR[9:8]); 

        //Check that we stay in game over
        @(posedge TB_KEY[0]) #1;
        assert( TB_current_state == `GAME_OVER)
            else $error( "Test #18 Failed. Current state is not GAME_OVER. State is %b", TB_current_state); 
        

        //TEST #2 - BANKER AND PLAYER BOTH GET A THIRD CARD --------------------------------------------------

        //Reset the game (we used negedge because the button is low when pressed)
        @(negedge TB_KEY[0]) TB_KEY[3] = 1'b0; 
        TB_CLOCK_50 = 0;
        #1;
        TB_CLOCK_50 = 1;
        @(posedge TB_KEY[0]);
        @(negedge TB_KEY[0]) TB_KEY[3] = 1'b1;
        

        assert( TB_LEDR == 0) //check all of the outupt LEDs are 0
            else $error( "Test #19 Failed. Output is not 5. Output is %b", TB_LEDR); 


        //Cycle the fast clock 1 times to get a 2 from deal hand
        repeat (1) begin
            TB_CLOCK_50 = 0;
            #1;
            TB_CLOCK_50 = 1;
            #1;
        end

        //Wait until state transition and confirm card + state matches
        @(posedge TB_KEY[0]) #1;

        assert( TB_current_state == `DEAL_CARD_2)
            else $error( "Test #20 Failed. Current state is not DEAL_CARD_2. State is %b", TB_current_state); 
        assert( TB_HEX0 == 7'b010_0100) //2
            else $error( "Test #21 Failed. Output is not 2. Output is %b", TB_HEX0); 
        assert( TB_LEDR[3:0] == 2) //player score is 2
            else $error( "Test #22 Failed. Output is not 2. Output is %b", TB_LEDR[3:0]); 
        assert( TB_LEDR[7:4] == 0) //banker score is 0
            else $error( "Test #23 Failed. Output is not 0. Output is %b", TB_LEDR[7:4]);

        //DEAL_CARD_2 -> DEAL_CARD_3
        @(posedge TB_KEY[0]) #1;
        assert( TB_current_state == `DEAL_CARD_3)
            else $error( "Test #24 Failed. Current state is not DEAL_CARD_3. State is %b", TB_current_state); 
        assert( TB_HEX3 == 7'b010_0100) //2
            else $error( "Test #25 Failed. Output is not 2. Output is %b", TB_HEX3); 
        assert( TB_LEDR[3:0] == 2) //player score is 2
            else $error( "Test #26 Failed. Output is not 2. Output is %b", TB_LEDR[3:0]); 
        assert( TB_LEDR[7:4] == 2) //banker score is 2
            else $error( "Test #27 Failed. Output is not 2. Output is %b", TB_LEDR[7:4]);

        //DEAL_CARD_3 -> DEAL_CARD_4
        @(posedge TB_KEY[0]) #1;

        assert( TB_current_state == `DEAL_CARD_4)
            else $error( "Test #28 Failed. Current state is not DEAL_CARD_4. State is %b", TB_current_state); 
        assert( TB_HEX1 == 7'b010_0100) //2
            else $error( "Test #29 Failed. Output is not 2. Output is %b", TB_HEX4); 
        assert( TB_LEDR[3:0] == 4) //player score is 2
            else $error( "Test #30 Failed. Output is not 2. Output is %b", TB_LEDR[3:0]); 
        assert( TB_LEDR[7:4] == 2) //banker score is 2
            else $error( "Test #31 Failed. Output is not 2. Output is %b", TB_LEDR[7:4]);


        //DEAL_CARD_4 -> COMPARE_SCORE_FOR_DEAL
        @(posedge TB_KEY[0]) #1;

        assert( TB_current_state == `COMPARE_SCORE_FOR_DEAL)
            else $error( "Test #28 Failed. Current state is not DEAL_CARD_4. State is %b", TB_current_state); 
        assert( TB_HEX4 == 7'b010_0100) //2
            else $error( "Test #29 Failed. Output is not 4. Output is %b", TB_HEX1); 
        assert( TB_LEDR[3:0] == 4) //player score is 4
            else $error( "Test #30 Failed. Output is not 4. Output is %b", TB_LEDR[3:0]); 
        assert( TB_LEDR[7:4] == 4) //banker score is 4
            else $error( "Test #31 Failed. Output is not 4. Output is %b", TB_LEDR[7:4]);

        
        //COMPARE_SCORE_FOR_DEAL -> DEAL_PLAYER_3RD
        @(posedge TB_KEY[0]) #1;

        assert( TB_current_state == `DEAL_PLAYER_3RD)
            else $error( "Test Failed. Current state is not DEAL_PLAYER_3RD. State is %b", TB_current_state); 
        assert( TB_HEX1 == 7'b010_0100) //2
            else $error( "Test Failed. Output is not 4. Output is %b", TB_HEX1); 
        assert( TB_LEDR[3:0] == 4) //player score is 4
            else $error( "Test Failed. Output is not 4. Output is %b", TB_LEDR[3:0]); 
        assert( TB_LEDR[7:4] == 4) //banker score is 4
            else $error( "Test Failed. Output is not 4. Output is %b", TB_LEDR[7:4]);

        //DEAL_PLAYER_3RD -> COMPARE_PLAYER_3RD
        @(posedge TB_KEY[0]) #1;

        assert( TB_current_state == `COMPARE_PLAYER_3RD)
            else $error( "Test Failed. Current state is not DEAL_PLAYER_3RD. State is %b", TB_current_state); 
        assert( TB_HEX2 == 7'b010_0100) //2
            else $error( "Test Failed. Output is not 4. Output is %b", TB_HEX1); 
        assert( TB_LEDR[3:0] == 6) //player score is 6
            else $error( "Test Failed. Output is not 4. Output is %b", TB_LEDR[3:0]); 
        assert( TB_LEDR[7:4] == 4) //banker score is 4
            else $error( "Test Failed. Output is not 4. Output is %b", TB_LEDR[7:4]);


        //COMPARE_PLAYER_3RD -> DEAL_BANKER_3RD
        @(posedge TB_KEY[0]) #1;

        assert( TB_current_state == `DEAL_BANKER_3RD)
            else $error( "Test Failed. Current state is not DEAL_PLAYER_3RD. State is %b", TB_current_state); 
        assert( TB_HEX5 == 7'b111_1111) //the value is empty
            else $error( "Test Failed. Output is not 4. Output is %b", TB_HEX1); 
        assert( TB_LEDR[3:0] == 6) //player score is 6
            else $error( "Test Failed. Output is not 4. Output is %b", TB_LEDR[3:0]); 
        assert( TB_LEDR[7:4] == 4) //banker score is 4
            else $error( "Test Failed. Output is not 4. Output is %b", TB_LEDR[7:4]);


        //DEAL_BANKER_3RD -> GAME_OVER
        @(posedge TB_KEY[0]) #1;

        assert( TB_current_state == `GAME_OVER)
            else $error( "Test Failed. Current state is not DEAL_PLAYER_3RD. State is %b", TB_current_state); 
        assert( TB_HEX5 == 7'b010_0100) //2
            else $error( "Test Failed. Output is not 4. Output is %b", TB_HEX1); 
        assert( TB_LEDR[3:0] == 6) //player score is 6
            else $error( "Test Failed. Output is not 4. Output is %b", TB_LEDR[3:0]); 
        assert( TB_LEDR[7:4] == 6) //banker score is 6
            else $error( "Test Failed. Output is not 4. Output is %b", TB_LEDR[7:4]);
        assert( TB_LEDR[9:8] == 2'b11) //Game is a tie
            else $error( "Test Failed. Output is not 4. Output is %b", TB_LEDR[9:8]);

        
        //TEST #3 - BANKER ONLY GETS A THIRD CARD --------------------------------------------------

        //Reset the game (we used negedge because the button is low when pressed)
        @(negedge TB_KEY[0]) TB_KEY[3] = 1'b0; 
        TB_CLOCK_50 = 0;
        #1;
        TB_CLOCK_50 = 1;
        @(posedge TB_KEY[0]);
        @(negedge TB_KEY[0]) TB_KEY[3] = 1'b1;
        

        assert( TB_LEDR == 0) //check all of the outupt LEDs are 0
            else $error( "Test Failed. Output LEDs not reset. Output is %b", TB_LEDR); 


        //Cycle the fast clock 2 times to get a 3 from deal hand
        repeat (2) begin
            TB_CLOCK_50 = 0;
            #1;
            TB_CLOCK_50 = 1;
            #1;
        end

        //INITIAL_STATE -> DEAL_CARD_2
        @(posedge TB_KEY[0]) #1;

        assert( TB_current_state == `DEAL_CARD_2)
            else $error( "Test Failed. Current state is not DEAL_CARD_2. State is %b", TB_current_state);
        assert( TB_HEX0 == 7'b011_0000) //3
            else $error( "Test Failed. Output is not 3. Output is %b", TB_HEX1); 
        assert( TB_LEDR[3:0] == 3) //player score is 3
            else $error( "Test Failed. Output is not 3. Output is %b", TB_LEDR[3:0]); 
        assert( TB_LEDR[7:4] == 0) //banker score is 0
            else $error( "Test Failed. Output is not 0. Output is %b", TB_LEDR[7:4]);
        assert( TB_LEDR[9:8] == 2'b00) //Game winner not declared
            else $error( "Test Failed. Winner not declared. Output is %b", TB_LEDR[9:8]);


        //DEAL_CARD_2 -> DEAL_CARD_3
        @(posedge TB_KEY[0]) #1;

        assert( TB_current_state == `DEAL_CARD_3)
            else $error( "Test Failed. Current state is not DEAL_CARD_3. State is %b", TB_current_state);
        assert( TB_HEX3 == 7'b011_0000) //3
            else $error( "Test Failed. Output is not 3. Output is %b", TB_HEX1); 
        assert( TB_LEDR[3:0] == 3) //player score is 3
            else $error( "Test Failed. Output is not 3. Output is %b", TB_LEDR[3:0]); 
        assert( TB_LEDR[7:4] == 3) //banker score is 3
            else $error( "Test Failed. Output is not 0. Output is %b", TB_LEDR[7:4]);
        assert( TB_LEDR[9:8] == 2'b00) //Game winner not declared
            else $error( "Test Failed. Winner not declared. Output is %b", TB_LEDR[9:8]);    

        //DEAL_CARD_3 -> DEAL_CARD_4
        @(posedge TB_KEY[0]) #1;

        assert( TB_current_state == `DEAL_CARD_4)
            else $error( "Test Failed. Current state is not DEAL_CARD_4. State is %b", TB_current_state);
        assert( TB_HEX1 == 7'b011_0000) //3
            else $error( "Test Failed. Output is not 3. Output is %b", TB_HEX1); 
        assert( TB_LEDR[3:0] == 6) //player score is 6
            else $error( "Test Failed. Output is not 3. Output is %b", TB_LEDR[3:0]); 
        assert( TB_LEDR[7:4] == 3) //banker score is 3
            else $error( "Test Failed. Output is not 0. Output is %b", TB_LEDR[7:4]);
        assert( TB_LEDR[9:8] == 2'b00) //Game winner not declared
            else $error( "Test Failed. Winner not declared. Output is %b", TB_LEDR[9:8]);    

        //Deal out a 1 from the deal hand by resetting the clock
        TB_KEY[3] = 1'b0; 
        TB_CLOCK_50 = 0;
        #1;
        TB_CLOCK_50 = 1;
        #1;
        TB_KEY[3] = 1'b1;


        //DEAL_CARD_4 -> COMPARE_SCORE_FOR_DEAL
        @(posedge TB_KEY[0]) #1;
        assert( TB_current_state == `COMPARE_SCORE_FOR_DEAL)
            else $error( "Test Failed. Current state is not DEAL_CARD_4. State is %b", TB_current_state);
        assert( TB_HEX4 == 7'b000_1000) //Ace dealt to the banker
            else $error( "Test Failed. Output is not 3. Output is %b", TB_HEX1); 
        assert( TB_LEDR[3:0] == 6) //player score is 6
            else $error( "Test Failed. Output is not 3. Output is %b", TB_LEDR[3:0]); 
        assert( TB_LEDR[7:4] == 4) //banker score is 4
            else $error( "Test Failed. Output is not 0. Output is %b", TB_LEDR[7:4]);
        assert( TB_LEDR[9:8] == 2'b00) //Game winner not declared
            else $error( "Test Failed. Winner not declared. Output is %b", TB_LEDR[9:8]); 


        //COMPARE_SCORE_FOR_DEAL -> DEAL_BANKER_3RD
        @(posedge TB_KEY[0]) #1;
        assert( TB_current_state == `DEAL_BANKER_3RD)
            else $error( "Test Failed. Current state is not DEAL_CARD_4. State is %b", TB_current_state);
        assert( TB_HEX5 == 7'b111_1111) //Nothing dealt yet
            else $error( "Test Failed. Output is not 3. Output is %b", TB_HEX1); 
        assert( TB_LEDR[3:0] == 6) //player score is 6
            else $error( "Test Failed. Output is not 3. Output is %b", TB_LEDR[3:0]); 
        assert( TB_LEDR[7:4] == 4) //banker score is 4
            else $error( "Test Failed. Output is not 0. Output is %b", TB_LEDR[7:4]);
        assert( TB_LEDR[9:8] == 2'b00) //Game winner not declared
            else $error( "Test Failed. Winner not declared. Output is %b", TB_LEDR[9:8]); 

        //DEAL_BANKER_3RD -> GAME_OVER
        @(posedge TB_KEY[0]) #1;
        assert( TB_current_state == `GAME_OVER)
            else $error( "Test Failed. Current state is not DEAL_CARD_4. State is %b", TB_current_state);
        assert( TB_HEX5 == 7'b000_1000) //Ace dealt to the banker again
            else $error( "Test Failed. Output is not 3. Output is %b", TB_HEX1); 
        assert( TB_LEDR[3:0] == 6) //player score is 6
            else $error( "Test Failed. Output is not 3. Output is %b", TB_LEDR[3:0]); 
        assert( TB_LEDR[7:4] == 5) //banker score is 5
            else $error( "Test Failed. Output is not 0. Output is %b", TB_LEDR[7:4]);
        assert( TB_LEDR[9:8] == 2'b01) //Game winner is player
            else $error( "Test Failed. Winner is player. Output is %b", TB_LEDR[9:8]);
            

        //TEST #4 - No one gets a card --------------------------------------------------


        //Reset the game (we used negedge because the button is low when pressed)
        @(negedge TB_KEY[0]) TB_KEY[3] = 1'b0; 
        TB_CLOCK_50 = 0;
        #1;
        TB_CLOCK_50 = 1;
        @(posedge TB_KEY[0]);
        @(negedge TB_KEY[0]) TB_KEY[3] = 1'b1;
        

        assert( TB_LEDR == 0) //check all of the outupt LEDs are 0
            else $error( "Test #19 Failed. Output is not 5. Output is %b", TB_LEDR); 


        //Cycle the fast clock 2 times to get a 3 from deal hand
        repeat (2) begin
            TB_CLOCK_50 = 0;
            #1;
            TB_CLOCK_50 = 1;
            #1;
        end


        //INITIAL_STATE -> DEAL_CARD_2
        @(posedge TB_KEY[0]) #1;
        assert( TB_current_state == `DEAL_CARD_2)
            else $error( "Test Failed. Current state is not DEAL_CARD_2. State is %b", TB_current_state);
        assert( TB_HEX0 == 7'b011_0000) //3
            else $error( "Test Failed. Output is not 3. Output is %b", TB_HEX1); 
        assert( TB_LEDR[3:0] == 3) 
            else $error( "Test Failed. Output is not 3. Output is %b", TB_LEDR[3:0]); 
        assert( TB_LEDR[7:4] == 0)
            else $error( "Test Failed. Output is not 0. Output is %b", TB_LEDR[7:4]);
        assert( TB_LEDR[9:8] == 2'b00) //Game winner is undeclared
            else $error( "Test Failed. Winner is player. Output is %b", TB_LEDR[9:8]);

        //DEAL_CARD_2 -> DEAL_CARD_3
        @(posedge TB_KEY[0]) #1;
        assert( TB_current_state == `DEAL_CARD_3)
            else $error( "Test Failed. Current state is not DEAL_CARD_3. State is %b", TB_current_state);
        assert( TB_HEX3 == 7'b011_0000) //3
            else $error( "Test Failed. Output is not 3. Output is %b", TB_HEX1); 
        assert( TB_LEDR[3:0] == 3) 
            else $error( "Test Failed. Output is not 3. Output is %b", TB_LEDR[3:0]); 
        assert( TB_LEDR[7:4] == 3)
            else $error( "Test Failed. Output is not 0. Output is %b", TB_LEDR[7:4]);
        assert( TB_LEDR[9:8] == 2'b00) //Game winner is undeclared
            else $error( "Test Failed. Winner is player. Output is %b", TB_LEDR[9:8]);

        //DEAL_CARD_3 -> DEAL_CARD_4
        @(posedge TB_KEY[0]) #1;
        assert( TB_current_state == `DEAL_CARD_4)
            else $error( "Test Failed. Current state is not DEAL_CARD_3. State is %b", TB_current_state);
        assert( TB_HEX1 == 7'b011_0000) //3
            else $error( "Test Failed. Output is not 3. Output is %b", TB_HEX1); 
        assert( TB_LEDR[3:0] == 6) 
            else $error( "Test Failed. Output is not 3. Output is %b", TB_LEDR[3:0]); 
        assert( TB_LEDR[7:4] == 3)
            else $error( "Test Failed. Output is not 0. Output is %b", TB_LEDR[7:4]);
        assert( TB_LEDR[9:8] == 2'b00) //Game winner is undeclared
            else $error( "Test Failed. Winner is player. Output is %b", TB_LEDR[9:8]);

        //DEAL_CARD_4 -> COMPARE_SCORE_FOR_DEAL   
        @(posedge TB_KEY[0]) #1;
        assert( TB_current_state == `COMPARE_SCORE_FOR_DEAL)
            else $error( "Test Failed. Current state is not DEAL_CARD_3. State is %b", TB_current_state);
        assert( TB_HEX4 == 7'b011_0000) //3
            else $error( "Test Failed. Output is not 3. Output is %b", TB_HEX1); 
        assert( TB_LEDR[3:0] == 6) 
            else $error( "Test Failed. Output is not 3. Output is %b", TB_LEDR[3:0]); 
        assert( TB_LEDR[7:4] == 6)
            else $error( "Test Failed. Output is not 0. Output is %b", TB_LEDR[7:4]);
        assert( TB_LEDR[9:8] == 2'b00) //Game winner is undeclared
            else $error( "Test Failed. Winner is player. Output is %b", TB_LEDR[9:8]);

        @(posedge TB_KEY[0]) #1;
        assert( TB_current_state == `GAME_OVER)
            else $error( "Test Failed. Current state is not DEAL_CARD_3. State is %b", TB_current_state);
        assert( TB_HEX1 == 7'b011_0000) //3
            else $error( "Test Failed. Output is not 3. Output is %b", TB_HEX1); 
        assert( TB_LEDR[3:0] == 6) 
            else $error( "Test Failed. Output is not 3. Output is %b", TB_LEDR[3:0]); 
        assert( TB_LEDR[7:4] == 6)
            else $error( "Test Failed. Output is not 0. Output is %b", TB_LEDR[7:4]);
        assert( TB_LEDR[9:8] == 2'b11) //Game is a tie
            else $error( "Test Failed. Game is a tie. Output is %b", TB_LEDR[9:8]);


        $display( "Testbench complete. If no errors displayed, all test cases passed!");
        $finish; 
    end


endmodule
