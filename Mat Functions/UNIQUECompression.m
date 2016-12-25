function ProcessedImage = UNIQUECompression(Img)
%This is a function that compresses images based on the UNIQUE algorithm.
%UNIQUE stands for UNsupervised Image QUality Estimation.
%Reference for UNIQUE can be found at:
%http://ieeexplore.ieee.org/document/7546870/

%% PART 1: Preprocessing
% Images and filters are loaded below. 

% Loading images and mat Files
img = im2double(Img);

% ColorSpace transformation
img1 = rgb2ycbcr(img);
img1(:,:,2) = img(:,:,2);

% Load mat files           
workspace = load('../Filters/ImageNet_Weights_YGCr.mat');
W1 = workspace.W;
b1 = workspace.b;
optTheta = workspace.optTheta;

hiddenSize  = size(W1,1);
visibleSize = size(W1,2);

W2 = reshape(optTheta((visibleSize * hiddenSize)+1:2*visibleSize * hiddenSize), visibleSize, hiddenSize);
b2 = optTheta(2*hiddenSize*visibleSize+1+hiddenSize:2*hiddenSize*visibleSize+hiddenSize+visibleSize);

I = img1;
Igs = img1(:,:,1);
origEnt = entropy(Igs);
fprintf('Entropy of the original image = %0.2f bits/pixel\n',origEnt);

%Parameter Initialisation
[m,n,~] = size(I);
epsilon = 0.01; 
count = 1; 
scale = 8;
scaling = zeros(size(I));

%Convert m x n x 3 image into (scale x scale x 3) x count patches. 
%patch_count is a variable to count the number of patches during 
%reconstruction
i = 1;
patch_count = 1;
while (i < m - (scale - 2))
    j = 1;
    patch_count = 1;
    while (j< n-(scale-2)) 
        scaling(i:i+(scale-1),j:j+(scale-1),:) = scaling(i:i+(scale-1),j:j+(scale-1),:) + 1;
        patch_temp = I(i:i+(scale-1),j:j+(scale-1),:);
        patches(:,count) = reshape(patch_temp,[],1);
        count = count+1;
        j = j+1;
        patch_count = patch_count+1;
    end    
    i = i+1;
end

% Subtract mean patch 
meanPatch = mean(patches, 2);  
MeanAllPatch = repmat(meanPatch,1,size(patches,2));
patches = bsxfun(@minus, patches, meanPatch);

% Apply ZCA whitening
sigma = patches * patches' / (count-1);
[u, s, v] = svd(sigma);
ZCAWhite = u * diag(1 ./ sqrt(diag(s) + epsilon)) * u';
patches = ZCAWhite * patches;

%% PART 2: IMAGE COMPRESSION
% Now the distorted image has been converted to patches and preprocessed.
% W1, b1 represent the forward filters and W2,b2 represent the reconstruction filters.
% As an example, usage of filters and reconstruction is shown. Comment out
% this code later

% Think of the DCT and IDCT as filter banks using the respective basis functions. 
% Thus, the compression technique can follow the same procedure as the JPEG 
% technique, except that the DCT and IDCT are replaced by W1,b1 and W2,b2 
% respectively.

% PART 1: Forward Transform
% This part involves applying the forward filters (i.e. W1,b1) and passing
% the result through a sigmoid layer.

feature_full = W1 * patches + repmat(b1,1,size(patches,2));

% Pass it through a sigmoid layer to obtain the final feature vector
feature_full1 = 1./(1 + exp(-(feature_full)));

% PART 2: Quantization
% Here, the values are multiplied by 100 and then rounded to the nearest integers.
% feature_full1r is the difference between the original feature vector and
% the vector with coefficients rounded.

feature_full1r = feature_full1 - round(feature_full1); 
feature_full1 = feature_full1*100;
feature_full1 = round(feature_full1);

% PART 3: Encoding and Decoding
% Both Run-Length Coding and Huffman Coding are used. In order to improve
% performance, Huffman coding is only performed on streams shorter than a
% certain threshold length (set to 60000 in this case). The larger the
% value, the more time the program is likely to take to run. However, the
% reconstruction would be more accurate.

[R,~] = size(feature_full1);
numofbits = 0; 
numofel = 0;

%mex RunLength.c

for i = 1:R
    [b,n] = RunLength_M(feature_full1(i,:));
    if(length(b) < 30000)
        [bitstream,dictionary] = ImageEncode(b);
        b_dec = huffmandeco(bitstream,dictionary);
        numofbits = numofbits + length(bitstream);
        numofel = numofel + length(b);
    else
        b_dec = b;
    end
    b_dec = reshape(b_dec,1,length(b_dec));
    feature_full1(i,:) = RunLength_M(b_dec,n);
end

compBitRate = numofbits/numofel;
fprintf('Bit rate of the compressed image = %0.2f bits/pixel\n',compBitRate);

% PART 4: Dequantization
% The aim here is to reverse the effects of the quantization. Thus, each
% element of the feature matrix is first divided by 100. Then, we 'unround'
% each element by adding back feature_full1r.

feature_full1 = feature_full1./100;
feature_full1 = feature_full1 + feature_full1r;

%PART 5: Reconstruction
% Here the reconstruction filters (W2,b2) are used on feature_full1. The
% obtained vector can then be reconstructed into the image using UNIQUE.

features_reconstructed = W2*feature_full1 + repmat(b2,1,size(patches,2));
features_reconstructed = pinv(ZCAWhite)*features_reconstructed;
features_reconstructed = features_reconstructed + MeanAllPatch;

%% PART 3: Image Reconstruction

%Reconstruct it back as before. Except now, the image has undergone a
%domain transformation from pixel space to feature space
[~,col] = size(features_reconstructed);
row_ind = 1;
col_ind = 1;
count_patch = 1;
feature = zeros(size(img));

for ii = 1:col
    feature(row_ind:row_ind+(scale-1),col_ind:col_ind+(scale-1),1:3) = feature(row_ind:row_ind+(scale-1),col_ind:col_ind+(scale-1),1:3) + reshape(features_reconstructed(:,ii),scale,scale,3);
    col_ind = col_ind + 1;
    count_patch = count_patch+1;
    if count_patch == (patch_count)
        row_ind = row_ind+1;
        col_ind = 1;
        count_patch = 1;
    end
end

ProcessedImage = feature./scaling;
PIgs = ProcessedImage(:,:,1);
recEnt = entropy(PIgs);
fprintf('Entropy of the reconstructed image = %0.2f bits/pixel\n',recEnt);

ProcessedImage = ygcr2rgb(ProcessedImage);
imagesc(ProcessedImage);
end