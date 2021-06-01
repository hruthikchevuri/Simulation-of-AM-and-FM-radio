s1_f = 10 * 10^3; s2_f = 16 * 10^3;s3_f = 22 * 10^3;
[s1_data,fs] = audioread('s1_audio.wav');
[s2_data,fs] = audioread('s2_audio.wav');
[s3_data,fs] = audioread('s3_audio.wav');
%%display(length(s1_data));
%%display(length(s2_data));
%%display(length(s3_data));
%soundsc(s1_data,fs);
s1_data = s1_data(:,1);
s2_data = s2_data(:,1);
s3_data = s3_data(:,1);
%soundsc(s1_data,fs);
resample_freq = 6e4;
s1_resample = resample(s1_data,60000,fs);
s2_resample = resample(s2_data,60000,fs);
s3_resample = resample(s3_data,60000,fs);
%soundsc(s2_resample,60000);
cutoff_frequency  = 2e3;

[b,a] = butter(6,2000/(30000));

s1_filter = filter(b,a,s1_resample);
s2_filter = filter(b,a,s2_resample);
s3_filter = filter(b,a,s3_resample);
%soundsc(s1_filter,60000);
figure;
subplot(2,1,1);

time_int = 1/resample_freq;
Nf = length(s1_filter);
tt = [0:time_int:(Nf-1)*time_int];
plot(tt,s1_filter);xlabel('time(sec)');ylabel('Amplitude');
title('signal in time domain');
grid on;
subplot(2,1,2);
ff = resample_freq/Nf.*(0:Nf-1);
s1_fft = fft(s1_filter,Nf);
s1_fft = abs(s1_fft(1:Nf))./(Nf/2);
plot(ff,s1_fft);
xlabel('frequency(Hz)');ylabel('Amplitude');
title('filtered signal in frequency domain');
grid on;

s1_mod = ammod(s1_filter,s1_f,60000,0,1);
s2_mod = ammod(s2_filter,s2_f,60000,0,1);
s3_mod = ammod(s3_filter,s3_f,60000,0,1);
%display(length(s1_mod));
%display(length(s2_mod));
%display(length(s3_mod));

s1_mod = s1_mod(1:326400);
s3_mod = s3_mod(1:326400);
display(length(s1_mod));
display(length(s2_mod));
display(length(s3_mod));
s_mod = s1_mod + s2_mod + s3_mod;

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




%snr = 20;
snr = 20;
s1_mod = awgn(s1_mod,snr);
s_mod_noise = s1_mod+s2_mod+s3_mod;
s1_mod_fft = fftshift(fft(s1_mod));
s1_mod_fft = abs(s1_mod_fft(1:N));
subplot(2,1,2);
plot(f,s1_mod_fft);
xlabel('frequency(Hz)');ylabel('Amplitude');ylim([0 1000]);
title('Spectrum of the modulated signal+jamming signal(noise)');



%receiver
r_freq = s1_f;
passage = [r_freq-2000,r_freq+2000];

%s_mod_rec = bandpass(s_mod,passage,60000);
s_mod_rec = bandpass(s_mod_noise,passage,60000);
s_out = amdemod(s_mod_rec,r_freq,60000,0,1);

soundsc(s_out,60000);
figure;
subplot(2,1,1);
plot(t,s_out);
xlabel('time(sec)');ylabel('Amplitude');
title('AM demodulated signal through a noise channel');
grid on;
xlim([0 5]);
subplot(2,1,2);
ff = resample_freq/N.*(0:N-1);
s_fft = fft(s_out,N);
s_fft = abs(s_fft(1:N))./(N/2);
plot(ff,s_fft);
xlabel('frequency(Hz)');ylabel('Amplitude');
title('Spectrum of the demodulated signal');
grid on;




