# old scanner code from 2005



export SCANNER_LOCK=/var/lock/scanner$SCAN_DEVICE_LOCK
 
# wait for the device to become ready
 
while [ -e $SCANNER_LOCK ] ; do
    echo "Waiting for device...";
    sleep 10
done
 
# lock the file for us
 
touch $SCANNER_LOCK
 
# Create enviroment for this job
 
mkdir /tmp/ScanThingy
mkdir /tmp/ScanThingy/$SCAN_JOB_NO
 
export OUT=/tmp/ScanThingy/$SCAN_JOB_NO/$SCAN_JOB_NO.pnm
export SCAN_OPT="--mode color --resolution 250 -x 215 -y 297"
 
# log scan progress
 
echo "Scanning document..."
 
scanimage $SCAN_OPT >$OUT
 
# remove lock
 
rm $SCANNER_LOCK
 
# log scan progress
 
echo "Scan complete. Converting image data..."
 
# read job data to get info about image conversion/file name
 
# BUG! for testing assume jpg output
 
export OUT_NEW=/tmp/ScanThingy/$SCAN_JOB_NO/$SCAN_JOB_NO.jpg
 
cat $OUT | pnmtojpeg > $OUT_NEW
 
# log scan progress
 
echo "Conversion complete. Delivering image..."
 
# read job data to get image delivery data
 
# BUG! for testing assume storage
 
export RENAME_TO=test1.jpg
 
nail -a $OUT_NEW kgroves
mv $OUT_NEW /tmp/ScanThingy
 
# Clean up
 
rm -f $OUT
rmdir /tmp/ScanThingy/$SCAN_JOB_NO
 
# log scan progress
 
echo "Job complete"
