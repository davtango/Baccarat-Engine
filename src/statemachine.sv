`define INITIAL_STATE 4'b0000
`define DEAL_CARD_2 4'b0001
`define DEAL_CARD_3 4'b0010
`define DEAL_CARD_4 4'b0011
`define COMPARE_SCORE_FOR_DEAL 4'b0100
`define GAME_OVER 4'b0101
`define DEAL_PLAYER_3RD 4'b0110
`define DEAL_BANKER_3RD 4'b0111
`define COMPARE_PLAYER_3RD 4'b1000

module statemachine(input logic slow_clock, input logic resetb,
                    input logic [3:0] dscore, input logic [3:0] pscore, input logic [3:0] pcard3,
                    output logic load_pcard1, output logic load_pcard2, output logic load_pcard3,
                    output logic load_dcard1, output logic load_dcard2, output logic load_dcard3,
                    output logic player_win_light, output logic dealer_win_light);

    //Stores the current state in a 4 bit variable. 
    reg [3:0] current_state;

    //load card based on what state we are in
    assign load_pcard1 = (current_state == `INITIAL_STATE);
    assign load_dcard1 = (current_state == `DEAL_CARD_2);
    assign load_pcard2 = (current_state == `DEAL_CARD_3);
    assign load_dcard2 = (current_state == `DEAL_CARD_4);
    assign load_pcard3 = (current_state == `DEAL_PLAYER_3RD);
    assign load_dcard3 = (current_state == `DEAL_BANKER_3RD);

    //Assigns player win light based on a mealy machine system, as the score was updated before we 
    //entered this state
    assign player_win_light = (current_state == `GAME_OVER) && (pscore >= dscore);
    assign dealer_win_light = (current_state == `GAME_OVER) && (dscore >= pscore);

    //always block for the state changes
    always_ff @(posedge slow_clock) begin
        if(resetb == 0) // active low sync. reset! 
            current_state <= `INITIAL_STATE;
        else begin
            case(current_state)

                //We alwasy deal at least 4 cards, so we move between these states no matter what
                `INITIAL_STATE : current_state <= `DEAL_CARD_2;

                `DEAL_CARD_2 : current_state <= `DEAL_CARD_3;

                `DEAL_CARD_3 : current_state <= `DEAL_CARD_4;

                `DEAL_CARD_4 : current_state <= `COMPARE_SCORE_FOR_DEAL;

                `COMPARE_SCORE_FOR_DEAL : begin //this is the main branching state

                    //check if the player or banker has a natural (8 or 9)
                    if(pscore >= 8 || dscore >= 8) 
                        current_state <= `GAME_OVER;

                    else begin
                        if(pscore <= 5) //Player gets 3RD card
                            current_state <= `DEAL_PLAYER_3RD;
                        else begin 
                            if(dscore <= 5) //Banker gets 3RD card
                                current_state <= `DEAL_BANKER_3RD;
                            else
                                current_state <= `GAME_OVER;
                        end
                    end
                end

                `DEAL_PLAYER_3RD : current_state <= `COMPARE_PLAYER_3RD;

                `COMPARE_PLAYER_3RD : begin //determine if the banker gets a third card 
                
                    // Simple if, else if chain to determine if we should deal a 3RD card to the Banker
                    if(dscore == 6 && (pcard3 == 6 || pcard3 == 7)) current_state <= `DEAL_BANKER_3RD;
                    else if(dscore == 5 && (pcard3 >= 4 && pcard3 <= 7)) current_state <= `DEAL_BANKER_3RD;
                    else if(dscore == 4 && (pcard3 >= 2 && pcard3 <= 7)) current_state <= `DEAL_BANKER_3RD;
                    else if(dscore == 3 && (pcard3 != 8)) current_state <= `DEAL_BANKER_3RD;
                    else if(dscore <= 2) current_state <= `DEAL_BANKER_3RD;
                    else current_state <= `GAME_OVER;
                end

                //We always end the game after the Banker gets a card. 
                `DEAL_BANKER_3RD : current_state <= `GAME_OVER;

                //Once in the game over state, we stay here until reset. 
                `GAME_OVER : current_state <= `GAME_OVER;

                default : current_state <= `GAME_OVER;
            endcase
        end
    end

endmodule
