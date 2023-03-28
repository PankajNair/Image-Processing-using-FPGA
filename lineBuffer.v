`timescale 1ns / 1ps

module lineBuffer(
    input clk,
    input rst,
    input [7:0] inData,
    input inDataValid,
    input inReadData,
    output [23:0] outData
);

reg [7:0] line [511:0];
reg [8:0] wrPointer;
reg [8:0] rdPointer;

always @(posedge clk)
begin
    if(inDataValid)
        line[wrPointer] <= inData;
end

always @(posedge clk)
begin
    if(rst)
        wrPointer <= 0;
    else if(inDataValid)
        wrPointer <= wrPointer + 1;
end

assign outData = {line[rdPointer],line[rdPointer+1],line[rdPointer+2]};

always @(posedge clk)
begin
    if(rst)
        rdPointer <= 0;
    else if(inReadData)
        rdPointer <= rdPointer + 1;
end

endmodule