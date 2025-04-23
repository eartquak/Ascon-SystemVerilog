`timescale 1ns / 1ps

import my_pkg::word;
import my_pkg::block;

module initialization (out, key, nonce);

    localparam logic [32:0]IV = 64'h80800c0800000000;

    output block out;
    input logic [127:0]key;
    input logic [127:0]nonce;

    always_comb begin
        out = {IV, key, nonce};
    end
endmodule
