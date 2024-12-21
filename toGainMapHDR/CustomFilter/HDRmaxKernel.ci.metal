//
//  HDRmaxKernel.ci.metal
//  toGainMapHDR
//
//  Created by Luyao Peng on 12/19/24.
//

#include <metal_stdlib>
#include <CoreImage/CoreImage.h>

using namespace metal;

extern "C" float4 HDRmaxFilter(coreimage::sample_t hdr, coreimage::destination dest)
{
    float gamma_ratio;
    float ratio;
    float rgb_max;
    float rg_max;
    rg_max = max(hdr.r, hdr.g);
    rgb_max = max(rg_max, hdr.b);
    if (rgb_max <= 1.0) {
        ratio = 1.0;
    } else {
        ratio = rgb_max;
    }
    gamma_ratio = log2(ratio)/4.0;
    return float4(gamma_ratio, gamma_ratio, gamma_ratio, 1.0);
}



