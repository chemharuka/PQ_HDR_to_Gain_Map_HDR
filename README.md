# Convert HDR files to Gain Map HDR

A macOS tool for converting HDR files to Adaptive HDR (Gain Map / ISO HDR)

Include:

1. PQHDRtoGMHDR, which convert png, tiff etc. HDR file (in PQ HDR / HLG HDR) to Adaptive HDR (gain map heic file). The program will read a image as both SDR and HDR image, then calculate difference between two images as gain map.
2. heic_hdr.py, a ChatGPT generated python script to convert all TIFF file to HEIC.

GUI program created by @vincenttsang [HDR-Gain-Map-Convert](https://github.com/vincenttsang/HDR-Gain-Map-Convert)

## Usage

### PQHDRtoGMHDR

Convert any HDR to ISO_HDR.heic by PQHDRtoGMHDR:

`./PQHDRtoGMHDR $file_dir $folder_dir $options`

Options:

-q \<value>: image quality (default: 0.85)

-f \<format>: export image in heic or jpg (default: heic)

-c \<color space>: output color space (srgb, p3, rec2020), default use source file's color space.

-d \<color depth>: output color depth (default: 8)

-s: export tone mapped SDR image without HDR gain map

-p: export 10 bits PQ HDR heic image

-h: export HLG HDR heic image (default in 10bit)

-g: export Google Photos compatible heic image \*\*

-help: print help information

Sample command：

 `./PQHDRtoGMHDR ~/Downloads/abc.png ~/Documents/ -q 0.95 -d 10 -c rec2020`

 `./PQHDRtoGMHDR ~/Downloads/abc.tiff ~/Documents/ -q 0.80 -f jpg`
 
About Google Photos compatible export:

/*/* Google photos only reads certain values ​​of "markerApple" to determine whether the image is HDR, so HDR images outputed by CIImageRepresentationOption.hdrImage cannot be identificated. To solve this problem, use CIImageRepresentationOption.hdrGainMapImage to output image. This may result in slower speed and slight change in brightness, but also smaller file size.

### heic_hdr.py

Batch convert all tiff file in a folder by heic_hdr.py:

1. Download all files in a folder:

`git clone https://github.com/chemharuka/PQ_HDR_to_Gain_Map_HDR.git`

`cd PQ_HDR_to_Gain_Map_HDR`

`chmod 711 ./PQHDRtoGMHDR`

2. run heic_hdr.py (default run with 8 threads, change it accroding to your chip's big core.)

`python3 ./heic_hdr.py $folder_for_convert $options`

You may need to change DIR of PQHDRtoGMHDR in heic_hdr.py before running. (in line 44)

Sample： `python3 ./heic_hdr.py ~/Documents/export/ -q 0.90 -c rec2020`

## Sample

sample 1:
![DJI_1_0616_D](https://github.com/user-attachments/assets/d4fd48bb-6561-496f-b1ab-083ee1ae8a95)

sample 2:
![DJI_1_0226_D](https://github.com/user-attachments/assets/0a718722-6939-41d3-844d-14517442de05)

sample 3:
![DJI_1_0927_D](https://github.com/user-attachments/assets/66da879e-d56a-4bae-8185-d2d7d462e10f)

## Note

FIXED: ~~It's better to limit PQ HDR range in +2 eV, to avoid losing hightlight details.~~

FIXED: ~~HDR headroom was limited to +2 eV, might improve in future.~~

FIXED: ~~Not support HDR preview in Google Photos.~~

Not support JPEG Gain Map HDR exported by Adobe.
