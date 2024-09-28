

#!/usr/bin/python
import numpy as np
import sys
import cv2

# Load image as string from file/database    
fd = open('out.bin','rb')
img_str = fd.read()
fd.close()

img_array = np.asarray(bytearray(img_str), dtype=np.uint8)

img = img_array.reshape(480,640)

cv2.imwrite('output.png', img)