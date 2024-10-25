% DSP-TA: Applying Band Pass Filter to Audio File with Variable Cutoff Frequency
clc;
clear all;
close all;

% Loading the audio files
[song1, fs2] = audioread('C:\Users\Bugaddr\Downloads\song.mp3');
[noise1, fs1] = audioread('C:\Users\Bugaddr\Downloads\noise.mp3');

% Converting stereo signal to mono signal
noise = noise1(:, 1);
song = song1(:, 1);
N2 = length(noise);
N5 = length(song);
fs = 44100;

% Zero padding of noise signal
song = [song; zeros((N2 - N5), 1)];
N3 = length(song);

% Adding noise to song
audio = (song + noise);
N = length(audio);

% Frequency axis construction
f3 = fs * (0:N2 - 1) / N2;
f4 = fs * (0:N3 - 1) / N3;

% FFT of the signals
NO = fft(noise);
SONG = fft(song);

% Plot of song spectrum and noise spectrum
figure;
subplot(2, 1, 1), plot(f3, abs(NO)), title('High Frequency Drums');
subplot(2, 1, 2), plot(f4, abs(SONG)), title('Song');

ts = 1 / fs; % Sampling time
t = 0:ts:(length(audio) / fs) - ts; % Time axis in seconds
f2 = fs * (0:N - 1) / N;
Aud = fft(audio);

% Plot of input time domain and frequency domain
figure;
subplot(2, 1, 1), plot(t, audio), title('Time Domain Input Signal (Combined)'), xlabel('Time (seconds)'), ylabel('Amplitude');
subplot(2, 1, 2), plot(f2, abs(Aud)), title('Input Audio Spectrum'), xlabel('Frequency'), ylabel('Magnitude');

disp('Playing input audio file...');
sound(audio, fs); % Playing input audio
pause(length(audio) / fs);

disp('Audio spectrum between 1k to 5k');
fcu = input('Enter the upper cut-off frequency: ');
fcl = input('Enter the lower cut-off frequency: ');
n1 = 12;
disp('Order is 12');

% Prewarping technique
ohmfcu = 2 * fs * tan(2 * pi * fcu / (2 * fs));
ohmfcl = 2 * fs * tan(2 * pi * fcl / (2 * fs));
bw = ohmfcu - ohmfcl; % Bandwidth calculation
cf = sqrt(ohmfcu * ohmfcl); % Center frequency calculation

% Normalized low pass filter zeros, poles, gains
[z1, p1, k1] = buttap(n1 / 2); 
[num1, den1] = zp2tf(z1, p1, k1); % Transfer function
[B1, A1] = lp2bp(num1, den1, cf, bw); % Scale the LPF to BPF
[bz1, az1] = bilinear(B1, A1, fs); % Bilinear transformation
[h1, f1] = freqz(bz1, az1, 22.05 * 1000, fs); % Frequency response

% Magnitude Spectrum of filter
figure;
subplot(2, 1, 1), plot(f1, mag2db(abs(h1))), title('Magnitude Response of Filter'), xlabel('Frequency'), ylabel('Attenuation (dB)');
subplot(2, 1, 2), plot(f1, angle(h1)), title('Phase Response of Filter'), xlabel('Frequency'), ylabel('Phase Angle');

% Filtering the audio
y1 = filter(bz1, az1, audio);
Y1 = fft(y1);

% Plot of output time domain and frequency domain
figure;
subplot(2, 1, 1), plot(t, y1), title('Time Domain Output Signal'), xlabel('Time (seconds)'), ylabel('Amplitude');
subplot(2, 1, 2), plot(f2, abs(Y1)), title('Output Audio Spectrum'), xlabel('Frequency'), ylabel('Magnitude');

% Plot of pole-zero plot of normalized LPF and BPF
figure;
subplot(2, 1, 1), zplane(num1, den1), title(['Normalized Low Pass Filter of Order: ' num2str(n1 / 2)]);
subplot(2, 1, 2), zplane(bz1, az1), title(['Bandpass Filter of Order: ' num2str(n1)]);

disp('Playing filtered audio...');
sound(y1, fs); % Playing output audio
pause(length(audio) / fs);
