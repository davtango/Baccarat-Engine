module card7seg(input logic [3:0] card, output logic [6:0] seg7);

   // always_comb block for seven-segment LED driver
   // 1 is OFF, 0 is ON

   always_comb begin
      case(card) 
         4'b0000: seg7 = 7'b111_1111; // 0 (blank)
         4'b0001: seg7 = 7'b000_1000; // Ace
         4'b0010: seg7 = 7'b010_0100; // 2
         4'b0011: seg7 = 7'b011_0000; // 3
         4'b0100: seg7 = 7'b001_1001; // 4
         4'b0101: seg7 = 7'b001_0010; // 5
         4'b0110: seg7 = 7'b000_0010; // 6
         4'b0111: seg7 = 7'b111_1000; // 7
         4'b1000: seg7 = 7'b000_0000; // 8
         4'b1001: seg7 = 7'b001_0000; // 9
         4'b1010: seg7 = 7'b100_0000; // 10 (shows up on HEX as a zero)
         4'b1011: seg7 = 7'b110_0001; // Jack
         4'b1100: seg7 = 7'b001_1000; // Queen
         4'b1101: seg7 = 7'b000_1001; // King
         4'b1110: seg7 = 7'b111_1111; // BLANK (unused)
         4'b1111: seg7 = 7'b111_1111; // BLANK (unused)
         default: seg7 = 7'b111_1111; // BLANK for default
      endcase
   end

endmodule

