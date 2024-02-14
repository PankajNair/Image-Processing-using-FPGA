# Image Processing using FPGA
The following is a design for an Image Processing IP for FPGAs based on the Neighborhood Processing algorithm. The IP is capable of performing four operations: BLUR, EDGE DETECTION, SHARPEN and EMBOSS. A 3x3 kernel is used to define each operation which can selected through switches on the FPGA.

![architecture]([https://github.com/PankajNair/Image-Processing-using-FPGA/blob/main/architecture.png])

The IP can be integrated with the ZYNQ processor to create an Image Processing System with a maximum operating frequency of approximately 105Mhz.

## Data Information
The input is a 512 x 512 grayscale BMP image.
## Project Pipeline
* Line Buffer Module (lineBuffer): The line buffers store the pixel data from the input image and feed it to the convolution module. Four line buffers are used to improve the performance by reducing the delay required for sending and storing the data.
* Convolution Module (convolution): This module uses four 3 x 3 kernels for convolution with the input data. The Multiply and Accumulation operations use the PL and are pipelined to meet timing constraints.
* Image Control Module (imageControl): This module controls the data flow from the line buffer to the convolution module.
* Output Buffer Module (outputBuffer): This is a FIFO Generator from the Xilinx IP core. This module synchronizes the incoming convolved data before outputting it due to pipelining in the convolution Module.
* Top Module (imageTop): This is the topmost module used to connect all other modules in the design.
