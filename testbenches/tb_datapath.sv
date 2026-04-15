`timescale 1 ns / 1 ps // ns, not in ps to accomodate fast_clock frequency

module tb_datapath();

// Your testbench goes here. Make sure your tests exercise the entire design
// in the .sv file.  Note that in our tests the simulator will exit after
// 10,000 ticks (equivalent to "initial #10000 $finish();").

    // Instantiation of TB logic

    logic TB_slow_clock, TB_fast_clock, TB_resetb, TB_load_pcard1, TB_load_pcard2, TB_load_pcard3, TB_load_dcard1, TB_load_dcard2, TB_load_dcard3;
    logic [3:0] TB_pcard3_out, TB_pscore_out, TB_dscore_out; // Outputs
    logic [6:0] TB_HEX5, TB_HEX4, TB_HEX3, TB_HEX2, TB_HEX1, TB_HEX0; // Outputs

    // Instantiation of Datapath Module

    datapath datapath( .slow_clock(TB_slow_clock), .fast_clock(TB_fast_clock), .resetb(TB_resetb), 
                       .load_pcard1(TB_load_pcard1), .load_pcard2(TB_load_pcard2), .load_pcard3(TB_load_pcard3),
                       .load_dcard1(TB_load_dcard1), .load_dcard2(TB_load_dcard2), .load_dcard3(TB_load_dcard3),
                       .pcard3_out(TB_pcard3_out), .pscore_out(TB_pscore_out), .dscore_out(TB_dscore_out),
                       .HEX5(TB_HEX5), .HEX4(TB_HEX4), .HEX3(TB_HEX3), .HEX2(TB_HEX2), .HEX1(TB_HEX1), .HEX0(TB_HEX0));

    // Instantiation of TB internal signals

    logic [3:0] TB_new_card, TB_pcard1, TB_pcard2, TB_pcard3, TB_dcard1, TB_dcard2, TB_dcard3;

    assign TB_new_card = datapath.new_card;
    assign TB_pcard1 = datapath.pcard1;
    assign TB_pcard2 = datapath.pcard2;
    assign TB_pcard3 = datapath.pcard3;
    assign TB_dcard1 = datapath.dcard1;
    assign TB_dcard2 = datapath.dcard2; 
    assign TB_dcard3 = datapath.dcard3; 

    // Simulate the fast clock for dealcard.sv 
    // 50 MHz = 20 nanosecond period. Or, 10 ns on and 10 ns off

    initial begin
        forever begin
            TB_fast_clock = 1'b0;
            #10;
            TB_fast_clock = 1'b1;
            #10;
        end
    end 

    // Main Initial Block for Datapath TB

    initial begin
        // Initialize all input signals to 0 or OFF. 
        TB_slow_clock = 1'b0;
        TB_resetb = 1'b1; // Reset is low sync., so set to 1'b1
        TB_load_pcard1 = 1'b0; 
        TB_load_pcard2 = 1'b0;
        TB_load_pcard3 = 1'b0;
        TB_load_dcard1 = 1'b0; 
        TB_load_dcard2 = 1'b0; 
        TB_load_dcard3 = 1'b0;
        #50;

        // Reset Datapath
        TB_resetb = 1'b0;
        #10;
        TB_slow_clock = 1'b1; 
        #10;
        TB_resetb = 1'b1;
        TB_slow_clock = 1'b0;
        #10;

        // TC1: Check that the reset works properly

        assert(TB_pscore_out == 0 && TB_dscore_out == 0)
            else $error("Reset not initializing all cards to 0. pscore_out == %0d, dscore_out == %0d", TB_pscore_out, TB_dscore_out);

        // TC2: Check that each register is loaded properly and is received by either the player's or dealer's respective scorehand
        //      We will view the internal signal for that card, the output on the 7 seg display for the respective reg, and the output scorehand
        //      If a card is loaded, it is guaranteed to be non-zero. Zeroes indicate a loading failure.
        //      Modular testing has been done for 7seg & scorehand modules. Therefore, this TB will not test for them -
        //      however their values will be printed onto the monitor for manual viewing if needed

        // TC2-A: Testing Player's Hand

        // First Player Card

        TB_load_pcard1 = 1'b1;
        #10;
        TB_slow_clock = 1'b1;
        #10;
        TB_load_pcard1 = 1'b0;
        TB_slow_clock = 1'b0;
        #10;

        assert( TB_pcard1 == 0)
            $display( "First Player Card Failed to Load");
            else $display( "First Player Card loaded. pcard1 = %0d, HEX0 = %b, pscore = %0d", TB_pcard1, TB_HEX0, TB_pscore_out); 

        // Second Player Card

        TB_load_pcard2 = 1'b1;
        #10;
        TB_slow_clock = 1'b1;
        #10;
        TB_load_pcard2 = 1'b0;
        TB_slow_clock = 1'b0;
        #10;

        assert( TB_pcard2 == 0)
            $display( "Second Player Card failed to load");
            else $display( "Second Player Card loaded. pcard2 = %0d, HEX1 = %b, pscore = %0d", TB_pcard2, TB_HEX1, TB_pscore_out);
        
        // Third Player Card

        TB_load_pcard3 = 1'b1;
        #10;
        TB_slow_clock = 1'b1;
        #10;
        TB_load_pcard3 = 1'b0;
        TB_slow_clock = 1'b0;
        #10;

        assert( TB_pcard3 == 0)
            $display( "Third Player Card failed to load");
            else $display( "Third Player Card loaded. pcard3 = %0d, HEX2 = %b, pscore = %0d", TB_pcard3, TB_HEX2, TB_pscore_out); 

        // TC2-B: Testing Dealer's Hand

        // First Dealer Card

        TB_load_dcard1 = 1'b1;
        #10;
        TB_slow_clock = 1'b1;
        #10;
        TB_load_dcard1 = 1'b0;
        TB_slow_clock = 1'b0;
        #10;

        assert( TB_dcard1 == 0)
            $display( "First Dealer Card failed to load");
            else $display( "First Dealer Card loaded. dcard1 = %0d, HEX3 = %b, dscore = %0d", TB_dcard1, TB_HEX3, TB_dscore_out);
        
        // Second Dealer Card 

        TB_load_dcard2 = 1'b1;
        #10;
        TB_slow_clock = 1'b1;
        #10;
        TB_load_dcard2 = 1'b0;
        TB_slow_clock = 1'b0;
        #10;

        assert( TB_dcard2 == 0)
            $display( "Second Dealer Card failed to load");
            else $display( "Second Dealer Card loaded. dcard2 = %0d, HEX4 = %b, dscore = %0d", TB_dcard2, TB_HEX4, TB_dscore_out);

        // Third Dealer Card

        TB_load_dcard3 = 1'b1;
        #10;
        TB_slow_clock = 1'b1;
        #10;
        TB_load_dcard3 = 1'b0;
        TB_slow_clock = 1'b0;
        #10;

        assert( TB_dcard3 == 0)
            $display( "Second Dealer Card failed to load");
            else $display( "Second Dealer Card loaded. dcard3 = %0d, HEX5 = %b, dscore = %0d", TB_dcard3, TB_HEX5, TB_dscore_out);

        $display( "All test cases complete.");

    end
endmodule
