// outputs X and Y coordinates of upper left corner of paddle
module paddle(width, length, clk, reset, ball_x, ball_y, ai_ctrl, side, outX, outY, LED);
    input[5:0] width; // width can range from 0-63
    input[8:0] length;
    input clk, reset;
    input[9:0] ball_x;
    input[8:0] ball_y;
    input ai_ctrl, side;

    output reg[9:0] outX;
    output reg[8:0] outY;
    output[1:0] LED;

    assign LED = {1'b1, 1'b0}; // direction, limit

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            if(side == 1'b1) begin // left paddle
                outX <= 0;
            end
            else if(side == 1'b0) begin // right paddle
                outX <= 640-width;
            end
            outY <= 480-(length>>1);
        end
        else begin



        end
    end
endmodule
