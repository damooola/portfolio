"""Synthesizes the site's sound effects into assets/sfx/*.wav.

Each sound is short (under 300ms) and quiet. Re-run after tweaking:
    python tool/make_sfx.py
"""
import math
import random
import struct
import wave

RATE = 22050
random.seed(7)


def write(name, samples, volume):
    peak = max(abs(s) for s in samples) or 1.0
    frames = b''.join(struct.pack('<h', int(s / peak * volume * 32767)) for s in samples)
    with wave.open(f'assets/sfx/{name}.wav', 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(frames)


def env(i, n, attack=0.004, decay=8.0):
    t = i / RATE
    a = min(1.0, t / attack)
    return a * math.exp(-decay * i / n)


def click():
    n = int(RATE * 0.035)
    return [env(i, n, 0.001, 9) * (0.6 * math.sin(2 * math.pi * 1800 * i / RATE) + 0.4 * (random.random() * 2 - 1)) for i in range(n)]


def chime():
    n = int(RATE * 0.26)
    out = []
    for i in range(n):
        t = i / RATE
        first = math.sin(2 * math.pi * 1318.5 * t) * math.exp(-14 * t)
        second = math.sin(2 * math.pi * 1975.5 * t) * math.exp(-12 * max(0, t - 0.07)) if t > 0.07 else 0
        out.append(min(1.0, t / 0.003) * (first + second))
    return out


def ding():
    n = int(RATE * 0.28)
    out = []
    for i in range(n):
        t = i / RATE
        s = (math.sin(2 * math.pi * 1568 * t) + 0.45 * math.sin(2 * math.pi * 3136 * t) + 0.2 * math.sin(2 * math.pi * 4704 * t))
        out.append(min(1.0, t / 0.002) * s * math.exp(-11 * t))
    return out


def stamp():
    n = int(RATE * 0.18)
    out = []
    phase = 0.0
    for i in range(n):
        t = i / RATE
        freq = 140 * math.exp(-12 * t) + 45
        phase += 2 * math.pi * freq / RATE
        body = math.sin(phase) * math.exp(-18 * t)
        hit = (random.random() * 2 - 1) * math.exp(-90 * t)
        out.append(min(1.0, t / 0.001) * (body + 0.5 * hit))
    return out


write('click', click(), 0.18)
write('chime', chime(), 0.22)
write('ding', ding(), 0.22)
write('stamp', stamp(), 0.45)
print('wrote assets/sfx/{click,chime,ding,stamp}.wav')
