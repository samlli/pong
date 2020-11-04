// handles ball movement
module ball(inX, inY, velX, velY, width, clk, reset, outX, outY);
    input[9:0] inX; // X Y coords of top left corner
    input[8:0] inY;
    input[5:0] velX, velY;
    input[5:0] width; // width can range from 0-63
    input clk, reset;

    output reg[9:0] outX;
    output reg[8:0] outY;

    always @(posedge clk or posedge reset) begin
        if(reset) begin // ball starts in middle
            outX <= 310-(width>>1);
            outY <= 240-(width>>1);
        end
        else begin
            outX <= inX + velX;
            outY <= inY + velY;
        end
    end
endmodule
