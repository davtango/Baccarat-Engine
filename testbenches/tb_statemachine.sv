// Ported state definitions from statemachine.sv
// If this compiles after/before statemachine.sv, these definitions will be redefined. 
// TODO REMINDER: Keep state definitions the same. If changes are made to statemachine.sv, update this one as well.

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

module tb_statemachine();

// Your testbench goes here. Make sure your tests exercise the entire design
// in the .sv file.  Note that in our tests the simulator will exit after
// 10,000 ticks (equivalent to "initial #10000 $finish();").

// Testbench was produced and used on 26/01/2026. Entire test bench lasts ~3000 ns or 3000 ticks. 

    logic TB_slow_clock, TB_resetb;
    logic [3:0] TB_dscore, TB_pscore, TB_pcard3;
    logic TB_load_pcard1, TB_load_pcard2, TB_load_pcard3, TB_load_dcard1, TB_load_dcard2, TB_load_dcard3, TB_player_win_light, TB_dealer_win_light;
    
    statemachine statemachine(.slow_clock(TB_slow_clock), .resetb(TB_resetb), .dscore(TB_dscore), .pscore(TB_pscore), .pcard3(TB_pcard3),
                              .load_pcard1(TB_load_pcard1), .load_pcard2(TB_load_pcard2), .load_pcard3(TB_load_pcard3),
                              .load_dcard1(TB_load_dcard1), .load_dcard2(TB_load_dcard2), .load_dcard3(TB_load_dcard3),
                              .player_win_light(TB_player_win_light), .dealer_win_light(TB_dealer_win_light));
    
    logic [3:0] TB_current_state;
    assign TB_current_state = statemachine.current_state;

    // Toggles TB_slow_clock with period 20 ns. Operates concurrently with primary initial block containing test cases.

    initial begin
        forever begin
            TB_slow_clock = 1'b0;
            #10;
            TB_slow_clock = 1'b1;
            #10;
        end
    end

    // Main initial Block for Statemachine TB

    /* LEGEND for Test Cases (TC)
    - TC1-5 checks for reset functionality and correctness of state transitions
    - TC6 checks that the right signals are asserted in their respective states
    - TC7 checks that the output LEDs are asserted correctly given the right state (`GAME_OVER) and pscore/dscore results. 
    - TC8 checks that the `GAME_OVER state remains on the `GAME_OVER state regardless of continous clocking. 
    */

    /* Additional notes:
    - TC-letter indicates sub-case for a given test-case
    - The general gist behind this test bench is to run the state machine several times and observe the correct behaviour/functionality
    - Each assertion is followed by an error with some text indicating the issue on the ModelSim command window for debugging purpsoes
    */

    initial begin

        // Initialize all values to 0 at first slow_clock negedge 

        @(negedge TB_slow_clock) begin
            TB_pscore = 4'b0000;
            TB_dscore = 4'b0000;
            TB_pcard3 = 4'b0000;
        end

        // TC1: Checking that reset works and sends us to RESET STATE
        // Recall that resetb is active low-sync.

        @(negedge TB_slow_clock) TB_resetb = 1'b0;
        @(posedge TB_slow_clock);
        @(negedge TB_slow_clock) TB_resetb = 1'b1;

        assert( TB_current_state == `INITIAL_STATE)
            else $error( "TC1 Failed. Reset failed. Current state is not INITIAL STATE. State is %b", TB_current_state);
        
        // TC2: Initial Card Dealing Sequence Check
        // INITIAL_STATE -> DC2 -> DC3 -> DC4 -> COMPARE_SCORE_FOR_DEAl

        // TC2-A: IS -> DC2 

        @(posedge TB_slow_clock) #5;
        assert( TB_current_state == `DEAL_CARD_2) 
            else $error( "TC2-A Failed. Current state is not DEAL_CARD_2. State is %b", TB_current_state);

        // TC2-B: DC2 -> DC3

        @(posedge TB_slow_clock) #5;
        assert( TB_current_state == `DEAL_CARD_3) 
            else $error( "TC2-B Failed. Current state is not DEAL_CARD_3. State is %b", TB_current_state); 

        // TC2-C: DC3 -> DC4 

        @(posedge TB_slow_clock) #5;
        assert( TB_current_state == `DEAL_CARD_4)
            else $error( "TC2-C failed. Current state is not DEAL_CARD_4. State is %b", TB_current_state);
        
        // TC2-D: DC4 -> COMPARE_SCORE_FOR_DEAL

        @(posedge TB_slow_clock) #5;
        assert( TB_current_state == `COMPARE_SCORE_FOR_DEAL)
            else $error( "TC2-D failed. Current state is not COMPARE_SCORE_FOR_DEAL. State is %b", TB_current_state);

        // TC3: Natural Check
        // Expected outcome: Resulting state should be GAME_OVER

        // TC3-A: Player's hand is an 8. Dealer's hand is a 3. 

        @(negedge TB_slow_clock) begin 
            TB_pscore = 4'b1000;
            TB_dscore = 4'b0011;
        end

        @(posedge TB_slow_clock) #5;
        assert( TB_current_state == `GAME_OVER)
            else $error( "TC3-A failed. Current state is not GAME_OVER. State is %b", TB_current_state);

        // RESET & RETURN TO COMPARE_SCORE_FOR_DEAL
        @(negedge TB_slow_clock) TB_resetb = 1'b0;
        @(posedge TB_slow_clock);
        @(negedge TB_slow_clock) TB_resetb = 1'b1;
        repeat (4) @(posedge TB_slow_clock);

        // TC3-B: Player's hand is a 4. Dealer's hand is a 9.

        @(negedge TB_slow_clock) begin
            TB_pscore = 4'b0100;
            TB_dscore = 4'b1001;
        end

        @(posedge TB_slow_clock) #5;
        assert( TB_current_state == `GAME_OVER)
            else $error ("TC3-B failed. Current state is not GAME_OVER. State is %b", TB_current_state);

        // RESET & RETURN TO COMPARE_SCORE_FOR_DEAL
        @(negedge TB_slow_clock) TB_resetb = 1'b0;
        @(posedge TB_slow_clock);
        @(negedge TB_slow_clock) TB_resetb = 1'b1;
        repeat (4) @(posedge TB_slow_clock);
        
        // TC3-C: Player's hand is an 8. Dealer's hand is a 9.

        @(negedge TB_slow_clock) begin 
            TB_pscore = 4'b1000; 
            TB_dscore = 4'b1001;
        end

        @(posedge TB_slow_clock) #5;
        assert( TB_current_state == `GAME_OVER)
            else $error( "TC3-C failed. Current state is not GAME_OVER. State is %b", TB_current_state);

        // RESET & RETURN TO COMPARE_SCORE_FOR_DEAL
        @(negedge TB_slow_clock) TB_resetb = 1'b0;
        @(posedge TB_slow_clock);
        @(negedge TB_slow_clock) TB_resetb = 1'b1;
        repeat (4) @(posedge TB_slow_clock);

        // TC3-D: Player's hand is a 9. Dealer's hand is a 9. 

        @(negedge TB_slow_clock) begin 
            TB_pscore = 4'b1001;
            TB_dscore = 4'b1001;
        end

        @(posedge TB_slow_clock) #5; 
        assert( TB_current_state == `GAME_OVER) 
            else $error( "TC3-D failed. Current state is not GAME_OVER. State is %b", TB_current_state); 

        // RESET & RETURN TO COMPARE_SCORE_FOR_DEAL
        @(negedge TB_slow_clock) TB_resetb = 1'b0;
        @(posedge TB_slow_clock);
        @(negedge TB_slow_clock) TB_resetb = 1'b1;
        repeat (4) @(posedge TB_slow_clock);
        
        // TC4: Player does not get a third card. All routes check
        // TC4-A - No one gets a third card. TC4-B - Dealer gets a third card. 
        // For TC4-A, we check that the state transition to GAME_OVER is met.
        // For TC4-B, we check that the state transition goes to DEAL_BANKER_3RD, then GAME_OVER

        // TC4-A1: Player has a 6. Dealer has a score of 7. No one gets a third card. 

        @(negedge TB_slow_clock) begin 
            TB_pscore = 4'b0110;
            TB_dscore = 4'b0111; 
        end

        @(posedge TB_slow_clock) #5;
        assert( TB_current_state == `GAME_OVER)
            else $error( "TC4-A1 failed. Current state is not GAME_OVER. State is %b", TB_current_state); 

        // RESET & RETURN TO COMPARE_SCORE_FOR_DEAL
        @(negedge TB_slow_clock) TB_resetb = 1'b0;
        @(posedge TB_slow_clock);
        @(negedge TB_slow_clock) TB_resetb = 1'b1;
        repeat (4) @(posedge TB_slow_clock);
        
        // TC4-B1: Player has a 6. Dealer has a score of 5

        @(negedge TB_slow_clock) begin 
            TB_pscore = 4'b0110;
            TB_dscore = 4'b0101;
        end

        @(posedge TB_slow_clock) #5;
        assert( TB_current_state == `DEAL_BANKER_3RD) 
            else $error( "TC4-B1 failed. Current state is not DEAL_BANKER_3RD. State is %b", TB_current_state);
        
        @(posedge TB_slow_clock) #5;
        assert( TB_current_state == `GAME_OVER)
            else $error( "TC4-B1 failed. Current state is not GAME_OVER. State is %b", TB_current_state);

        // RESET & RETURN TO COMPARE_SCORE_FOR_DEAL
        @(negedge TB_slow_clock) TB_resetb = 1'b0;
        @(posedge TB_slow_clock);
        @(negedge TB_slow_clock) TB_resetb = 1'b1;
        repeat (4) @(posedge TB_slow_clock);

        // TC4-B2: Player has a 7. Dealer has a score of 3. 

        @(negedge TB_slow_clock) begin 
            TB_pscore = 4'b0111;
            TB_dscore = 4'b0011;
        end

        @(posedge TB_slow_clock) #5;
        assert( TB_current_state == `DEAL_BANKER_3RD) 
            else $error( "TC4-B1 failed. Current state is not DEAL_BANKER_3RD. State is %b", TB_current_state);
        
        @(posedge TB_slow_clock) #5;
        assert( TB_current_state == `GAME_OVER)
            else $error( "TC4-B1 failed. Current state is not GAME_OVER. State is %b", TB_current_state);

        // RESET & RETURN TO COMPARE_SCORE_FOR_DEAL
        @(negedge TB_slow_clock) TB_resetb = 1'b0;
        @(posedge TB_slow_clock);
        @(negedge TB_slow_clock) TB_resetb = 1'b1;
        repeat (4) @(posedge TB_slow_clock);

        // TC5: Player gets a third card.
        // TC5-a, TC5-else will check their respective conditions where banker does not get third card 
        // TC5-b, TC5-c, TC5-d, TC5-e, and TC5-f will check their respective conditions where banker gets third card or not

        // TC5-a1: Player score is 0. Dealer score is 7. DEAL_PLAYER_3RD -> COMPARE_PLAYER_3RD -> GAME_OVER
        // No 3rd card for dealer

        @(negedge TB_slow_clock) begin 
            TB_pscore = 4'b0000;
            TB_dscore = 4'b0111;
        end

        @(posedge TB_slow_clock) #5;
        assert( TB_current_state == `DEAL_PLAYER_3RD)
            else $error( "TC5-a1 failed. Current state is not DEAL_PLAYER_3RD. State is %b", TB_current_state); 
        
        @(posedge TB_slow_clock) #5; 
        assert( TB_current_state == `COMPARE_PLAYER_3RD)
            else $error("TC5-a1 failed. Current state is not COMPARE_PLAYER_3RD. State is %b", TB_current_state);

        @(posedge TB_slow_clock) #5; 
        assert( TB_current_state == `GAME_OVER)
            else $error("TC5-a1 failed. Current state is not GAME_OVER. State is %b", TB_current_state);
        
        // RESET & RETURN TO COMPARE_SCORE_FOR_DEAL
        @(negedge TB_slow_clock) TB_resetb = 1'b0;
        @(posedge TB_slow_clock);
        @(negedge TB_slow_clock) TB_resetb = 1'b1;
        repeat (4) @(posedge TB_slow_clock);

        // TC5-b1. Player score is 1. Dealer score is 6. Player's third card is 6. Banker gets 3rd card. 

        @(negedge TB_slow_clock) begin 
            TB_pscore = 4'b0001;
            TB_dscore = 4'b0110; 
        end

        @(posedge TB_slow_clock) #5; 
        assert( TB_current_state == `DEAL_PLAYER_3RD) 
            else $error("TC5-b1 failed. Current state is not DEAL_PLAYER_3RD. State is %b", TB_current_state); 
        
        @(posedge TB_slow_clock) #5;
        assert( TB_current_state == `COMPARE_PLAYER_3RD)
            else $error("TC5-b1 failed. Current state is not COMPARE_PLAYER_3RD. State is %b", TB_current_state);

        @(negedge TB_slow_clock) TB_pcard3 = 4'b0110; 
        
        @(posedge TB_slow_clock) #5;
        assert( TB_current_state == `DEAL_BANKER_3RD)
            else $error("TC5-b1 failed. Current state is not DEAL_BANKER_3RD. State is %b", TB_current_state); 

        @(posedge TB_slow_clock) #5; 
        assert(TB_current_state == `GAME_OVER)
            else $error("TC5-b1 failed. Current state is not GAME_OVER. State is %b", TB_current_state);
        
        // RESET & RETURN TO COMPARE_SCORE_FOR_DEAL
        @(negedge TB_slow_clock) TB_resetb = 1'b0;
        @(posedge TB_slow_clock);
        @(negedge TB_slow_clock) TB_resetb = 1'b1;
        repeat (4) @(posedge TB_slow_clock);

        // TC5-b2. Player score is 1. Dealer score is 6. Player's third card is 3. Banker does not get 3rd card. 

        @(negedge TB_slow_clock) begin 
            TB_pscore = 4'b0001;
            TB_dscore = 4'b0110; 
        end

        @(posedge TB_slow_clock) #5; 
        assert( TB_current_state == `DEAL_PLAYER_3RD) 
            else $error("TC5-b2 failed. Current state is not DEAL_PLAYER_3RD. State is %b", TB_current_state); 
        
        @(posedge TB_slow_clock) #5;
        assert( TB_current_state == `COMPARE_PLAYER_3RD)
            else $error("TC5-b2 failed. Current state is not COMPARE_PLAYER_3RD. State is %b", TB_current_state);

        @(negedge TB_slow_clock) TB_pcard3 = 4'b0011; 

        @(posedge TB_slow_clock) #5; 
        assert(TB_current_state == `GAME_OVER)
            else $error("TC5-b2 failed. Current state is not GAME_OVER. State is %b", TB_current_state);
        
        // RESET & RETURN TO COMPARE_SCORE_FOR_DEAL
        @(negedge TB_slow_clock) TB_resetb = 1'b0;
        @(posedge TB_slow_clock);
        @(negedge TB_slow_clock) TB_resetb = 1'b1;
        repeat (4) @(posedge TB_slow_clock);

        // TC5-c1. Player score is 2. Dealer's score is 5. Player's third card is 4. Banker gets 3rd card. 

        @(negedge TB_slow_clock) begin 
            TB_pscore = 4'b0010;
            TB_dscore = 4'b0101; 
        end

        @(posedge TB_slow_clock) #5; 
        assert( TB_current_state == `DEAL_PLAYER_3RD) 
            else $error("TC5-c1 failed. Current state is not DEAL_PLAYER_3RD. State is %b", TB_current_state); 
        
        @(posedge TB_slow_clock) #5;
        assert( TB_current_state == `COMPARE_PLAYER_3RD)
            else $error("TC5-c1 failed. Current state is not COMPARE_PLAYER_3RD. State is %b", TB_current_state);

        @(negedge TB_slow_clock) TB_pcard3 = 4'b0100; 
        
        @(posedge TB_slow_clock) #5;
        assert( TB_current_state == `DEAL_BANKER_3RD)
            else $error("TC5-c1 failed. Current state is not DEAL_BANKER_3RD. State is %b", TB_current_state); 

        @(posedge TB_slow_clock) #5; 
        assert(TB_current_state == `GAME_OVER)
            else $error("TC5-c1 failed. Current state is not GAME_OVER. State is %b", TB_current_state);
        
        // RESET & RETURN TO COMPARE_SCORE_FOR_DEAL
        @(negedge TB_slow_clock) TB_resetb = 1'b0;
        @(posedge TB_slow_clock);
        @(negedge TB_slow_clock) TB_resetb = 1'b1;
        repeat (4) @(posedge TB_slow_clock);

        // TC5-c2. Player score is 2. Dealer's score is 5. Player's third card is 2. Banker does not get 3rd card. 

        @(negedge TB_slow_clock) begin 
            TB_pscore = 4'b0010;
            TB_dscore = 4'b0101; 
        end

        @(posedge TB_slow_clock) #5; 
        assert( TB_current_state == `DEAL_PLAYER_3RD) 
            else $error("TC5-c2 failed. Current state is not DEAL_PLAYER_3RD. State is %b", TB_current_state); 
        
        @(posedge TB_slow_clock) #5;
        assert( TB_current_state == `COMPARE_PLAYER_3RD)
            else $error("TC5-c2 failed. Current state is not COMPARE_PLAYER_3RD. State is %b", TB_current_state);

        @(negedge TB_slow_clock) TB_pcard3 = 4'b0010; 

        @(posedge TB_slow_clock) #5; 
        assert(TB_current_state == `GAME_OVER)
            else $error("TC5-c2 failed. Current state is not GAME_OVER. State is %b", TB_current_state);
        
        // RESET & RETURN TO COMPARE_SCORE_FOR_DEAL
        @(negedge TB_slow_clock) TB_resetb = 1'b0;
        @(posedge TB_slow_clock);
        @(negedge TB_slow_clock) TB_resetb = 1'b1;
        repeat (4) @(posedge TB_slow_clock);

        // TC5-d1. Player score is 3. Dealer's score is 4. Player's 3rd card is 2. Dealer gets 3rd card. 

        @(negedge TB_slow_clock) begin 
            TB_pscore = 4'b0011;
            TB_dscore = 4'b0100; 
        end

        @(posedge TB_slow_clock) #5; 
        assert( TB_current_state == `DEAL_PLAYER_3RD) 
            else $error("TC5-d1 failed. Current state is not DEAL_PLAYER_3RD. State is %b", TB_current_state); 
        
        @(posedge TB_slow_clock) #5;
        assert( TB_current_state == `COMPARE_PLAYER_3RD)
            else $error("TC5-d1 failed. Current state is not COMPARE_PLAYER_3RD. State is %b", TB_current_state);

        @(negedge TB_slow_clock) TB_pcard3 = 4'b0010; 
        
        @(posedge TB_slow_clock) #5;
        assert( TB_current_state == `DEAL_BANKER_3RD)
            else $error("TC5-d1 failed. Current state is not DEAL_BANKER_3RD. State is %b", TB_current_state); 

        @(posedge TB_slow_clock) #5; 
        assert(TB_current_state == `GAME_OVER)
            else $error("TC5-d1 failed. Current state is not GAME_OVER. State is %b", TB_current_state);
        
        // RESET & RETURN TO COMPARE_SCORE_FOR_DEAL
        @(negedge TB_slow_clock) TB_resetb = 1'b0;
        @(posedge TB_slow_clock);
        @(negedge TB_slow_clock) TB_resetb = 1'b1;
        repeat (4) @(posedge TB_slow_clock);

        // TC5-d2. Player score is 3. Dealer score is 4. Player's 3rd card is an ace. Dealer does not get third card.

        @(negedge TB_slow_clock) begin 
            TB_pscore = 4'b0011;
            TB_dscore = 4'b0100; 
        end

        @(posedge TB_slow_clock) #5; 
        assert( TB_current_state == `DEAL_PLAYER_3RD) 
            else $error("TC5-d2 failed. Current state is not DEAL_PLAYER_3RD. State is %b", TB_current_state); 
        
        @(posedge TB_slow_clock) #5;
        assert( TB_current_state == `COMPARE_PLAYER_3RD)
            else $error("TC5-d2 failed. Current state is not COMPARE_PLAYER_3RD. State is %b", TB_current_state);

        @(negedge TB_slow_clock) TB_pcard3 = 4'b0001; 

        @(posedge TB_slow_clock) #5; 
        assert(TB_current_state == `GAME_OVER)
            else $error("TC5-d2 failed. Current state is not GAME_OVER. State is %b", TB_current_state);
        
        // RESET & RETURN TO COMPARE_SCORE_FOR_DEAL
        @(negedge TB_slow_clock) TB_resetb = 1'b0;
        @(posedge TB_slow_clock);
        @(negedge TB_slow_clock) TB_resetb = 1'b1;
        repeat (4) @(posedge TB_slow_clock);

        // TC5-e1. Player score is 4. Dealer's score is 3. Players 3rd card is a 2. Dealer gets a 3rd card. 

        @(negedge TB_slow_clock) begin 
            TB_pscore = 4'b0100;
            TB_dscore = 4'b0011; 
        end

        @(posedge TB_slow_clock) #5; 
        assert( TB_current_state == `DEAL_PLAYER_3RD) 
            else $error("TC5-e1 failed. Current state is not DEAL_PLAYER_3RD. State is %b", TB_current_state); 
        
        @(posedge TB_slow_clock) #5;
        assert( TB_current_state == `COMPARE_PLAYER_3RD)
            else $error("TC5-e1 failed. Current state is not COMPARE_PLAYER_3RD. State is %b", TB_current_state);

        @(negedge TB_slow_clock) TB_pcard3 = 4'b0010; 
        
        @(posedge TB_slow_clock) #5;
        assert( TB_current_state == `DEAL_BANKER_3RD)
            else $error("TC5-e1 failed. Current state is not DEAL_BANKER_3RD. State is %b", TB_current_state); 

        @(posedge TB_slow_clock) #5; 
        assert(TB_current_state == `GAME_OVER)
            else $error("TC5-e1 failed. Current state is not GAME_OVER. State is %b", TB_current_state);
        
        // RESET & RETURN TO COMPARE_SCORE_FOR_DEAL
        @(negedge TB_slow_clock) TB_resetb = 1'b0;
        @(posedge TB_slow_clock);
        @(negedge TB_slow_clock) TB_resetb = 1'b1;
        repeat (4) @(posedge TB_slow_clock);

        // TC5-e2. Player score is 4. Dealer's score is 3. Player's 3rd card is an 8. Dealer does not get 3rd card.

        @(negedge TB_slow_clock) begin 
            TB_pscore = 4'b0100;
            TB_dscore = 4'b0011; 
        end

        @(posedge TB_slow_clock) #5; 
        assert( TB_current_state == `DEAL_PLAYER_3RD) 
            else $error("TC5-e2 failed. Current state is not DEAL_PLAYER_3RD. State is %b", TB_current_state); 
        
        @(posedge TB_slow_clock) #5;
        assert( TB_current_state == `COMPARE_PLAYER_3RD)
            else $error("TC5-e2 failed. Current state is not COMPARE_PLAYER_3RD. State is %b", TB_current_state);

        @(negedge TB_slow_clock) TB_pcard3 = 4'b1000; 

        @(posedge TB_slow_clock) #5; 
        assert(TB_current_state == `GAME_OVER)
            else $error("TC5-e2 failed. Current state is not GAME_OVER. State is %b", TB_current_state);
        
        // RESET & RETURN TO COMPARE_SCORE_FOR_DEAL
        @(negedge TB_slow_clock) TB_resetb = 1'b0;
        @(posedge TB_slow_clock);
        @(negedge TB_slow_clock) TB_resetb = 1'b1;
        repeat (4) @(posedge TB_slow_clock);

        // TC5-f1. Player score is 5. Dealer's score is 0. Dealer gets a 3rd card. 

        @(negedge TB_slow_clock) begin 
            TB_pscore = 4'b0101;
            TB_dscore = 4'b0000;
        end

        @(posedge TB_slow_clock) #5; 
        assert( TB_current_state == `DEAL_PLAYER_3RD) 
            else $error("TC5-f1 failed. Current state is not DEAL_PLAYER_3RD. State is %b", TB_current_state);  

        @(posedge TB_slow_clock) #5;
        assert( TB_current_state == `COMPARE_PLAYER_3RD)
            else $error("TC5-f1 failed. Current state is not COMPARE_PLAYER_3RD. State is %b", TB_current_state);
        
        @(posedge TB_slow_clock) #5;
        assert( TB_current_state == `DEAL_BANKER_3RD)
            else $error("TC5-f1 failed. Current state is not DEAL_BANKER_3RD. State is %b", TB_current_state); 

        @(posedge TB_slow_clock) #5; 
        assert(TB_current_state == `GAME_OVER)
            else $error("TC5-f1 failed. Current state is not GAME_OVER. State is %b", TB_current_state);

        // END OF STATE TRANSITION TEST CASES

        // RESET & RETURN TO INITIAL_STATE
        @(negedge TB_slow_clock) TB_resetb = 1'b0;
        @(posedge TB_slow_clock);
        @(negedge TB_slow_clock) TB_resetb = 1'b1;

        // TC6: Check that the asserted signals load_pcard & load_dcard are correct at their respective states.
        
        // TC6-A: Check that the load_pcard_1 is ON at INITIAL_STATE and all others are off

        assert( TB_load_pcard1 == 1'b1 && TB_load_pcard2 == 1'b0 && TB_load_pcard3 == 1'b0 && TB_load_dcard1 == 1'b0 && TB_load_dcard2 == 1'b0 
        && TB_load_dcard3 == 1'b0)
              else begin 
                $error( "TC6-A failed. Signals are not asserted correctly at INITIAL_STATE");
                $display( "load_pcard1 = %b, load_pcard2 = %b, load_pcard3 = %b, load_dcard1 = %b, load_dcard2 = %b, load_dcard3 = %b", 
                TB_load_pcard1, TB_load_pcard2, TB_load_pcard3, TB_load_dcard1, TB_load_dcard2, TB_load_dcard3);
              end

        // TC6-B: Check that the load_dcard_1 is ON at DC2 and all others are off

        @(posedge TB_slow_clock) #5;
        assert( TB_load_pcard1 == 1'b0 && TB_load_pcard2 == 1'b0 && TB_load_pcard3 == 1'b0 && TB_load_dcard1 == 1'b1 && TB_load_dcard2 == 1'b0 
        && TB_load_dcard3 == 1'b0)
              else begin 
                $error( "TC6-B failed. Signals are not asserted correctly at DEAL_CARD_2");
                $display( "load_pcard1 = %b, load_pcard2 = %b, load_pcard3 = %b, load_dcard1 = %b, load_dcard2 = %b, load_dcard3 = %b", 
                TB_load_pcard1, TB_load_pcard2, TB_load_pcard3, TB_load_dcard1, TB_load_dcard2, TB_load_dcard3);
              end

        // TC6-C: Check that the load_pcard_2 is ON at DC3 and all others are off

        @(posedge TB_slow_clock) #5;
        assert( TB_load_pcard1 == 1'b0 && TB_load_pcard2 == 1'b1 && TB_load_pcard3 == 1'b0 && TB_load_dcard1 == 1'b0 && TB_load_dcard2 == 1'b0 
        && TB_load_dcard3 == 1'b0)
              else begin 
                $error( "TC6-C failed. Signals are not asserted correctly at DEAL_CARD_3");
                $display( "load_pcard1 = %b, load_pcard2 = %b, load_pcard3 = %b, load_dcard1 = %b, load_dcard2 = %b, load_dcard3 = %b", 
                TB_load_pcard1, TB_load_pcard2, TB_load_pcard3, TB_load_dcard1, TB_load_dcard2, TB_load_dcard3);
              end

        // TC6-D: Check that the load_dcard_2 is ON at DC4 and all others are off

        @(posedge TB_slow_clock) #5;
        assert( TB_load_pcard1 == 1'b0 && TB_load_pcard2 == 1'b0 && TB_load_pcard3 == 1'b0 && TB_load_dcard1 == 1'b0 && TB_load_dcard2 == 1'b1 
        && TB_load_dcard3 == 1'b0)
              else begin 
                $error( "TC6-D failed. Signals are not asserted correctly at DEAL_CARD_4");
                $display( "load_pcard1 = %b, load_pcard2 = %b, load_pcard3 = %b, load_dcard1 = %b, load_dcard2 = %b, load_dcard3 = %b", 
                TB_load_pcard1, TB_load_pcard2, TB_load_pcard3, TB_load_dcard1, TB_load_dcard2, TB_load_dcard3);
              end    
        
        // TC6-E: Check that all load_pcard and load_dcard are OFF at COMPARE_SCORE_FOR_DEAL

        @(posedge TB_slow_clock) #5;
        assert( TB_load_pcard1 == 1'b0 && TB_load_pcard2 == 1'b0 && TB_load_pcard3 == 1'b0 && TB_load_dcard1 == 1'b0 && TB_load_dcard2 == 1'b0 
        && TB_load_dcard3 == 1'b0)
              else begin 
                $error( "TC6-E failed. Signals are not asserted correctly at COMPARE_SCORE_FOR_DEAL");
                $display( "load_pcard1 = %b, load_pcard2 = %b, load_pcard3 = %b, load_dcard1 = %b, load_dcard2 = %b, load_dcard3 = %b", 
                TB_load_pcard1, TB_load_pcard2, TB_load_pcard3, TB_load_dcard1, TB_load_dcard2, TB_load_dcard3);
              end    

        // TC6-F: Check that load_pcard3 is asserted correctly at DEAL_PLAYER_3RD

        @(negedge TB_slow_clock) begin 
            TB_pscore = 4'b0011;
            TB_dscore = 4'b0100;
            TB_pcard3 = 4'b0000;
        end

        @(posedge TB_slow_clock) #5;
        assert( TB_load_pcard1 == 1'b0 && TB_load_pcard2 == 1'b0 && TB_load_pcard3 == 1'b1 && TB_load_dcard1 == 1'b0 && TB_load_dcard2 == 1'b0 
        && TB_load_dcard3 == 1'b0)
              else begin 
                $error( "TC6-F failed. Signals are not asserted correctly at DEAL_PLAYER_3RD");
                $display( "load_pcard1 = %b, load_pcard2 = %b, load_pcard3 = %b, load_dcard1 = %b, load_dcard2 = %b, load_dcard3 = %b", 
                TB_load_pcard1, TB_load_pcard2, TB_load_pcard3, TB_load_dcard1, TB_load_dcard2, TB_load_dcard3);
              end    

        // TC6-G: Check that all load_pcard and load_dcard are OFF at COMPARE_PLAYER_3RD

        @(posedge TB_slow_clock) #5;
        assert( TB_load_pcard1 == 1'b0 && TB_load_pcard2 == 1'b0 && TB_load_pcard3 == 1'b0 && TB_load_dcard1 == 1'b0 && TB_load_dcard2 == 1'b0 
        && TB_load_dcard3 == 1'b0)
              else begin 
                $error( "TC6-G failed. Signals are not asserted correctly at COMPARE_PLAYER_3RD");
                $display( "load_pcard1 = %b, load_pcard2 = %b, load_pcard3 = %b, load_dcard1 = %b, load_dcard2 = %b, load_dcard3 = %b", 
                TB_load_pcard1, TB_load_pcard2, TB_load_pcard3, TB_load_dcard1, TB_load_dcard2, TB_load_dcard3);
              end    

        // TC6-H: Check that load_dcard3 is asserted at DEAL_BANKER_3RD

        @(negedge TB_slow_clock) begin 
            TB_pscore = 4'b0110;
            TB_dscore = 4'b0100;
            TB_pcard3 = 4'b0011;
        end

        @(posedge TB_slow_clock) #5;
        assert( TB_load_pcard1 == 1'b0 && TB_load_pcard2 == 1'b0 && TB_load_pcard3 == 1'b0 && TB_load_dcard1 == 1'b0 && TB_load_dcard2 == 1'b0 
        && TB_load_dcard3 == 1'b1)
              else begin 
                $error( "TC6-H failed. Signals are not asserted correctly at DEAL_BANKER_3RD");
                $display( "load_pcard1 = %b, load_pcard2 = %b, load_pcard3 = %b, load_dcard1 = %b, load_dcard2 = %b, load_dcard3 = %b", 
                TB_load_pcard1, TB_load_pcard2, TB_load_pcard3, TB_load_dcard1, TB_load_dcard2, TB_load_dcard3);
              end

        // TC6-I: Check that all load_pcard and load_dcard are OFF at GAME_OVER

        @(posedge TB_slow_clock) #5;
        assert( TB_load_pcard1 == 1'b0 && TB_load_pcard2 == 1'b0 && TB_load_pcard3 == 1'b0 && TB_load_dcard1 == 1'b0 && TB_load_dcard2 == 1'b0 
        && TB_load_dcard3 == 1'b0)
              else begin 
                $error( "TC6-I failed. Signals are not asserted correctly at GAME_OVER");
                $display( "load_pcard1 = %b, load_pcard2 = %b, load_pcard3 = %b, load_dcard1 = %b, load_dcard2 = %b, load_dcard3 = %b", 
                TB_load_pcard1, TB_load_pcard2, TB_load_pcard3, TB_load_dcard1, TB_load_dcard2, TB_load_dcard3);
              end
        
        // END OF ASSERTION TEST CASES

        // TC7: Checks output LEDR[9:8] at GAME_OVER state; player_win_light and dealer_win_light state machine outputs

        // TC7-A: Player wins. player_win_light is ON. dealer_win_light is OFF.

        @(negedge TB_slow_clock) begin 
            TB_pscore = 4'b1001;
            TB_dscore = 4'b0010;
            #5;
        end

        assert( TB_player_win_light == 1'b1 && TB_dealer_win_light == 1'b0)
            else $error( "TC7-A failed. Player wins but LEDs do not correspond. player_win_light = %b, dealer_win_light = %b", TB_player_win_light,
            TB_dealer_win_light);

        // TC7-B: Dealer wins. player_win_light is oFF. dealer_win_light is ON.

        @(negedge TB_slow_clock) begin 
            TB_pscore = 4'b0010;
            TB_dscore = 4'b1001;
            #5;
        end

        assert( TB_player_win_light == 1'b0 && TB_dealer_win_light == 1'b1) 
            else $error( "TC7-B failed. Dealer wins but LEDs do not correspond. player_win_light = %b, dealer_win_light =%b", TB_player_win_light,
            TB_dealer_win_light);
        
        // TC7-C: Tie. player_win_light is ON. dealer_win_light is ON.

        @(negedge TB_slow_clock) begin 
            TB_pscore = 4'b1001;
            TB_dscore = 4'b1001;
            #5;
        end

        assert( TB_player_win_light == 1'b1 && TB_dealer_win_light == 1'b1)
            else $error( "TC7-C failed. Tie, but LEDs do not correspond. player_win_light = %b, dealer_win_light = %b", TB_player_win_light,
            TB_dealer_win_light);

        // TC8: Checks that the state machine does nothing (stays in the same state) after game over.

        repeat (7) @(posedge TB_slow_clock);
        #5;

        assert( TB_current_state == `GAME_OVER)
            else $error( "TC8 failed. State has transitioned elsewhere despite game ending. State is %b", TB_current_state);

        #10;

        $display( "Testbench complete. If no errors displayed, all test cases passed!");
        $finish; 
    end
endmodule
