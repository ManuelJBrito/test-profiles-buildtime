#!/bin/sh

unzip -o scimark2_1c.zip -d scimark2_files
cd scimark2_files/
$CC $CFLAGS -o scimark2 *.c -lm
echo $CC
(time $CC $CFLAGS -o scimark2 *.c -lm) 2>&1 | grep real | cut -f2 > "$COMPILE_TIME_PATH/compile_time_${NUM_CPU_CORES}_cores_scimark2"
echo $? > ~/install-exit-status
cd ..

TASKSET="taskset -c 1"
echo "#!/bin/sh
cd scimark2_files/
$TASKSET ./scimark2 -large > \$LOG_FILE 2>&1" > scimark2
chmod +x scimark2
