# Image Processing using FPGA
## Problem Statement
Image processing is a critical application in many fields, including medical imaging, surveillance, robotics, and automotive systems. FPGAs have gained popularity as a hardware platform for implementing image processing algorithms due to their flexibility, reconfigurability, and parallel processing capabilities. Using FPGA for image processing allows customization of the hardware architecture to meet the specific requirements of the application. This enables the implementation of specialized image processing algorithms that may not be available in standard software libraries.  With the right expertise and hardware design, FPGA-based image processing systems can provide customized and optimized solutions for various image processing applications.

The following is the design for a FPGA-based image processing system based on the neighbourhood image processing algorithm. 
## Data Information
The input is a 512 x 512 grayscale Bitmap file.
## Project Pipeline
* Line Buffer Module (lineBuffer): There four line buffers in the design. The line buffers are used to store the pixel data from the input image and feed it to the convolution module. Three line buffers are used to store the data and the fourth line buffer is used for improving the performace by reducing the delay required for sending and storing the data.
* Convolution Module (conv): This module uses a 3 x 3 kernel for convolution with the input data. It is capable of performing four operations: BLUR, OUTLINE, SHARPEN and EMBOSS.
* Image Control Module (imageControl): This module controls the flow of data from the line buffer to convolution module.
* Output Buffer Module (outBuffer): This is a FIFO Generator from the Xilinx IP core. This module is used to synchronize the incoming convolved data before outputting it due to pipelining in the Convolution Module.
* Top Module (imageProcessTop): This is the topmost module which is used to connect all other modules in the design.
