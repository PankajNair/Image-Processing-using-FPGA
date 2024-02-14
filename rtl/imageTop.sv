`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.02.2024 17:18:09
// Design Name: 
// Module Name: imageTop
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


module imageTop(
input logic clk, reset_n,
input logic [1:0] modeSelect,
//Slave interface
input logic [7:0] inData,
input logic inDataValid,
output logic outDataReady,
//Master interface
output logic [7:0] outData,
output logic outDataValid,
input logic inDataReady,
//Interrupt
output logic interrupt
    );

logic [71:0] pixelData;
logic [7:0] convolvedData;
logic pixelDataValid, convolvedDataValid; 
logic axisProgFull;

assign outDataReady = !axisProgFull;

imageControl imageControl(
.clk(clk), 
.reset(!reset_n),
.inData(inData),
.inDataValid(inDataValid),
.outData(pixelData),
.outDataValid(pixelDataValid),
.interrupt(interrupt)
    );

convolution convolution(
.clk(clk),
.inData(pixelData),
.inDataValid(pixelDataValid),
.modeSelect(modeSelect),
.outData(convolvedData),
.outDataValid(convolvedDataValid)
    );

outputBuffer outputBuffer(
.wr_rst_busy(),      
.rd_rst_busy(),       
.s_aclk(clk),                 
.s_aresetn(reset_n),           
.s_axis_tvalid(convolvedDataValid),    
.s_axis_tready(),    
.s_axis_tdata(convolvedData),     
.m_axis_tvalid(outDataValid),   
.m_axis_tready(inDataReady),   
.m_axis_tdata(outData),      
.axis_prog_full(axisProgFull)  
);

endmodule
