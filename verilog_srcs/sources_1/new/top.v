`timescale 1ns / 1ps
module top(
    input clk,
    input rst,
    input [63:0]inputA ,
    input [63:0]inputB ,
    output reg [127:0]Cout 
);  
    // I am declaring these regs as they would help in
    // data handling, but may be omitted in case we 
    // face shortage of components
    reg [3:0]A[15:0];
    reg [3:0]B[15:0];
    wire [7:0]C[15:0];
    
    // Instatiating the PE interconnects
    // These would transfer information between the PEs
    wire [3:0]connect_x_0to1;
    wire [3:0]connect_x_1to2;
    wire [3:0]connect_x_2to3;
    wire [3:0]connect_x_4to5;
    wire [3:0]connect_x_5to6;
    wire [3:0]connect_x_6to7;
    wire [3:0]connect_x_8to9;
    wire [3:0]connect_x_9to10;
    wire [3:0]connect_x_10to11;    
    wire [3:0]connect_x_12to13;
    wire [3:0]connect_x_13to14;
    wire [3:0]connect_x_14to15;
        
    wire [3:0]connect_y_0to4;
    wire [3:0]connect_y_4to8;
    wire [3:0]connect_y_8to12;
    wire [3:0]connect_y_1to5;
    wire [3:0]connect_y_5to9;
    wire [3:0]connect_y_9to13;
    wire [3:0]connect_y_2to6;
    wire [3:0]connect_y_6to10;
    wire [3:0]connect_y_10to14;    
    wire [3:0]connect_y_3to7;
    wire [3:0]connect_y_7to11;
    wire [3:0]connect_y_11to15;
    
    // Intialise the end wires
    // The PEs present at the edges
    // not need any more transmission
    // of data in one or two directions
    // end_wires ar so name as such
    // they lead to nowhere
    wire [3:0] end_wire_x_3;
    wire [3:0] end_wire_x_7;
    wire [3:0] end_wire_x_11;
    wire [3:0] end_wire_x_15;
    wire [3:0] end_wire_y_12;
    wire [3:0] end_wire_y_13;
    wire [3:0] end_wire_y_14;
    wire [3:0] end_wire_y_15;
    
    
    // Instatiating the transfer registers
    // These registers would hold the data
    // and introduce delays, to materialise
    // the systolis architecture
    reg [3:0]Reg_A_4_0;   
    reg [3:0]Reg_A_8_0;   
    reg [3:0]Reg_A_8_1;   
    reg [3:0]Reg_A_12_0;   
    reg [3:0]Reg_A_12_1;   
    reg [3:0]Reg_A_12_2;   
                        
    reg [3:0]Reg_B_1_0;   
    reg [3:0]Reg_B_2_0;   
    reg [3:0]Reg_B_2_1;   
    reg [3:0]Reg_B_3_0;   
    reg [3:0]Reg_B_3_1;   
    reg [3:0]Reg_B_3_2;   
    
    
    // Load inputs into internal registers A and B
    // When the system is not in reset state, 
    // this code parses the flat 64 bit array into
    // 16, 4bit sized chunks. 
    integer i;
    always @(*) begin
        if (rst) begin
            for (i = 0; i < 16; i = i + 1) begin
                A[i] = 4'b0;
                B[i] = 4'b0;
            end
        end else begin
            for (i = 0; i < 16; i = i + 1) begin
                A[i] = inputA[(4 * i) +: 4];  // Use range slicing to select 4 bits
                B[i] = inputB[(4 * i) +: 4];  // Use range slicing to select 4 bits
            end
        end
    end 

    // Instantiate the PE block
    // We go diagonally from top right to bottom left
    // This is the way
    block PE0(A[0], B[0], clk, rst, connect_x_0to1, connect_y_0to4, C[0]);
    
    block PE1(connect_x_0to1, Reg_B_1_0, clk, rst, connect_x_1to2, connect_y_1to5, C[1]);
    block PE4(Reg_A_4_0, connect_y_0to4, clk, rst, connect_x_4to5, connect_y_4to8, C[4]);
    
    block PE2(connect_x_1to2, Reg_B_2_0, clk, rst, connect_x_2to3, connect_y_2to6, C[2]);
    block PE5(connect_x_4to5, connect_y_1to5, clk, rst, connect_x_5to6, connect_y_5to9, C[5]);
    block PE8(Reg_A_8_0, connect_y_4to8, clk, rst, connect_x_8to9, connect_y_8to12, C[8]);
    
    block PE3(connect_x_2to3, Reg_B_3_0, clk, rst, end_wire_x_3, connect_y_3to7, C[3] );
    block PE6(connect_x_5to6, connect_y_2to6, clk, rst, connect_x_6to7, connect_y_6to10, C[6]);
    block PE9(connect_x_8to9, connect_y_5to9, clk, rst, connect_x_9to10, connect_y_9to13, C[9]);
    block PE12(Reg_A_12_0, connect_y_8to12, clk, rst, connect_x_12to13, end_wire_y_12, C[12]);
    
    block PE7(connect_x_6to7, connect_y_3to7, clk, rst, end_wire_x_7, connect_y_7to11, C[7]);
    block PE10(connect_x_9to10, connect_y_6to10, clk, rst, connect_x_10to11, connect_y_10to14, C[10]);
    block PE13(connect_x_12to13, connect_y_9to13, clk, rst, connect_x_13to14, end_wire_y_13, C[13]);
    
    block PE11(connect_x_10to11, connect_y_7to11, clk, rst, end_wire_x_11, connect_y_11to15, C[11]);
    block PE14(connect_x_13to14, connect_y_10to14, clk, rst, connect_x_14to15, end_wire_y_14, C[14]);
    
    block PE15(connect_x_14to15, connect_y_11to15, clk, rst, end_wire_x_15, end_wire_y_15, C[15]);
   
    // Reset logic and state
    // Making a seperate always block to
    // implement the data transfer between
    // the successive registers
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Reg_A_4_0  =1'b0;
            Reg_A_8_0  =1'b0;
            Reg_A_8_1  =1'b0;
            Reg_A_12_0 =1'b0;
            Reg_A_12_1 =1'b0;
            Reg_A_12_2 =1'b0;
            Reg_B_1_0  =1'b0;
            Reg_B_2_0  =1'b0;
            Reg_B_2_1  =1'b0;
            Reg_B_3_0  =1'b0;
            Reg_B_3_1  =1'b0;
            Reg_B_3_2  =1'b0;             
        end 
        else begin
            // Row 1
            A[0] <= A[1];
            A[1] <= A[2];
            A[2] <= A[3];
            A[3] <= 4'b0000;
            
            // Column 1
            B[0] <= B[4];
            B[4] <= B[8];
            B[8] <= B[12];
            B[12] <= 4'b0000;
            
             // Row 2
            Reg_A_4_0 <= A[4]; 
            A[4] <= A[5];
            A[5] <= A[6];
            A[6] <= A[7];
            A[7] <= 4'b0000;
            
            // Column 2
            Reg_B_1_0 <= B[1];
            B[1] <= B[5];
            B[5] <= B[9];
            B[9] <= B[13];
            B[13] <= 4'b0000;           
            
            // Row 3
            Reg_A_8_0 <= Reg_A_8_1; 
            Reg_A_8_1 <= A[8];
            A[8] <= A[9];
            A[9] <= A[10];
            A[10] <= A[11];
            A[11] <= 4'b0000;
            
            // Column 3
            Reg_B_2_0 <= Reg_B_2_1; 
            Reg_B_2_1 <= B[2];            
            B[2] <= B[6];
            B[6] <= B[10];
            B[10] <= B[14];
            B[14] <= 4'b0000; 
            
            // Row 4
            Reg_A_12_0 <= Reg_A_12_1;             
            Reg_A_12_1 <= Reg_A_12_2; 
            Reg_A_12_2 <= A[12];
            A[12] <= A[13];
            A[13] <= A[14];
            A[14] <= A[15];
            A[15] <= 4'b0000;
            
            // Column 4
            Reg_B_3_0 <= Reg_B_3_1;             
            Reg_B_3_1 <= Reg_B_3_2; 
            Reg_B_3_2 <= B[3];
            B[3] <= B[7];
            B[7] <= B[11];
            B[11] <= B[15];
            B[15] <= 4'b0000;
                                                          
        end
        
    end
    
    
    // Finally, converting the 16x8 bit memory array 
    // C to a flat 128 bit array Cout
    always@(*) begin
        for (i=0; i<16; i=i+1) begin
            Cout[8*i] = C[i][0];
            Cout[8*i+1] = C[i][1];
            Cout[8*i+2] = C[i][2];
            Cout[8*i+3] = C[i][3];
            Cout[8*i+4] = C[i][4];
            Cout[8*i+5] = C[i][5];
            Cout[8*i+6] = C[i][6];
            Cout[8*i+7] = C[i][7];
            
        end
    end
endmodule

