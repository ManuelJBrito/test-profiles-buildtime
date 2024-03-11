#!/bin/sh

rm -rf redis-7.0.4
tar -xzf redis-7.0.4.tar.gz

cd ~/redis-7.0.4/deps
make hiredis jemalloc linenoise lua

cd ~/redis-7.0.4
(time make MALLOC=libc -j $NUM_CPU_CORES) 2>&1 | grep real | cut -f2 > "$COMPILE_TIME_PATH/compile_time_${NUM_CPU_CORES}_cores_redis"
echo $? > ~/install-exit-status

TASKSET="taskset -c 1"

cd ~
echo "#!/bin/sh
cd ~/redis-7.0.4

echo \"io-threads 1
io-threads-do-reads yes
tcp-keepalive 0\" > redis.conf

$TASKSET ./src/redis-server redis.conf &
REDIS_SERVER_PID=\$!
sleep 6

taskset -c 1 ./src/redis-benchmark \$@ > \$LOG_FILE
kill \$REDIS_SERVER_PID
sed \"s/\\\"/ /g\" -i \$LOG_FILE" > redis
chmod +x redis
