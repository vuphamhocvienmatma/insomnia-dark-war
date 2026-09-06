import wave, struct, math, random, os

def save_wav(filename, samples, sample_rate=44100):
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with wave.open(filename, 'w') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sample_rate)
        for s in samples:
            w.writeframesraw(struct.pack('<h', int(max(-32767, min(32767, s * 32767)))))

def gen_item_pickup():
    sr = 44100
    samples = []
    for i in range(int(sr * 0.15)):
        env = math.exp(-i / (sr * 0.05))
        f = 800 + 400 * (i / (sr * 0.15))
        val = math.sin(2 * math.pi * f * i / sr)
        samples.append(val * env * 0.6)
    return samples

def gen_plant():
    sr = 44100
    samples = []
    for i in range(int(sr * 0.2)):
        env = math.exp(-i / (sr * 0.05))
        # noise for rustling dirt
        samples.append(random.uniform(-1, 1) * env * 0.4)
    return samples

def gen_harvest():
    sr = 44100
    samples = []
    for i in range(int(sr * 0.3)):
        env = math.exp(-i / (sr * 0.08))
        f = 600 + 200 * math.sin(i / sr * 30)
        val = math.sin(2 * math.pi * f * i / sr)
        samples.append((val * 0.5 + random.uniform(-0.5, 0.5)) * env * 0.5)
    return samples

save_wav('assets/sfx/item_pickup.wav', gen_item_pickup())
save_wav('assets/sfx/plant.wav', gen_plant())
save_wav('assets/sfx/harvest.wav', gen_harvest())
print("Additional SFX generated!")
