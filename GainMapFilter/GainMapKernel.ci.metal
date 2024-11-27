//
//  GainMap.ci.metal
//  PQHDR_to_GainMapHDR
//
//  Created by Luyao Peng on 11/27/24.
//

#include <metal_stdlib>
#include <CoreImage/CoreImage.h>

using namespace metal;

float ratio(float input1, float input2) {
    if (input2 == 0.0)  return 0.0;
    else return input1/input2;
}

extern "C" float4 GainMapFilter(coreimage::sample_t hdr, coreimage::sample_t sdr, coreimage::destination dest)
{
    float rgb_ratio;
    float gamma_ratio;
    rgb_ratio = ratio(hdr.r+hdr.g+hdr.b,sdr.r+sdr.g+sdr.b);
    gamma_ratio = log2(rgb_ratio)/log2(2.2)/4;
    return float4(gamma_ratio, gamma_ratio, gamma_ratio, 1.0);
}




