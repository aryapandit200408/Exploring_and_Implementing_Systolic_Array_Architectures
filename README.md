# Exploring_and_Implementing_Systolic_Array_Architectures
This is a repository of my explorations on systolic array architectures and implementing some in multisim and Verilog HDL. 

## Systolic Arrays and Their Architectures

Systolic arrays are specialized hardware architectures designed for high-performance, parallel data processing. They are particularly well-suited for tasks involving linear algebra operations, such as matrix multiplication, which are fundamental to many scientific computations, image processing tasks, and modern machine learning applications.

### Concept of Systolic Arrays
The term "systolic" is derived from the rhythmic contraction and relaxation of the heart, symbolizing the synchronized flow of data through a network of interconnected processing elements (PEs). In a systolic array, data flows between PEs in a pipelined manner, minimizing memory access and increasing computational efficiency. Each PE performs a small portion of the overall computation, passing partial results to neighboring PEs.

### Architectural Features
Data Flow: Systolic architectures leverage a regular grid of PEs that process and pass data in a highly predictable manner.
Synchronization: All PEs operate synchronously to maximize throughput.
Parallelism: The architecture supports high levels of parallelism, making it ideal for matrix operations.
Google's Tensor Processing Unit (TPU)
One of the most prominent modern implementations of a systolic array architecture is Google's Tensor Processing Unit (TPU). TPUs are application-specific integrated circuits (ASICs) optimized for deep learning workloads. Google's TPUs feature a systolic array of PEs dedicated to accelerating the training and inference of neural networks. This architecture dramatically reduces the time required for tensor computations by parallelizing matrix multiplications, a core operation in machine learning algorithms.

### Other Modern Architectures
Beyond Google's TPU, systolic arrays have inspired other modern architectures:
<ul>
<li>NVIDIA Tensor Cores: These are integrated into their GPUs, designed to accelerate matrix operations, particularly for machine learning tasks.</li>
<li>Intel Nervana Neural Network Processor (NNP): This processor incorporates systolic elements to achieve high efficiency in neural network training.</li>
<li>Graphcore IPU: The Intelligence Processing Unit (IPU) utilizes concepts inspired by systolic arrays to enhance parallel processing and memory bandwidth for AI computations.</li>
Advantages and Applications
</ul>

Systolic arrays excel in computational tasks requiring regular data flow and intensive matrix operations. They offer:
<ul>
<li> High Throughput: By parallelizing operations, systolic arrays achieve high computational speeds. </li>
<li> Energy Efficiency: Reduced memory access contributes to lower power consumption. </li>
<li> Scalability: The regular, grid-like structure allows for scalable designs. </li>
</ul>

## Methodology
### Design 1: 2x2 Matrix Multiplication with 1-bit data depth in Multisim (Manual Mode)
I have tried to explore these architecturs in detail. We start by implementing a 2x2 Matrix Multiplication with 1-bit data deptth in NI Multisim 14.
Please the file at, 
![image](https://github.com/user-attachments/assets/287ad209-bbbd-4be2-937d-bcab07635aa8)

#### Operation
1.	Change A11, A12, A21, A22 and B11, B12, B21, B22 as we see fit
2.	Reset all the register by making R=1, then again R=0, to make the circuit ready for operation.
3.	Instantiate the registers by loading the values. Make L=1 for this and drive the clock. Make sure S=0 to prevent load/shift conflict.
4.	Change the mode of the registers to shift mode, ie. S=1 and L=0.
5.	Drive the clock pulse till desired results are gotten.

### Design 2: 2x2 Matrix Multiplication with 1-bit data depth in Multisim (Automatic Mode)
It is the same as design 1, but with an extra module for control unit, so that the operation becomes automatic.
#### Automatic Control Design
We can identify 3 major control steps from our previous manual control steps. These are 1) Reset 2) Load 3)Shift, Multiply and Accumulate till results are obtained.

So we make a state machine to obtain the same. Let us employ One-Hot-Encoding and the states are T1 (Reset), T2 (Load), T3(Shift).

<center>
  T1 -> T2 -> T3 -> T3 -> T3 .... Continues
</center>

<p align= "center">
  ![image](https://github.com/user-attachments/assets/e46c2d5d-fb44-4800-934b-f6ec6d7c1a36)
Diagram of the FSM
</p>

#### Circuit Layout
![image](https://github.com/user-attachments/assets/aef44776-6bf3-4ded-bdc7-8a042059c0d9)
<p align= "center">
Diagram of the Schematic with the FSM
</p>

#### Ouput
-> The data is 1 bit and the output may be of maximum 3 bits.
-> The output is shown as in triplets of LEDs (like X1, X2, X3), in the same order as it should be.

### Design 3: Implementing 4x4 Matrix Multiplication in Verilog HDL
Emboldened with the successes of the previous design, we step forward to implementing a 4x4 MAC Design. That too, in Verilog.

#### The Processing Elements (PEs)
We first implement the processing elements (PEs), that would later become the the building block of our design.

```verilog
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

```

<p align = "center"> 
![image](https://github.com/user-attachments/assets/345627a3-4bff-4373-bca5-ac4059f3dd4d)
Resulting Elaborated Design of the PEs
</p>


#### Top Module
After making the PEs, we connect 16 of these into the Top module along with other peripherals.

```verilog
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
```

#### Testbench
Wohooo! Our design is done, lets add a testbench to get some beautiful (and correct, hopefully!) waveforms!
```verilog
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
```
<p aiggn = "center">
![image](https://github.com/user-attachments/assets/f9f0d799-bb42-418a-893a-7e43d3cb7aea)
Testbench along with the inputs

![image](https://github.com/user-attachments/assets/7e79c000-d2bd-4b23-b1c4-e1e1593b61a6)
The testbench simulation results showing the internal processes
</p>

#### Some Interesting Observation While Writing the TestBench Code
	2D arrays cannot be passed directly into modules and give error. This is because Verilog considers any 2D array as a memory element.
	Slicing using variables that we are so much habituated to do after years of using python, wont work in Verilog. Here special operators like range slicing operators like +: and -: operators can be used to do a similar thing.
	A bigger output array is required. Using 10 bits bit depth for C instead of the assumed 8 bit depth is required while finding the multiplication and addition the of bigger 4 bit values.
	Reseting all the values before operation is crucial for getting correct results.
	The implementation, even if it is free of error wont synthesis as the number of input ports required (258) is simply too large. Rather it can be used for internal calculations.

### Design 4: 4x4 Matrix Multiplication as an extension of the previous 2x2 multiplication circuit using some mux modules, a few more clock cycles and a quarter of the number of formerly used PEs
Idea: To select and multiply any two rows of X matrix and any two columns of the Y matrix at a time. A multiplexing circuit may be used for choosing the appropriate rows and columns. 

<p align = "center">
  ![image](https://github.com/user-attachments/assets/24331fcd-fb36-4d76-9d7b-fc2494061842)
  ![image](https://github.com/user-attachments/assets/cbc0fce2-b955-40a4-8a8e-6408283093a9)
</p>

The resulting structure uses multiplexers as in:-
<p align = "center">
  ![image](https://github.com/user-attachments/assets/bf186ebf-a82e-46a2-8549-0c9ddd4d58b9)
</p>

#### Implementation in Multisim
<p align = "center">
![image](https://github.com/user-attachments/assets/f6541d93-41d1-4466-acfb-b6c67cc824c1)
  The implementation in multisim 
Here Q=0 and W=0 therefore multiplication of (A1x, A2x) and (Bx1, Bx2) is occurring similarly calculations for (Q=0, W=1), (Q=1, W=0), (Q=1, W=1) may be done
</p>

#### Conclusion
•	This type of array may use much less hardware, but will be much slower and would require almost four times to be computed
•	This implementation may be used for scaling up the array sizes by doubling the number of rows or columns being used. This would give us more flexibility while multiplying matrices of difference shapes and sizes.
Untill now, systolic architectures have been explored. These systolic architectures are the basis of many modern high performance computing systems like Google’s Tensor Processing Units (TPUs). These system have a huge number of applications like the frequent Multiply and Accumulate (MAC) operations common in DNN and CNN inference and learning tasks, along with other fields like Digital Signal Processing.

## References
1.	HT Kung’s seminal paper
2.	Prof. Onar Multu’s lectures on systolic arrays
3.	[digitalsystemdesign.in/systolic-matrix-multiplier/](https://digitalsystemdesign.in/systolic-matrix-multiplier/) : from here I learned the systolic array reduction/cascading technique discussed in section 4.


