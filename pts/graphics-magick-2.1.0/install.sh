#!/bin/sh

tar -xjf GraphicsMagick-1.3.38.tar.bz2
unzip -o sample-photo-6000x4000-1.zip

mkdir $HOME/gm_
cd GraphicsMagick-1.3.38/
LDFLAGS="-L$HOME/gm_/lib" CPPFLAGS="-I$HOME/gm_/include" ./configure --without-perl --prefix=$HOME/gm_ --without-png --disable-openmp > /dev/null
if [ $OS_TYPE = "BSD" ]
then
	gmake -j $NUM_CPU_CORES
else
  (time make -j $NUM_CPU_CORES) 2>&1 | grep real | cut -f2 > "$COMPILE_TIME_PATH/compile_time_${NUM_CPU_CORES}_cores_GraphicsMagick-1.3.38"
fi

echo $? > ~/install-exit-status
if [ $OS_TYPE = "BSD" ]
then
	gmake install
else
	make install
fi

cd ~
rm -rf GraphicsMagick-1.3.38/
rm -rf gm_/share/doc/GraphicsMagick/
rm -rf gm_/share/man/

./gm_/bin/gm convert sample-photo-6000x4000.JPG input.mpc

TASKSET="taskset -c 1"

echo "#!/bin/sh
$TASKSET ./gm_/bin/gm benchmark -duration 60 convert input.mpc \$@ null: > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > graphics-magick
chmod +x graphics-magick
