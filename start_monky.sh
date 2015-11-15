#!/bin/bash

conky -c ~/.monky/conky/monky_realtime > /dev/null 2>&1 &
conky -c ~/.monky/conky/monky_static > /dev/null 2>&1   &
conky -c ~/.monky/conky/monky_dynamic > /dev/null 2>&1 &
