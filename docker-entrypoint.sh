#!/bin/sh
kong migrations up
kong start -c /kong.conf