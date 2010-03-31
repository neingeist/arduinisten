############################################################
#
# karplus-simple.py
#
# Author: MV (http://electro-nut.blogspot.com/)
#
# Generates a plucked string sound WAV file using the
# Karplus-Strong algorithm. (Simple version.)
#
############################################################
from math import sin, pi
from array import array
from random import random

import wave

# KS params
SR = 44100
f = 220
N = SR/f

# WAV params
NCHANNELS = 1
SWIDTH = 2
FRAME_RATE = 44100
NFRAMES = 44100
NSAMPLES = 44100
# max - 128 for 8-bit, 32767 for 16-bit
MAX_VAL= 32767

# pluck
buf = [random() - 0.5 for i in range(N)]

#init samples 
samples = []

# KS - ring buffer
bufSize = len(buf)
for i in range(NSAMPLES):
    samples.append(buf[0])
    avg = 0.996*0.5*(buf[0] + buf[1])
    buf.append(avg)
    buf.pop(0)

# samples to 16-bit to string
tmpBuf = [int(x*MAX_VAL) for x in samples] 
data = array('h', tmpBuf).tostring()

# write out WAV file
file = wave.open('karplus-simple.wav', 'wb')
file.setparams((NCHANNELS, SWIDTH, FRAME_RATE, NFRAMES,
                'NONE', 'noncompressed'))
file.writeframes(data)
file.close()
