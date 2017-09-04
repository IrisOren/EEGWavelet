%This script is based on Ex13 from  Analysing Neural Times series data
%Input data is Data vector from LoadMioEEG

%To test: replace section between % % lines with the following
%%%%%%%%%%%%%%%%%%%
Fs = 1000;
t = linspace(0,5,5e3);
x = cos(2*pi*20*t).*(t<1)+cos(2*pi*50*t).*(3<t)+0.3*randn(size(t));
SampF=Fs;

Times=t;
%%%%%%%%%%%%%%%%%%

NumWavelets = 50;
MinFreq = 2;
MaxFreq = 100;

[FreqList, n_data, n_convolution, n_conv_pow2, HalfWaveletSize, fftWaveletFamily]=CreateWavelet(x, NumWavelets, MinFreq, MaxFreq, SampF);

WaveletData=RunWaveletTransform(NumWavelets, x, n_data, n_convolution, n_conv_pow2, HalfWaveletSize, fftWaveletFamily);

figure; 
subplot(2,1,1);
contourf(Times, FreqList, squeeze(WaveletData(:, 1, :)), 40, 'linecolor','none');
subplot(2,1,2);
plot(tReshape, x);
