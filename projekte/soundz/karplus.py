############################################################
#
# karplus.py
#
# Author: MV (http://electro-nut.blogspot.com/)
#
# Generates a plucked string sound WAV file using the
# Karplus-Strong algorithm. 
#
############################################################
from math import sin, pi
from array import array
from random import random
import wave

# KS params
SR = 44100
f = 220

# WAV params
NCHANNELS = 1
SWIDTH = 2
FRAME_RATE = 44100
NFRAMES = 44100
NSAMPLES = 44100*2
# max - 128 for 8-bit, 32767 for 16-bit
MAX_VAL= 32767

class String:
    def __init__(self, freq, SR):
        self.freq = freq
        self.N = SR/freq
    # 'pluck' string
    def pluck(self):
        self.buf = [random() - 0.5 for i in range(self.N)]
    # return current sample, increment step
    def sample(self):
        val = self.buf[0]
        avg = 0.996*0.5*(self.buf[0] + self.buf[1])
        self.buf.append(avg)
        self.buf.pop(0)
        return val
    
str1, str2 = String(196, SR), String(440, SR)

str1.pluck()
str2.pluck()

samples = []

for i in range(NSAMPLES):
    sample = str1.sample()
    if(i > NSAMPLES/8):
        sample += str2.sample()
    samples.append(sample)

# samples to 16-bit to string
tmpBuf = [int(x*MAX_VAL) for x in samples] 
data = array('h', tmpBuf).tostring()

# write out WAV file
file = wave.open('karplus.wav', 'wb')
file.setparams((NCHANNELS, SWIDTH, FRAME_RATE, NFRAMES,
                'NONE', 'noncompressed'))
file.writeframes(data)
file.close()
