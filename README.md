MicroPython Fuzzing Project
===========================

Use the following sequence:

```
make clone    -  clone MicroPython repository
make patch    -  apply patches for easier fuzzing
make build    -  build MicroPython unix port with AFL instrumentation and mpy-cross
make prepare  -  pre-compile tests using mpy-cross
make params   -  set optimal kernel parameters for testing (this one has to be run as root!)
make fuzz     -  run American Fuzzy Lop
```
