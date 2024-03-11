#!/bin/sh
tar -xvf z3-4.12.1.tar.gz
cd z3-z3-4.12.1
PYTHON=/usr/bin/python3 ./configure
cd build
(time make -j$NUM_CPU_CORES z3) 2>&1 | grep real | cut -f2 > "$COMPILE_TIME_PATH/compile_time_${NUM_CPU_CORES}_cores_z3"
TASKSET="taskset -c 1"
echo "#!/bin/sh
$TASKSET ./z3-z3-4.12.1/build/z3 \$1 > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > ~/z3
chmod +x ~/z3
