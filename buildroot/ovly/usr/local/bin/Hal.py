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

    def led(self, val):
        # Turn On LEDs
        self.mmap_led.seek(0)
        self.mmap_led.write(struct.pack('I', val))

    def mode(self, val):
        # Set Mode
        self.mmap_ctrl.seek(0)
        self.mmap_ctrl.write(struct.pack('I', val))

    def dac0_test(self, val):
        # Set Mode
        self.mmap_ctrl.seek(4)
        self.mmap_ctrl.write(struct.pack('I', val))

    def dac1_test(self, val):
        # Set Mode
        self.mmap_ctrl.seek(8)
        self.mmap_ctrl.write(struct.pack('I', val))

    def valve(self, val):
        # Set Mode
        self.mmap_ctrl.seek(12)
        self.mmap_ctrl.write(struct.pack('I', val))


if __name__ == "__main__":
    hal = Hal()
    hal.led_off()
    time.sleep(2)
    hal.led_on()



# print(map.read(4))
# map.seek(0)
# map.flush()
# map.seek(0)
# print(map.read(4))
# map.seek(0)
# print(map.read(4))
# map.close()
# os.close(f)
