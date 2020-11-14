// linear feedback shift registers to generate pseudorandom numbers
// fibonacci lfsr credit wikipedia
// taps: 16 14 13 11
// feedback polynomial: x^16 + x^14 + x^13 + x^11 + 1
module lfsr(clk, reset, value);
    input clk, reset;
    output[15:0] value;

    reg[15:0] bits, lfsr;

    assign value = lfsr;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            lfsr <= 16'hACE1;
        end
        else begin
            bits = ((lfsr>>0) ^ (lfsr>>2) ^ (lfsr>>3) ^ (lfsr>>5));
            lfsr = (lfsr>>1) | (bits<<15);
        end
    end
endmodule
