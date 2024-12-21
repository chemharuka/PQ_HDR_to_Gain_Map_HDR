//
//  HDRmaxFilter.swift
//  toGainMapHDR
//
//  Created by Luyao Peng on 12/19/24.
//

import CoreImage

class HDRmaxFilter: CIFilter {
    var HDRImage: CIImage?
    static var kernel: CIKernel = { () -> CIColorKernel in
        guard let url = Bundle.main.url(
              forResource: "HDRmaxKernel.ci",
              withExtension: "metallib"),
              let data = try? Data(contentsOf: url) else {
              fatalError("Unable to load metallib")
            }
        
        guard let kernel = try? CIColorKernel(
              functionName: "HDRmaxFilter",
              fromMetalLibraryData: data) else {
              fatalError("Unable to create color kernel")
            }
        return kernel
    }()
    override var outputImage: CIImage? {
        guard let HDRImage = HDRImage else { return nil }
        return HDRmaxFilter.kernel.apply(extent: HDRImage.extent,
                                          roiCallback: { _, rect in return rect},
                                          arguments: [HDRImage])
      }
}

