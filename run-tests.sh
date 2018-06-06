#!/bin/bash

FILES=${1:-*}'.vader'
TZ=UTC vim "+Vader! autoload/kronos/**/$FILES"

