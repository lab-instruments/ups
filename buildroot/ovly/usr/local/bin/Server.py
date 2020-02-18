from bottle import route, run
from Hal import Hal


hal = Hal()

@route('/led/<val>')
def led_ctrl(val):
    hal.led(int(val))
    return "LED SET -- {0}".format(val)

@route('/mode/<val>')
def mode_ctrl(val):
    hal.mode(int(val))
    return "MODE SET -- {0}".format(val)

@route('/dac0_test/<val>')
def dac0_test_ctrl(val):
    hal.dac0_test(int(val))
    return "DAC0 TEST VALUE SET -- {0}".format(val)

@route('/dac1_test/<val>')
def dac1_test_ctrl(val):
    hal.dac1_test(int(val))
    return "DAC1 TEST VALUE SET -- {0}".format(val)

@route('/valve/<val>')
def valve_ctrl(val):
    hal.valve(int(val))
    return "VALVE SET -- {0}".format(val)


run(host='0.0.0.0', port=8080, debug=True)