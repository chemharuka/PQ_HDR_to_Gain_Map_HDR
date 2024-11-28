//
//  evAdjustFilter.swift
//  toGainMapHDR
//
//  Created by Luyao Peng on 11/28/24.
//

import CoreImage

class evAdjustFilter: CIFilter {
    var inputImage: CIImage?
    var inputEV: Float? = 0.0
    static var kernel: CIKernel = { () -> CIColorKernel in
        guard let url = Bundle.main.url(
              forResource: "evAdjustKernel.ci",
              withExtension: "metallib"),
              let data = try? Data(contentsOf: url) else {
              fatalError("Unable to load metallib")
            }
        
        guard let kernel = try? CIColorKernel(
              functionName: "evAdjustFilter",
              fromMetalLibraryData: data) else {
              fatalError("Unable to create color kernel")
            }
        return kernel
    }()
    override var outputImage: CIImage? {
        guard let input = inputImage else { return nil }
        guard let inputEV = inputEV else { return nil }
        return evAdjustFilter.kernel.apply(extent: inputImage!.extent,
                                           roiCallback: { _, rect in return rect},
                                           arguments: [input, inputEV])
      }
}

