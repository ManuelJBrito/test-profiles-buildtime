#!/bin/sh

tar -xf ngspice-34.tar.gz
tar -xf iscas85Circuits-1.tar.xz

cd ngspice-34
./configure
(time make) 2>&1 | grep real | cut -f2 > "$COMPILE_TIME_PATH/compile_time_${NUM_CPU_CORES}_cores_ngspice-34"
echo $? > ~/install-exit-status
cd ~
TASKSET="taskset -c 1"

echo "#!/bin/sh

cd ngspice-34
$TASKSET ./src/ngspice \$@ > \$LOG_FILE" > ngspice
chmod +x ngspice
