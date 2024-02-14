`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.02.2024 20:43:18
// Design Name: 
// Module Name: convolution
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


(* use_dsp = "automax" *)
module convolution(
input logic clk,
input logic [71:0] inData,
input logic inDataValid,
input logic [1:0] modeSelect,
output logic [7:0] outData,
output logic outDataValid
    );

logic [71:0] inData_reg;
logic [7:0] kernel [8:0];
logic [16:0] multData [8:0];
logic [16:0] multData_reg [8:0];
logic [16:0] sumData, sumDataInt;
logic multDataValid, sumDataValid, multDataValid_reg;
logic [16:0] sumDataIntRow [2:0];

//Kernel Initialisation
always_comb
begin
    case(modeSelect)
    2'b00: kernel = {1,2,1,2,4,2,1,2,1};     //Blur
    2'b01: kernel = {0,1,0,1,-5,1,0,1,0};    //Edge Detection
    2'b10: kernel = {0,-1,0,-1,6,-1,0,-1,0}; //Sharpen
    2'b11: kernel = {-2,-1,0,-1,1,1,0,1,2};  //Emboss
    endcase
end

always_ff @(posedge clk)
begin
    inData_reg <= inData;
end

//Multiplication
always_ff @(posedge clk) 
begin
    for (int i=0;i<9;i=i+1) 
    begin
      multData_reg[i] <= $signed(kernel[i]) * $signed({1'b0, inData_reg[i*8 +: 8]});
    end
    multDataValid_reg <= inDataValid;
end

always_ff @(posedge clk) begin
  multData <= multData_reg;
  multDataValid <= multDataValid_reg;
end

//Addition
always_ff @(posedge clk)
begin
    sumDataIntRow[0] = $signed(multData[0]) + $signed(multData[1]) + $signed(multData[2]);
    sumDataIntRow[1] = $signed(multData[3]) + $signed(multData[4]) + $signed(multData[5]);
    sumDataIntRow[2] = $signed(multData[6]) + $signed(multData[7]) + $signed(multData[8]);
end

always_comb
begin
    sumDataInt <= sumDataIntRow[0] + sumDataIntRow[1] + sumDataIntRow[2];
end

always_ff @(posedge clk)
begin
    sumData <= sumDataInt;
    sumDataValid <= multDataValid;
end

//Output
always_ff @(posedge clk)
begin
    if(modeSelect == 2'b00)
        outData <= sumData>>4;
    else if(modeSelect == 2'b10)
         outData <= sumData>>1;
    else
        outData <= sumData;
    outDataValid <= sumDataValid;
end

endmodule
