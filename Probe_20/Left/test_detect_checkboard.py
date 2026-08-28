

# import cv2

# # Read RGB image 
# img1 = cv2.imread("Left_01.jpg")
# img2 = cv2.imread("Right_01.jpg")
  
# # Output img with window name as 'image' 
# # cv2.imshow('img1', img1)
# # cv2.imshow('img2', img2)


# rval, image_corners = cv2.findChessboardCorners(img1, (9,10), None)

# im1 = cv2.drawChessboardCorners(img1, (9,10),image_corners, rval)
# plt.imshow(img1)
# plt.show()


import cv2
import numpy as np 
import os 
import glob 

CHECKBOARD = (6,9)
criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 30, 0.001)

objpoints = []
imgpoints = []

objp = np.zeros((1, CHECKBOARD[0]*CHECKBOARD[1],3),np.float32)
objp[0,:,:2] = np.mgrid[0:CHECKBOARD[0], 0:CHECKBOARD[1]].T.reshape(-1,2)
prev_img_shape = None

images = glob.glob('*.jpg')
count = 1

for fnames in images:

	img = cv2.imread(fnames)
	gray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)


# cv2.imshow('img',img)
# cv2.waitKey(2000)

	retval,corners = cv2.findChessboardCorners(gray, CHECKBOARD, cv2.CALIB_CB_NORMALIZE_IMAGE)
	print(f"{retval}")

	if retval == True:
		objpoints.append(objp)
		corners2 = cv2.cornerSubPix(gray,corners,(11,11),(-1,-1),criteria)

		imgpoints.append(corners2)
		img = cv2.drawChessboardCorners(img, CHECKBOARD, corners2, retval)
		print(count)
		count +=1

	else:
		print("Could not detect checkerboard.")
		count += 1


