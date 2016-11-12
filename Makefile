all:
	@echo
	@echo 'Use the following sequence:'
	@echo
	@echo '  make clone    -  clone micropython repository'
	@echo '  make build    -  build micropython unix port with afl instrumentation and mpy-cross'
	@echo '  make prepare  -  pre-compile tests using mpy-cross'
	@echo '  make params   -  set optimal kernel parameters for testing (this one has to be run as root!)'
	@echo '  make fuzz     -  run american fuzzy lop'

clone:
	git clone --recursive https://github.com/micropython/micropython.git

build:
	make -C micropython/mpy-cross
	make -C micropython/unix axtls
	make -C micropython/unix CC=afl-gcc

prepare:
	find micropython/tests/basics -name '*.py' -exec micropython/mpy-cross/mpy-cross -mcache-lookup-bc {} \;
	mkdir ./afl-tests/
	mv micropython/tests/basics/*.mpy ./afl-tests/

# must be run as root
params:
	echo core > /proc/sys/kernel/core_pattern
	echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

fuzz:
	afl-fuzz -i ./afl-tests/ -o ./afl-fuzz/ -f afltest.mpy micropython/unix/micropython -c 'import afltest'

clean:
	rm -rf ./afltest.mpy ./afl-fuzz/ ./afl-tests/
