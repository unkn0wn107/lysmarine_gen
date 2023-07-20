#!/bin/sh

/usr/bin/su -c '/usr/bin/systemctl is-enabled signalk && /usr/bin/systemctl restart signalk'
/usr/bin/su -c '/usr/bin/systemctl is-enabled kplex && /usr/bin/systemctl restart kplex'
