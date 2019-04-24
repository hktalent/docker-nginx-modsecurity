#!/bin/sh
grep -Ev "^$|^#" ./owasp-modsecurity-crs/crs-setup.conf.example>crs-setup.conf

echo "Include /.../crs-setup.conf" >> crs-setup.conf
echo "Include /.../rules/*.conf" >> crs-setup.conf
