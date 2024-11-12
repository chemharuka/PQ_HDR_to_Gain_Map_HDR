# Convert HDR files to Gain Map HDR

A macOS tool for converting HDR files to Adaptive HDR (Gain Map/ISO HDR)

Include:

1. PQHDRtoGMHDR, which convert png, tiff etc. HDR file (which supported by macOS, like PQ HDR / HLG HDR / UltraHDR) to Adaptive HDR (gain map heic file). This code will read a image file as both SDR and HDR image, then calculate difference between two images as gain map.
2. heic_hdr.py, a ChatGPT generated python script to convert all TIFF file to HEIC.

## Usage

Convert any HDR to ISO_HDR.heic:

`./PQHDRtoGMHDR $file_dir $folder_dir`

Batch convert all tiff file in a folder:

1. Download all files in same folder:

`git clone https://github.com/chemharuka/PQ_HDR_to_Gain_Map_HDR.git`

`cd PQ_HDR_to_Gain_Map_HDR`

`chmod 711 ./PQHDRtoGMHDR`

2. run heic_hdr.py (default run with 8 threads, change it accroding to your chip's big core.)

`python3 ./heic_hdr.py $folder_for_convert`

You may need to change DIR of PQHDRtoGMHDR in heic_hdr.py before running. (in line44)

## Sample

sample 1:
![DJI_1_0616_D](https://github.com/user-attachments/assets/d4fd48bb-6561-496f-b1ab-083ee1ae8a95)

sample 2:
![DJI_1_0226_D](https://github.com/user-attachments/assets/0a718722-6939-41d3-844d-14517442de05)

sample 3:
![DJI_1_0927_D](https://github.com/user-attachments/assets/66da879e-d56a-4bae-8185-d2d7d462e10f)

## Note

FIXED: ~~It's better to limit PQ HDR range in +2 eV, to avoid losing hightlight details.~~

HDR headroom was limited to +2 eV, might improve in future.

