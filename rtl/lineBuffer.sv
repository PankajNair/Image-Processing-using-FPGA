`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.02.2024 17:04:26
// Design Name: 
// Module Name: lineBuffer
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


module lineBuffer(
input logic clk, reset,
input logic [7:0] inData,
input logic inDataValid,
input logic bufferSelect,
output logic [23:0] outData
    );

logic [7:0] lineBuffer [511:0];
logic [8:0] writePointer, readPointer;

//Write Logic
always_ff @(posedge clk)
begin
    if(inDataValid)
        lineBuffer[writePointer] <= inData;
end

always_ff @(posedge clk)
begin
    if(reset)
        writePointer <= 0;
    else if(inDataValid)
        writePointer <= writePointer + 1;
end

//Read Logic
assign outData = {lineBuffer[readPointer], lineBuffer[readPointer+1], lineBuffer[readPointer+2]};

always_ff @(posedge clk)
begin
    if(reset)
        readPointer <= 0;
    else if(bufferSelect)
        readPointer <= readPointer + 1;
end

endmodule
