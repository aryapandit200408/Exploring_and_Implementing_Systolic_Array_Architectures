`timescale 1ns / 1ps
module block(
        input [3:0]X_in,
        input [3:0]Y_in,        
        input clk,
        input rst,
        output reg [3:0]X_out,
        output reg [3:0]Y_out,
        output reg [7:0]acc_value
    );
    
    wire [7:0]multi;
    assign multi = X_in * Y_in;
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            acc_value <=0;
            X_out <=0;
            Y_out <=0;
        end
        else begin
            X_out <= X_in;
            Y_out <= Y_in;
            acc_value <= acc_value + multi;
        end
    end
endmodule