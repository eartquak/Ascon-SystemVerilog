`timescale 1ns / 1ps

import my_pkg::word;
import my_pkg::block;

module permutation #(parameter byte NUMR = 2)
    (out, in, round, numRounds);

    output block out;
    input block in;
    input logic [3:0]round;
    input logic [3:0]numRounds;

    word in_t[5];
    always_comb begin
        {in_t[0], in_t[1], in_t[2], in_t[3], in_t[4]} = in;
    end
    word p_i[NUMR + 1][5];

    word p_ii[NUMR][2][5];

    int i;
    always_comb begin
        for (i = 0; i < 5; i++)
            p_i[0][i] = in_t[i];
    end

    genvar j;
    generate
        for (j = 0; j < NUMR; j = j + 1) begin : g_rounds
            roundConstant rC(.out(p_ii[j][0]), .in(p_i[j]), .round(round + j), .numRounds(numRounds));
            substitute s(.out(p_ii[j][1]), .in(p_ii[j][0]));
            linearDiffusion lD(.out(p_i[j+1]), .in(p_ii[j][1]));
        end
    endgenerate

    always_comb begin
            out = { p_i[NUMR][0], p_i[NUMR][1], p_i[NUMR][2], p_i[NUMR][3], p_i[NUMR][4] };
    end
endmodule
