clear all
close all
clc

%for sounds & plots set flag=1
flag=1;

%reading sound file
[snd,fs]=audioread("helloWorld.wav");

if flag==1
    %playing the sound file
    sound(snd,fs)
end

%message to be trasnmitted
m=snd;

%% quantization:
%--------------

%finding maximum value
mp=max(abs(m));

%number of bits per sample
n=2;

%number of quantization levels
L=2^n;

%distance between consecutive quantization levels
Dv=2*mp/L;

%quantization intervals
intervals=-mp:Dv:mp;

%quantization levels
quant_lvls=intervals+Dv/2;

%ignoring the last (extra) one
quant_lvls(end)=[];

%representing quantization levels using bits
bit_lvls=zeros(L,n);

for ii=0:L-1

    bit_lvls(ii+1,:)=double(dec2bin(ii,n)-'0');

end

%representing data using bits
m_bits=[];
for ii=1:length(m)

    %finding where the signal value lies closest to
    dummy=abs(m(ii)-quant_lvls);

    %allocating the signal to the closest quantization level
    m_quant(ii)=min(quant_lvls(dummy==min(dummy)));

    %converting the quantized signal into bits
    m_bits=[m_bits, bit_lvls(m_quant(ii)==quant_lvls,:)];

end

%adjusting dimension
m_quant=m_quant';

%adjusting dimension
m_bits=m_bits';

%number of data points
N=length(m_bits);

%reshaping to compare with quantization levels
m_bits_reshaped=reshape(m_bits,n,length(m_bits)/n)';

for ii=1:(length(m_bits)/n)

    %allocating each bit combination to its correponding quantization level
    m_quant(ii)=quant_lvls(sum(m_bits_reshaped(ii,:)==bit_lvls,2)==n);

end

%adjusting dimension
m_quant=m_quant';

if flag==1
    %playing the quantized signal
    sound(m_quant,fs)
end

%% raised cosine pulse shaping:
%-----------------------------

%roll-off factor
r=.25;

%number of symbols that the pulse spans
span=4;

%number of samples per symbol
sps=8;

%raised cosine (RC) filter
p_rc=rcosdesign(r,span,sps,"normal");

%trasnmitted bits
tx_bits=m_bits;

%upsampling to match the length of the RC pulse and converting to polar
tx_bits_upsampled=upsample(2*tx_bits-1,sps*span);

%convolving with the RC pulse
tx_symbols_rc=conv(tx_bits_upsampled,p_rc);

%picking a few shaped samples to plot
T=400;

%time is the number of samples normalized by sampling rate
time=(1:T)/(sps*span);

if flag==1
    %plotting (a few) shaped symbols
    figure
    plot(time,tx_symbols_rc(1:T))
    xlim([0 T/(sps*span)])
    % ylim([-1 1])
    grid on
    xlabel("time")
    ylabel("binary polar signaling with raised cosine pulses")
end

%% awgn channel, matched filter & threshold detection:
%----------------------------------------------------

%snr values in dB
if flag==1
    snr_dB_vals=0;
else
    snr_dB_vals=linspace(-5,10,50);
end

%looping to test the system for every snr value
for ss=1:length(snr_dB_vals)

    snr_dB=snr_dB_vals(ss);

    %computing noise power assuming signal power is normalized
    sigma2_n=1/(10^(0.1*snr_dB));

    %adding Gaussian noise to the transmitted symbols
    rx_signal_rc=tx_symbols_rc+sqrt(sigma2_n)*randn(length(tx_symbols_rc),1);

    if flag==1
        %plotting (a few) noisy symbols
        figure
        plot(time,rx_signal_rc(1:T))
        xlim([0 T/(sps*span)])
        % ylim([-2 2])
        grid on
        xlabel("time")
        ylabel("channel output")
    end

    %matched filter
    h_matched_rc=p_rc(end:-1:1);

    %passing noisy received symbols through matched filter
    rx_symbols_rc=conv(rx_signal_rc,h_matched_rc);

    if flag==1
        %plotting (a few) output symbols of the matched filter
        figure
        plot(time,rx_symbols_rc(1:T))
        xlim([0 T/(sps*span)])
        % ylim([-2 2])
        grid on
        xlabel("time")
        ylabel("matched filter output")
    end

    %sampling time t_b equals the duration of the pulse
    t_b=sps*span;

    %sampling every t_b and comparing to the threshold (0 for polar signaling)
    rx_bits_rc=double(rx_symbols_rc(t_b+1:t_b:end)>0);

    %ignoring the extra sample from the tail of the convolution
    rx_bits_rc=rx_bits_rc(1:N);

    %computing bit error rate
    p_b_rc(ss)=1/N*sum(rx_bits_rc~=tx_bits);

    %computing analytical bit error rate as a baseline
    p_b_analytical(ss)=qfunc(sqrt(10^(0.1*snr_dB)));

    %reshaping to compare with quantization levels
    rx_bits_rc_reshaped=reshape(rx_bits_rc,n,length(rx_bits_rc)/n)';

    for ii=1:(length(rx_bits_rc)/n)

        %allocating each bit combination to its correponding quantization level
        m_rx_rc(ii)=quant_lvls(sum(rx_bits_rc_reshaped(ii,:)==bit_lvls,2)==n);

    end

    %adjusting dimension
    m_rx_rc=m_rx_rc';

    if flag==1
        %playing the received signal
        sound(m_rx_rc,fs)
    end

end

if flag~=1
    %plotting BER vs SNR
    figure
    semilogy(snr_dB_vals,p_b_rc)
    hold on
    semilogy(snr_dB_vals,p_b_analytical)
    legend("rc","analytical")
    grid on
    xlabel("SNR (dB)")
    ylabel("BER")
end


