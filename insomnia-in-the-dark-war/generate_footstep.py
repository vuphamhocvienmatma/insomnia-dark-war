import wave
import struct
import random
import math

def generate_footstep(filename):
    sample_rate = 44100
    duration = 0.15 # 150ms
    num_samples = int(sample_rate * duration)
    
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        
        for i in range(num_samples):
            t = i / sample_rate
            
            # Envelope (quick attack, short decay)
            env = math.exp(-t * 25.0)
            
            # White noise base
            noise = random.uniform(-1.0, 1.0)
            
            # Low frequency thud
            thud = math.sin(2 * math.pi * 60 * t) * math.exp(-t * 40.0)
            
            sample = (noise * 0.3 + thud * 0.7) * env
            
            # Clamp and convert to 16-bit PCM
            sample = max(-1.0, min(1.0, sample))
            pcm_val = int(sample * 32767)
            wav_file.writeframes(struct.pack('<h', pcm_val))

generate_footstep('assets/sfx/footstep.wav')
print("Generated footstep.wav")
