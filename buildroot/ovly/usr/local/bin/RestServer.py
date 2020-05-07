from bottle import Bottle, request, HTTPResponse
from Hal import Hal
import logging
from logging.handlers import SysLogHandler

# Setup Log
log = logging.getLogger(__name__)
handler = SysLogHandler('/dev/log')
formatter = logging.Formatter('%(module)s.%(funcName)s: %(message)s')
handler.setFormatter(formatter)
log.addHandler(handler)
log.setLevel(logging.DEBUG)


class RestServer:

    # -------------------------------------------------------------------------
    #  Initialization Method
    # -------------------------------------------------------------------------
    def __init__(self, host, port, debug=False):

        # ---------------------------------------------------------------------
        #  Bottle Objects
        # ---------------------------------------------------------------------
        self.host = host
        self.port = port
        self.app = Bottle()
        self.debug = debug

        # ---------------------------------------------------------------------
        #  Generate Bottle Routes
        # ---------------------------------------------------------------------
        self.generate_routes()

        # ---------------------------------------------------------------------
        #  Get Hardware Abstraction Object
        # ---------------------------------------------------------------------
        self.hal = Hal()

    # -------------------------------------------------------------------------
    #  Start Server
    # -------------------------------------------------------------------------
    def start(self):
        self.app.run(host=self.host, port=self.port, quiet=self.debug)

    # -------------------------------------------------------------------------
    #  Generate Routes
    # -------------------------------------------------------------------------
    def generate_routes(self):
        self.app.route('/led', method='POST', callback=self.set_led)
        self.app.route('/mode', method='POST', callback=self.set_mode)
        self.app.route('/debug_dac0', method='POST', callback=self.set_dac0)
        self.app.route('/debug_dac1', method='POST', callback=self.set_dac1)

    # -------------------------------------------------------------------------
    #  LED Control
    # -------------------------------------------------------------------------
    def set_led(self):
        # Log Request
        log.info('LED change request')

        # Get Received Message Data
        msg = request.json

        # Get LED Value Data from Dictionary
        val = msg['led_val']

        # Set LED
        self.hal.led(int(val))

        # Create Response
        resp = {'STATUS': 0}

        return HTTPResponse(status=200, body=resp)

    # -------------------------------------------------------------------------
    #  Mode Control
    # -------------------------------------------------------------------------
    def set_mode(self):
        # Log Request
        log.info('Mode change request')

        # Get Received Message Data
        msg = request.json

        # Get LED Value Data from Dictionary
        val = msg['led_val']

        # Set LED
        self.hal.led(int(val))

        # Create Response
        resp = {'STATUS': 0}

        return HTTPResponse(status=200, body=resp)

"""
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
"""

if __name__ == "__main__":
    srv = RestServer('0.0.0.0', 8088)
    srv.start()
