//
//  main.swift
//  PQHDR_to_GainMapHDR
//  This code will convert PQ HDR file to luminance gain map HDR heic file.
//
//  Created by Luyao Peng on 2024/9/27.
//

import CoreImage
import Foundation

let ctx = CIContext()


let arguments = CommandLine.arguments
guard arguments.count > 2 else {
    print("Usage: PQHDRtoGMHDR <source file> <destination folder> <options>\n       options:\n         -q <value>: image quality (default: 0.85)\n         -f <format>: export image in heic or jpg (default: heic)\n         -c <color space>: specify output color space (srgb, p3, rec2020)\n         -d <color depth>: specify output color depth (default: 8)\n         -s: export tone mapped SDR image without HDR gain map\n         -p: export 10bit PQ HDR heic image\n         -h: export HLG HDR heic image (default in 10bit)\n         -help: print help information")
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

let hdr_image = CIImage(contentsOf: url_hdr, options: [.expandToHDR: true])
let tonemapped_sdrimage = hdr_image?.applyingFilter("CIToneMapHeadroom", parameters: ["inputTargetHeadroom":1.0])

if hdr_image == nil {
    print("Error: No input image found.")
    exit(1)
}
let export_options = NSDictionary(dictionary:[kCGImageDestinationLossyCompressionQuality:imagequality ?? 0.85, CIImageRepresentationOption.hdrImage:hdr_image!])

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
            case "srgb","709","rec709","rec.709","bt709","bt,709","itu709":
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

if (sdr_export && hlg_export) || (hlg_export && pq_export) || (pq_export && sdr_export) {
    print("Error: Only one export format can be used.")
    exit(1)
}
if (jpg_export && hlg_export) || (jpg_export && pq_export) {
    print("Error: Not support exporting JPEG with HLG or PQ transfer function.")
    exit(1)
}
if hlg_export && eight_bit {print("Warrning: Suggested to use 10-bit with HLG.")}
if jpg_export && bit_depth == CIFormat.RGB10 {print("Warning: Color depth will be 8 when exporting JPEG.")}



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
// debug
//let filename2 = url_hdr.deletingPathExtension().appendingPathExtension("png").lastPathComponent
//let url_export_heic2 = path_export.appendingPathComponent(filename2)
//try! ctx.writePNGRepresentation(of: gainmap!, to: url_export_heic2, format: CIFormat.RGBA8, colorSpace:CGColorSpace(name: CGColorSpace.displayP3)!)


