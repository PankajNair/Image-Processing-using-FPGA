`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.03.2023 15:51:56
// Design Name: 
// Module Name: imageProcessTop
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

module imageProcessTop(
    input axi_clk,
    input axi_reset_n,
//slave interface
    input inDataValid,
    input [7:0] inData,
    output outDataReady,
//master interface
    output outDataValid,
    output [7:0] outData,
    input inDataReady,
//interrupt
    output intr
);

wire [71:0] pixelData;
wire pixelDataValid;
wire axisProgFull;
wire [7:0] convolvedData;
wire convolvedDataValid;

assign outDataReady = !axisProgFull;
    
imageControl IC(
  .clk(axi_clk),
  .rst(!axi_reset_n),
  .inPixelData(inData),
  .inPixelDataValid(inDataValid),
  .outPixelData(pixelData),
  .outPixelDataValid(pixelDataValid),
  .intr(intr)
);    
  
conv conv(
  .clk(axi_clk),
  .inPixelData(pixelData),
  .inPixelDataValid(pixelDataValid),
  .outConvolvedData(convolvedData),
  .outConvolvedDataValid(convolvedDataValid)
); 
 
outBuffer OB (
  .wr_rst_busy(),        // output wire wr_rst_busy
  .rd_rst_busy(),        // output wire rd_rst_busy
  .s_aclk(axi_clk),                  // input wire s_aclk
  .s_aresetn(axi_reset_n),            // input wire s_aresetn
  .s_axis_tvalid(convolvedDataValid),    // input wire s_axis_tvalid
  .s_axis_tready(),    // output wire s_axis_tready
  .s_axis_tdata(convolvedData),      // input wire [7 : 0] s_axis_tdata
  .m_axis_tvalid(outDataValid),    // output wire m_axis_tvalid
  .m_axis_tready(inDataReady),    // input wire m_axis_tready
  .m_axis_tdata(outData),      // output wire [7 : 0] m_axis_tdata
  .axis_prog_full(axisProgFull)  // output wire axis_prog_full
); 
   
endmodule
