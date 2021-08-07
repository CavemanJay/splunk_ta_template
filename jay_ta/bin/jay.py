from __future__ import absolute_import, division, print_function, unicode_literals

import os
import sys

splunkhome = os.environ['SPLUNK_HOME']
sys.path.append(os.path.join(splunkhome, 'etc', 'apps', 'jay_ta', 'lib'))

from splunklib.searchcommands import dispatch, GeneratingCommand, Configuration, Option, validators, StreamingCommand
import time


@Configuration(streaming=True)
class JayCommand(GeneratingCommand):

    count = Option(require=True, validate=validators.Integer(0))

    def generate(self):
        self.logger.debug("Generating %s events" % self.count)
        for i in range(1, self.count + 1):
            text = 'Hello World %d' % i
            time.sleep(1)
            yield {'_time': time.time(), 'event_no': i, '_raw': text}


dispatch(JayCommand, sys.argv, sys.stdin, sys.stdout, __name__)
