function WaveletData=RunWaveletTransform(NumWavelets, WaveToTransform, n_data, n_convolution, n_conv_pow2, HalfWaveletSize, fftWaveletFamily)
    for fi=1:NumWavelets
        fftData=fft(reshape(WaveToTransform, 1, n_data), n_conv_pow2);       %FFT of EEG data. I think the reshape is redundant here. The n_conv_pow2 size of fft is for efficinecy
        %fft_wavelet=fft(sqrt(1/(s(fi)*sqrt(pi))) * exp(2*1i*pi*freq_list(fi).*timeW) .* exp(-timeW.^2./(2*(s(fi)^2))), n_conv_pow2); %FFT of wavelet. I tried doing FFT of all wavelet family once, but this gave errors. Could try again
        fftWavelet=fftWaveletFamily(fi, :);
        convolution=ifft(fftData.*fftWavelet, n_conv_pow2); %IFFT of fft multiplication
        convolution2=convolution(1:n_convolution);
        convolution3=convolution2(HalfWaveletSize+1:end-HalfWaveletSize);
        DataFilt=real(convolution3);
        DataPower=abs(convolution3).^2;
        DataPhase=angle(convolution3);
        WaveletData(fi, 1, :)=DataPower;
        WaveletData(fi, 2, :)=DataPhase;
    end 
end
