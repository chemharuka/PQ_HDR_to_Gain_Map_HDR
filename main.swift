//
//  toGainMapHDR
//  This code will convert PQ HDR file to luminance gain map HDR heic file.
//
//  Created by Luyao Peng on 2024/9/27. Distributed under MIT license.
//

import CoreImage
import Foundation
import CoreImage.CIFilterBuiltins

let ctx = CIContext()
let help_info = "Usage: PQHDRtoGMHDR <source file> <destination folder> <options>\n       options:\n         -q <value>: image quality (default: 0.85)\n         -b <base_photo>: specify the base photo and output in RGB gain map format\n         -c <color space>: specify output color space (srgb, p3, rec2020)\n         -d <color depth>: specify output color depth (default: 8)\n         -g: output monochrome gain map for solving compatibility issue\n         -s: export tone mapped SDR image without HDR gain map\n         -p: export 10bit PQ HDR heic image\n         -h: export HLG HDR heic image (default in 10bit)\n         -j : export image in JPEG format\n         -help: print help information"
let arguments = CommandLine.arguments
guard arguments.count > 2 else {
    print(help_info)
    exit(1)
}

let url_hdr = URL(fileURLWithPath: arguments[1])
let filename = url_hdr.deletingPathExtension().appendingPathExtension("heic").lastPathComponent
let filename_jpg = url_hdr.deletingPathExtension().appendingPathExtension("jpg").lastPathComponent
let path_export = URL(fileURLWithPath: arguments[2])
let url_export_heic = path_export.appendingPathComponent(filename)
let url_export_jpg = path_export.appendingPathComponent(filename_jpg)
let imageoptions = arguments.dropFirst(3)
var base_image_url : URL?

var imagequality: Double? = 0.85
var base_image_bool : Bool = false
var sdr_export: Bool = false
var pq_export: Bool = false
var hlg_export: Bool = false
var jpg_export: Bool = false
var bit_depth = CIFormat.RGBA8
var eight_bit: Bool = false
var gain_map_mono: Bool = false

let hdr_image = CIImage(contentsOf: url_hdr, options: [.expandToHDR: true])

if hdr_image == nil {
    print("Error: No input image found.")
    exit(1)
}

var sdr_color_space = CGColorSpace.displayP3
var hdr_color_space = CGColorSpace.displayP3_PQ
var hlg_color_space = CGColorSpace.displayP3_HLG

let image_color_space = String(describing: hdr_image?.colorSpace)

if image_color_space.contains("709") {
    sdr_color_space = CGColorSpace.itur_709
    hdr_color_space = CGColorSpace.itur_709_PQ
    hlg_color_space = CGColorSpace.itur_709_HLG
}
if image_color_space.contains("sRGB") {
    sdr_color_space = CGColorSpace.itur_709
    hdr_color_space = CGColorSpace.itur_709_PQ
    hlg_color_space = CGColorSpace.itur_709_HLG
}
if image_color_space.contains("2100") {
    sdr_color_space = CGColorSpace.itur_2020_sRGBGamma
    hdr_color_space = CGColorSpace.itur_2100_PQ
    hlg_color_space = CGColorSpace.itur_2100_HLG
}
if image_color_space.contains("2020") {
    sdr_color_space = CGColorSpace.itur_2020_sRGBGamma
    hdr_color_space = CGColorSpace.itur_2100_PQ
    hlg_color_space = CGColorSpace.itur_2100_HLG
}

var index:Int = 0
while index < imageoptions.count {
    let option = arguments[index+3]
    switch option {
    case "-q": // Handle -q <value> option
        // Check if there is a next value in the array
        guard index + 1 < imageoptions.count else {
            print("Error: The -q option requires a valid numeric value.")
            exit(1)
        }
        if let value = Double(arguments[index + 4]) {
            if value > 1 {
                imagequality = value/100
            } else {
                imagequality = value
            }
            index += 1 // Skip the next value
        } else {
            print("Error: The -q option requires a valid numeric value.")
            exit(1)
        }
    case "-b":
        guard index + 1 < imageoptions.count else {
            print("Error: The -b option requires a argument.")
            exit(1)
        }
        base_image_url = URL(fileURLWithPath: arguments[index + 4])
        base_image_bool = true
        index += 1
    case "-s":
        sdr_export = true
    case "-p":
        pq_export = true
    case "-h":
        hlg_export = true
    case "-j":
        jpg_export = true
    case "-g":
        gain_map_mono = true
    case "-d":
        guard index + 1 < imageoptions.count else {
            print("Error: The -d option requires a argument.")
            exit(1)
        }
        let bit_depth_argument = String(arguments[index + 4])
        if bit_depth_argument == "8"{
            index += 1
            eight_bit = true
        } else { if bit_depth_argument == "10"{
            bit_depth = CIFormat.RGB10
            index += 1
        } else {
            print("Error: Color depth must be either 8 or 10.")
            exit (1)
        }}
    case "-c":
        guard index + 1 < imageoptions.count else {
            print("Error: The -c option requires color space argument.")
            exit(1)
        }
        let color_space_argument = String(arguments[index + 4])
        let color_space_option = color_space_argument.lowercased()
        switch color_space_option {
            case "srgb","709","rec709","rec.709","bt709","bt.709","itu709":
                sdr_color_space = CGColorSpace.itur_709
                hdr_color_space = CGColorSpace.itur_709_PQ
                hlg_color_space = CGColorSpace.itur_709_HLG
            case "p3","dcip3","dci-p3","dci.p3","displayp3":
                sdr_color_space = CGColorSpace.displayP3
                hdr_color_space = CGColorSpace.displayP3_PQ
                hlg_color_space = CGColorSpace.displayP3_HLG
            case "rec2020","2020","rec.2020","bt2020","itu2020","2100","rec2100","rec.2100":
                sdr_color_space = CGColorSpace.itur_2020_sRGBGamma
                hdr_color_space = CGColorSpace.itur_2100_PQ
                hlg_color_space = CGColorSpace.itur_2100_HLG
            default:
                print("Error: The -c option requires color space argument. (srgb, p3, rec2020)")
                exit(1)
        }
        index += 1 // Skip the next value
    case "-help":
        print(help_info)
        exit(1)
    default:
        print("Warrning: Unknown option: \(option)")
    }
    index += 1
}

if [pq_export, hlg_export, sdr_export, gain_map_mono, base_image_bool].filter({$0}).count >= 2 {
    print("Error: Only one export format can be used.")
    exit(1)
}
if (jpg_export && hlg_export) || (jpg_export && pq_export) {
    print("Error: Not support exporting JPEG with HLG or PQ transfer function.")
    exit(1)
}
if hlg_export && eight_bit {print("Warrning: Suggested to use 10-bit with HLG.")}
if jpg_export && bit_depth == CIFormat.RGB10 {print("Warning: Color depth will be 8 when exporting JPEG.")}
if pq_export && eight_bit {print("Warning: Color depth will be 10 when exporting PQ HDR.")}


let export_options = NSDictionary(dictionary:[kCGImageDestinationLossyCompressionQuality:imagequality ?? 0.85, CIImageRepresentationOption.hdrImage:hdr_image!])

var tonemapped_sdrimage : CIImage?

tonemapped_sdrimage = hdr_image?.applyingFilter("CIToneMapHeadroom", parameters: ["inputSourceHeadroom":16.0,"inputTargetHeadroom":1.0])

if base_image_bool{
    if CIImage(contentsOf: base_image_url!) == nil {
        print("Warning: Could not load base image, will generate base image by tone mapping.")
    }
    else {
        tonemapped_sdrimage = CIImage(contentsOf: base_image_url!)
    }
}

if tonemapped_sdrimage == nil {
    print("Error: Could not generate tone mapped image.")
    exit(1)
}

while sdr_export{
    let sdr_export_options = NSDictionary(dictionary:[kCGImageDestinationLossyCompressionQuality:imagequality ?? 0.85])
    if jpg_export{
        try! ctx.writeJPEGRepresentation(of: tonemapped_sdrimage!,
                                         to: url_export_jpg,
                                         colorSpace: CGColorSpace(name: sdr_color_space)!,
                                         options:sdr_export_options as! [CIImageRepresentationOption : Any])
    } else {
        try! ctx.writeHEIFRepresentation(of: tonemapped_sdrimage!,
                                         to: url_export_heic,
                                         format: bit_depth,
                                         colorSpace: CGColorSpace(name: sdr_color_space)!,
                                         options:sdr_export_options as! [CIImageRepresentationOption : Any])
    }
    exit(0)
}

while hlg_export{
    let hlg_export_options = NSDictionary(dictionary:[kCGImageDestinationLossyCompressionQuality:imagequality ?? 0.85])
    if !eight_bit {bit_depth = CIFormat.RGB10}
    try! ctx.writeHEIFRepresentation(of: hdr_image!,
                                     to: url_export_heic,
                                     format: bit_depth,
                                     colorSpace: CGColorSpace(name: hlg_color_space)!,
                                     options:hlg_export_options as! [CIImageRepresentationOption : Any])
    exit(0)
}

while pq_export {
    let pq_export_options = NSDictionary(dictionary:[kCGImageDestinationLossyCompressionQuality:imagequality ?? 0.85])
    try! ctx.writeHEIF10Representation(of: hdr_image!,
                                       to: url_export_heic,
                                       colorSpace: CGColorSpace(name: hdr_color_space)!,
                                       options:pq_export_options as! [CIImageRepresentationOption : Any])
    exit(0)
}

if !gain_map_mono {
    if jpg_export {
        try! ctx.writeJPEGRepresentation(of: tonemapped_sdrimage!,
                                         to: url_export_jpg,
                                         colorSpace: CGColorSpace(name: sdr_color_space)!,
                                         options:export_options as! [CIImageRepresentationOption : Any])
    } else {
        try! ctx.writeHEIFRepresentation(of: tonemapped_sdrimage!,
                                         to: url_export_heic,
                                         format: bit_depth,
                                         colorSpace: CGColorSpace(name: sdr_color_space)!,
                                         options: export_options as! [CIImageRepresentationOption : Any])
    }
    exit(0)
}

// export monochrome gain map photo which compatible with Google Photos.
// HDR images output using CIImageRepresentationOption.hdrImage will generate RGB gain map.
// Output image through CIImageRepresentationOption.hdrGainMapImage will generate monochrome gain map.
// This method will output more slowly and there will be slight changes in brightness,
// but the file size will be smaller.

func subtractBlendMode(inputImage: CIImage, backgroundImage: CIImage) -> CIImage {
    let colorBlendFilter = CIFilter.subtractBlendMode()
    colorBlendFilter.inputImage = inputImage
    colorBlendFilter.backgroundImage = backgroundImage
    return colorBlendFilter.outputImage!
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

func maximumComponent(inputImage: CIImage) -> CIImage {
    let maximumComponentFilter = CIFilter.maximumComponent()
    maximumComponentFilter.inputImage = inputImage
    return maximumComponentFilter.outputImage!
}

func toneCurve1(inputImage: CIImage) -> CIImage {
    let toneCurveFilter = CIFilter.toneCurve()
    toneCurveFilter.inputImage = inputImage
    toneCurveFilter.point0 = CGPoint(x: 0.0, y: 0.7)
    toneCurveFilter.point1 = CGPoint(x: 0.5, y: 0.74)
    toneCurveFilter.point2 = CGPoint(x: 0.74, y: 0.90)
    toneCurveFilter.point3 = CGPoint(x: 0.80, y: 0.98)
    toneCurveFilter.point4 = CGPoint(x: 1.0, y: 1.0)
    return toneCurveFilter.outputImage!
}

func colorClamp(inputImage: CIImage) -> CIImage {
    let colorClampFilter = CIFilter.colorClamp()
    colorClampFilter.inputImage = inputImage
    colorClampFilter.minComponents = CIVector(x: 0.02, y: 0.02, z: 0.02, w: 0)
    colorClampFilter.maxComponents = CIVector (x: 1, y: 1, z: 1, w: 1)
    return colorClampFilter.outputImage!
}

func gammaAdjust(inputImage: CIImage) -> CIImage {
    let gammaAdjustFilter = CIFilter.gammaAdjust()
    gammaAdjustFilter.inputImage = inputImage
    gammaAdjustFilter.power = 1/2.2
    return gammaAdjustFilter.outputImage!
}

func hdrtosdr(inputImage: CIImage) -> CIImage {
    let imagedata = ctx.tiffRepresentation(of: inputImage,
                                           format: CIFormat.RGBA8,
                                           colorSpace: CGColorSpace(name: CGColorSpace.displayP3)!
    )
    let sdrimage = CIImage(data: imagedata!)
    return sdrimage!
}

let sdr_image = hdrtosdr(inputImage:hdr_image!)
let subtracted_image = subtractBlendMode(
    inputImage:exposureAdjust(inputImage:sdr_image,inputEV: -3),backgroundImage: exposureAdjust(inputImage:hdr_image!,inputEV: -3)
)
let gain_map = gammaAdjust(inputImage:colorClamp(inputImage:maximumComponent(inputImage:subtracted_image)))
let tone_mapped_gain_map = toneCurve1(inputImage:gain_map)

var imageProperties = hdr_image!.properties
var makerApple = imageProperties[kCGImagePropertyMakerAppleDictionary as String] as? [String: Any] ?? [:]
makerApple["33"] = 1.0
makerApple["48"] = 0.0096867 //headroom = 5
imageProperties[kCGImagePropertyMakerAppleDictionary as String] = makerApple

let modifiedImage = tonemapped_sdrimage!.settingProperties(imageProperties)
let alt_export_options = NSDictionary(dictionary:[kCGImageDestinationLossyCompressionQuality:imagequality ?? 0.85, CIImageRepresentationOption.hdrGainMapImage:tone_mapped_gain_map])

if jpg_export {
    try! ctx.writeJPEGRepresentation(of: modifiedImage,
                                     to: url_export_jpg,
                                     colorSpace: CGColorSpace(name: sdr_color_space)!,
                                     options:alt_export_options as! [CIImageRepresentationOption : Any])
} else {
    try! ctx.writeHEIFRepresentation(of: modifiedImage,
                                     to: url_export_heic,
                                     format: bit_depth,
                                     colorSpace: CGColorSpace(name: sdr_color_space)!,
                                     options: alt_export_options as! [CIImageRepresentationOption : Any])
}
exit(0)
// debug
//let filename2 = url_hdr.deletingPathExtension().appendingPathExtension("png").lastPathComponent
//let url_export_heic2 = path_export.appendingPathComponent(filename2)
//try! ctx.writePNGRepresentation(of: gainmap!, to: url_export_heic2, format: CIFormat.RGBA8, colorSpace:CGColorSpace(name: CGColorSpace.displayP3)!)


