# copy_wishlist.py
# Script to copy the entire WishList addon folder to a new location, replacing files if needed (Windows)

import os
import shutil
import sys

# Set source and destination paths
SRC = os.path.abspath(os.path.dirname(__file__))
# You can change this default destination or pass it as an argument
DST = r'C:\Battle.net\World of Warcraft\_classic_\Interface\AddOns\WishList'

if len(sys.argv) > 1:
    DST = sys.argv[1]

print(f'Copying from {SRC} to {DST}')

if os.path.exists(DST):
    print('Destination exists, removing...')
    shutil.rmtree(DST)

shutil.copytree(SRC, DST)
print('Copy complete.')
