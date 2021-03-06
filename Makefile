all:
	@echo
	@cat README.md

clone:
	git clone --recursive https://github.com/micropython/micropython.git

patch:
	for p in patches/*.patch; do patch -p0 < $$p ; done

build:
	make -C micropython/mpy-cross
	make -C micropython/unix axtls
	make -C micropython/unix CC=afl-gcc DEBUG=1

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
	make -C micropython/mpy-cross clean
	make -C micropython/unix clean
	rm -rf ./afltest.mpy ./afl-fuzz/ ./afl-tests/
