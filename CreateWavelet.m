%Function to create wavelet family for wavelet transforms of data
%Input:
%   NumWavelets=number of frequencies 
%   MinFreq, MaxFreq = Minumum and Maximum Frequencues
%   SampF=Frequency in Hz
%Output:
%   FreqList=List of Frequencies
%   n_data=Length of data
%   n_convolution=Length of convolution vector
%   HalfWaveletSize
%   fftWaveletFamily=Family of Wavelets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [FreqList, n_data, n_convolution, n_conv_pow2, HalfWaveletSize, fftWaveletFamily]=CreateWavelet(WaveToTransform, NumWavelets, MinFreq, MaxFreq, SampF)

    FreqList=logspace(log10(MinFreq), log10(MaxFreq), NumWavelets);
    %freq_list=linspace(min_freq, max_freq, num_wavelets);
    timeW = -2:1/SampF:2;               %+-2 needed for 2 Hz wavelet to go to 0
    s  = 6./(2*pi*FreqList);

    for fi=1:NumWavelets;
          wavelet=sqrt(1/(s(fi)*sqrt(pi))) * exp(2*1i*pi*FreqList(fi).*timeW) .* exp(-timeW.^2./(2*(s(fi)^2)));
          wavelet_family(fi,:) = wavelet; 
    end


    % definte convolution parameters
    n_wavelet            = length(timeW);
    n_data               = length(WaveToTransform); %EEG.pnts;  %*EEG.trials;        %single trial for each channel. If all trials, multiply by EEG.trials HAVEN'T TESTED
    n_convolution        = n_wavelet+n_data-1;
    n_conv_pow2          = pow2(nextpow2(n_convolution));
    HalfWaveletSize      = (n_wavelet-1)/2;

    %wavelet family convolution
    for fi=1:NumWavelets
        %fft_wavelet=fft(wavelet_family(fi), n_conv_pow2);
        fftWavelet=fft(sqrt(1/(s(fi)*sqrt(pi))) * exp(2*1i*pi*FreqList(fi).*timeW) .* exp(-timeW.^2./(2*(s(fi)^2))), n_conv_pow2);
        fftWaveletFamily(fi, :)=fftWavelet;
    end
end

