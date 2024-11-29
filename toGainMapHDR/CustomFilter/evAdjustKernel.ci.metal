//
//  evAdjuestFilter.metal
//  toGainMapHDR
//
//  Created by Luyao Peng on 11/28/24.
//

#include <metal_stdlib>
#include <CoreImage/CoreImage.h>

using namespace metal;

extern "C" float4 evAdjustFilter(coreimage::sample_t input, float headroom, coreimage::destination dest)
{
    float adj;
    float linear_value;
    float gamma;
    adj = input.r*4.0 + exp(-input.r*4.0)/log2(headroom);
    linear_value = pow(2.0,adj);
    gamma = log2(linear_value)/log2(headroom);
    return float4(gamma, gamma, gamma, 1.0);
}


