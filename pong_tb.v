`timescale 1 ns / 100 ps
module pong_tb():
    reg clock = 0;

    // pong tester();

    // output gtkwave
    initial begin
        $dumpfile("wavefile.vcd");
        $dumpvars(0,pong_tb);

        #100000;
        $finish;
    end

    always
        #20 clock = !clock;
endmodule
