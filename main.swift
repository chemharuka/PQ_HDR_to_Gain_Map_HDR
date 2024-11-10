//
//  main.swift
//  PQHDR_to_GainMapHDR
//  This code will read a image file as both SDR and HDR image, then calculate difference between
//  two images as gain map. After denoise and gamma adjustment, combine SDR image with gain map
//  to get GainMapHDR file.
//
//  Created by Luyao Peng on 2024/9/27.
//

import CoreImage
import CoreGraphics
import Foundation
import CoreImage.CIFilterBuiltins

let ctx = CIContext()

func subtractBlendMode(inputImage: CIImage, backgroundImage: CIImage) -> CIImage {
    let colorBlendFilter = CIFilter.subtractBlendMode()
    colorBlendFilter.inputImage = inputImage
    colorBlendFilter.backgroundImage = backgroundImage
    return colorBlendFilter.outputImage!
}

func noiseReduction(inputImage: CIImage) -> CIImage? {
    let noiseReductionfilter = CIFilter.noiseReduction()
    noiseReductionfilter.inputImage = inputImage
    noiseReductionfilter.noiseLevel = 2
    noiseReductionfilter.sharpness = 0
    return noiseReductionfilter.outputImage
}

func linearTosRGB(inputImage: CIImage) -> CIImage {
    let linearTosRGB = CIFilter.linearToSRGBToneCurve()
    linearTosRGB.inputImage = inputImage
    return linearTosRGB.outputImage!
}

func exposureAdjust(inputImage: CIImage, inputEV: Float) -> CIImage {
    let exposureAdjustFilter = CIFilter.exposureAdjust()
    exposureAdjustFilter.inputImage = inputImage
    exposureAdjustFilter.ev = inputEV
    return exposureAdjustFilter.outputImage!
}

func hdrtosdr(inputImage: CIImage) -> CIImage {
    let imagedata = ctx.tiffRepresentation(of: inputImage,
                                           format: CIFormat.RGBA8,
                                           colorSpace: CGColorSpace(name: CGColorSpace.displayP3)!
    )
    let sdrimage = CIImage(data: imagedata!)
    return sdrimage!
}

let arguments = CommandLine.arguments
guard arguments.count == 3 else {
    print("Usage: PQHDRtoGMHDR <source file> <destination>")
    exit(1)
}


let url_hdr = URL(fileURLWithPath: arguments[1])
let filename = url_hdr.deletingPathExtension().appendingPathExtension("heic").lastPathComponent
let path_export = URL(fileURLWithPath: arguments[2])
let url_export_heic = path_export.appendingPathComponent(filename)


let hdrimage = CIImage(contentsOf: url_hdr, options: [.expandToHDR: true])
let sdrimage = hdrtosdr(inputImage:hdrimage!)


let gainMap = noiseReduction(
            inputImage:exposureAdjust(
                inputImage:linearTosRGB(
                    inputImage:subtractBlendMode(
                        inputImage:
                            exposureAdjust(inputImage:sdrimage,inputEV: -3),backgroundImage: exposureAdjust(inputImage:hdrimage!,inputEV: -3)
                        )
                    ), inputEV: 0.5
                )
            )

// codes below from: https://gist.github.com/kiding/fa4876ab4ddc797e3f18c71b3c2eeb3a?permalink_comment_id=4289828#gistcomment-4289828

// Get metadata, and especially the {MakerApple} tags from the main image.
var imageProperties = sdrimage.properties
var makerApple = imageProperties[kCGImagePropertyMakerAppleDictionary as String] as? [String: Any] ?? [:]

// Set HDR-related tags as desired.
makerApple["33"] = 0.0 // 0x21, seems to describe the global HDR headroom. Can be 0.0 or un-set when setting the tag below.
makerApple["48"] = 0.0 // 0x30, seems to describe the effect of the gain map to the HDR effect, between 0.0 and 8.0 with 0.0 being the max.

// Set metadata back on image before export.
imageProperties[kCGImagePropertyMakerAppleDictionary as String] = makerApple
let modifiedImage = sdrimage.settingProperties(imageProperties)

try! ctx.writeHEIFRepresentation(of: modifiedImage,
                                 to: url_export_heic,
                                 format: CIFormat.RGBA8,
                                 colorSpace: (sdrimage.colorSpace)!,
                                 options: [.hdrGainMapImage: gainMap!])


// debug
//let filename2 = url_hdr.deletingPathExtension().appendingPathExtension("png").lastPathComponent
//let url_export_heic2 = path_export.appendingPathComponent(filename2)
//try! ctx.writePNGRepresentation(of: gainMap!, to: url_export_heic2, format: CIFormat.RGBA8, colorSpace: (sdrimage.colorSpace)!)
