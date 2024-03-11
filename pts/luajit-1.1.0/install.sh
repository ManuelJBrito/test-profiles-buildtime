#!/bin/sh

tar -xf LuaJIT-20190110.tar.xz
cd LuaJIT-Git
(time make -j $NUM_CPU_CORES) 2>&1 | grep real | cut -f2 > "$COMPILE_TIME_PATH/compile_time_${NUM_CPU_CORES}_cores_LuaJIT"
echo $? > ~/install-exit-status

TASKSET="taskset -c 1"

cd ~
echo "#!/bin/sh
$TASKSET ./LuaJIT-Git/src/luajit scimark.lua -large > \$LOG_FILE 2>&1" > luajit
chmod +x luajit
