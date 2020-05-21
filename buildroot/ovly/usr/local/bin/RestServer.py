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

    # --------------------------------------------------------------------------
    #  Initialization Method
    # --------------------------------------------------------------------------
    def __init__(self, host, port, debug=False):

        # ----------------------------------------------------------------------
        #  Bottle Objects
        # ----------------------------------------------------------------------
        self.host = host
        self.port = port
        self.app = Bottle()
        self.debug = debug

        # ----------------------------------------------------------------------
        #  Generate Bottle Routes
        # ----------------------------------------------------------------------
        self.generate_routes()

        # ----------------------------------------------------------------------
        #  Get Hardware Abstraction Object
        # ----------------------------------------------------------------------
        self.hal = Hal()

    # --------------------------------------------------------------------------
    #  Start Server
    # --------------------------------------------------------------------------
    def start(self):
        self.app.run(host=self.host, port=self.port, quiet=self.debug)

    # --------------------------------------------------------------------------
    #  Generate Routes
    # --------------------------------------------------------------------------
    def generate_routes(self):
        self.app.route('/led', method='PUT', callback=self.put_led)
        self.app.route('/led', method='GET', callback=self.get_led)
        self.app.route('/mode', method='PUT', callback=self.set_mode)
        self.app.route('/dac0', method='PUT', callback=self.set_dac0)
        self.app.route('/dac1', method='PUT', callback=self.set_dac1)
        self.app.route('/valve', method='PUT', callback=self.set_valve)
        self.app.route('/check', method='GET', callback=self.get_check)

    # --------------------------------------------------------------------------
    #  LED Control
    # --------------------------------------------------------------------------
    # Set LED Value
    def put_led(self):
        # Log Request
        log.info('Set LED request')

        # Get Received Message Data
        msg = request.json

        # Get LED Value Data from Dictionary
        val = msg['led_val']

        # Set LED Value
        self.hal.set_led(int(val))

        # Create Response
        resp = {'STATUS': 0}

        return HTTPResponse(status=200, body=resp)

    # Get LED Value
    def get_led(self):
        # Log Request
        log.info('Get LED request')

        # Get LED Value
        val = self.hal.get_led()

        # Create Response
        resp = {'STATUS': 0, 'VALUE': val}

        return HTTPResponse(status=200, body=resp)

    # --------------------------------------------------------------------------
    #  Mode Control
    # --------------------------------------------------------------------------
    def set_mode(self):
        # Log Request
        log.info('Mode change request')

        # Get Received Message Data
        msg = request.json

        # Get LED Value Data from Dictionary
        val = msg['mode']

        # Set LED
        self.hal.set_mode(int(val))

        # Create Response
        resp = {'STATUS': 0}

        return HTTPResponse(status=200, body=resp)

    # --------------------------------------------------------------------------
    #  DAC0 Debug Control
    # --------------------------------------------------------------------------
    def set_dac0(self):
        # Log Request
        log.info('DAC0 Value Change Request')

        # Get Received Message Data
        msg = request.json

        # Get LED Value Data from Dictionary
        val = msg['dac0']

        # Set LED
        self.hal.set_dac0(int(val))

        # Create Response
        resp = {'STATUS': 0}

        return HTTPResponse(status=200, body=resp)

    # --------------------------------------------------------------------------
    #  DAC1 Debug Control
    # --------------------------------------------------------------------------
    def set_dac1(self):
        # Log Request
        log.info('DAC1 Value Change Request')

        # Get Received Message Data
        msg = request.json

        # Get LED Value Data from Dictionary
        val = msg['dac1']

        # Set LED
        self.hal.set_dac1(int(val))

        # Create Response
        resp = {'STATUS': 0}

        return HTTPResponse(status=200, body=resp)

    # --------------------------------------------------------------------------
    #  Pinch Valve Control
    # --------------------------------------------------------------------------
    def set_valve(self):
        # Log Request
        log.info('Pinch Valve State Change Request')

        # Get Received Message Data
        msg = request.json

        # Get LED Value Data from Dictionary
        val = msg['valve_state']

        # Set LED
        self.hal.set_valve(int(val))

        # Create Response
        resp = {'STATUS': 0}

        return HTTPResponse(status=200, body=resp)

    # --------------------------------------------------------------------------
    #  Check Code Get Handler
    # --------------------------------------------------------------------------
    def get_check(self):

        # Log Request
        log.info('Check code request')

        # Create Response
        resp = {'STATUS': 0, 'CHECK_CODE': 123456789}

        # Return
        return HTTPResponse(status=200, body=resp)


if __name__ == "__main__":
    srv = RestServer('0.0.0.0', 8088)
    srv.start()
