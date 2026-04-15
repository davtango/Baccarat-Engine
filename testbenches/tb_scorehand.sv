// Created 23/01/2026
/* This testbench covers the scorehand module. It will test both regular addition cases 
and confirm that the bit overflow cases (sums > 10) is treated appropriately. */

// TODO: 

module tb_scorehand();

// Your testbench goes here. Make sure your tests exercise the entire design
// in the .sv file.  Note that in our tests the simulator will exit after
// 10,000 ticks (equivalent to "initial #10000 $finish();").

    logic [3:0] TB_card1, TB_card2, TB_card3;
    logic [3:0] TB_total;

    scorehand scorehand(.card1(TB_card1), .card2(TB_card2), .card3(TB_card3), .total(TB_total));

    initial begin

        // TC# = test case number

        // TC1: Regular addition: 1 + 2 + 3 = 6
        TB_card1 = 4'b0001;
        TB_card2 = 4'b0010;
        TB_card3 = 4'b0011;
        #10;
        assert(TB_total == 4'b0110)
        else $error("TC1 failed. TB_total = %0d ", TB_total);

        // TC2: Addition with 3 kings: 13 + 13 + 13 = 0
        TB_card1 = 4'b1101;
        TB_card2 = 4'b1101;
        TB_card3 = 4'b1101;
        #10;
        assert(TB_total == 4'b0000)
        else $error("TC2 failed. TB_total = %0d ", TB_total);

        // TC3: Addition with 3 9s: 9 + 9 + 9 = 27. 
        // Expected result is 7 under proper modding
        // If there was as bit-width mismatch, probable result is 3 or 4'b0011. Card_valuer module is faulty.
        TB_card1 = 4'b1001;
        TB_card2 = 4'b1001;
        TB_card3 = 4'b1001;
        #10;
        assert(TB_total == 4'b0111)
        else $error("TC3 failed. TB_total = %0d", TB_total);

        $display("End of testbench. If no errors asserted, all test cases are successful");
    end


endmodule
