#!/usr/bin/python
#!/usr/bin/python
# Based on Picon Zero Motor Test
#
# robot hardware:
#  4init 4wd bot base
#  sharp ir sensor
#  ultrasonic sensor
#  pan/tilt arm (2 x servo)
#  usb webcam mounted on continuois servo (becase lacking a 180deg servo)
#  piconzero controller
#    motors connected h-bridge
#    ultrasonic on deadicated connection
#    ir on input pin 3
#    wheel rotation counters on pins 0 and 1
#    arm pan/tilt on output 0 and 1
#    webcam server on output 2
#
# software:
#  python
#  opencv/simplecv
#  motion (with single image and video streaming)
#  piconzero requirements for i2c
#  lighttpd for access to motion/opencv image processing
# 


import subprocess
from SimpleCV import Color, Image
import time
import cv2
import sys
import tty
import termios
import select
import PIL
import zbar
import curses
from shutil import copyfile
import random
from bisect import bisect




img = Image("/dev/shm/lastsnap.jpg")


object = img.hueDistance(Color.BLUE)
	object.save("/dev/shm/p3.png")
	object.save("/dev/shm/p3.jpg") # for shape denoise handling

	#blobs = blue_distance.findBlobs()

	#object.draw(color=Color.PUCE, width=2)
	#blue_distance.show()
	#blue_distance.save("/dev/shm/p3.png")

corners=img.findCorners()

	statusWin.clear()
statusWin.addstr( 1, 1,  str(object.meanColor()))


corners.draw()

img.addDrawingLayer(object.dl())


	# circle tracking

	#dist = img.colorDistance(Color.BLACK).dilate(2)
	#segmented = dist.stretch(200,255)

blobs = img.findBlobs()
	if blobs:
circles = blobs.filter([b.isCircle(0.2) for b in blobs])
	if circles:
img.drawCircle((circles[-1].x, circles[-1].y), circles[-1].radius(),Color.BLUE,3)


blobs.draw(color=Color.RED, width=2)


	num_corners = len(corners)
num_blobs = len(blobs)
	statusWin.addstr(2,1, "Corners Found:" + str(num_corners))
	statusWin.addstr(3,1, "Blobs Found:" + str(num_blobs))

	img.save("/dev/shm/p4.png")
	img.save("/dev/shm/p4b.jpg")

	img2 = cv2.imread('/dev/shm/lastsnap.jpg')
	grey = cv2.imread('/dev/shm/p3.jpg',0)
	#grey = cv2.imread('/dev/shm/lastsnap.jpg',0)

	#worked are removing noise but took wayyyyyy too long
	#denos=cv2.fastNlMeansDenoising(grey, None, 10)

	# detection against a greyscale image. 
	# change thresholds against different backgrounds
	#ret, thresh = cv2.threshold( denos,80,80, 1)
	ret, thresh = cv2.threshold( grey,80,80,1)
contours, h = cv2.findContours( thresh, 1,2 )

	# http://stackoverflow.com/questions/11424002/how-to-detect-simple-geometric-shapes-using-opencv

	cpent=0
	ctri=0
	csqr=0
	chc=0
	ccir=0
	for cnt in contours:
approx = cv2.approxPolyDP(cnt,0.01*cv2.arcLength(cnt,True),True)
	#print len(approx)
	statusWin.addstr(3,20, "Contours Found:" + str(len(approx)))
	if len(approx)==5:
	#print "pentagon"
	cpent=cpent+1
	#cv2.drawContours(img2,[cnt],0,255,-1)
	elif len(approx)==3:
	#print "triangle"
	ctri=ctri+1
cv2.drawContours(img2,[cnt],0,Color.RED,-1)
	elif len(approx)==4:
	#print "square"
	csqr=csqr+1
cv2.drawContours(img2,[cnt],0,Color.BLUE,-1)
	elif len(approx) == 9:
	#print "half-circle"
	chc=chc+1
cv2.drawContours(img2,[cnt],0,Color.GREEN,-1)
	elif len(approx) > 15:
	#print "circle"
	ccir=ccir+1
	#cv2.drawContours(img2,[cnt],0,Color.PUCE,-1)

	statusWin.addstr(3,40, "pent=" + str(cpent)+" R.tri="+str(ctri)+" B.sqr="+str(csqr)+" G.hc="+str(chc)+" cir="+str(ccir))


	#cv2.imwrite("/dev/shm/pdenos.jpg",denos)
	cv2.imwrite("/dev/shm/pdenos.jpg",grey)
	cv2.imwrite("/dev/shm/p5.jpg",img2)


	# using the greyscale version from the shape detector detect bar codes

scanner = zbar.ImageScanner()
	scanner.parse_config('enable')
pil = PIL.Image.fromarray(grey)
	width, height = pil.size
raw = pil.tostring()

	image = zbar.Image(width, height, 'Y800', raw)
scanner.scan(image)

	fstr=''
	for symbol in image:
	fstr = fstr + ' decoded' + symbol.type + ' symbol '+ symbol.data

	statusWin.addstr(4,1, "barcode "+fstr)


