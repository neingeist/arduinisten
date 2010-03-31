import sys
sys.path.append("midi")
from MidiOutStream import MidiOutStream
from MidiInFile import MidiInFile

class ArduinoConverter(MidiOutStream):
    
  "Convert MIDI stream to some weird format I can actually use"
    
  def note_on(self, channel=0, note=0x40, velocity=0x40):
    if self.get_current_track() == 3 and channel == 0:
      print note, self.rel_time()

  def sysex_event(self, data):
    "dummy"
    pass

# get data
test_file = 'nevergoingtoU.mid'
# do parsing
c = ArduinoConverter()
midiIn = MidiInFile(c, test_file)
midiIn.read()
