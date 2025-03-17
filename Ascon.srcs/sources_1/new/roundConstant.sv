`timescale 1ns / 1ps
import my_pkg::word;

module roundConstant
    (out, in, round, numRounds);

    output word out[5];
    input word in[5];
    input [3:0]round;
    input [3:0]numRounds;

    localparam byte CR[12] = {8'hf0, 8'he1, 8'hd2, 8'hc3, 8'hb4, 8'ha5,
                              8'h96, 8'h87, 8'h78, 8'h69, 8'h5a, 8'h4b};

    int i;
    always_comb begin
        for (i = 0; i < 5; i++) begin
            out[i] = in[i];
        end
        out[2] = in[2] ^ CR[12-numRounds+round];
    end


endmodule
