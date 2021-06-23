module top(input clk, input btn, output [7:0] led);
    reg[7:0] count;
    reg[7:0] next_count;

    always @ (posedge clk or posedge btn) begin
        if (btn) begin
            count <= '0;
        end else begin
            count <= next_count;
        end
    end

    always @ (count) begin
        next_count = count + 1;
    end

    assign led = count;
endmodule
