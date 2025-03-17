`timescale 1ns / 1ps

import my_pkg::word;

module linearDiffusion
    (out, in);

    output word out[5];
    input word in[5];
    
    
    wire circ0;
    assign circ0 =circShiftR(.in(in[0]), .s(19));
    wire circ1; 
    assign circ1 = circShiftR(.in(in[0]), .s(28));

    function automatic word circShiftR;
        input word in;
        input byte s;

        circShiftR = (in >> s) | (in << (64 - s));
    endfunction

    always_comb begin
        out[0] = in[0] ^ circShiftR(.in(in[0]), .s(19)) ^ circShiftR(.in(in[0]), .s(28));
        out[1] = in[1] ^ circShiftR(.in(in[1]), .s(61)) ^ circShiftR(.in(in[1]), .s(39));
        out[2] = in[2] ^ circShiftR(.in(in[2]), .s(01)) ^ circShiftR(.in(in[2]), .s(06));
        out[3] = in[3] ^ circShiftR(.in(in[3]), .s(10)) ^ circShiftR(.in(in[3]), .s(17));
        out[4] = in[4] ^ circShiftR(.in(in[4]), .s(07)) ^ circShiftR(.in(in[4]), .s(41));
    end
endmodule
