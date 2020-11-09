// outputs X and Y coordinates of upper left corner of ball
module ball(width, clk, reset, outX, outY, LED);
    input[5:0] width; // width can range from 0-63
    input clk, reset;

    output reg[9:0] outX;
    output reg[8:0] outY;
    output[1:0] LED;

    reg[5:0] dx, dy; // speed
    reg dir_x, dir_y; // direction

    assign LED = {dir_x, dir_y}; // debug LEDs

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            outX <= 310-(width>>1); // ball starts in middle
            outY <= 240-(width>>1);

            dx <= 6'd3; // initial speed
            dy <= 6'd3;

            dir_x <= 1'b1; // initial direction
            dir_y <= 1'b1;
        end
        else begin
            if(outX < 14) begin // left wall
                dir_x <= 1'b0;
            end
            else if(outX+width > 626) begin // right wall
                dir_x <= 1'b1;
            end
            outX <= dir_x ? outX - dx : outX + dx;

            if(outY < 14) begin // top wall
                dir_y <= 1'b0;
            end
            else if(outY+width > 466) begin // bottom wall
                dir_y <= 1'b1;
            end
            outY <= dir_y ? outY - dy : outY + dy;
        end
    end
endmodule
