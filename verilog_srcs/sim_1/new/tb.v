`timescale 1ns / 1ps
module tb();

    reg clk = 1'b0;
    reg rst = 1'b1;

    reg [63:0]inputA;
    reg [63:0]inputB;
    wire [127:0]C;
    
    
    top DUT(clk, rst, inputA, inputB, C);
     
    initial begin
    forever begin 
    #5;
    clk = ~clk;
    end
    end
    
    
    initial begin
    inputA <= 64'hAAAAAAAAAAAAAAAA;
    inputB <= 64'h5555555555555555;
    #5;
    rst = 1'b0;
    end
    
endmodule
