# Convert HDR files to Gain Map HDR

A macOS tool for converting HDR files to Adaptive HDR (Gain Map / ISO HDR)

Include:

1. toGainMapHDR, which convert png, tiff etc. HDR file (in PQ HDR / HLG HDR) to Adaptive HDR (gain map heic file). The program will read a image as both SDR and HDR image, then calculate difference between two images as gain map.
2. heic_hdr.py, a ChatGPT generated python script to convert all TIFF file to HEIC.
3. GainMapKernel.ci.metallib, library needed to output linear gain map.
4. gmAdjustKernel.ci.metallib, library needed to generate gain map with correct gamma.

GUI program created by @vincenttsang [HDR-Gain-Map-Convert](https://github.com/vincenttsang/HDR-Gain-Map-Convert)

## Usage

### toGainMapHDR

Convert any HDR Files to Gain_Map_HDR.heic by toGainMapHDR:

`./toGainMapHDR $file_dir $folder_dir $options`

Supported input format:

* AVIF、JXL、HEIF (in PQ/HLG/Gain map)
* TIFF (in PQ/HLG/Linear32)
* PNG (in PQ/HLG)
* JPG (gain map)
* EXR、HDR

#### System Require

Require macOS 15.0+ (Some format support require 15.1+), PLEASE UPGRADE your system to LATEST version for more compatibility.

#### Options:

-q \<value>: image quality (default: 0.85)

-b \<file_path>: specify the base image and output in RGB gain map format.

-c \<color space>: output color space (srgb, p3, rec2020), default use source file's color space.

-d \<color depth>: output color depth (default: 8)

-g: output compatible monochrome gain map (recommanded) \*\*

-s: export tone mapped SDR image without HDR gain map

-j: export image in JPEG format

-p: export 10-bit PQ HDR heic image

-h: export HLG HDR heic image (default in 10-bit)

-help: print help information

#### Sample command：

 `./toGainMapHDR ~/Downloads/abc.png ~/Documents/ -q 0.95 -d 10 -c rec2020`

 `./toGainMapHDR ~/Downloads/abc.tiff ~/Documents/ -q 0.80 -f jpg`
 
convert gain map abc.avif to gain map heic file and keep base image:
 
 `./toGainMapHDR ~/Downloads/abc.avif ~/Documents/ -b ./Downloads/abc.avif` 
 
convert abc.tiff to compatible monochrome gain map file:
 
 `./toGainMapHDR ~/Downloads/abc.tiff ~/Documents/ -g` 
 
convert RGB gain map file to compatible monochrome gain map heic file (rename it as heif to avoid overwrite):

 `./toGainMapHDR ~/Downloads/abc.heif ~/Documents/ -g` 

#### Note: 

1. Using a specific base photo will result larger file size (approximately double)
2. Exporting 10-bit heic files will result larger file size (approximately double)
3. \*\* Monochrome gain map compatible with Google Photos, Instagram etc. Recommended to use for sharing.
4. When exporting 8-bit heic photo, color discontinuity may occur in low-texture areas, like clouds, lakes.

### heic_hdr.py

Batch convert all tiff files in a folder by heic_hdr.py:

1. Download all files in a folder:

`git clone https://github.com/chemharuka/PQ_HDR_to_Gain_Map_HDR.git`

`cd PQ_HDR_to_Gain_Map_HDR/bin`

`chmod 711 ./PQHDRtoGMHDR`

2. run heic_hdr.py (default run with 8 threads, change it accroding to your chip's performance core.)

`python3 ./heic_hdr.py $folder_for_convert $options`

You may need to change the DIR of toGainMapHDR in heic_hdr.py before running. (in line 44)

#### Sample：

`python3 ./heic_hdr.py ~/Documents/export/ -q 0.90 -c rec2020`

#### Note: 

1. Not support specifying base image in batch converting.

## Sample

sample 1:
![DJI_1_0616_D](https://github.com/user-attachments/assets/d4fd48bb-6561-496f-b1ab-083ee1ae8a95)

sample 2:
![DJI_1_0226_D](https://github.com/user-attachments/assets/0a718722-6939-41d3-844d-14517442de05)

sample 3:
![DJI_1_0927_D](https://github.com/user-attachments/assets/66da879e-d56a-4bae-8185-d2d7d462e10f)

## Notes

FIXED: ~~It's better to limit PQ HDR range in +2 eV, to avoid losing hightlight details.~~

FIXED: ~~HDR headroom was limited to +2 eV, might improve in future.~~

FIXED: ~~Not support HDR preview in Google Photos.~~

