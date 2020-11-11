// outputs X and Y coordinates of upper left corner of paddle
module paddle(width, wall_width, ball_width, length, clk, reset, ball_x, ball_y, ball_direction, ai_ctrl, side, outX, outY, LED);
    input[5:0] width; // width can range from 0-63
    input[5:0] wall_width, ball_width;
    input[8:0] length;
    input clk, reset;
    input[9:0] ball_x;
    input[8:0] ball_y;
    input ball_direction, ai_ctrl, side;

    output reg[9:0] outX;
    output reg[8:0] outY;
    output[1:0] LED;

    reg[5:0] dy; // paddle speed
    reg move; // paddle move

    assign LED = {move, 1'b0}; // direction, limit

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            if(side == 1'b1) begin // left paddle
                outX <= 0;
            end
            else if(side == 1'b0) begin // right paddle
                outX <= 640-width;
            end
            outY <= ((480-length)>>1);

            dy <= 2;
            // move <= 1'b0;
        end
        else begin
            if((outY-dy < wall_width &&
                ball_y < wall_width+(length>>1)) ||
                (outY+length+dy > 480-wall_width &&
                ball_y > 480-wall_width-(length>>1))) begin
                if(outY-wall_width > 480-wall_width-(outY+length)) begin
                    outY <= 480-wall_width-length;
                end
                else begin
                    outY <= wall_width;
                end
            end
            else begin
                if(outY >= wall_width &&
                    outY <= 480-length-wall_width) begin
                    // move <= 1'b1;
                    if(outY+(length>>1) < ball_y) begin
                        outY <= outY + dy;
                        // move <= 1'b1;
                    end
                    else if(outY+(length>>1) > ball_y) begin
                        outY <= outY - dy;
                        // move <= 1'b0;
                    end
                end
            end
        end
    end
endmodule
