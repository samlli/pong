// outputs X and Y coordinates of upper left corner of ball
module ball(ball_width, wall_width, paddle_width, paddle_length, paddle_l_y, paddle_r_y, clk, reset, outX, outY, ball_direction, LED, score_left_tens, score_left_ones, score_right_tens, score_right_ones);
    input[5:0] ball_width;
    input[5:0] wall_width; // top and bottom boundaries
    input[5:0] paddle_width; // left and right boundaries
    input[8:0] paddle_length;
    input[8:0] paddle_l_y, paddle_r_y;
    input clk, reset;

    output reg[9:0] outX;
    output reg[8:0] outY;
    output ball_direction;
    output[15:0] LED;

    output reg[3:0] score_left_tens, score_left_ones, score_right_tens, score_right_ones;

    reg[2:0] dx; // cap horizontal speed at 7?
    reg[2:0] dy; // want to avoid insane vertical speed
    reg dir_x, dir_y; // direction

    // assign LED = {dir_x, dir_y}; // debug LEDs
    assign ball_direction = dir_x; // determine which paddle ball is moving towards

    // generate random values
    wire[15:0] random;
    lfsr random(clk, reset, random);
    assign LED = {dy}; // display lfsr value

    reg score; // round finished

    always @(posedge clk or posedge reset or posedge score) begin
        if(reset) begin
            score_left_ones <= 0;
            score_left_tens <= 0;
            score_right_ones <= 0;
            score_right_tens <= 0;
        end
        if(reset || score) begin
            outX <= 310-(ball_width>>1); // ball starts in middle
            outY <= 240-(ball_width>>1);

            dx <= 2; // initial speed
            dy <= {random[2:1], 1'b1}; //(random[3:1]==3'b0) ? 3'b001 : random[3:1]; // randomize this part, controls how much ball goes up or down by
            // dy at least 1, prevents horizontal ball endless bouncing

            dir_x <= 1'b0; // first ball towards player
            dir_y <= random[0]; // should randomize this part, controls ball going up or down

            score <= 1'b0;
        end
        else begin
            // collision detection
            // detect if next move is a goal
            if(outX <= 7) begin
                // right paddle scored
                // if(dir_x == 1'b1) begin
                //     outX <= 0;
                // end
                // else begin
                //     outX <= 639-ball_width;
                // end
                if(score_right_ones < 9) begin
                    score_right_ones <= score_right_ones + 1;
                end
                else begin
                    score_right_tens <= score_right_tens + 1;
                    score_right_ones <= 0;
                end

                score <= 1'b1; // resets ball
            end
            else if(outX+ball_width >= 632) begin // 632=639-7
                // left paddle scored
                // if(dir_x == 1'b0) begin
                if(score_left_ones < 9) begin
                    score_left_ones <= score_left_ones + 1;
                end
                else begin
                    score_left_tens <= score_left_tens + 1;
                    score_left_ones <= 0;
                end

                score <= 1'b1;
            end


            // else no goal, regular movement
            else begin
                if(outX < paddle_width &&
                    outY+ball_width > paddle_l_y &&
                    outY < paddle_l_y+paddle_length) begin // left paddle
                    dir_x <= 1'b0;
                    if(dx < 6) begin // cap speed at 6
                        dx <= dx + 1; // ball gets one step faster
                    end
                    dy <= {random[2:1], 1'b1};
                end
                else if(outX+ball_width > 639-paddle_width &&
                    outY+ball_width > paddle_r_y &&
                    outY < paddle_r_y+paddle_length) begin // right paddle
                    dir_x <= 1'b1;
                    dy <= {random[2:1], 1'b1};
                end

                // slow the testing down!
                // slow the ball as it approaches paddle... works nicely with collision logic
                // if(outX < paddle_width+dx+2 || outX+ball_width > 639-paddle_width-dx-2) begin
                //     outX <= dir_x ? outX - 2 : outX + 2;
                // end
                // else begin
                // move ball
                outX <= dir_x ? (outX-dx<0 ? outX-1 : outX - dx) : (outX+dx>639 ? outX+1 : outX + dx);
                // end

                if(outY < wall_width) begin // top wall
                    dir_y <= 1'b0;
                end
                else if(outY+ball_width > 479-wall_width) begin // bottom wall
                    dir_y <= 1'b1;
                end
                outY <= dir_y ? outY - dy : outY + dy;
            end
        end
    end
endmodule
