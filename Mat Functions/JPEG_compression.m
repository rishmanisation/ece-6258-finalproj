%ECE6258: Digital image processing 
%Prof. Ghassan Alregib 
%School of Electrical and Computer Engineering 
%Georgia Instiute of Technology 
%
% Edit the sections labeled with "EDIT THIS PART"
%
%Date Modified : 10/10/2016 by Motaz Alfarraj (motaz@gatech.edu)  
%% 
close all
clear all
%clc

%% STEP 1: Loading the image 
% EDIT THIS PART
X = imread('I05.bmp'); %read the image 

%% STEP 2: Converting to YCbCr
% EDIT THIS PART
X = rgb2ycbcr(X); %Convert to YCbCr

%% STEP 3: Keeping only the luminance channel 
% EDIT THIS PART
X = X(:,:,1); % Keep the luminance channel only. 

%% DO NOT EDIT THIS PART
% imshow(X,[]); 
% title('Grayscale image'); 

%% STEP 4: Calculating the entropy of the image 
% EDIT THIS PART
H = entropy(X); % calculate the entropy of the greyscale image

%% DO NOT EDIT THIS PART
fprintf('Entropy of the grayscale image = %0.3f Bits/pixel\n',H); 
clear H; 
%% STEP 5: Coding of the original image
% EDIT THIS PART
XBitStream = ImageEncode(X); %Encode the image using the provided function 
XBitRate = length(XBitStream)/numel(X); %Calculate the bitRate 

%% DO NOT EDIT THIS PART
fprintf('Bit rate of the original image = %0.3f bits/pixel\n',XBitRate);

%clear XBitRate 
clear XBitStream

%% STEP 6: Subtract 127
% EDIT THIS PART
X = double(X); %Change X to double 
X = X - 127; %Subtract 127 from each pixel


%% STEP 7: Block-wise DCT
blocksize = 8; 

%EDIT THIS PART
fun = @(block_struct) dct2(block_struct.data);
X_DCT = blockproc(X,[8 8],fun);
% use blockproc and dct2 to calculate blockwise DCT.
                       % (type "help blockproc" to learn how about this
                       % function. 
%% DO NOT EDIT THIS PART 
% figure 
% imshow(X_DCT,[]); 
% title(['Block-wise DCT coefficients - Blocksize =', num2str(blocksize),'x',num2str(blocksize)]); 
%% STEP 8: Quantization 
c = 1;
Q =         [16 11 10 16  24  40  51  61
            12 12 14 19  26  58  60  55
            14 13 16 24  40  57  69  56
            14 17 22 29  51  87  80  62
            18 22 37 56  68 109 103  77
            24 35 55 64  81 104 113  92
            49 64 78 87 103 121 120 101
            72 92 95 98 112 100 103 99];
        
% EDIT THIS PART
fun = @(block_struct) round(block_struct.data./(c.*Q));
XQ = blockproc(X_DCT,[8 8],fun);  %use blockproc to quantize the X_DCT in blocks  

%% DO NOT EDIT THIS PART
clear X_DCT; 
% figure 
% imshow(XQ,[]); 
% title('Quantized DCT coefficients'); 
%% STEP 9: Entropy Coding 
[XQBitStream, Dictionary] = ImageEncode(XQ); %You don't need to edit this line

% EDIT THIS PART
XQBitRate = length(XQBitStream)/numel(XQ); %calculate the bit rate

%% DO NOT EDIT THIS PART
fprintf('Bit rate of the compressed image = %0.3f bits/pixel\n',XQBitRate);    
%clear XQBitRate; 
clear XQ; 
%% STEP 10: Saving the bitstream to a binary file
% DO NOT EDIT THIS PART
BitStreamFile = fopen('CompressedLena.bin','w');
fwrite(BitStreamFile,XQBitStream,'ubit1'); 
fclose all; 
clear BitStreamFile XQBitStream

%% STEP 11-i: Read the binary file

% DO NOT EDIT THIS PART
BitStreamFile = fopen('CompressedLena.bin','r');
XQBitStream = fread(BitStreamFile,'ubit1'); 
fclose all; 

%% STEP 11-ii: Decoding 
% EDIT THIS PART 
XQDecoded = huffmandeco(XQBitStream,Dictionary); 
%Use the function huffmandeco to decode
                                      %the BitStream. Use the dictionary obtained 
                                      % in STEP 9. 

%% DO NOT EDIT THIS PART 
XQDecoded = XQDecoded(1:prod(size(X))); 
XQ_reconstructed = reshape(XQDecoded,size(X,1),size(X,2));

%% STEP 12: Dequantization 

fun = @(block_struct) round(block_struct.data.*(c.*Q));
XdeQ_reconstructed = blockproc(XQ_reconstructed,[8 8],fun);

%% STEP 13: Inverse DCT
%EDIT THIS PART
fun = @(block_struct) idct2(block_struct.data);
X_reconstructed = blockproc(XdeQ_reconstructed,[8 8],fun);
% use blockproc and idct2 to calculate blockwise iDCT of XdeQ_reconstructed. 
 
%% STEP 14: Add 127 to every pixel. 
X_reconstructed = X_reconstructed + 127;
% Add 127 to all pixels in X_reconstructed

%% DO NOT EDIT THIS PART
% figure 
% imshow(X_reconstructed,[]); 
% title('Reconstructed image'); 

X = X+127; 
Xrbitstream = ImageEncode(round(X_reconstructed));
Xrbitrate = length(Xrbitstream)/numel(X_reconstructed)

%% STEP 15: Calculating MSE and PSNR
MSE = mean(mean((X_reconstructed-X).^2)); %Calculate MSE 
PSNR = psnr(X_reconstructed,X,255); 
%Calculate PSNR. Use MATLAB function psnr and set PEAKVAL to 255

%% DO NOT EDIT THIS PART
fprintf('MSE = %0.2f\n',MSE); 
fprintf('PSNR = %0.2f dB\n',PSNR); 
