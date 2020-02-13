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

@route('/dac_test/<val>')
def dac_test_ctrl(val):
    hal.dac_test(int(val))
    return "DAC TEST VALUE SET -- {0}".format(val)

@route('/valve/<val>')
def valve_ctrl(val):
    hal.valve(int(val))
    return "VALVE SET -- {0}".format(val)


run(host='0.0.0.0', port=8080, debug=True)