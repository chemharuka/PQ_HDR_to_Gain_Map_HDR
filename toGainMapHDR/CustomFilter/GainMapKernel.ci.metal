//
//  GainMap.ci.metal
//  PQHDR_to_GainMapHDR
//
//  Created by Luyao Peng on 11/27/24.
//

#include <metal_stdlib>
#include <CoreImage/CoreImage.h>

using namespace metal;

extern "C" float4 GainMapFilter(coreimage::sample_t hdr, coreimage::sample_t sdr, coreimage::destination dest)
{
    float gamma_ratio;
    float ratio;
    float hdr_ave;
    float sdr_ave;
    hdr_ave = (hdr.r+hdr.g+hdr.b)/3.0 + pow(10.0,-5.0);
    sdr_ave = (sdr.r+sdr.g+sdr.b)/3.0 + pow(10.0,-5.0);
    ratio = hdr_ave/sdr_ave;
    gamma_ratio = log2(ratio)/4.0;
    return float4(gamma_ratio, gamma_ratio, gamma_ratio, 1.0);
}



