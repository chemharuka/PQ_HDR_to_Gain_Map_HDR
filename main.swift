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


let arguments = CommandLine.arguments
guard arguments.count > 2 else {
    print("Usage: PQHDRtoGMHDR <source file> <destination folder> <options>\n       options:\n         -q <value>: image quality (default: 0.85)\n         -f <format>: export image in heic or jpg (default: heic)\n         -c <color space>: specify output color space (srgb, p3, rec2020)\n         -d <color depth>: specify output color depth (default: 8)\n         -s: export tone mapped SDR image without HDR gain map\n         -p: export 10bit PQ HDR heic image\n         -h: export HLG HDR heic image (default in 10bit)\n         -g: export Google Photos compatible heic image\n         -help: print help information")
    exit(1)
}

let url_hdr = URL(fileURLWithPath: arguments[1])
let filename = url_hdr.deletingPathExtension().appendingPathExtension("heic").lastPathComponent
let filename_jpg = url_hdr.deletingPathExtension().appendingPathExtension("jpg").lastPathComponent
let path_export = URL(fileURLWithPath: arguments[2])
let url_export_heic = path_export.appendingPathComponent(filename)
let url_export_jpg = path_export.appendingPathComponent(filename_jpg)
let imageoptions = arguments.dropFirst(3)

var imagequality: Double? = 0.85
var sdr_export: Bool = false
var pq_export: Bool = false
var hlg_export: Bool = false
var jpg_export: Bool = false
var bit_depth = CIFormat.RGBA8
var eight_bit: Bool = false
var google_photo: Bool = false

let hdr_image = CIImage(contentsOf: url_hdr, options: [.expandToHDR: true])
let tonemapped_sdrimage = hdr_image?.applyingFilter("CIToneMapHeadroom", parameters: ["inputTargetHeadroom":1.0])

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
    case "-s":
        sdr_export = true
    case "-p":
        pq_export = true
    case "-h":
        hlg_export = true
    case "-g":
        google_photo = true
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
    case "-f":
        guard index + 1 < imageoptions.count else {
            print("Error: The -f option requires image format argument. (heic, jpg)")
            exit(1)
        }
        let export_format = arguments[index + 4]
        switch export_format {
            case "heic","h","heif":
                ()
            case "jpg","j","jpeg":
                jpg_export = true
            default:
                print("Error: The -f option requires image format argument. (heic, jpg)")
                exit(1)
        }
        index += 1 // Skip the next value
    case "-help":
        print("Usage: PQHDRtoGMHDR <source file> <destination folder> <options>\n       options:\n         -q <value>: image quality (default: 0.85)\n         -f <format>: export image in heic or jpg (default: heic)\n         -c <color space>: specify output color space (srgb, p3, rec2020)\n         -d <color depth>: specify output color depth (default: 8)\n         -s: export tone mapped SDR image without HDR gain map\n         -p: export 10bit PQ HDR heic image\n         -h: export HLG HDR heic image (default in 10bit)\n         -help: print help information")
        exit(1)
    default:
        print("Warrning: Unknown option: \(option)")
    }
    index += 1
}

if [pq_export, hlg_export, sdr_export, google_photo].filter({$0}).count >= 2 {
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

if !google_photo {
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

// export Google Photos compatible heic image. Due to some compatibility issues
// (Google photos only reads certain values ​​of "markerApple" to determine whether the image is HDR),
// HDR images output using CIImageRepresentationOption.hdrImage cannot be recognized by Google Photos.
// To solve this problem, output image through CIImageRepresentationOption.hdrGainMapImage.
// This method will output more slowly and there will be slight changes in brightness,
// but the file size will be smaller.

let temporaryDirectory = FileManager.default.temporaryDirectory
let virtualDirectoryURL = temporaryDirectory.appendingPathComponent("VirtualDirectory")
try FileManager.default.createDirectory(at: virtualDirectoryURL, withIntermediateDirectories: true, attributes: nil)

let temp_gmhdr_file_name = "gainmaphdr.heic"
let temp_gmhdr_file_url = virtualDirectoryURL.appendingPathComponent(temp_gmhdr_file_name)
let temp_export_options = NSDictionary(dictionary:[kCGImageDestinationLossyCompressionQuality:1.0, CIImageRepresentationOption.hdrImage:hdr_image!])
try! ctx.writeHEIFRepresentation(of: tonemapped_sdrimage!,
                                 to: temp_gmhdr_file_url,
                                 format: CIFormat.RGBA8,
                                 colorSpace: CGColorSpace(name: sdr_color_space)!,
                                 options: temp_export_options as! [CIImageRepresentationOption : Any])

let temp_hdr_image = CIImage(contentsOf: temp_gmhdr_file_url, options: [.expandToHDR: true])
let headroom_value = temp_hdr_image!.properties["Headroom"]
let gainmap_image = CIImage(contentsOf: temp_gmhdr_file_url, options: [.auxiliaryHDRGainMap: true])
let output_image = tonemapped_sdrimage!.applyingGainMap(gainmap_image!, headroom: headroom_value as! Float)
var imageProperties = temp_hdr_image!.properties
var makerApple = imageProperties[kCGImagePropertyMakerAppleDictionary as String] as? [String: Any] ?? [:]
let stops = log2(headroom_value as! Float)
var gamma_value : Double = 2.2

//print("\(String(describing: headroom_value))")
//print("\(stops)")

func gammaAdjust(inputImage: CIImage) -> CIImage {
    let gammaAdjustFilter = CIFilter.gammaAdjust()
    gammaAdjustFilter.inputImage = inputImage
    gammaAdjustFilter.power = Float(gamma_value)
    return gammaAdjustFilter.outputImage!
}

func toneCurve(inputImage: CIImage) -> CIImage {
    let toneCurveFilter = CIFilter.toneCurve()
    toneCurveFilter.inputImage = inputImage
    toneCurveFilter.point0 = CGPoint(x: 0, y: pow(0.5,1/gamma_value))   //0.5^(1/gamma)
    toneCurveFilter.point1 = CGPoint(x: 0.5, y: (1+pow(0.5,1/gamma_value))/2)
    toneCurveFilter.point2 = CGPoint(x: 1, y: 1)
    return toneCurveFilter.outputImage!
}

let gamma_gainmap_image = toneCurve(inputImage:gammaAdjust(inputImage: gainmap_image!))

switch stops {
case let x where x >= 3:
    makerApple["33"] = 1.0
    makerApple["48"] = 0.0
case 2.3..<3:
    makerApple["33"] = 1.0
    makerApple["48"] = (3 - stops)/70
case 1.8..<2.3:
    makerApple["33"] = 1.0
    makerApple["48"] = (2.303 - stops)/0.303
case 1.6..<1.8:
    makerApple["33"] = 0.0
    makerApple["48"] = (1.8 - stops)/20
default:
    makerApple["33"] = 0.0
    makerApple["48"] = (1.601 - stops)/0.101
}

imageProperties[kCGImagePropertyMakerAppleDictionary as String] = makerApple
let modifiedImage = tonemapped_sdrimage!.settingProperties(imageProperties)

let alt_export_options = NSDictionary(dictionary:[kCGImageDestinationLossyCompressionQuality:imagequality ?? 0.85, CIImageRepresentationOption.hdrGainMapImage:gamma_gainmap_image])

try! ctx.writeHEIFRepresentation(of: modifiedImage,
                                 to: url_export_heic,
                                 format: bit_depth,
                                 colorSpace: CGColorSpace(name: sdr_color_space)!,
                                 options: alt_export_options as! [CIImageRepresentationOption : Any])

exit(0)
// debug
//let filename2 = url_hdr.deletingPathExtension().appendingPathExtension("png").lastPathComponent
//let url_export_heic2 = path_export.appendingPathComponent(filename2)
//try! ctx.writePNGRepresentation(of: gainmap!, to: url_export_heic2, format: CIFormat.RGBA8, colorSpace:CGColorSpace(name: CGColorSpace.displayP3)!)


