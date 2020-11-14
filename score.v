module score(ball_x, ball_width, paddle_left, clk, reset, score_tens, score_ones);
    input[9:0] ball_x;
    input[5:0] ball_width;

    input paddle_left, clk, reset;

    output reg[3:0] score_tens, score_ones; // need to store 0-9 for each digit

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            score_ones <= 0;
            score_tens <= 0;
        end
        else begin
            if(paddle_left == 1'b1) begin
                if(ball_x+ball_width >= 638) begin
                    if(score_ones < 9) begin
                        score_ones <= score_ones + 1;
                    end
                    else begin
                        score_tens <= score_tens + 1;
                        score_ones <= 0;
                    end
                    // probably needs some buffer
                    // todo: handle ball behavior not hitting paddle
                    // score <= score + 1;
                end
            end
            else begin
                if(ball_x <= 0) begin
                    if(score_ones < 9) begin
                        score_ones <= score_ones + 1;
                    end
                    else begin
                        score_tens <= score_tens + 1;
                        score_ones <= 0;
                    end
                end
            end
        end
    end
endmodule
