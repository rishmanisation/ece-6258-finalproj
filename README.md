# ece-6258-finalproj
Digital Image Processing Final Project: Under further development

The project applies the UNIQUE algorithm to image compression. UNIQUE stands for UNsupervised Image QUality Estimation.

There are 3 folders:

1. Filters : This folder contains the filter.mat file. The file includes three variables:
 		W = filter weights (400 x 192 matrix)
		b = bias vector (400 x 1 vector)
		optTheta = used for generating reconstruction filter weights and bias vector (154192 x 1 vector)

2. Images :  10 images of .BMP format. Images are numbered I01 through I10. Prior to execution of the main function, the image must be read using imread:
		I = imread('I01.bmp');  % replace I01.bmp with the filename of the desired image
	     There is no need to convert the image matrix to double, as this is taken care of in the main function.

3. Mat Files : This folder contains the following functions/files:
		displayColorNetwork.m - Displaying filters. Usage - displayColorNetwork((W*ZCAWhite)');
	       	ygcr2rgb.m - Function to convert processed YGCr images to RGB. Usage - img_rgb = ygcr2rgb(img_ygcr);
		ImageEncode.m - Function to convert an image into a bitstream and a dictionary (i.e. performs Huffman coding). 
				Usage: [Bitstream,Dictionary] = ImageEncode(I);
		RunLength_M.m - MATLAB function to perform Run Length Coding. Usage: ENCODING: [b,n] = RunLength_M(vector);
										     DECODING: b_decoded = RunLength_M(b,n);
		NOTE: This function was written by Jan Simon and is available at: https://www.mathworks.com/matlabcentral/fileexchange/41813-runlength
		UNIQUECompression.m - Function that uses the UNIQUE algorithm to compress images. Usage: ProcessedImage = UNIQUECompression(Image);
					NOTE: The input to this function is the image matrix, NOT a filename.
		RunLength_ReadMe.txt - A Readme for the RunLength coding functions and the associated files.
        JPEG_compression.m - Code for the JPEG compression from the paper. 
        
Instructions:

1. Read images from the Images folder. For example, I = imread('I01.bmp');
2. Use the UNIQUECompression function to compress the image and obtain the reconstructed image as follows: ProcessedImage = UNIQUECompression(I);

NOTE: The function will take around 5 minutes to fully run.

Miscellaneous:

If a more efficient implementation of Run Length coding is desired, the function RunLength.m can be used instead of RunLength_M.m. The usage syntax is the same, i.e.

ENCODING: [b,n] = RunLength(vector);
DECODING: b_decoded = RunLength(b,n);

The difference between RunLength_M and RunLength is that RunLength uses a C program to implement the function. In order to make this work, the MinGW-w64 compiler v4.9.2 will have to 
be downloaded. This can be done in either of the following two ways:

1. In MATLAB itself, navigate to the 'HOME' tab. Click on 'Add-Ons', and then 'Get Add-Ons'. Then, either enter 'MinGW' in the search box on click on 'Features' under 'Refine by Type'.

OR

2. Download from here: https://sourceforge.net/projects/tdm-gcc/files/TDM-GCC%20Installer/Previous/1.1309.0/ (You MUST download version 4.9.2).

If the second method was followed, then you must also complete the additional set-up steps: https://www.mathworks.com/help/matlab/matlab_external/compiling-c-mex-files-with-mingw.html

Once this is done, uncomment the line 'mex RunLength.c' (it is line 111 in UNIQUECompression.m) and replace the two occurrences of 'RunLength_M' (lines 114 and 124 respectively) with
'RunLength'.

More information regarding RunLength can be found in the file 'RunLength_ReadMe.txt'. 



