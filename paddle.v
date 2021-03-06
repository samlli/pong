// outputs X and Y coordinates of upper left corner of paddle
module paddle(width, wall_width, ball_width, length, clk, reset, ball_x, ball_y, ball_direction, ball2, ball_2_x, ball_2_y, ball_2_direction, ai_ctrl, side, up, down, outX, outY, LED);
    input[5:0] width; // width can range from 0-63
    input[5:0] wall_width, ball_width;
    input[8:0] length;
    input clk, reset;
    input[9:0] ball_x;
    input[8:0] ball_y;
    input ball_direction, ai_ctrl, side;
    input[9:0] ball_2_x;
    input[8:0] ball_2_y;
    input ball_2_direction, ball2;
    input up, down;

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

            dy <= 4; // paddle speed
            // move <= 1'b0;
        end
        else begin
            // ai controlled
            if(ai_ctrl == 1'b1) begin
                // separate the left and right paddles
                // only react if ball is heading in my direction
                // left = side 1, right = side 0
                if(side == ball_direction) begin
                    // check if paddle is less than one step away from wall, and ball is either above/below midpoint of paddle, if so then only move paddle to wall instead of full step
                    if((outY-dy < wall_width &&
                        ball_y+(ball_width>>1) < wall_width+(length>>1)) ||
                        (outY+length+dy > 480-wall_width &&
                        ball_y+(ball_width>>1) > 480-wall_width-(length>>1))) begin
                        // if paddle is closest to the bottom wall
                        if(outY-wall_width > 480-wall_width-(outY+length)) begin
                            outY <= 480-wall_width-length;
                        end
                        // otherwise paddle is closest to the top wall
                        else begin
                            outY <= wall_width;
                        end
                    end
                    // have paddle take step in direction of ball
                    else begin
                        if(outY >= wall_width &&
                            outY <= 480-length-wall_width) begin
                            // move <= 1'b1;
                            // move paddle down
                            if(outY+(length>>1) < ball_y+(ball_width>>1)) begin
                                outY <= outY + dy;
                                // move <= 1'b1;
                            end
                            // move paddle up
                            else if(outY+(length>>1) > ball_y+(ball_width>>1)) begin
                                outY <= outY - dy;
                                // move <= 1'b0;
                            end
                        end
                    end
                end
                // chase second ball
                else if(side == ball_2_direction && ball2 == 1) begin
                    if((outY-dy < wall_width &&
                        ball_2_y+(ball_width>>1) < wall_width+(length>>1)) ||
                        (outY+length+dy > 480-wall_width &&
                        ball_2_y+(ball_width>>1) > 480-wall_width-(length>>1))) begin
                        // if paddle is closest to the bottom wall
                        if(outY-wall_width > 480-wall_width-(outY+length)) begin
                            outY <= 480-wall_width-length;
                        end
                        // otherwise paddle is closest to the top wall
                        else begin
                            outY <= wall_width;
                        end
                    end
                    // have paddle take step in direction of ball
                    else begin
                        if(outY >= wall_width &&
                            outY <= 480-length-wall_width) begin
                            // move <= 1'b1;
                            // move paddle down
                            if(outY+(length>>1) < ball_2_y+(ball_width>>1)) begin
                                outY <= outY + dy;
                                // move <= 1'b1;
                            end
                            // move paddle up
                            else if(outY+(length>>1) > ball_2_y+(ball_width>>1)) begin
                                outY <= outY - dy;
                                // move <= 1'b0;
                            end
                        end
                    end


                end
                // otherwise move paddle closer to center
                else begin
                    if(outY+(length>>1) < 240) begin
                        outY <= outY + 1;
                        // move <= 1'b1;
                    end
                    // move paddle up
                    else if(outY+(length>>1) > 240) begin
                        outY <= outY - 1;
                        // move <= 1'b0;
                    end
                end
            end
            // keyboard control
            else begin
                // w key move up
                if(up) begin
                    if(outY-dy < wall_width) begin
                        outY <= wall_width;
                    end else begin
                        outY <= outY-dy;
                    end
                end
                // s key move down
                else if(down) begin
                    if(outY+length+dy > 480-wall_width) begin
                        outY <= 480-length-wall_width;
                    end else begin
                        outY <= outY+dy;
                    end
                end
            end


        end
    end
endmodule
