# Convert PQ HDR to Gain Map HDR

A macOS tool for converting HDR file to Adaptive HDR (Gain Map/ISO HDR)

Include:

1. PQHDRtoGMHDR, which convert png, tiff etc. PQ HDR file to Gain Map HDR. This code will read a image file as both SDR and HDR image, then calculate difference between two images as gain map. After denoise, combine SDR image with gain map to get GainMapHDR file.
2. heic_hdr.py, a ChatGPT generated python script to convert all TIFF file to HEIC.

## Usage

Convert PQ_HDR to ISO_HDR.heic:

`./PQHDRtoGMHDR $file_dir $folder_dir`

Batch convert all tiff file in a folder:

1. Download all files in same folder:

`git clone https://github.com/chemharuka/PQ_HDR_to_Gain_Map_HDR.git`

`cd PQ_HDR_to_Gain_Map_HDR`

2. run heic_hdr.py (default run with 8 threads, change it accroding to your chip's big core.)

`./heic_hdr.py $folder_for_convert`

You may need to change DIR of PQHDRtoGMHDR in heic_hdr.py before running. (in line40)

## Sample

sample 1:
![DJI_1_0616_D](https://github.com/user-attachments/assets/da00b25d-b1b8-4e34-a0b8-20653e787f72)

sample 2:
![DJI_1_0226_D](https://github.com/user-attachments/assets/b542e146-b2fc-48c9-9021-0dc469203bad)


## Note

FIXED: ~~It's better to limit PQ HDR range in +2 eV, to avoid losing hightlight details.~~
