s1_f = 10 * 10^3; s2_f = 16 * 10^3;s3_f = 22 * 10^3;
[s1_data,fs] = audioread('m1_audio.wav');
[s2_data,fs] = audioread('m2_audio.wav');
[s3_data,fs] = audioread('m3_audio.wav');
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

power_ratio = -4;%dB
p_ratio = 10^(power_ratio/10);

s1_mod = ammod(s1_filter,s1_f,60000,0,1);
s2_mod = ammod(s2_filter,s2_f,60000,0,1);
s3_mod = ammod(s3_filter,s1_f,60000,0,1);
pinitial_1 = bandpower(s1_mod);
pinitial_2 = bandpower(s3_mod);
pi_ratio = (pinitial_2/pinitial_1);
p_mul = (p_ratio*pinitial_1)/pinitial_2;
p_mul = p_mul^0.5;
s3_mod = p_mul * ammod(s3_filter,s1_f,60000,0,1);

p_1 = bandpower(s1_mod);
p_2 = bandpower(s3_mod);

interference_ratio = 10*log10(p_2/p_1)

figure;
subplot(2,1,1);
N = length(s1_mod(1:300000));
f = resample_freq/N.*(-N/2:N/2-1);
s1_mod_fft = fftshift(fft(s1_mod));
s1_mod_fft = abs(s1_mod_fft(1:N));
plot(f,s1_mod_fft);
xlabel('frequency(Hz)');ylabel('Amplitude');ylim([0 5000]);
title('Spectrum of the modulated signal');
subplot(2,1,2);

s1_mod_fft = fftshift(fft(s1_mod(1:300000) + s3_mod(1:300000)));
s1_mod_fft = abs(s1_mod_fft(1:N));
plot(f,s1_mod_fft);
xlabel('frequency(Hz)');ylabel('Amplitude');ylim([0 5000]);
title('Spectrum of the modulated signal+jamming signal');

s_mod = s1_mod(1:300000) + s2_mod(1:300000)+ s3_mod(1:300000);


%channel
snr = 15;
s_mod_noise = awgn(s_mod,snr);


%receiver
r_freq = s1_f;
passage = [r_freq-2000,r_freq+2000];

s_mod_rec = bandpass(s_mod,passage,60000);
s_mod_rec_noise = bandpass(s_mod_noise,passage,60000);
s_out = amdemod(s_mod_rec,r_freq,60000,0,1);

soundsc(s_out,60000);
audiowrite('AM_jammer_greater.wav',s_out,60000);

