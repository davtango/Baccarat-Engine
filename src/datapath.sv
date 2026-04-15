module datapath(input logic slow_clock, input logic fast_clock, input logic resetb,
                input logic load_pcard1, input logic load_pcard2, input logic load_pcard3,
                input logic load_dcard1, input logic load_dcard2, input logic load_dcard3,
                output logic [3:0] pcard3_out,
                output logic [3:0] pscore_out, output logic [3:0] dscore_out,
                output logic [6:0] HEX5, output logic [6:0] HEX4, output logic [6:0] HEX3,
                output logic [6:0] HEX2, output logic [6:0] HEX1, output logic [6:0] HEX0);

    logic [3:0] new_card, pcard1, pcard2, pcard3, dcard1, dcard2, dcard3;

    // Instantiation of the dealcard block, uses fast clock (50 MHz)

    dealcard dealcard( .clock(fast_clock), .resetb(resetb), .new_card(new_card));

    // Instantiations for pcards, uses slow clock (KEY0)

    reg4 reg4_pcard1( .new_card(new_card), .load_card(load_pcard1), .resetb(resetb), .slow_clock(slow_clock), .card(pcard1));
    reg4 reg4_pcard2( .new_card(new_card), .load_card(load_pcard2), .resetb(resetb), .slow_clock(slow_clock), .card(pcard2));
    reg4 reg4_pcard3( .new_card(new_card), .load_card(load_pcard3), .resetb(resetb), .slow_clock(slow_clock), .card(pcard3));

    // Instantiations for dcards, uses slow clock (KEY0)

    reg4 reg4_dcard1( .new_card(new_card), .load_card(load_dcard1), .resetb(resetb), .slow_clock(slow_clock), .card(dcard1));
    reg4 reg4_dcard2( .new_card(new_card), .load_card(load_dcard2), .resetb(resetb), .slow_clock(slow_clock), .card(dcard2));
    reg4 reg4_dcard3( .new_card(new_card), .load_card(load_dcard3), .resetb(resetb), .slow_clock(slow_clock), .card(dcard3));

    // Instantiations for card7seg controlling HEX0 -> HEX5, outputs HEX0 - HEX5 are used

    card7seg card7seg_HEX0( .card(pcard1), .seg7(HEX0));
    card7seg card7seg_HEX1( .card(pcard2), .seg7(HEX1));
    card7seg card7seg_HEX2( .card(pcard3), .seg7(HEX2));
    card7seg card7seg_HEX3( .card(dcard1), .seg7(HEX3));
    card7seg card7seg_HEX4( .card(dcard2), .seg7(HEX4));
    card7seg card7seg_HEX5( .card(dcard3), .seg7(HEX5));

    // Instantiations for scorehand 

    scorehand pscorehand( .card1(pcard1), .card2(pcard2), .card3(pcard3), .total(pscore_out)); // output pscore_out is used
    scorehand dscorehand( .card1(dcard1), .card2(dcard2), .card3(dcard3), .total(dscore_out)); // output dscore_out is used

    // Assignment statement for pcard3, which is fed to the FSM controller

    assign pcard3_out = pcard3;

endmodule


// Instantiation of reg4 module for pcard & dcard use
// Active low-sync. reset 
// if resetb == 0, card = 0. if load_card is enabled (=1), card = new_card. otherwise, card remembers original value
// reg4 initializes to 0 upon first reset

// untested 19/01/2026

module reg4(input logic [3:0] new_card, input logic load_card, input logic resetb, input logic slow_clock, output logic [3:0] card);

    always_ff@(posedge slow_clock) begin
        if(resetb == 0) card <= 4'b0000;
        else if(load_card == 1'b1) card <= new_card;
    end

endmodule
