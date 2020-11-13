module score(ball_x, ball_width, paddle_left, clk, reset, score);
    input[9:0] ball_x;
    input[5:0] ball_width;

    input paddle_left, clk, reset;

    output reg[13:0] score; // max on 4 digit seven segment is 9999 < 2^14 = 16348

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            score <= 0;
        end
        else begin
            if(paddle_left == 1'b1) begin
                if(ball_x+ball_width >= 640) begin
                    // probably needs some buffer
                    // todo: handle ball behavior not hitting paddle
                    score <= score + 1;
                end
            end
            else begin
                if(ball_x <= 0) begin
                    score <= score + 1;
                end
            end
        end
    end
endmodule
