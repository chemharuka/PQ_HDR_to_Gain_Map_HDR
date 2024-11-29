//
//  evAdjuestFilter.metal
//  toGainMapHDR
//
//  Created by Luyao Peng on 11/28/24.
//

#include <metal_stdlib>
#include <CoreImage/CoreImage.h>

using namespace metal;

extern "C" float4 gmAdjustFilter(coreimage::sample_t input, float headroom, coreimage::destination dest)
{
    float ratio;
    float linear_value;
    float gamma;
    float head_ratio;
    ratio = input.r*4.0;
    if (headroom >= 15.0) {
        head_ratio = -0.328073;
    } else {
        if (headroom <= 3.0) {
            head_ratio = 0.380279*(headroom-2.0);
        } else {
            head_ratio = 0.40-0.80*pow(log2(headroom)/4.0,4.0);
        };
    }
//Empirical
    ratio = ratio + exp(-ratio)*head_ratio;
    linear_value = pow(2.0, ratio);
    gamma = log2(linear_value)/log2(headroom);
    return float4(gamma, gamma, gamma, 1.0);
}


