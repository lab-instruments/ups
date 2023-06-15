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

        # LED Control Nodes
        self.app.route('/led', method='PUT', callback=self.put_led)
        self.app.route('/led', method='GET', callback=self.get_led)

        # Mode Control Nodes
        self.app.route('/mode', method='PUT', callback=self.set_mode)
        self.app.route('/mode', method='GET', callback=self.get_mode)

        # DAC0 Control Nodes
        self.app.route('/dac0', method='PUT', callback=self.set_dac0)
        self.app.route('/dac0', method='GET', callback=self.get_dac0)

        # DAC1 Control Nodes
        self.app.route('/dac1', method='PUT', callback=self.set_dac1)
        self.app.route('/dac1', method='GET', callback=self.get_dac1)

        # Valve Control Nodes
        self.app.route('/valve', method='PUT', callback=self.set_valve)
        self.app.route('/valve', method='GET', callback=self.get_valve)

        # Check Node
        self.app.route('/check', method='GET', callback=self.get_check)

        # Run Control Nodes
        self.app.route('/run', method='PUT', callback=self.set_run)
        self.app.route('/run', method='GET', callback=self.get_run)

        # Stop Control Node
        self.app.route('/stop', method='PUT', callback=self.set_stop)

        # Status Node
        self.app.route('/status', method='GET', callback=self.get_status)

        # Version Node
        self.app.route('/ver', status='GET', callback=self.get_ver)

        # Reset Route
        self.app.route('/reset', method='PUT', callback=self.set_reset)

    # --------------------------------------------------------------------------
    #  RESET Control
    # --------------------------------------------------------------------------
    # Set STOP Values
    def set_reset(self):
        # Log Request
        log.info('Set RESET request')

        # Initiate Stop
        self.hal.set_reset()

        # Create Response
        resp = {'STATUS': 0}
        return HTTPResponse(status=200, body=resp)

    # --------------------------------------------------------------------------
    #  Get Version
    # --------------------------------------------------------------------------
    # Get STATUS Values
    def get_ver(self):
        # Log Request
        log.info('Get VERSION request')

        # Open File and Read Version/Status
        with open('/root/version', 'r') as f:
            lines = f.readlines()

        # Create Response
        resp = {}
        resp['GIT_VER'] = lines[0].rstrip()
        resp['GIT_STAT'] = lines[1].rstrip()
        resp['STATUS'] = 0

        # Return
        return HTTPResponse(status=200, body=resp)

    # --------------------------------------------------------------------------
    #  Get Status
    # --------------------------------------------------------------------------
    # Get STATUS Values
    def get_status(self):
        # Log Request
        log.info('Get STATUS request')

        # Get RUN Values
        resp = {}
        resp['RUN_STATUS'] = self.hal.get_status()

        # Create Response
        resp['STATUS'] = 0
        return HTTPResponse(status=200, body=resp)

    # --------------------------------------------------------------------------
    #  RUN Control
    # --------------------------------------------------------------------------
    # Set RUN Values
    def set_run(self):
        # Log Request
        log.info('Set RUN request')

        # Get Received Message Data
        msg = request.json

        # Get Run Settings
        loops = msg['RUN_LOOPS']
        pre = msg['RUN_PRE_CNT']
        post = msg['RUN_POST_CNT']
        run = msg['RUN_CNT']

        # Set Run Values
        self.hal.set_run_cnt(int(run))
        self.hal.set_run_pre_cnt(int(pre))
        self.hal.set_run_post_cnt(int(post))
        self.hal.set_run_loops(int(loops))
        self.hal.set_run_start()

        # Create Response
        resp = {'STATUS': 0}
        return HTTPResponse(status=200, body=resp)

    # Get RUN Values
    def get_run(self):
        # Log Request
        log.info('Get RUN request')

        # Get RUN Values
        resp = {}
        resp['RUN_CNT'] = self.hal.get_run_cnt()
        resp['RUN_PRE_CNT'] = self.hal.get_run_pre_cnt()
        resp['RUN_POST_CNT'] = self.hal.get_run_post_cnt()
        resp['RUN_LOOPS'] = self.hal.get_run_loops()

        # Create Response
        resp['STATUS'] = 0
        return HTTPResponse(status=200, body=resp)

    # --------------------------------------------------------------------------
    #  STOP Control
    # --------------------------------------------------------------------------
    # Set STOP Values
    def set_stop(self):
        # Log Request
        log.info('Set STOP request')

        # Initiate Stop
        self.hal.set_run_stop()

        # Create Response
        resp = {'STATUS': 0}
        return HTTPResponse(status=200, body=resp)

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
        val = msg['LED']

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
        resp = {'STATUS': 0, 'LED': val}
        return HTTPResponse(status=200, body=resp)

    # --------------------------------------------------------------------------
    #  Mode Control
    # --------------------------------------------------------------------------
    # Set MODE Value
    def set_mode(self):
        # Log Request
        log.info('Set MODE request')

        # Get Received Message Data
        msg = request.json

        # Get MODE Value Data from Dictionary
        val = msg['MODE']

        # Set MODE
        self.hal.set_mode(int(val))

        # Create Response
        resp = {'STATUS': 0}
        return HTTPResponse(status=200, body=resp)

    # Get MODE Value
    def get_mode(self):
        # Log Request
        log.info('Get MODE request')

        # Get MODE Value
        val = self.hal.get_mode()

        # Create Response
        resp = {'STATUS': 0, 'MODE': val}
        return HTTPResponse(status=200, body=resp)

    # --------------------------------------------------------------------------
    #  DAC0 Debug Control
    # --------------------------------------------------------------------------
    # Set DAC0 Value
    def set_dac0(self):
        # Log Request
        log.info('Set DAC0 Request')

        # Get Received Message Data
        msg = request.json

        # Get DAC0 Value Data from Dictionary
        val = msg['DAC0']

        # Set DAC0
        self.hal.set_dac0(int(val))

        # Create Response
        resp = {'STATUS': 0}
        return HTTPResponse(status=200, body=resp)

    # Get DAC0 Value
    def get_dac0(self):
        # Log Request
        log.info('Get DAC0 Request')

        # Get DAC0 Value
        val = self.hal.get_dac0()

        # Create Response
        resp = {'STATUS': 0, 'DAC0': val}
        return HTTPResponse(status=200, body=resp)

    # --------------------------------------------------------------------------
    #  DAC1 Debug Control
    # --------------------------------------------------------------------------
    # Set DAC1 Value
    def set_dac1(self):
        # Log Request
        log.info('Set DAC1 Request')

        # Get Received Message Data
        msg = request.json

        # Get DAC1 Value Data from Dictionary
        val = msg['DAC1']

        # Set DAC1 Value
        self.hal.set_dac1(int(val))

        # Create Response
        resp = {'STATUS': 0}
        return HTTPResponse(status=200, body=resp)

    # Get DAC1 Value
    def get_dac1(self):
        # Log Request
        log.info('Get DAC1 Request')

        # Get DAC1 Value
        val = self.hal.get_dac1()

        # Create Response
        resp = {'STATUS': 0, 'DAC1': val}
        return HTTPResponse(status=200, body=resp)

    # --------------------------------------------------------------------------
    #  Pinch Valve Control
    # --------------------------------------------------------------------------
    # Set Valve Value
    def set_valve(self):
        # Log Request
        log.info('Set VALVE Request')

        # Get Received Message Data
        msg = request.json

        # Get Valve Value Data from Dictionary
        val = msg['VALVE']

        # Set VALVE Value
        self.hal.set_valve(int(val))

        # Create Response
        resp = {'STATUS': 0}
        return HTTPResponse(status=200, body=resp)

    # Get Valve Value
    def get_valve(self):
        # Log Request
        log.info('Get VALVE Request')

        # Get VALVE Value
        val = self.hal.get_valve()

        # Create Response
        resp = {'STATUS': 0, 'VALVE': val}
        return HTTPResponse(status=200, body=resp)

    # --------------------------------------------------------------------------
    #  Check Code Get Handler
    # --------------------------------------------------------------------------
    def get_check(self):

        # Log Request
        log.info('Check code request')

        # Create Response
        resp = {'STATUS': 0, 'CHECK_CODE': 123456789}
        return HTTPResponse(status=200, body=resp)


if __name__ == "__main__":
    srv = RestServer('0.0.0.0', 8088)
    srv.start()
