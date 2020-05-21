import os
import mmap
import struct
import time


class Hal:

    def __init__(self):
        # Get Handle to /DEV/MEM
        self.f = os.open('/dev/mem', os.O_RDWR | os.O_SYNC)

        # Get Window Handle to LED Memory Map
        self.mmap_led = mmap.mmap(
                                  self.f,
                                  4095,
                                  mmap.MAP_SHARED,
                                  offset=0x41200000
                                 )

        # Get Window Handle to Control Memory Map
        self.mmap_ctrl = mmap.mmap(
                                   self.f,
                                   4095,
                                   mmap.MAP_SHARED,
                                   offset=0x43C00000
                                  )

    def set_led(self, val):
        # Write LED Memory Map Word
        self.mmap_led.seek(0)
        self.mmap_led.write(struct.pack('I', val))

    def get_led(self):
        # Read LED Memory Map Word
        self.mmap_led.seek(0)
        val = self.mmap_led.read(4)
        return struct.unpack('I', val)[0]

    def set_mode(self, val):
        # Set Mode
        self.mmap_ctrl.seek(0)
        self.mmap_ctrl.write(struct.pack('I', val))

    def get_mode(self):
        # Get Mode
        self.mmap_ctrl.seek(0)
        val = self.mmap_ctrl.read(4)
        return struct.unpack('I', val)[0]

    def set_dac0(self, val):
        # Set DAC0 Value
        self.mmap_ctrl.seek(4)
        self.mmap_ctrl.write(struct.pack('I', val))

    def get_dac0(self):
        # Get DAC0 Value
        self.mmap_ctrl.seek(4)
        val = self.mmap_ctrl.read(4)
        return struct.unpack('I', val)[0]

    def set_dac1(self, val):
        # Set DAC1 Value
        self.mmap_ctrl.seek(8)
        self.mmap_ctrl.write(struct.pack('I', val))

    def get_dac1(self, val):
        # Get DAC1 Value
        self.mmap_ctrl.seek(8)
        val = self.mmap_ctrl.read(4)
        return struct.unpack('I', val)[0]

    def set_valve(self, val):
        # Get Mode Value
        self.mmap_ctrl.seek(12)
        self.mmap_ctrl.write(struct.pack('I', val))

    def get_valve(self, val):
        # Get Mode Value
        self.mmap_ctrl.seek(12)
        val = self.mmap_ctrl.read(4)
        return struct.unpack('I', val)[0]


if __name__ == "__main__":
    hal = Hal()
    hal.set_led(0xAFFFF3)
    time.sleep(1)
    print('0x{0:08X}'.format(hal.get_led()))
    time.sleep(1)
    hal.set_led(0)
    print(hal.get_led())
