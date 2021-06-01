%transmitter
s1_f = 15 * 10^3; s2_f = 25 * 10^3;
[s1_data,fs] = audioread('s1_audio.wav');
[s2_data,fs] = audioread('s2_audio.wav');
%%display(length(s1_data));
%%display(length(s2_data));
%soundsc(s1_data,fs);
s1_data = s1_data(:,1);
s2_data = s2_data(:,1);
%soundsc(s1_data,fs);
resample_freq = 8e4;
s1_resample = resample(s1_data,resample_freq,fs);
s2_resample = resample(s2_data,resample_freq,fs);
%soundsc(s2_resample,80000);
cutoff_frequency  = 4e3;

[b,a] = butter(6,cutoff_frequency/(40000));

s1_filter = filter(b,a,s1_resample);
s2_filter = filter(b,a,s2_resample);
%soundsc(s1_filter,80000);



beta = 1;fm = 2000;
dev = beta * fm;
s1_mod = fmmod(s1_filter,s1_f,resample_freq,dev);
s2_mod = fmmod(s2_filter,s2_f,resample_freq,dev);
display(length(s1_mod));
display(length(s2_mod));


figure;
subplot(2,1,1);
N = length(s1_mod);
t = [0:time_int:(N-1)*time_int];
f = resample_freq/N.*(-N/2:N/2-1);
s1_mod_fft = fftshift(fft(s1_mod));
s1_mod_fft = abs(s1_mod_fft(1:N));
plot(f,s1_mod_fft);
xlabel('frequency(Hz)');ylabel('Amplitude');ylim([0 1000]);
title('Spectrum of the modulated signal');




s_mod = s1_mod(1:400000) + s2_mod(1:400000);




%channel
snr = 10;
s1_mod = awgn(s1_mod,snr);
s_mod_noise = s1_mod(1:400000) + s2_mod(1:400000);
s1_mod_fft = fftshift(fft(s1_mod));
s1_mod_fft = abs(s1_mod_fft(1:N));
subplot(2,1,2);
plot(f,s1_mod_fft);
xlabel('frequency(Hz)');ylabel('Amplitude');ylim([0 1000]);
title('Spectrum of the modulated signal+jamming signal(noise)');


%receiver
r_freq = s1_f;
passage = [r_freq-4000,r_freq+4000];

s_mod_rec = bandpass(s_mod,passage,80000);
s_mod_rec_noise = bandpass(s_mod_noise,passage,80000);
s_out = fmdemod(s_mod_rec,r_freq,80000,dev);
s_out_noise = fmdemod(s_mod_rec_noise,r_freq,80000,dev);

soundsc(s_out_noise,80000);







