function [BitStream,Dictionary] = ImageEncode(X)
%ECE6258: Digital image processing 
%Prof. Ghassan Alregib 
%School of Electrical and Computer Engineering 
%Georgia Instiute of Technology 
%
% This function take an image X as input and returns encoded bits of 
% the image in the variable BitStream and the Huffman dictionary to decode
% the BitStream. 
% Exmple: 
%           X = imread('cameraman.tif'); 
%           [BitStream,Dictionary] = ImageEncode(X); 
%
% To decode an image use: 
%           X_decoded = huffmandeco(BitStream,Dictionary); 
%           X_decoded = reshape(X_decoded,size(X,1),size(X,2)); 
%
% Date Modified : 10/10/2016 by Motaz Alfarraj (motaz@gatech.edu)  
%% 
X = double(X); 
symbols = unique(X(:)); 
count = hist(X(:),symbols); 
prob = count/sum(count); 
Dictionary = huffmandict(symbols, prob); 
BitStream = huffmanenco(X(:),Dictionary);

end 