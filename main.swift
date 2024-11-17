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
    print("Usage: PQHDRtoGMHDR <source file> <destination> <options>, options: -q <value> image quality (default: 0.85).")
    exit(1)
}

let url_hdr = URL(fileURLWithPath: arguments[1])
let filename = url_hdr.deletingPathExtension().appendingPathExtension("heic").lastPathComponent
let path_export = URL(fileURLWithPath: arguments[2])
let url_export_heic = path_export.appendingPathComponent(filename)
let imageoptions = arguments.dropFirst(3)
var imagequality: Double? = 0.85

var index:Int = 0
while index < imageoptions.count {
    let option = arguments[index+3]
    switch option {
    case "-q": // Handle -q <value> option
        // Check if there is a next value in the array
        guard index + 1 < imageoptions.count else {
            print("Error: The -q option requires a numeric value.")
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
            print("Error: The -q option must be followed by a valid numeric value.")
            exit(1)
        }
    default:
        print("Unknown option: \(option)")
    }
    index += 1
}

let hdr_image = CIImage(contentsOf: url_hdr, options: [.expandToHDR: true])
let tonemapped_sdrimage = hdr_image?.applyingFilter("CIToneMapHeadroom", parameters: ["inputTargetHeadroom":1.0])
let export_options = NSDictionary(dictionary:[kCGImageDestinationLossyCompressionQuality:imagequality ?? 0.85, CIImageRepresentationOption.hdrImage:hdr_image!])

try! ctx.writeHEIFRepresentation(of: tonemapped_sdrimage!,
                                 to: url_export_heic,
                                 format: CIFormat.RGBA8,
                                 colorSpace: CGColorSpace(name: CGColorSpace.displayP3)!,
                                 options: export_options as! [CIImageRepresentationOption : Any])

// debug
//let filename2 = url_hdr.deletingPathExtension().appendingPathExtension("png").lastPathComponent
//let url_export_heic2 = path_export.appendingPathComponent(filename2)
//try! ctx.writePNGRepresentation(of: gainmap!, to: url_export_heic2, format: CIFormat.RGBA8, colorSpace:CGColorSpace(name: CGColorSpace.displayP3)!)
