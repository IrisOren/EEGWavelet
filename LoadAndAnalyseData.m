%DataStructNameChan0='EEGDev1ai0';
%DataStructNameChan1='EEGDev1ai1';

%Convert all *.tdms files in folder 
%simpleConvertTDMS writes .mat file

%Uncomment below if files need conversion
%FileListTDMS = dir('*.tdms');
%N = size(FileListTDMS,1);

%for k = 1:N
 %   TempFileName=FileListTDMS(k).name;
 %   TempTDMS=simpleConvertTDMS(TempFileName);
%end

%%
%Initialise Variables

PointsToSample=800000;
NumWavelets = 10;
MinFreq = 2;
MaxFreq = 50;


%%
%For each file, load the file and store n=PointsToSample of EEG in
%DataArray
if exist('DataArray')==1
    clear('DataArray');
    clear('RecordNameVector');
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
    %RecordNameVector(k)=RecordName;
    %plot(0:SamplingFreq:LastTimePoint, Data)
            
end
%% 
%Create morlet wavelets for transform
for i=1:N;
    [FreqList, n_data, n_convolution, n_conv_pow2, HalfWaveletSize, fftWaveletFamily]=CreateWavelet(DataArray(:,:,i), NumWavelets, MinFreq, MaxFreq, SamplingFreq);


    %Run Wavelet Transform
    WaveletData=RunWaveletTransform(NumWavelets, DataArray(:,:,i), n_data, n_convolution, n_conv_pow2, HalfWaveletSize, fftWaveletFamily);


    %Plot
    RecordName=FileListM(i).name;
    RecordName=strrep(RecordName, '.mat', '');   %Remove .mat suffix
    RecordName=strrep(RecordName, ' ', '_');  %Replace spaces with _
    RecordName=strrep(RecordName, '-', '_'); %Replace - with _
    Filename=strcat('WaveletFigs/',RecordName,'.jpg');

    Times=linspace(0,(n_data-1)/SamplingFreq, n_data);
    figure; 
    subplot(2,1,1);
    contourf(Times, FreqList, squeeze(WaveletData(:, 1, :)), 40, 'linecolor','none');
    subplot(2,1,2);
    plot(Times, DataArray(:,:,i))
    title(RecordName);

    saveas(gcf, Filename);
    
    close
end

%%
%PSD and calculation of power in specified band btwn fMin and fMax
fMin=10;
fMax=30;
PowerValues=zeros(N,1);
for i=1:N
    if exist('PSD', 'dir')==0
        mkdir 'PSD'
    end
    [fy,f]=FFT(DataArray(:,:,i), SamplingFreq, 0);
    RecordName=FileListM(i).name;
    RecordName=strrep(RecordName, '.mat', '');   %Remove .mat suffix
    RecordName=strrep(RecordName, ' ', '_');  %Replace spaces with _
    RecordName=strrep(RecordName, '-', '_'); %Replace - with _
    Filename=strcat('PSD/',RecordName,'.jpg');
    saveas(gcf, Filename);
    
    IndexMin=min(find(f>fMin));
    IndexMax=min(find(f>fMax));
    fSubset=f(IndexMin:IndexMax);
    % PSD
    Power=fy.*conj(fy);
    PowerSubset=Power(IndexMin:IndexMax);
    PowerValues(i)=trapz(fSubset, PowerSubset);
    
    
    
    
end
Repetitions=N/2;
figure; scatter([1:Repetitions], PowerValues(Repetitions+1:2*Repetitions)),
xlabel('EEG sample time'),
ylabel('Power in 10-30Hz');
saveas(gcf, 'PSD/PSDSummary.jpg');

%%
%Morlet wavelet at 20Hz
NumWavelets=1;
MinFreq=20;
MaxFreq=20;
for i=1:N
    if exist('SingleWavelet', 'dir')==0
        mkdir 'SingleWavelet'
    end
    [FreqList, n_data, n_convolution, n_conv_pow2, HalfWaveletSize, fftWaveletFamily]=CreateWavelet(DataArray(:,:,i), NumWavelets, MinFreq, MaxFreq, SamplingFreq);
    WaveletData=RunWaveletTransform(NumWavelets, DataArray(:,:,i), n_data, n_convolution, n_conv_pow2, HalfWaveletSize, fftWaveletFamily);
    figure; plot(Times, squeeze(WaveletData(1, 1, :)));
    RecordName=FileListM(i).name;
    RecordName=strrep(RecordName, '.mat', '');   %Remove .mat suffix
    RecordName=strrep(RecordName, ' ', '_');  %Replace spaces with _
    RecordName=strrep(RecordName, '-', '_'); %Replace - with _
    Filename=strcat('SingleWavelet/',RecordName,'.jpg');
    saveas(gcf, Filename);
    close


    
end   