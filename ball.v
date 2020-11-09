// outputs X and Y coordinates of upper left corner of ball
module ball(width, clk, reset, outX, outY, collision);
    input[5:0] width; // width can range from 0-63
    input clk, reset;

    output reg[9:0] outX;
    output reg[8:0] outY;
    output reg collision;

    reg[5:0] dx, dy;
    reg dir_x, dir_y;

    always @(posedge clk or posedge reset) begin
        if(reset) begin // ball starts in middle
            outX <= 310-(width>>1);
            outY <= 240-(width>>1);

            dx <= 6'd3;
            dy <= 6'd3;
            dir_x <= 1'b0;
            dir_y <= 1'b0;
            collision <= 1'b0;
        end
        else begin
            if(outX < 14) begin
                dir_x <= 1'b0;
            end else if(outX+width > 626) begin
                dir_x <= 1'b1;
            end
            outX <= dir_x ? outX - dx : outX + dx;

            if(outY < 14) begin
                dir_y <= 1'b0;
            end else if(outY+width > 466) begin
                dir_y <= 1'b1;
            end
            outY <= dir_y ? outY - dy : outY + dy;

            collision <= dir_x;
        end
    end
endmodule
