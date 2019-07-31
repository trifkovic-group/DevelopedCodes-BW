%This source code calculate the Fractal dimension using multi-resolution
%calculation.
%Author: Tan H. Nguyen
%University of Illinois at Urbana-Champaign
function demo
    clc;
    clear all;
    close all;
    I = imread('http://4.bp.blogspot.com/-aHCfmDvyzFU/Un_U-Neo_GI/AAAAAAAAGpQ/DWzjztkh4HM/s1600/sierpinski.png');
    Ibw = ~im2bw(I); %Note that the background need to be 0
    figure(1);
    imagesc(Ibw);
    colormap gray;
    tic
    dim_val=BoxCountfracDim(Ibw) %Compute the box-count dimension
    toc
end

