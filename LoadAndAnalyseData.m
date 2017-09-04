DataStructNameChan0='EEGDev1ai0';
DataStructNameChan1='EEGDev1ai1';

%Convert all *.tdms files in folder 
%simpleConvertTDMS writes .mat file
FileListTDMS = dir('*.tdms');
N = size(FileListTDMS,1);

for k = 1:N
    TempFileName=FileListTDMS(k).name;
    TempTDMS=simpleConvertTDMS(TempFileName);
end
%%
%Initialise Variables

PointsToSample=200000;
NumWavelets = 10;
MinFreq = 2;
MaxFreq = 50;


%%
%For each file, load the file and store n=PointsToSample of EEG in
%DataArray
if exist('DataArray')==1
    clear(DataArray);
end


FileListM=dir('*.mat');
N = size(FileListM,1);
for k=1:N
    load(FileListM(k).name);
    RecordName=FileListM(k).name;
    RecordName=strrep(RecordName, '.mat', '');   %Remove .mat suffix
    RecordName=strrep(RecordName, ' ', '_');  %Replace spaces with _
    RecordName=strrep(RecordName, '-', '_'); %Replace - with _
       
    if strncmp(RecordName, 'R', 1)==1
            Data=EEGDev1ai0.Data;
            SamplingFreq=1/EEGDev1ai0.Property.wf_increment;
            LastTimePoint=(EEGDev1ai0.Total_Samples-1)*SamplingFreq;
    elseif strncmp(RecordName, 'L', 1)==1
            Data=EEGDev1ai1.Data;
            SamplingFreq=1/EEGDev1ai1.Property.wf_increment;
            LastTimePoint=(EEGDev1ai1.Total_Samples-1)*SamplingFreq;
    else
            error('Channel error');
    end
    
    Data=Data(1:PointsToSample);
    DataArray(:, :, k)=Data;
 
    %plot(0:SamplingFreq:LastTimePoint, Data)
            
end
%% 
%Create morlet wavelets for transform
i=6;
[FreqList, n_data, n_convolution, n_conv_pow2, HalfWaveletSize, fftWaveletFamily]=CreateWavelet(DataArray(:,:,i), NumWavelets, MinFreq, MaxFreq, SamplingFreq);

%% 
%Run Wavelet Transform
WaveletData=RunWaveletTransform(NumWavelets, DataArray(:,:,i), n_data, n_convolution, n_conv_pow2, HalfWaveletSize, fftWaveletFamily);

%%
%Plot
Times=linspace(0,(n_data-1)/SamplingFreq, n_data);
figure; 
subplot(2,1,1);
contourf(Times, FreqList, squeeze(WaveletData(:, 1, :)), 40, 'linecolor','none');
subplot(2,1,2);
plot(Times, DataArray(:,:,i))
