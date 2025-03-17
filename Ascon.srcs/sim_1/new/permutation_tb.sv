`timescale 1ns / 1ps

import my_pkg::word;
import my_pkg::block;

module permutation_tb();

    wire block out;
    block in;
    logic [3:0]round;
    logic [3:0]numRounds;

    permutation #(.NUMR(1))perm(.out(out), .in(in), .round(round), .numRounds(numRounds));

    initial begin
        round = 0;
        numRounds = 12;
        in = 320'h1000808c0001dda1494c73cf256ddb5b5fab8f4d3e27dda1494c73cf256ddb5b5fab8f4d3e27;
    end

endmodule
