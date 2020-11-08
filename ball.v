// outputs X and Y coordinates of upper left corner of ball
module ball(width, clk, reset, outX, outY);
    input[5:0] width; // width can range from 0-63
    input clk, reset;

    output reg[9:0] outX;
    output reg[8:0] outY;
    // output reg[5:0] outDx, outDy;

    reg bounceX, bounceY;

    reg[5:0] dx, dy;
    wire[5:0] dxval, dyval;

    assign dxval = dx;
    assign dyval = dy;
    // assign dx = (outX<10 || outX+width>630) ? 6'b111111 : 6'b000001;
    // assign dy = (outY<10 || outY+width>470) ? 6'b111111 : 6'b000001;

    always @(posedge clk or posedge reset) begin
        if(reset) begin // ball starts in middle
            outX <= 310-(width>>1);
            outY <= 240-(width>>1);

            dx <= 6'b1;
            dy <= 6'b1;
            bounceX <= 0;
            bounceY <= 0;
        end
        else begin
            outX <= outX + dx;
            outY <= outY + dy;

            // dx <= (outX<10 || outX+width>630) ? -dxval : dxval;
            // dy <= (outY<10 || outY+width>470) ? -dyval : dyval;

            bounceX <= (outX<10 || outX+width>630) ? 1 : 0;
            bounceY <= (outY<10 || outY+width>470) ? 1 : 0;

            // if(outX<10 || outX+width>630) ? 1 : 0;
            // bounceY <=
            //     bounceX <= 1;
            // else
            //     bounceX <= 0;
            // if(outY<10 || outY+width>470)
            //     bounceY <= 1;
            // else
            //     bounceY <= 0;
        end
    end
    always @(posedge bounceX) begin
        dx <= -dxval;
        // dx <= (outX<10 || outX+width>630) ? -dxval : dxval;
    end
    always @(posedge bounceY) begin
        dy <= -dyval;
        // dy <= (outY<10 || outY+width>470) ? -dyval : dyval;
    end
endmodule
