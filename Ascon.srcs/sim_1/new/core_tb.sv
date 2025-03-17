`timescale 1ns / 1ps

module core_tb();
    wire [127:0]out;
    logic [127:0]in;
    wire ready;
    wire ready_o;
    logic ready_i;
    logic ready_k;
    logic k_n;
    logic done;
    logic term;
    logic a_p;
    logic e_d;
    logic clk;
    logic rst = 1;

    core #(.NUMR(2))
        c(.out(out), .in(in), .ready(ready),
        .ready_o(ready_o), .ready_i(ready_i), .ready_k(ready_k),
        .k_n(k_n), .done(done), .term(term), .a_p(a_p), .e_d(e_d), .clk(clk), .rst(rst));

    always
        #5 clk = ~clk;

    initial begin

        //Encryption
        clk = 0;
        rst = 0;
        ready_k = 0;
        done = 0;
        term = 0;
        ready_i = 0;
        k_n = 0;
        a_p = 0;
        e_d = 0;
        #3 rst = 1;

        @(posedge clk) #1;
        k_n = 0;
        ready_i = 1;
        in = 128'hff6d25cf734c49a1dd273e4d8f5f5bdb;
        @(posedge clk) #1;
        k_n = 1;
        in = 128'hff6d25cf734c49a1dd273e4d8f5f5bdb;
        @(posedge clk) #1;
        ready_k = 1;
        ready_i = 0;


        @(posedge clk) #1;
        wait(ready == 1);
        ready_i = 1;
        a_p = 0;
        in = 128'h6d25cf734c49a1dd273e4d8f5f5bdb01;
        @(posedge clk) #1;
        ready_i = 1;
        in = 128'h6d25cf734c49a1dd273e4d8f5f5bdb01;
        @(posedge clk) #1;
        ready_i = 0;
        done = 1;

        @(posedge ready);
        @(posedge clk);
        ready_i = 1;
        in = 128'h6d25cf734c49a1dd273e4d8f5f5bac01;
        @(posedge clk);
        ready_i = 0;
        term = 1;

        //Decryption
        #5
        clk = 0;
        rst = 0;
        ready_k = 0;
        done = 0;
        term = 0;
        ready_i = 0;
        k_n = 0;
        a_p = 0;
        e_d = 1;
        #5 rst = 1;

        @(posedge clk);
        k_n = 0;
        ready_i = 1;
        a_p = 0;
        in = 128'hff6d25cf734c49a1dd273e4d8f5f5bdb;
        @(posedge clk);
        k_n = 1;
        in = 128'hff6d25cf734c49a1dd273e4d8f5f5bdb;
        @(posedge clk);
        ready_k = 1;
        ready_i = 0;

        @(posedge ready);
        @(posedge clk);
        ready_i = 1;
        a_p = 1;
        in = 128'h6d25cf734c49a1dd273e4d8f5f5bdb01;
        @(posedge clk);
        ready_i = 1;
        in = 128'h3e6d18f72a86a11ebc1138c4ede7a632;
        @(posedge clk);
        ready_i = 0;
        done = 1;

        @(posedge ready);
        @(posedge clk);
        ready_i = 1;
        in = 128'h92d9b2704bebeb3a641c6c17b4133124;
        @(posedge clk);
        ready_i = 0;
        term = 1;

    end

endmodule
