`timescale 1ns / 1ps
`include "param.v"
module conv(
    input clk,
    input [71:0] inPixelData,
    input inPixelDataValid,
    output reg [7:0] outConvolvedData,
    output reg outConvolvedDataValid
);
    
integer i; 
reg [7:0] kernel [8:0];
reg [15:0] multData[8:0];
reg [15:0] sumDataInt;
reg [15:0] sumData;
reg multDataValid;
reg sumDataValid;
    
`ifdef BLUR 
initial
begin
    kernel[0] = 0.0625;
    kernel[1] = 0.125;
    kernel[2] = 0.0625;
    kernel[3] = 0.125;
    kernel[4] = 0.25;
    kernel[5] = 0.125;
    kernel[6] = 0.0625;
    kernel[7] = 0.125;
    kernel[8] = 0.0625;
end  
`endif

`ifdef OUTLINE 
initial
begin
    kernel[0] = -1;
    kernel[1] = -1;
    kernel[2] = -1;
    kernel[3] = -1;
    kernel[4] = 8;
    kernel[5] = -1;
    kernel[6] = -1;
    kernel[7] = -1;
    kernel[8] = -1;
end  
`endif

`ifdef SHARPEN 
initial
begin
    kernel[0] = 0;
    kernel[1] = -1;
    kernel[2] = 0;
    kernel[3] = -1;
    kernel[4] = 5;
    kernel[5] = -1;
    kernel[6] = 0;
    kernel[7] = -1;
    kernel[8] = 0;
end  
`endif

`ifdef EMBOSS 
initial
begin
    kernel[0] = -2;
    kernel[1] = -1;
    kernel[2] = 0;
    kernel[3] = -1;
    kernel[4] = 1;
    kernel[5] = 1;
    kernel[6] = 0;
    kernel[7] = 1;
    kernel[8] = 2;
end  
`endif

always @(posedge clk)
begin
    for(i=0;i<9;i=i+1)
    begin
        multData[i] <= kernel[i] * inPixelData[i*8+:8];
    end
    multDataValid <= inPixelDataValid;
end

always @(*)
begin
    sumDataInt = 0;
    for(i=0;i<9;i=i+1)
    begin
        sumDataInt = sumDataInt + multData[i];
    end
end

always @(posedge clk)
begin
    sumData <= sumDataInt;
    sumDataValid <= multDataValid;
end
    
always @(posedge clk)
begin
    outConvolvedData <= sumData;
    outConvolvedDataValid <= sumDataValid;
end
    
endmodule