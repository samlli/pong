// outputs X and Y coordinates of upper left corner of ball
module ball(ball_width, wall_width, paddle_width, paddle_length, paddle_l_y, paddle_r_y, clk, reset, outX, outY, ball_direction, LED);
    input[5:0] ball_width;
    input[5:0] wall_width; // top and bottom boundaries
    input[5:0] paddle_width; // left and right boundaries
    input[8:0] paddle_length;
    input[8:0] paddle_l_y, paddle_r_y;
    input clk, reset;

    output reg[9:0] outX;
    output reg[8:0] outY;
    output ball_direction;
    output[1:0] LED;

    reg[5:0] dx, dy; // speed
    reg dir_x, dir_y; // direction

    assign LED = {dir_x, dir_y}; // debug LEDs
    assign ball_direction = dir_x; // determine which paddle ball is moving towards

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            outX <= 310-(ball_width>>1); // ball starts in middle
            outY <= 240-(ball_width>>1);

            dx <= 3; // initial speed
            dy <= 3;

            dir_x <= 1'b1; // initial direction
            dir_y <= 1'b1;
        end
        else begin
            // collision detection
            if(outX < paddle_width &&
                outY+ball_width > paddle_l_y &&
                outY < paddle_l_y+paddle_length) begin // left paddle
                dir_x <= 1'b0;
            end
            else if(outX+ball_width > 640-paddle_width &&
                outY+ball_width > paddle_r_y &&
                outY < paddle_r_y+paddle_length) begin // right wall
                dir_x <= 1'b1;
            end
            // move ball up or down
            outX <= dir_x ? outX - dx : outX + dx;

            if(outY < wall_width) begin // top wall
                dir_y <= 1'b0;
            end
            else if(outY+ball_width > 480-wall_width) begin // bottom wall
                dir_y <= 1'b1;
            end
            outY <= dir_y ? outY - dy : outY + dy;
        end
    end
endmodule
