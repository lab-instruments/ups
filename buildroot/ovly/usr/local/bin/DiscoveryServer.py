import socket as s
import pickle as p
import logging
from logging.handlers import SysLogHandler

# Get Log Handler
log = logging.getLogger(__name__)


class DiscoveryServer:

    def __init__(self, ip='', port=9989):

        # Create UDP Socket Object
        self.sock = s.socket(s.AF_INET, s.SOCK_DGRAM)

        # Bind Socket to IP/Port Combo
        self.sock.bind((ip, port))

        self.setup_logging()

    def setup_logging(self):
        handler = SysLogHandler('/dev/log')
        formatter = logging.Formatter('%(module)s.%(funcName)s: %(message)s')
        handler.setFormatter(formatter)
        log.addHandler(handler)
        log.setLevel(logging.DEBUG)

    def run(self):

        # Start Server Message
        log.info('Start Python Discovery Server')

        # Generate Response Dictionary and Pickle
        resp = {
            'TYPE': 'DEVICE_SEARCH_RESP',
            'DEVICE_TYPE': 'UPS'
        }
        resp_p = p.dumps(resp)

        # Loop to Receiver
        while True:

            # Blocking Receive
            d, a = self.sock.recvfrom(4096)

            # Try to Unpickle Receive
            try:
                # Try to Unpickle the Received Data
                d_unpckl = p.loads(d)

                # Log Info to Syslog
                log.info('Rcv {0} Bytes from {1}'.format(len(d), a))

                # Check Dictionary
                if all(k in d_unpckl for k in ('TYPE', 'DEVICE_TYPE')):
                    if d_unpckl['TYPE'] == 'DEVICE_SEARCH_REQ' and d_unpckl['DEVICE_TYPE'] == 'UPS':
                        log.info('Response sent to {0}'.format(a))
                        self.sock.sendto(resp_p, a)

                    else:
                        log.error('Incorrect pkt type or device type')

                else:
                    log.error('Correct dictionary fields not present')

            except Exception as e:
                # Log Error to Syslog
                log.error('Exepction -- ', exc_info=True)


if __name__ == "__main__":
    serv = DiscoveryServer()
    serv.run()
