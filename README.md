# Full Digital Communication System Simulation

## Project Overview
This project aims to simulate a complete digital communication system by processing an analog signal (a `.wav` file), quantizing it, transmitting it through an Additive White Gaussian Noise (AWGN) channel, and reconstructing it at the receiver. The project is divided into three main tasks:  

1. **Quantization**  
2. **Pulse Shaping**  
3. **AWGN Channel Transmission & Reception**  

## Tasks Breakdown

### Task 1: Quantization  
- Load and play the provided sound file (`helloWorld.wav`).  
- Quantize the signal using a uniform quantizer with `L = 2^n` levels, where `n` is the number of bits per sample.  
- Convert the quantized signal into a bit stream.  
- Play the quantized sound file for `n = 2` and compare the quality with the original file.  

### Task 2: Pulse Shaping  
- Convert the bit stream into binary polar signaling.  
- Apply pulse shaping using the raised cosine pulse `p_rc(t)`.  
- Upsample the bit stream before convolution with `p_rc(t)`.  
- Normalize the energy of `p_rc(t)`.  
- Plot the first `T = 400` shaped samples with an accurate time vector.  

### Task 3: AWGN Channel Transmission  
- Transmit the shaped symbols through an AWGN channel for a given SNR (dB).  
- Plot the noisy shaped samples and compare them with the ones before transmission.  
- Apply a matched filter to maximize the received SNR.  
- Sample the matched filter output at every symbol duration `T_b`.  
- Detect the transmitted binary data using an optimal threshold.  
- Compute the empirical Bit Error Rate (BER) and compare it with the analytical BER.  
- Convert detected bits back to quantized levels and play the reconstructed signal.  
- Repeat the process for SNR values ranging from `-5 dB` to `10 dB`, and plot BER vs. SNR on a semilog scale, comparing with the analytical BER.  

## Results & Analysis  
- Audio quality comparison between original, quantized, and received signals.  
- BER performance evaluation across different SNR levels.  

## Requirements  
- Python with `numpy`, `matplotlib`, and `scipy`.  
- A `.wav` file (`helloWorld.wav`).  

## Usage  
1. Clone this repository.  
2. Run the provided script step by step for each task.  
3. Analyze the output plots and results.  

## Contributors  
- **Md Nurul Absar Siddiky**  
