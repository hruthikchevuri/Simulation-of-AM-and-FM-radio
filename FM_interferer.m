%transmitter
s1_f = 15 * 10^3;s2 = 25 * 10^3;
[s1_data,fs] = audioread('original.wav');
[s2_data,fs] = audioread('m2_audio.wav');
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

beta = 1,fm = 2000;
dev = beta * fm;

power_ratio = 10;%dB
p_mul = 10^(power_ratio/20);

s1_mod = fmmod(s1_filter,s1_f,resample_freq,dev);
s2_mod = p_mul*fmmod(s2_filter,s1_f,resample_freq,dev);
display(length(s1_mod));
display(length(s2_mod));
p_1 = bandpower(s1_mod);
p_2 = bandpower(s2_mod);

interference_ratio = 10*log10(p_2/p_1)

figure;
subplot(2,1,1);
N = length(s1_mod(1:360000));
f = resample_freq/N.*(-N/2:N/2-1);
s1_mod_fft = fftshift(fft(s1_mod));
s1_mod_fft = abs(s1_mod_fft(1:N));
plot(f,s1_mod_fft);grid on;
xlabel('frequency(Hz)');ylabel('Amplitude');ylim([0 5000]);
title('Spectrum of the modulated signal');
subplot(2,1,2);

s1_mod_fft = fftshift(fft(s1_mod(1:360000) + s2_mod(1:360000)));
s1_mod_fft = abs(s1_mod_fft(1:N));
plot(f,s1_mod_fft);grid on;
xlabel('frequency(Hz)');ylabel('Amplitude');ylim([0 5000]);
title('Spectrum of the modulated signal+jamming signal');
s_mod = s1_mod(1:360000) + s2_mod(1:360000);


%channel
snr = 100;
s_mod_noise = awgn(s_mod,snr);

%receiver
r_freq = s1_f;
passage = [r_freq-4000,r_freq+4000];

s_mod_rec = bandpass(s_mod,passage,80000);
s_mod_rec_noise = bandpass(s_mod_noise,passage,80000);
s_out = fmdemod(s_mod_rec,r_freq,80000,dev);
s_out_noise = fmdemod(s_mod_rec_noise,r_freq,80000,dev);

soundsc(s_out,80000);
audiowrite('FM_jammer_greater.wav',s_out,80000);
