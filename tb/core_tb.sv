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
    logic clk = 0;
    logic rst = 1;
    logic [127:0]out_got;

    core #(.NUMR(2))
        c(.out(out), .in(in), .ready(ready),
        .ready_o(ready_o), .ready_i(ready_i), .ready_k(ready_k),
        .k_n(k_n), .done(done), .term(term), .a_p(a_p), .e_d(e_d), .clk(clk), .rst(rst));

    always
        #5 clk = ~clk;

    initial begin

        //Encryption
        rst = 0;
        ready_k = 0;
        done = 0;
        term = 0;
        ready_i = 0;
        k_n = 0;
        a_p = 0;
        e_d = 0;
        #1 rst = 1;
        @(posedge clk);

        k_n = 0;
        ready_i = 1;
        in = 128'hff6d25cf734c49a1dd273e4d8f5f5bdb;
        @(posedge clk);

        k_n = 1;
        ready_i = 1;
        in = 128'hff6d25cf734c49a1dd273e4d8f5f5bdb;
        @(posedge clk);

        ready_k = 1;
        ready_i = 0;
        @(posedge clk);

        //wait(ready == 1);
        @(posedge ready);
        ready_i = 1;
        a_p = 0;
        in = 128'h6d25cf734c49a1dd273e3e4d8f5f5bdb;
        @(posedge clk);

        //wait(ready == 1);
        @(posedge ready);
        ready_i = 1;
        a_p = 1;
        @(posedge clk);

        ready_i = 1;
        in = 128'h6d25cf734c49a1dd273e4d8f5f5bdb01;
        @(posedge clk);

        ready_i = 0;
        done = 1;
        @(posedge clk);

        assert (ready_o == 1);
        out_got = out;
        @(posedge clk);

        //wait(ready == 1);
        @(posedge ready);
        ready_i = 0;
        term = 1;
        @(posedge clk);

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

        k_n = 0;
        ready_i = 1;
        in = 128'hff6d25cf734c49a1dd273e4d8f5f5bdb;
        @(posedge clk);

        k_n = 1;
        in = 128'hff6d25cf734c49a1dd273e4d8f5f5bdb;
        @(posedge clk);

        ready_k = 1;
        ready_i = 0;
        @(posedge clk);

        //wait(ready == 1);
        @(posedge ready);
        ready_i = 1;
        a_p = 0;
        in = 128'h6d25cf734c49a1dd273e3e4d8f5f5bdb;
        @(posedge clk);

        //wait(ready == 1);
        @(posedge ready);
        ready_i = 1;
        a_p = 1;
        @(posedge clk);

        ready_i = 1;
        in = out_got;
        @(posedge clk);

        ready_i = 0;
        done = 1;
        @(posedge clk);

        assert(ready_o == 1);
        assert(out == 128'h6d25cf734c49a1dd273e4d8f5f5bdb01);
        @(posedge clk);

        //wait(ready == 1);
        @(posedge ready);
        ready_i = 0;
        term = 1;
        @(posedge clk);

    end

endmodule
