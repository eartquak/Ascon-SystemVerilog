`timescale 1ns / 1ps

import my_pkg::word;
import my_pkg::block;

module core #(parameter byte NUMR = 2)
    (out, in, ready, ready_o, sys_state, ready_i, ready_k, k_n, done, term, a_p, e_d, clk, rst);

    localparam byte DATASIZE = 128;
    localparam logic [32:0]IV = 64'h00001000808c0001;
    localparam byte RA       = 12;
    localparam byte RB       = 6;

    output logic [127:0]out;
    input logic [127:0]in;
    //Ready to take input
    output logic ready;
    //Output is ready
    output logic ready_o;
    //Debugging - State of the System
    output logic [1:0]sys_state;
    //Indicate input is ready
    input logic ready_i;
    //Indicate key is ready
    input logic ready_k;
    //Indicate if it is a key or nonce
    input logic k_n;
    //Output has been ready
    input logic done;
    //Terminate
    input logic term;
    //Input is associate data or plaintext
    input logic a_p;
    //Encrypt or Decrypt
    input logic e_d;
    input clk, rst;

    logic [127:0]key_t;
    logic [127:0]nonce_t;
    logic [127:0]in_t;
    logic e_d_t;

    block init;
    block state_i;
    wire block state_o;
    block state;

    logic [3:0]n_rounds;
    logic [3:0]round;

    always_comb begin
        init = {IV, key_t, nonce_t};
    end

    permutation #(.NUMR(NUMR)) perm_m(.out(state_o), .in(state_i), .round(round), .numRounds(n_rounds));

    typedef enum logic [2:0] {
        IDLE_F   = 3'b000,
        INIT_F   = 3'b001,
        WAITA_F = 3'b010,
        WAITP_F = 3'b011,
        OUT_F    = 3'b100,
        ASS_F    = 3'b101,
        PT_F     = 3'b110,
        TERM_F   = 3'b111
    } fsm_t;

    fsm_t curr_s;
    fsm_t next_s;

    typedef enum logic [1:0] {
        INIT_S = 2'b00,
        ASS_S  = 2'b01,
        PT_S   = 2'b10,
        TERM_S = 2'b11
    } fsm_e;

    //Control Signals logic
    always_comb begin
        ready = 0;
        ready_o = 0;
        unique case(curr_s)
            IDLE_F: begin
                n_rounds = 0;
                ready_o = 0;
                ready = 1;
            end
            INIT_F: begin
                n_rounds = RA;
                ready_o = 0;
                ready = 0;
                sys_state = INIT_S;
            end
            WAITA_F: begin
                n_rounds = 0;
                ready_o = 0;
                ready = 1;
                sys_state = ASS_S;
            end
            WAITP_F: begin
                n_rounds = 0;
                ready_o = 0;
                ready = 1;
                sys_state = PT_S;
            end
            OUT_F: begin
                n_rounds = 0;
                ready_o = 1;
                ready = 1;
                sys_state = PT_S;
            end
            ASS_F: begin
                n_rounds = RB;
                ready_o = 0;
                ready = 0;
                sys_state = ASS_S;
            end
            PT_F: begin
                n_rounds = RB;
                ready_o = 0;
                ready = 0;
                sys_state = PT_S;
            end
            TERM_F: begin
                n_rounds = RA;
                ready_o = 0;
                sys_state = TERM_S;
            end
        endcase
    end

    //FSM Next State logic
    always_comb begin
        next_s = curr_s;
        unique case(curr_s)
            IDLE_F: begin
                if (ready_k == 1) begin
                    next_s = INIT_F;
                    // ready = 0;
                end
            end
            INIT_F: begin
                if (n_rounds == (round + NUMR)) begin
                    next_s = WAITA_F;
                    // ready = 1;
                end
            end
            WAITA_F: begin
                if (ready_i == 1) begin
                    if (a_p == 0) begin
                        next_s = ASS_F;
                        // ready = 0;
                    end
                    if (a_p == 1) begin
                        next_s = WAITP_F;
                            // ready = 1;
                    end
                end
                else if (term == 1) begin
                    next_s = TERM_F;
                    // ready = 0;
                end
            end
            WAITP_F: begin
                if (ready_i == 1) begin
                    next_s = OUT_F;
                    // ready = 1;
                end
            end
            OUT_F: begin
                if (done == 1) begin
                    next_s = PT_F;
                    // ready = 0;
                end
                else if (term == 1) begin
                    next_s = TERM_F;
                    // ready = 0;
                end
            end
            ASS_F: begin
                if (n_rounds == (round + NUMR)) begin
                    next_s = WAITA_F;
                    // ready = 1;
                end
            end
            PT_F: begin
                if (n_rounds == (round + NUMR)) begin
                    next_s = WAITP_F;
                    // ready = 1;
                end
            end
            TERM_F: begin
                if (n_rounds == (round + NUMR)) begin
                    next_s = IDLE_F;
                    // ready = 1;
                end
            end
        endcase
    end

    //FSM State update
    always_ff @(posedge clk or negedge rst) begin
        if (rst == 0) begin
            curr_s <= IDLE_F;
        end
        else
            curr_s <= next_s;
    end

    //Internal State update
    byte i;
    always_ff @(posedge clk) begin
        unique case(curr_s)
            IDLE_F: begin
                round <= 0;
                state_i <= init;
            end
            INIT_F: begin
                round <= round + NUMR;
                state_i <= state_o;
                if (next_s == WAITA_F) begin
                    state <= state_o ^ {192'b0, key_t};
                    state_i <= state_o ^ {192'b0, key_t};
                end
            end
            WAITA_F: begin
                round <= 0;
                if (next_s == ASS_F) begin
                    state <= state ^ {in, {(320-DATASIZE){1'b0}}};
                    state_i <= state ^ {in, {(320-DATASIZE){1'b0}}};
                end
                if (next_s == WAITP_F) begin
                    state <= state ^ {319'b0, 1'b1};
                    state_i <= state ^ {319'b0, 1'b1};
                end
                if (next_s == TERM_F) begin
                    state <= state_o ^ {key_t, 192'b0};
                    state_i <= state_o ^ {key_t, 192'b0};
                end
            end
            WAITP_F: begin
                round <= 0;
            end
            OUT_F: begin
                if (next_s == PT_F) begin
                    if (e_d_t == 0) begin
                        state <= state ^ {in_t, {192{1'b0}}};
                        state_i <= state ^ {in_t, {192{1'b0}}};
                    end
                    if (e_d_t == 1) begin
                        state <= {in_t, state_o[191:0]};
                        state_i <= {in_t, state_o[191:0]};
                    end
                end
                else if (next_s == TERM_F) begin
                    state <= state ^ {key_t, 192'b0};
                    state_i <= state ^ {key_t, 192'b0};
                end
            end
            ASS_F: begin
                round <= round + NUMR;
                state_i <= state_o;
                if (next_s == WAITA_F)
                    state <= state_o;
            end
            PT_F: begin
                round <= round + NUMR;
                state_i <= state_o;
                if (next_s == WAITP_F)
                    state <= state_o;
            end
            TERM_F: begin
                round <= round + NUMR;
                state_i <= state_o;
                if (next_s == IDLE_F) begin
                    state <= state_o;
                end
            end
        endcase
    end

    always_ff @(posedge clk) begin
        case(curr_s)
            IDLE_F: begin
                if (ready_i == 1) begin
                    if (k_n == 0)
                        key_t <= in;
                    if (k_n == 1)
                        nonce_t <= in;
                    e_d_t <= e_d;
                end
            end
            WAITA_F: begin
                if (next_s != WAITA_F)
                    in_t <= in;
            end
            WAITP_F: begin
                if (next_s == OUT_F) begin
                    in_t <= in;
                    out <= state[319:192] ^ in;
                end
            end
            OUT_F: out <= state[319:192] ^ in_t;
            default: begin
            end
        endcase
    end
endmodule
