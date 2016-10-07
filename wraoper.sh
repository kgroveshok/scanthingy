# old wrapper.sh from scanthing 2005


scanimage -f "%i;%d;%v %m %t"
 
export SANE_DEFAULT_DEVICE=`scanimage -f "%d"`
export SCAN_DEVICE_LOCK=0
export SCAN_JOB_NO=$$
./scan.sh &
