clc;
clear all;
%% Speech Enhancement and Object Evaluation Program
environment = ["car", "restaurant", "train"];
dB = ["0", "5", "10", "15"];
method = ["wiener", "SS"];
[clean_speech, fs]= audioread('..\female\sp30.wav');
aInfo = audioinfo('..\female\sp30.wav');
nbits = aInfo.BitsPerSample; % 16 bits resolution
for i = 1:length(environment)
    for j = 1:length(dB)
        infile = strcat('..\female\', environment(i), '\in\sp30_', ... 
            environment(i), '_sn', dB(j), '.wav');
        [noisy_speech{i,j}, fs]= audioread(infile);
        for k = 1:length(method)
            outfile = strcat('..\female\', environment(i), '\out\', method(k), ...
                '_sp30_', environment(i), '_sn', dB(j), '.wav');
            if k == 1
                [enhanced_wiener{i,j}, fs, nbits] = wiener_as(infile, outfile);
            elseif k == 2
                [enhanced_ss{i,j}, Srate] = specsub(infile, outfile);
            end
            fwSNRseg((i-1)*length(dB)+j,k) = comp_fwseg('..\female\sp30.wav', outfile);
            LLR((i-1)*length(dB)+j,k) = comp_llr('..\female\sp30.wav', outfile);
            PESQ((i-1)*length(dB)+j,k) = pesq('..\female\sp30.wav', outfile);
        end
    end
end
all_result = table(fwSNRseg, LLR, PESQ);
%% Plot Signal in Time and Frequency Domain
% [SNR((i-1)*length(dB)+j,k), segSNR((i-1)*length(dB)+j,k), LLR((i-1)*length(dB)+j,k), ...
%                  PESQ((i-1)*length(dB)+j,k), SIG((i-1)*length(dB)+j,k), BAK((i-1)*length(dB)+j,k), ...
%                  OVL((i-1)*length(dB)+j,k)] = composite('..\female\sp30.wav', outfile);
% all_result2 = table(SNR, segSNR, SIG, BAK, OVL);
for i = 1:length(environment)
    %signal plot in time domain
    figure();
    subplot(4,1,1), plot((1:length(clean_speech))/fs,clean_speech);
    title('Clean Speech');
    xlabel('Time (s)');ylabel('Amplitude');
    subplot(4,1,2), plot((1:length(noisy_speech{i,1}))/fs,noisy_speech{i,1});
    title('Noisy Speech');
    xlabel('Time (s)');ylabel('Amplitude');
    subplot(4,1,3), plot((1:length(enhanced_wiener{i,1}))/fs,enhanced_wiener{i,1});
    title('Wiener Enhanced Speech');
    xlabel('Time (s)');ylabel('Amplitude');
    subplot(4,1,4), plot((1:length(enhanced_ss{i,1}))/fs,enhanced_ss{i,1});
    title('SS Enhanced Speech');
    xlabel('Time (s)');ylabel('Amplitude');
    %signal plot in frequency domain
    figure();
    subplot(4,1,1), specgram(clean_speech,160*2,fs,hamming(160),80);
    title('Clean Speech');
    xlabel('Time (s)');ylabel('Frequency (Hz)');
    subplot(4,1,2), specgram(noisy_speech{i,1},160*2,fs,hamming(160),80);
    title('Noisy Speech');
    xlabel('Time (s)');ylabel('Frequency (Hz)');
    subplot(4,1,3), specgram(enhanced_wiener{i,1},160*2,fs,hamming(160),80);
    title('Wiener Enhanced Speech');
    xlabel('Time (s)');ylabel('Frequency (Hz)');
    subplot(4,1,4), specgram(enhanced_ss{i,1},160*2,fs,hamming(160),80);
    title('SS Enhanced Speech');
    xlabel('Time (s)');ylabel('Frequency (Hz)');
end