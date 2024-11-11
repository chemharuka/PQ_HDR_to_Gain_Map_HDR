import os
import sys
import subprocess
from concurrent.futures import ThreadPoolExecutor

# Get path of dir
if len(sys.argv) != 2:
    print("Usage: python run.py <directory>")
    sys.exit(1)

dir_path = os.path.expanduser(sys.argv[1])

# check dir
if not os.path.isdir(dir_path):
    print(f"Error: Directory {dir_path} does not exist.")
    sys.exit(1)

# define extension name
input_extension = ".tif"
output_extension = ".heic"

# get the list of .tif file
tif_files = [f for f in os.listdir(dir_path) if f.endswith(input_extension)]


if not tif_files:
    print(f"No {input_extension} files found in the directory {dir_path}.")
    sys.exit(1)

# get working dir

current_directory = os.getcwd()
exc_path = os.path.join(current_directory, "PQHDRtoGMHDR")

# define convert function
def convert_to_heic(tif_file):
    input_file_path = os.path.join(dir_path, tif_file)
    output_file_path = dir_path

    # run PQHDRtoGMHDR, please edit exc_path before running!
    # sample: result = subprocess.run([‘/home/user/PQHDRtoGMHDR’, input ······
    
    try:
        result = subprocess.run([exc_path, input_file_path, output_file_path], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        print(f"Converted {tif_file} to {output_extension}")
    except subprocess.CalledProcessError as e:
        print(f"Error converting {tif_file}: {e.stderr.decode()}")


# set max threads 8
max_threads = 8

# use ThreadPoolExecutor batch convert
with ThreadPoolExecutor(max_workers=max_threads) as executor:
    executor.map(convert_to_heic, tif_files)



print("All files have been processed.")
