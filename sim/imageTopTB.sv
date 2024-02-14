`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.02.2024 17:23:57
// Design Name: 
// Module Name: imageTopTB
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


`define headerSize 1080
`define imageSize 512*512

module imageTopTB();
logic clk = 0, reset_n;
logic [1:0] modeSelect;
logic [7:0] inData;
logic inDataValid;
logic outDataReady;
logic [7:0] outData;
logic outDataValid;
logic interrupt;

imageTop uut(
.clk(clk), 
.reset_n(reset_n),
.modeSelect(modeSelect),
.inData(inData),
.inDataValid(inDataValid),
.outDataReady(outDataReady),
.outData(outData),
.outDataValid(outDataValid),
.inDataReady(1'b1),
.interrupt(interrupt)
    );

always
begin
    #5 clk = !clk;
end

integer sentSize, receivedSize = 0; 
integer file1, file2, file3; 

initial
begin
    reset_n = 1'b0;
    inDataValid = 1'b0;
    sentSize = 0;
    modeSelect = 2'b10;
    #100
    reset_n = 1'b1;
    #100
    file1 = $fopen("lena_gray.bmp", "rb");
    file2 = $fopen("output_lena.bmp", "wb");
    file3 = $fopen("imageData.h", "w");
    for(int i=0;i<`headerSize;i=i+1)
        begin
            $fscanf(file1, "%c", inData);
            $fwrite(file2, "%c", inData);
        end
    for(int i=0;i<4*512;i=i+1)
        begin
            @(posedge clk)
            $fscanf(file1, "%c", inData);
            $fwrite(file3, "%0d,", inData);
            inDataValid = 1'b1;
        end
    sentSize = 4*512;
    @(posedge clk)
    inDataValid = 1'b0;
    while(sentSize<`imageSize)
        begin
            @(posedge interrupt)
            for(int i=0;i<512;i=i+1)
            begin
                @(posedge clk)
                $fscanf(file1, "%c", inData);
                $fwrite(file3, "%0d,", inData);
                inDataValid = 1'b1;
            end
            @(posedge clk)
            inDataValid = 1'b0;
            sentSize = sentSize+512;
        end
    @(posedge clk)
    inDataValid = 1'b0;
    @(posedge interrupt)
    for(int i=0;i<512;i=i+1)
        begin
            @(posedge clk)
            inData = 0;
            $fwrite(file3, "%0d,", 0);
            inDataValid = 1'b1;
        end
    @(posedge clk)
    inDataValid = 1'b0;
    @(posedge interrupt)
    for(int i=0;i<512;i=i+1)
        begin
            @(posedge clk)
            inData = 0;
            $fwrite(file3, "%0d,", 0);
            inDataValid = 1'b1;
        end
    $fclose(file1);
    $fclose(file3);
end

always @(posedge clk)
begin
    if(outDataValid)
        begin
            $fwrite(file2, "%c", outData);
            receivedSize = receivedSize+1;
        end
    if(receivedSize == `imageSize)
        begin
            $fclose(file2);
            $stop;
        end
end
endmodule
