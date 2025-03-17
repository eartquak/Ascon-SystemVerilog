`timescale 1ns / 1ps

import my_pkg::word;

module substitute
    (out, in);

    output word out[5];
    input word in[5];

    word x[5];

    word t[5];

    int i;
    always_comb begin
        for (i = 0; i < 5; i++) begin
            x[i] = in[i];
        end
        x[0] ^= x[4]; x[4] ^= x[3]; x[2] ^= x[1];
        t[0] = x[0]; t[1] = x[1]; t[2] = x[2]; t[3] = x[3]; t[4]= x[4];
        t[0] =~ t[0]; t[1] =~ t[1]; t[2] =~ t[2]; t[3] =~ t[3]; t[4] =~ t[4];
        t[0] &= x[1]; t[1] &= x[2]; t[2] &= x[3]; t[3] &= x[4]; t[4] &= x[0];
        x[0] ^= t[1]; x[1] ^= t[2]; x[2] ^= t[3]; x[3] ^= t[4]; x[4] ^= t[0];
        x[1] ^= x[0]; x[0] ^= x[4]; x[3] ^= x[2]; x[2] =~ x[2];
        for (i = 0; i < 5; i++) begin
            out[i] = x[i];
        end
    end
endmodule
