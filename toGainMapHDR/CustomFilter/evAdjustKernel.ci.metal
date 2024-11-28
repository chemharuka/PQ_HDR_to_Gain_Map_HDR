//
//  evAdjuestFilter.metal
//  toGainMapHDR
//
//  Created by Luyao Peng on 11/28/24.
//

#include <metal_stdlib>
#include <CoreImage/CoreImage.h>

using namespace metal;

extern "C" float4 evAdjustFilter(coreimage::sample_t input, float ev_value, coreimage::destination dest)
{
    float pixel;
    float gamma;
    pixel = input.r*ev_value;
    gamma = pixel;
    return float4(gamma, gamma, gamma, 1.0);
}


