module scorehand(input logic [3:0] card1, input logic [3:0] card2, input logic [3:0] card3, output logic [3:0] total);

    logic [3:0] valued_card1, valued_card2, valued_card3;
    logic [4:0] sum; // the highest possible sum is 27 or max 5 bits (adjust to [4:0] to avoid bit overflow)

    // instantiate card_valuer, which evaluates 10s, Jacks, Queens, and Kings as 0s and stores in valued_card

    card_valuer cardvaluer1(.card(card1), .valued_card(valued_card1));
    card_valuer cardvaluer2(.card(card2), .valued_card(valued_card2));
    card_valuer cardvaluer3(.card(card3), .valued_card(valued_card3));

    assign sum = valued_card1 + valued_card2 + valued_card3; // accounts for bitwdith mismatches
    assign total = sum % 5'd10;

endmodule

// 10s, Jacks, Queens, Kings -> 0
// turned into a submodule as writing 3 cases looks cumbersome

module card_valuer( input logic [3:0] card, output logic [3:0] valued_card);

    always_comb begin
        case(card)
            4'b0000: valued_card = 4'b0000; // card value is 0
            4'b0001: valued_card = 4'b0001; // card value is ACE or 1
            4'b0010: valued_card = 4'b0010; // card value is 2
            4'b0011: valued_card = 4'b0011; // card value is 3
            4'b0100: valued_card = 4'b0100; // card value is 4
            4'b0101: valued_card = 4'b0101; // card value is 5
            4'b0110: valued_card = 4'b0110; // card value is 6
            4'b0111: valued_card = 4'b0111; // card value is 7
            4'b1000: valued_card = 4'b1000; // card value is 8
            4'b1001: valued_card = 4'b1001; // card value is 9
            4'b1010: valued_card = 4'b0000; // card value is 10 -> turns to 0
            4'b1011: valued_card = 4'b0000; // card value is 11 or JACK -> turns to 0
            4'b1100: valued_card = 4'b0000; // card value is 12 or QUEEN -> turns to 0
            4'b1101: valued_card = 4'b0000; // card value is 13 or KING -> turns 0
            4'b1110: valued_card = 4'b0000; // card value is 14 or N/A -> turns to 0
            4'b1111: valued_card = 4'b0000; // card value is 15 or N/A -> turns to 0
            default: valued_card = 4'b0000; // default is 4'b0000
        endcase
    end

endmodule

