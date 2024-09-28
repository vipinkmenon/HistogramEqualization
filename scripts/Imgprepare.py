import cv2
import numpy as np
from matplotlib import pyplot as plt

im = cv2.imread('uneq.jpg', cv2.IMREAD_GRAYSCALE)
f = open('input.bin','wb')
f.write(im)
f.close()