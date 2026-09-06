import wave, struct, math, random, os

def save_wav(filename, samples, sample_rate=44100):
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with wave.open(filename, 'w') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sample_rate)
        for s in samples:
            w.writeframesraw(struct.pack('<h', int(max(-32767, min(32767, s * 32767)))))

def gen_typewriter():
    sr = 44100
    samples = []
    for i in range(int(sr * 0.05)):
        # burst of noise with fast decay
        env = math.exp(-i / (sr * 0.01))
        samples.append(random.uniform(-1, 1) * env * 0.5)
    return samples

def gen_door_creak():
    sr = 44100
    samples = []
    for i in range(int(sr * 0.6)):
        env = math.sin(i / (sr * 0.6) * math.pi)
        # pitch bends slightly
        f = 150 + 50 * math.sin(i / sr * 5)
        val = math.sin(2 * math.pi * f * i / sr)
        noise = random.uniform(-0.2, 0.2)
        samples.append((val * 0.3 + noise) * env)
    return samples

def gen_turret_shoot():
    sr = 44100
    samples = []
    for i in range(int(sr * 0.2)):
        env = math.exp(-i / (sr * 0.03))
        # Square wave sweep
        f = 400 * math.exp(-i / (sr * 0.05))
        val = 1.0 if math.sin(2 * math.pi * f * i / sr) > 0 else -1.0
        samples.append(val * env * 0.5)
    return samples

def gen_wall_break():
    sr = 44100
    samples = []
    for i in range(int(sr * 0.5)):
        env = math.exp(-i / (sr * 0.1))
        samples.append(random.uniform(-1, 1) * env * 0.8)
    return samples

def gen_night_ambient():
    sr = 22050
    samples = []
    for i in range(int(sr * 10)): # 10 seconds loop
        # Low drone
        val = math.sin(2 * math.pi * 55 * i / sr) * 0.3
        val += math.sin(2 * math.pi * 56 * i / sr) * 0.3
        # Occasional cricket (high freq chirp)
        if i % sr < sr * 0.1:
            val += math.sin(2 * math.pi * 4000 * i / sr) * 0.1 * math.sin(2 * math.pi * 20 * i / sr)
        samples.append(val)
    return samples

def gen_day_lofi():
    sr = 22050
    samples = []
    for i in range(int(sr * 10)):
        env = (1 - ((i % (sr)) / sr)) # 1 beat per second
        chord = math.sin(2*math.pi*220*i/sr) + math.sin(2*math.pi*277*i/sr) + math.sin(2*math.pi*329*i/sr)
        chord *= 0.1 * env
        # kick drum
        kick_env = math.exp(-(i % sr) / (sr * 0.1))
        kick = math.sin(2*math.pi*60*(i%sr)/sr) * kick_env * 0.5
        samples.append(chord + kick)
    return samples

save_wav('assets/sfx/typewriter_tick.wav', gen_typewriter())
save_wav('assets/sfx/wood_creak.wav', gen_door_creak())
save_wav('assets/sfx/turret_shoot.wav', gen_turret_shoot())
save_wav('assets/sfx/wall_break.wav', gen_wall_break())
save_wav('assets/bgm/night_ambient.wav', gen_night_ambient())
save_wav('assets/bgm/day_lofi.wav', gen_day_lofi())

print("Audio generated!")
