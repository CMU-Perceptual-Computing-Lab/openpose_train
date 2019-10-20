def getResNet50Init():
    string = '\
layer {\n\
    bottom: "image"\n\
    top: "conv1"\n\
    name: "conv1"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 64\n\
        kernel_size: 7\n\
        pad: 3\n\
        stride: 2\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "conv1"\n\
    top: "conv1"\n\
    name: "bn_conv1"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "conv1"\n\
    top: "conv1"\n\
    name: "scale_conv1"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "conv1"\n\
    top: "conv1"\n\
    name: "conv1_relu"\n\
    type: "ReLU"\n\
}\n\
\n\
layer {\n\
    bottom: "conv1"\n\
    top: "pool1"\n\
    name: "pool1"\n\
    type: "Pooling"\n\
    pooling_param {\n\
        kernel_size: 3\n\
        stride: 2\n\
        pool: MAX\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "pool1"\n\
    top: "res2a_branch1"\n\
    name: "res2a_branch1"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 256\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2a_branch1"\n\
    top: "res2a_branch1"\n\
    name: "bn2a_branch1"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2a_branch1"\n\
    top: "res2a_branch1"\n\
    name: "scale2a_branch1"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "pool1"\n\
    top: "res2a_branch2a"\n\
    name: "res2a_branch2a"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 64\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2a_branch2a"\n\
    top: "res2a_branch2a"\n\
    name: "bn2a_branch2a"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2a_branch2a"\n\
    top: "res2a_branch2a"\n\
    name: "scale2a_branch2a"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2a_branch2a"\n\
    top: "res2a_branch2a"\n\
    name: "res2a_branch2a_relu"\n\
    type: "ReLU"\n\
}\n\
\n\
layer {\n\
    bottom: "res2a_branch2a"\n\
    top: "res2a_branch2b"\n\
    name: "res2a_branch2b"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 64\n\
        kernel_size: 3\n\
        pad: 1\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2a_branch2b"\n\
    top: "res2a_branch2b"\n\
    name: "bn2a_branch2b"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2a_branch2b"\n\
    top: "res2a_branch2b"\n\
    name: "scale2a_branch2b"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2a_branch2b"\n\
    top: "res2a_branch2b"\n\
    name: "res2a_branch2b_relu"\n\
    type: "ReLU"\n\
}\n\
\n\
layer {\n\
    bottom: "res2a_branch2b"\n\
    top: "res2a_branch2c"\n\
    name: "res2a_branch2c"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 256\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2a_branch2c"\n\
    top: "res2a_branch2c"\n\
    name: "bn2a_branch2c"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2a_branch2c"\n\
    top: "res2a_branch2c"\n\
    name: "scale2a_branch2c"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2a_branch1"\n\
    bottom: "res2a_branch2c"\n\
    top: "res2a"\n\
    name: "res2a"\n\
    type: "Eltwise"\n\
}\n\
\n\
layer {\n\
    bottom: "res2a"\n\
    top: "res2a"\n\
    name: "res2a_relu"\n\
    type: "ReLU"\n\
}\n\
\n\
layer {\n\
    bottom: "res2a"\n\
    top: "res2b_branch2a"\n\
    name: "res2b_branch2a"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 64\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2b_branch2a"\n\
    top: "res2b_branch2a"\n\
    name: "bn2b_branch2a"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2b_branch2a"\n\
    top: "res2b_branch2a"\n\
    name: "scale2b_branch2a"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2b_branch2a"\n\
    top: "res2b_branch2a"\n\
    name: "res2b_branch2a_relu"\n\
    type: "ReLU"\n\
}\n\
\n\
layer {\n\
    bottom: "res2b_branch2a"\n\
    top: "res2b_branch2b"\n\
    name: "res2b_branch2b"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 64\n\
        kernel_size: 3\n\
        pad: 1\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2b_branch2b"\n\
    top: "res2b_branch2b"\n\
    name: "bn2b_branch2b"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2b_branch2b"\n\
    top: "res2b_branch2b"\n\
    name: "scale2b_branch2b"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2b_branch2b"\n\
    top: "res2b_branch2b"\n\
    name: "res2b_branch2b_relu"\n\
    type: "ReLU"\n\
}\n\
\n\
layer {\n\
    bottom: "res2b_branch2b"\n\
    top: "res2b_branch2c"\n\
    name: "res2b_branch2c"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 256\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2b_branch2c"\n\
    top: "res2b_branch2c"\n\
    name: "bn2b_branch2c"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2b_branch2c"\n\
    top: "res2b_branch2c"\n\
    name: "scale2b_branch2c"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2a"\n\
    bottom: "res2b_branch2c"\n\
    top: "res2b"\n\
    name: "res2b"\n\
    type: "Eltwise"\n\
}\n\
\n\
layer {\n\
    bottom: "res2b"\n\
    top: "res2b"\n\
    name: "res2b_relu"\n\
    type: "ReLU"\n\
}\n\
\n\
layer {\n\
    bottom: "res2b"\n\
    top: "res2c_branch2a"\n\
    name: "res2c_branch2a"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 64\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2c_branch2a"\n\
    top: "res2c_branch2a"\n\
    name: "bn2c_branch2a"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2c_branch2a"\n\
    top: "res2c_branch2a"\n\
    name: "scale2c_branch2a"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2c_branch2a"\n\
    top: "res2c_branch2a"\n\
    name: "res2c_branch2a_relu"\n\
    type: "ReLU"\n\
}\n\
\n\
layer {\n\
    bottom: "res2c_branch2a"\n\
    top: "res2c_branch2b"\n\
    name: "res2c_branch2b"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 64\n\
        kernel_size: 3\n\
        pad: 1\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2c_branch2b"\n\
    top: "res2c_branch2b"\n\
    name: "bn2c_branch2b"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2c_branch2b"\n\
    top: "res2c_branch2b"\n\
    name: "scale2c_branch2b"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2c_branch2b"\n\
    top: "res2c_branch2b"\n\
    name: "res2c_branch2b_relu"\n\
    type: "ReLU"\n\
}\n\
\n\
layer {\n\
    bottom: "res2c_branch2b"\n\
    top: "res2c_branch2c"\n\
    name: "res2c_branch2c"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 256\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2c_branch2c"\n\
    top: "res2c_branch2c"\n\
    name: "bn2c_branch2c"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2c_branch2c"\n\
    top: "res2c_branch2c"\n\
    name: "scale2c_branch2c"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2b"\n\
    bottom: "res2c_branch2c"\n\
    top: "res2c"\n\
    name: "res2c"\n\
    type: "Eltwise"\n\
}\n\
\n\
layer {\n\
    bottom: "res2c"\n\
    top: "res2c"\n\
    name: "res2c_relu"\n\
    type: "ReLU"\n\
}\n\
\n\
layer {\n\
    bottom: "res2c"\n\
    top: "res3a_branch1"\n\
    name: "res3a_branch1"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 512\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 2\n\
        bias_term: false\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3a_branch1"\n\
    top: "res3a_branch1"\n\
    name: "bn3a_branch1"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3a_branch1"\n\
    top: "res3a_branch1"\n\
    name: "scale3a_branch1"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res2c"\n\
    top: "res3a_branch2a"\n\
    name: "res3a_branch2a"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 128\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 2\n\
        bias_term: false\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3a_branch2a"\n\
    top: "res3a_branch2a"\n\
    name: "bn3a_branch2a"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3a_branch2a"\n\
    top: "res3a_branch2a"\n\
    name: "scale3a_branch2a"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3a_branch2a"\n\
    top: "res3a_branch2a"\n\
    name: "res3a_branch2a_relu"\n\
    type: "ReLU"\n\
}\n\
\n\
layer {\n\
    bottom: "res3a_branch2a"\n\
    top: "res3a_branch2b"\n\
    name: "res3a_branch2b"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 128\n\
        kernel_size: 3\n\
        pad: 1\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3a_branch2b"\n\
    top: "res3a_branch2b"\n\
    name: "bn3a_branch2b"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3a_branch2b"\n\
    top: "res3a_branch2b"\n\
    name: "scale3a_branch2b"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3a_branch2b"\n\
    top: "res3a_branch2b"\n\
    name: "res3a_branch2b_relu"\n\
    type: "ReLU"\n\
}\n\
\n\
layer {\n\
    bottom: "res3a_branch2b"\n\
    top: "res3a_branch2c"\n\
    name: "res3a_branch2c"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 512\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3a_branch2c"\n\
    top: "res3a_branch2c"\n\
    name: "bn3a_branch2c"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3a_branch2c"\n\
    top: "res3a_branch2c"\n\
    name: "scale3a_branch2c"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3a_branch1"\n\
    bottom: "res3a_branch2c"\n\
    top: "res3a"\n\
    name: "res3a"\n\
    type: "Eltwise"\n\
}\n\
\n\
layer {\n\
    bottom: "res3a"\n\
    top: "res3a"\n\
    name: "res3a_relu"\n\
    type: "ReLU"\n\
}\n\
\n\
layer {\n\
    bottom: "res3a"\n\
    top: "res3b_branch2a"\n\
    name: "res3b_branch2a"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 128\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3b_branch2a"\n\
    top: "res3b_branch2a"\n\
    name: "bn3b_branch2a"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3b_branch2a"\n\
    top: "res3b_branch2a"\n\
    name: "scale3b_branch2a"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3b_branch2a"\n\
    top: "res3b_branch2a"\n\
    name: "res3b_branch2a_relu"\n\
    type: "ReLU"\n\
}\n\
\n\
layer {\n\
    bottom: "res3b_branch2a"\n\
    top: "res3b_branch2b"\n\
    name: "res3b_branch2b"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 128\n\
        kernel_size: 3\n\
        pad: 1\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3b_branch2b"\n\
    top: "res3b_branch2b"\n\
    name: "bn3b_branch2b"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3b_branch2b"\n\
    top: "res3b_branch2b"\n\
    name: "scale3b_branch2b"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3b_branch2b"\n\
    top: "res3b_branch2b"\n\
    name: "res3b_branch2b_relu"\n\
    type: "ReLU"\n\
}\n\
\n\
layer {\n\
    bottom: "res3b_branch2b"\n\
    top: "res3b_branch2c"\n\
    name: "res3b_branch2c"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 512\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3b_branch2c"\n\
    top: "res3b_branch2c"\n\
    name: "bn3b_branch2c"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3b_branch2c"\n\
    top: "res3b_branch2c"\n\
    name: "scale3b_branch2c"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3a"\n\
    bottom: "res3b_branch2c"\n\
    top: "res3b"\n\
    name: "res3b"\n\
    type: "Eltwise"\n\
}\n\
\n\
layer {\n\
    bottom: "res3b"\n\
    top: "res3b"\n\
    name: "res3b_relu"\n\
    type: "ReLU"\n\
}\n\
\n\
layer {\n\
    bottom: "res3b"\n\
    top: "res3c_branch2a"\n\
    name: "res3c_branch2a"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 128\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3c_branch2a"\n\
    top: "res3c_branch2a"\n\
    name: "bn3c_branch2a"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3c_branch2a"\n\
    top: "res3c_branch2a"\n\
    name: "scale3c_branch2a"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3c_branch2a"\n\
    top: "res3c_branch2a"\n\
    name: "res3c_branch2a_relu"\n\
    type: "ReLU"\n\
}\n\
\n\
layer {\n\
    bottom: "res3c_branch2a"\n\
    top: "res3c_branch2b"\n\
    name: "res3c_branch2b"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 128\n\
        kernel_size: 3\n\
        pad: 1\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3c_branch2b"\n\
    top: "res3c_branch2b"\n\
    name: "bn3c_branch2b"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3c_branch2b"\n\
    top: "res3c_branch2b"\n\
    name: "scale3c_branch2b"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3c_branch2b"\n\
    top: "res3c_branch2b"\n\
    name: "res3c_branch2b_relu"\n\
    type: "ReLU"\n\
}\n\
\n\
layer {\n\
    bottom: "res3c_branch2b"\n\
    top: "res3c_branch2c"\n\
    name: "res3c_branch2c"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 512\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3c_branch2c"\n\
    top: "res3c_branch2c"\n\
    name: "bn3c_branch2c"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3c_branch2c"\n\
    top: "res3c_branch2c"\n\
    name: "scale3c_branch2c"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3b"\n\
    bottom: "res3c_branch2c"\n\
    top: "res3c"\n\
    name: "res3c"\n\
    type: "Eltwise"\n\
}\n\
\n\
layer {\n\
    bottom: "res3c"\n\
    top: "res3c"\n\
    name: "res3c_relu"\n\
    type: "ReLU"\n\
}\n\
\n\
layer {\n\
    bottom: "res3c"\n\
    top: "res3d_branch2a"\n\
    name: "res3d_branch2a"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 128\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3d_branch2a"\n\
    top: "res3d_branch2a"\n\
    name: "bn3d_branch2a"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3d_branch2a"\n\
    top: "res3d_branch2a"\n\
    name: "scale3d_branch2a"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3d_branch2a"\n\
    top: "res3d_branch2a"\n\
    name: "res3d_branch2a_relu"\n\
    type: "ReLU"\n\
}\n\
\n\
layer {\n\
    bottom: "res3d_branch2a"\n\
    top: "res3d_branch2b"\n\
    name: "res3d_branch2b"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 128\n\
        kernel_size: 3\n\
        pad: 1\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3d_branch2b"\n\
    top: "res3d_branch2b"\n\
    name: "bn3d_branch2b"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3d_branch2b"\n\
    top: "res3d_branch2b"\n\
    name: "scale3d_branch2b"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3d_branch2b"\n\
    top: "res3d_branch2b"\n\
    name: "res3d_branch2b_relu"\n\
    type: "ReLU"\n\
}\n\
\n\
layer {\n\
    bottom: "res3d_branch2b"\n\
    top: "res3d_branch2c"\n\
    name: "res3d_branch2c"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 512\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3d_branch2c"\n\
    top: "res3d_branch2c"\n\
    name: "bn3d_branch2c"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3d_branch2c"\n\
    top: "res3d_branch2c"\n\
    name: "scale3d_branch2c"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
\n\
layer {\n\
    bottom: "res3c"\n\
    bottom: "res3d_branch2c"\n\
    top: "res3d"\n\
    name: "res3d"\n\
    type: "Eltwise"\n\
}\n\
\n\
layer {\n\
    bottom: "res3d"\n\
    top: "res3d"\n\
    name: "res3d_relu"\n\
    type: "ReLU"\n\
}\n'
    return string


































def getResNet152Init():
    string = '\
layer {\n\
    bottom: "image"\n\
    top: "conv1"\n\
    name: "conv1"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 64\n\
        kernel_size: 7\n\
        pad: 3\n\
        stride: 2\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "conv1"\n\
    top: "conv1"\n\
    name: "bn_conv1"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "conv1"\n\
    top: "conv1"\n\
    name: "scale_conv1"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    top: "conv1"\n\
    bottom: "conv1"\n\
    name: "conv1_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "conv1"\n\
    top: "pool1"\n\
    name: "pool1"\n\
    type: "Pooling"\n\
    pooling_param {\n\
        kernel_size: 3\n\
        stride: 2\n\
        pool: MAX\n\
    }\n\
}\n\
layer {\n\
    bottom: "pool1"\n\
    top: "res2a_branch1"\n\
    name: "res2a_branch1"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 256\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res2a_branch1"\n\
    top: "res2a_branch1"\n\
    name: "bn2a_branch1"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res2a_branch1"\n\
    top: "res2a_branch1"\n\
    name: "scale2a_branch1"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "pool1"\n\
    top: "res2a_branch2a"\n\
    name: "res2a_branch2a"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 64\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res2a_branch2a"\n\
    top: "res2a_branch2a"\n\
    name: "bn2a_branch2a"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res2a_branch2a"\n\
    top: "res2a_branch2a"\n\
    name: "scale2a_branch2a"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    top: "res2a_branch2a"\n\
    bottom: "res2a_branch2a"\n\
    name: "res2a_branch2a_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res2a_branch2a"\n\
    top: "res2a_branch2b"\n\
    name: "res2a_branch2b"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 64\n\
        kernel_size: 3\n\
        pad: 1\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res2a_branch2b"\n\
    top: "res2a_branch2b"\n\
    name: "bn2a_branch2b"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res2a_branch2b"\n\
    top: "res2a_branch2b"\n\
    name: "scale2a_branch2b"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    top: "res2a_branch2b"\n\
    bottom: "res2a_branch2b"\n\
    name: "res2a_branch2b_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res2a_branch2b"\n\
    top: "res2a_branch2c"\n\
    name: "res2a_branch2c"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 256\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res2a_branch2c"\n\
    top: "res2a_branch2c"\n\
    name: "bn2a_branch2c"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res2a_branch2c"\n\
    top: "res2a_branch2c"\n\
    name: "scale2a_branch2c"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res2a_branch1"\n\
    bottom: "res2a_branch2c"\n\
    top: "res2a"\n\
    name: "res2a"\n\
    type: "Eltwise"\n\
}\n\
layer {\n\
    bottom: "res2a"\n\
    top: "res2a"\n\
    name: "res2a_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res2a"\n\
    top: "res2b_branch2a"\n\
    name: "res2b_branch2a"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 64\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res2b_branch2a"\n\
    top: "res2b_branch2a"\n\
    name: "bn2b_branch2a"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res2b_branch2a"\n\
    top: "res2b_branch2a"\n\
    name: "scale2b_branch2a"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    top: "res2b_branch2a"\n\
    bottom: "res2b_branch2a"\n\
    name: "res2b_branch2a_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res2b_branch2a"\n\
    top: "res2b_branch2b"\n\
    name: "res2b_branch2b"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 64\n\
        kernel_size: 3\n\
        pad: 1\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res2b_branch2b"\n\
    top: "res2b_branch2b"\n\
    name: "bn2b_branch2b"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res2b_branch2b"\n\
    top: "res2b_branch2b"\n\
    name: "scale2b_branch2b"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    top: "res2b_branch2b"\n\
    bottom: "res2b_branch2b"\n\
    name: "res2b_branch2b_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res2b_branch2b"\n\
    top: "res2b_branch2c"\n\
    name: "res2b_branch2c"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 256\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res2b_branch2c"\n\
    top: "res2b_branch2c"\n\
    name: "bn2b_branch2c"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res2b_branch2c"\n\
    top: "res2b_branch2c"\n\
    name: "scale2b_branch2c"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res2a"\n\
    bottom: "res2b_branch2c"\n\
    top: "res2b"\n\
    name: "res2b"\n\
    type: "Eltwise"\n\
}\n\
layer {\n\
    bottom: "res2b"\n\
    top: "res2b"\n\
    name: "res2b_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res2b"\n\
    top: "res2c_branch2a"\n\
    name: "res2c_branch2a"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 64\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res2c_branch2a"\n\
    top: "res2c_branch2a"\n\
    name: "bn2c_branch2a"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res2c_branch2a"\n\
    top: "res2c_branch2a"\n\
    name: "scale2c_branch2a"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    top: "res2c_branch2a"\n\
    bottom: "res2c_branch2a"\n\
    name: "res2c_branch2a_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res2c_branch2a"\n\
    top: "res2c_branch2b"\n\
    name: "res2c_branch2b"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 64\n\
        kernel_size: 3\n\
        pad: 1\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res2c_branch2b"\n\
    top: "res2c_branch2b"\n\
    name: "bn2c_branch2b"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res2c_branch2b"\n\
    top: "res2c_branch2b"\n\
    name: "scale2c_branch2b"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    top: "res2c_branch2b"\n\
    bottom: "res2c_branch2b"\n\
    name: "res2c_branch2b_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res2c_branch2b"\n\
    top: "res2c_branch2c"\n\
    name: "res2c_branch2c"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 256\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res2c_branch2c"\n\
    top: "res2c_branch2c"\n\
    name: "bn2c_branch2c"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res2c_branch2c"\n\
    top: "res2c_branch2c"\n\
    name: "scale2c_branch2c"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res2b"\n\
    bottom: "res2c_branch2c"\n\
    top: "res2c"\n\
    name: "res2c"\n\
    type: "Eltwise"\n\
}\n\
layer {\n\
    bottom: "res2c"\n\
    top: "res2c"\n\
    name: "res2c_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res2c"\n\
    top: "res3a_branch1"\n\
    name: "res3a_branch1"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 512\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 2\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3a_branch1"\n\
    top: "res3a_branch1"\n\
    name: "bn3a_branch1"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3a_branch1"\n\
    top: "res3a_branch1"\n\
    name: "scale3a_branch1"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res2c"\n\
    top: "res3a_branch2a"\n\
    name: "res3a_branch2a"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 128\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 2\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3a_branch2a"\n\
    top: "res3a_branch2a"\n\
    name: "bn3a_branch2a"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3a_branch2a"\n\
    top: "res3a_branch2a"\n\
    name: "scale3a_branch2a"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    top: "res3a_branch2a"\n\
    bottom: "res3a_branch2a"\n\
    name: "res3a_branch2a_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res3a_branch2a"\n\
    top: "res3a_branch2b"\n\
    name: "res3a_branch2b"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 128\n\
        kernel_size: 3\n\
        pad: 1\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3a_branch2b"\n\
    top: "res3a_branch2b"\n\
    name: "bn3a_branch2b"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3a_branch2b"\n\
    top: "res3a_branch2b"\n\
    name: "scale3a_branch2b"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    top: "res3a_branch2b"\n\
    bottom: "res3a_branch2b"\n\
    name: "res3a_branch2b_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res3a_branch2b"\n\
    top: "res3a_branch2c"\n\
    name: "res3a_branch2c"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 512\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3a_branch2c"\n\
    top: "res3a_branch2c"\n\
    name: "bn3a_branch2c"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3a_branch2c"\n\
    top: "res3a_branch2c"\n\
    name: "scale3a_branch2c"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3a_branch1"\n\
    bottom: "res3a_branch2c"\n\
    top: "res3a"\n\
    name: "res3a"\n\
    type: "Eltwise"\n\
}\n\
layer {\n\
    bottom: "res3a"\n\
    top: "res3a"\n\
    name: "res3a_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res3a"\n\
    top: "res3b1_branch2a"\n\
    name: "res3b1_branch2a"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 128\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b1_branch2a"\n\
    top: "res3b1_branch2a"\n\
    name: "bn3b1_branch2a"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b1_branch2a"\n\
    top: "res3b1_branch2a"\n\
    name: "scale3b1_branch2a"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    top: "res3b1_branch2a"\n\
    bottom: "res3b1_branch2a"\n\
    name: "res3b1_branch2a_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res3b1_branch2a"\n\
    top: "res3b1_branch2b"\n\
    name: "res3b1_branch2b"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 128\n\
        kernel_size: 3\n\
        pad: 1\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b1_branch2b"\n\
    top: "res3b1_branch2b"\n\
    name: "bn3b1_branch2b"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b1_branch2b"\n\
    top: "res3b1_branch2b"\n\
    name: "scale3b1_branch2b"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    top: "res3b1_branch2b"\n\
    bottom: "res3b1_branch2b"\n\
    name: "res3b1_branch2b_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res3b1_branch2b"\n\
    top: "res3b1_branch2c"\n\
    name: "res3b1_branch2c"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 512\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b1_branch2c"\n\
    top: "res3b1_branch2c"\n\
    name: "bn3b1_branch2c"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b1_branch2c"\n\
    top: "res3b1_branch2c"\n\
    name: "scale3b1_branch2c"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3a"\n\
    bottom: "res3b1_branch2c"\n\
    top: "res3b1"\n\
    name: "res3b1"\n\
    type: "Eltwise"\n\
}\n\
layer {\n\
    bottom: "res3b1"\n\
    top: "res3b1"\n\
    name: "res3b1_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res3b1"\n\
    top: "res3b2_branch2a"\n\
    name: "res3b2_branch2a"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 128\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b2_branch2a"\n\
    top: "res3b2_branch2a"\n\
    name: "bn3b2_branch2a"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b2_branch2a"\n\
    top: "res3b2_branch2a"\n\
    name: "scale3b2_branch2a"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    top: "res3b2_branch2a"\n\
    bottom: "res3b2_branch2a"\n\
    name: "res3b2_branch2a_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res3b2_branch2a"\n\
    top: "res3b2_branch2b"\n\
    name: "res3b2_branch2b"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 128\n\
        kernel_size: 3\n\
        pad: 1\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b2_branch2b"\n\
    top: "res3b2_branch2b"\n\
    name: "bn3b2_branch2b"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b2_branch2b"\n\
    top: "res3b2_branch2b"\n\
    name: "scale3b2_branch2b"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    top: "res3b2_branch2b"\n\
    bottom: "res3b2_branch2b"\n\
    name: "res3b2_branch2b_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res3b2_branch2b"\n\
    top: "res3b2_branch2c"\n\
    name: "res3b2_branch2c"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 512\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b2_branch2c"\n\
    top: "res3b2_branch2c"\n\
    name: "bn3b2_branch2c"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b2_branch2c"\n\
    top: "res3b2_branch2c"\n\
    name: "scale3b2_branch2c"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b1"\n\
    bottom: "res3b2_branch2c"\n\
    top: "res3b2"\n\
    name: "res3b2"\n\
    type: "Eltwise"\n\
}\n\
layer {\n\
    bottom: "res3b2"\n\
    top: "res3b2"\n\
    name: "res3b2_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res3b2"\n\
    top: "res3b3_branch2a"\n\
    name: "res3b3_branch2a"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 128\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b3_branch2a"\n\
    top: "res3b3_branch2a"\n\
    name: "bn3b3_branch2a"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b3_branch2a"\n\
    top: "res3b3_branch2a"\n\
    name: "scale3b3_branch2a"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    top: "res3b3_branch2a"\n\
    bottom: "res3b3_branch2a"\n\
    name: "res3b3_branch2a_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res3b3_branch2a"\n\
    top: "res3b3_branch2b"\n\
    name: "res3b3_branch2b"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 128\n\
        kernel_size: 3\n\
        pad: 1\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b3_branch2b"\n\
    top: "res3b3_branch2b"\n\
    name: "bn3b3_branch2b"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b3_branch2b"\n\
    top: "res3b3_branch2b"\n\
    name: "scale3b3_branch2b"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    top: "res3b3_branch2b"\n\
    bottom: "res3b3_branch2b"\n\
    name: "res3b3_branch2b_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res3b3_branch2b"\n\
    top: "res3b3_branch2c"\n\
    name: "res3b3_branch2c"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 512\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b3_branch2c"\n\
    top: "res3b3_branch2c"\n\
    name: "bn3b3_branch2c"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b3_branch2c"\n\
    top: "res3b3_branch2c"\n\
    name: "scale3b3_branch2c"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b2"\n\
    bottom: "res3b3_branch2c"\n\
    top: "res3b3"\n\
    name: "res3b3"\n\
    type: "Eltwise"\n\
}\n\
layer {\n\
    bottom: "res3b3"\n\
    top: "res3b3"\n\
    name: "res3b3_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res3b3"\n\
    top: "res3b4_branch2a"\n\
    name: "res3b4_branch2a"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 128\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b4_branch2a"\n\
    top: "res3b4_branch2a"\n\
    name: "bn3b4_branch2a"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b4_branch2a"\n\
    top: "res3b4_branch2a"\n\
    name: "scale3b4_branch2a"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    top: "res3b4_branch2a"\n\
    bottom: "res3b4_branch2a"\n\
    name: "res3b4_branch2a_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res3b4_branch2a"\n\
    top: "res3b4_branch2b"\n\
    name: "res3b4_branch2b"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 128\n\
        kernel_size: 3\n\
        pad: 1\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b4_branch2b"\n\
    top: "res3b4_branch2b"\n\
    name: "bn3b4_branch2b"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b4_branch2b"\n\
    top: "res3b4_branch2b"\n\
    name: "scale3b4_branch2b"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    top: "res3b4_branch2b"\n\
    bottom: "res3b4_branch2b"\n\
    name: "res3b4_branch2b_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res3b4_branch2b"\n\
    top: "res3b4_branch2c"\n\
    name: "res3b4_branch2c"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 512\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b4_branch2c"\n\
    top: "res3b4_branch2c"\n\
    name: "bn3b4_branch2c"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b4_branch2c"\n\
    top: "res3b4_branch2c"\n\
    name: "scale3b4_branch2c"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b3"\n\
    bottom: "res3b4_branch2c"\n\
    top: "res3b4"\n\
    name: "res3b4"\n\
    type: "Eltwise"\n\
}\n\
layer {\n\
    bottom: "res3b4"\n\
    top: "res3b4"\n\
    name: "res3b4_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res3b4"\n\
    top: "res3b5_branch2a"\n\
    name: "res3b5_branch2a"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 128\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b5_branch2a"\n\
    top: "res3b5_branch2a"\n\
    name: "bn3b5_branch2a"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b5_branch2a"\n\
    top: "res3b5_branch2a"\n\
    name: "scale3b5_branch2a"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    top: "res3b5_branch2a"\n\
    bottom: "res3b5_branch2a"\n\
    name: "res3b5_branch2a_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res3b5_branch2a"\n\
    top: "res3b5_branch2b"\n\
    name: "res3b5_branch2b"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 128\n\
        kernel_size: 3\n\
        pad: 1\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b5_branch2b"\n\
    top: "res3b5_branch2b"\n\
    name: "bn3b5_branch2b"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b5_branch2b"\n\
    top: "res3b5_branch2b"\n\
    name: "scale3b5_branch2b"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    top: "res3b5_branch2b"\n\
    bottom: "res3b5_branch2b"\n\
    name: "res3b5_branch2b_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res3b5_branch2b"\n\
    top: "res3b5_branch2c"\n\
    name: "res3b5_branch2c"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 512\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b5_branch2c"\n\
    top: "res3b5_branch2c"\n\
    name: "bn3b5_branch2c"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b5_branch2c"\n\
    top: "res3b5_branch2c"\n\
    name: "scale3b5_branch2c"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b4"\n\
    bottom: "res3b5_branch2c"\n\
    top: "res3b5"\n\
    name: "res3b5"\n\
    type: "Eltwise"\n\
}\n\
layer {\n\
    bottom: "res3b5"\n\
    top: "res3b5"\n\
    name: "res3b5_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res3b5"\n\
    top: "res3b6_branch2a"\n\
    name: "res3b6_branch2a"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 128\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b6_branch2a"\n\
    top: "res3b6_branch2a"\n\
    name: "bn3b6_branch2a"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b6_branch2a"\n\
    top: "res3b6_branch2a"\n\
    name: "scale3b6_branch2a"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    top: "res3b6_branch2a"\n\
    bottom: "res3b6_branch2a"\n\
    name: "res3b6_branch2a_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res3b6_branch2a"\n\
    top: "res3b6_branch2b"\n\
    name: "res3b6_branch2b"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 128\n\
        kernel_size: 3\n\
        pad: 1\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b6_branch2b"\n\
    top: "res3b6_branch2b"\n\
    name: "bn3b6_branch2b"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b6_branch2b"\n\
    top: "res3b6_branch2b"\n\
    name: "scale3b6_branch2b"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    top: "res3b6_branch2b"\n\
    bottom: "res3b6_branch2b"\n\
    name: "res3b6_branch2b_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res3b6_branch2b"\n\
    top: "res3b6_branch2c"\n\
    name: "res3b6_branch2c"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 512\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b6_branch2c"\n\
    top: "res3b6_branch2c"\n\
    name: "bn3b6_branch2c"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b6_branch2c"\n\
    top: "res3b6_branch2c"\n\
    name: "scale3b6_branch2c"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b5"\n\
    bottom: "res3b6_branch2c"\n\
    top: "res3b6"\n\
    name: "res3b6"\n\
    type: "Eltwise"\n\
}\n\
layer {\n\
    bottom: "res3b6"\n\
    top: "res3b6"\n\
    name: "res3b6_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res3b6"\n\
    top: "res3b7_branch2a"\n\
    name: "res3b7_branch2a"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 128\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b7_branch2a"\n\
    top: "res3b7_branch2a"\n\
    name: "bn3b7_branch2a"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b7_branch2a"\n\
    top: "res3b7_branch2a"\n\
    name: "scale3b7_branch2a"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    top: "res3b7_branch2a"\n\
    bottom: "res3b7_branch2a"\n\
    name: "res3b7_branch2a_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res3b7_branch2a"\n\
    top: "res3b7_branch2b"\n\
    name: "res3b7_branch2b"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 128\n\
        kernel_size: 3\n\
        pad: 1\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b7_branch2b"\n\
    top: "res3b7_branch2b"\n\
    name: "bn3b7_branch2b"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b7_branch2b"\n\
    top: "res3b7_branch2b"\n\
    name: "scale3b7_branch2b"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    top: "res3b7_branch2b"\n\
    bottom: "res3b7_branch2b"\n\
    name: "res3b7_branch2b_relu"\n\
    type: "ReLU"\n\
}\n\
layer {\n\
    bottom: "res3b7_branch2b"\n\
    top: "res3b7_branch2c"\n\
    name: "res3b7_branch2c"\n\
    type: "Convolution"\n\
    convolution_param {\n\
        num_output: 512\n\
        kernel_size: 1\n\
        pad: 0\n\
        stride: 1\n\
        bias_term: false\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b7_branch2c"\n\
    top: "res3b7_branch2c"\n\
    name: "bn3b7_branch2c"\n\
    type: "BatchNorm"\n\
    batch_norm_param {\n\
        use_global_stats: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b7_branch2c"\n\
    top: "res3b7_branch2c"\n\
    name: "scale3b7_branch2c"\n\
    type: "Scale"\n\
    scale_param {\n\
        bias_term: true\n\
    }\n\
}\n\
layer {\n\
    bottom: "res3b6"\n\
    bottom: "res3b7_branch2c"\n\
    top: "res3b7"\n\
    name: "res3b7"\n\
    type: "Eltwise"\n\
}\n\
layer {\n\
    bottom: "res3b7"\n\
    top: "res3b7"\n\
    name: "res3b7_relu"\n\
    type: "ReLU"\n\
}\n'
    return string



































def getResNet101v2Init():
    string = '\
layer {\n\
  name: "conv1"\n\
  type: "Convolution"\n\
  bottom: "image"\n\
  top: "conv1"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 64\n\
    pad: 3\n\
    kernel_size: 7\n\
    stride: 2\n\
  }\n\
}\n\
layer {\n\
  name: "conv1_bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv1"\n\
  top: "conv1"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "conv1_scale"\n\
  type: "Scale"\n\
  bottom: "conv1"\n\
  top: "conv1"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "conv1_relu"\n\
  type: "ReLU"\n\
  bottom: "conv1"\n\
  top: "conv1"\n\
}\n\
layer {\n\
  name: "pool1"\n\
  type: "Pooling"\n\
  bottom: "conv1"\n\
  top: "pool1"\n\
  pooling_param {\n\
    pool: MAX\n\
    kernel_size: 3\n\
    stride: 2\n\
  }\n\
}\n\
layer {\n\
  name: "res1_conv1"\n\
  type: "Convolution"\n\
  bottom: "pool1"\n\
  top: "res1_conv1"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 64\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res1_conv1_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res1_conv1"\n\
  top: "res1_conv1"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res1_conv1_scale"\n\
  type: "Scale"\n\
  bottom: "res1_conv1"\n\
  top: "res1_conv1"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res1_conv1_relu"\n\
  type: "ReLU"\n\
  bottom: "res1_conv1"\n\
  top: "res1_conv1"\n\
}\n\
layer {\n\
  name: "res1_conv2"\n\
  type: "Convolution"\n\
  bottom: "res1_conv1"\n\
  top: "res1_conv2"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 64\n\
    pad: 1\n\
    kernel_size: 3\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res1_conv2_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res1_conv2"\n\
  top: "res1_conv2"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res1_conv2_scale"\n\
  type: "Scale"\n\
  bottom: "res1_conv2"\n\
  top: "res1_conv2"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res1_conv2_relu"\n\
  type: "ReLU"\n\
  bottom: "res1_conv2"\n\
  top: "res1_conv2"\n\
}\n\
layer {\n\
  name: "res1_conv3"\n\
  type: "Convolution"\n\
  bottom: "res1_conv2"\n\
  top: "res1_conv3"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 256\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res1_match_conv"\n\
  type: "Convolution"\n\
  bottom: "pool1"\n\
  top: "res1_match_conv"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 256\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res1_eletwise"\n\
  type: "Eltwise"\n\
  bottom: "res1_match_conv"\n\
  bottom: "res1_conv3"\n\
  top: "res1_eletwise"\n\
  eltwise_param {\n\
    operation: SUM\n\
  }\n\
}\n\
layer {\n\
  name: "res2_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res1_eletwise"\n\
  top: "res2_bn"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res2_scale"\n\
  type: "Scale"\n\
  bottom: "res2_bn"\n\
  top: "res2_bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res2_relu"\n\
  type: "ReLU"\n\
  bottom: "res2_bn"\n\
  top: "res2_bn"\n\
}\n\
layer {\n\
  name: "res2_conv1"\n\
  type: "Convolution"\n\
  bottom: "res2_bn"\n\
  top: "res2_conv1"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 64\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res2_conv1_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res2_conv1"\n\
  top: "res2_conv1"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res2_conv1_scale"\n\
  type: "Scale"\n\
  bottom: "res2_conv1"\n\
  top: "res2_conv1"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res2_conv1_relu"\n\
  type: "ReLU"\n\
  bottom: "res2_conv1"\n\
  top: "res2_conv1"\n\
}\n\
layer {\n\
  name: "res2_conv2"\n\
  type: "Convolution"\n\
  bottom: "res2_conv1"\n\
  top: "res2_conv2"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 64\n\
    pad: 1\n\
    kernel_size: 3\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res2_conv2_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res2_conv2"\n\
  top: "res2_conv2"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res2_conv2_scale"\n\
  type: "Scale"\n\
  bottom: "res2_conv2"\n\
  top: "res2_conv2"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res2_conv2_relu"\n\
  type: "ReLU"\n\
  bottom: "res2_conv2"\n\
  top: "res2_conv2"\n\
}\n\
layer {\n\
  name: "res2_conv3"\n\
  type: "Convolution"\n\
  bottom: "res2_conv2"\n\
  top: "res2_conv3"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 256\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res2_eletwise"\n\
  type: "Eltwise"\n\
  bottom: "res1_eletwise"\n\
  bottom: "res2_conv3"\n\
  top: "res2_eletwise"\n\
  eltwise_param {\n\
    operation: SUM\n\
  }\n\
}\n\
layer {\n\
  name: "res3_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res2_eletwise"\n\
  top: "res3_bn"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res3_scale"\n\
  type: "Scale"\n\
  bottom: "res3_bn"\n\
  top: "res3_bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res3_relu"\n\
  type: "ReLU"\n\
  bottom: "res3_bn"\n\
  top: "res3_bn"\n\
}\n\
layer {\n\
  name: "res3_conv1"\n\
  type: "Convolution"\n\
  bottom: "res3_bn"\n\
  top: "res3_conv1"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 64\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res3_conv1_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res3_conv1"\n\
  top: "res3_conv1"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res3_conv1_scale"\n\
  type: "Scale"\n\
  bottom: "res3_conv1"\n\
  top: "res3_conv1"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res3_conv1_relu"\n\
  type: "ReLU"\n\
  bottom: "res3_conv1"\n\
  top: "res3_conv1"\n\
}\n\
layer {\n\
  name: "res3_conv2"\n\
  type: "Convolution"\n\
  bottom: "res3_conv1"\n\
  top: "res3_conv2"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 64\n\
    pad: 1\n\
    kernel_size: 3\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res3_conv2_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res3_conv2"\n\
  top: "res3_conv2"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res3_conv2_scale"\n\
  type: "Scale"\n\
  bottom: "res3_conv2"\n\
  top: "res3_conv2"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res3_conv2_relu"\n\
  type: "ReLU"\n\
  bottom: "res3_conv2"\n\
  top: "res3_conv2"\n\
}\n\
layer {\n\
  name: "res3_conv3"\n\
  type: "Convolution"\n\
  bottom: "res3_conv2"\n\
  top: "res3_conv3"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 256\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res3_eletwise"\n\
  type: "Eltwise"\n\
  bottom: "res2_eletwise"\n\
  bottom: "res3_conv3"\n\
  top: "res3_eletwise"\n\
  eltwise_param {\n\
    operation: SUM\n\
  }\n\
}\n\
layer {\n\
  name: "res4_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res3_eletwise"\n\
  top: "res4_bn"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res4_scale"\n\
  type: "Scale"\n\
  bottom: "res4_bn"\n\
  top: "res4_bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res4_relu"\n\
  type: "ReLU"\n\
  bottom: "res4_bn"\n\
  top: "res4_bn"\n\
}\n\
layer {\n\
  name: "res4_conv1"\n\
  type: "Convolution"\n\
  bottom: "res4_bn"\n\
  top: "res4_conv1"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 128\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res4_conv1_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res4_conv1"\n\
  top: "res4_conv1"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res4_conv1_scale"\n\
  type: "Scale"\n\
  bottom: "res4_conv1"\n\
  top: "res4_conv1"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res4_conv1_relu"\n\
  type: "ReLU"\n\
  bottom: "res4_conv1"\n\
  top: "res4_conv1"\n\
}\n\
layer {\n\
  name: "res4_conv2"\n\
  type: "Convolution"\n\
  bottom: "res4_conv1"\n\
  top: "res4_conv2"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 128\n\
    pad: 1\n\
    kernel_size: 3\n\
    stride: 2\n\
  }\n\
}\n\
layer {\n\
  name: "res4_conv2_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res4_conv2"\n\
  top: "res4_conv2"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res4_conv2_scale"\n\
  type: "Scale"\n\
  bottom: "res4_conv2"\n\
  top: "res4_conv2"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res4_conv2_relu"\n\
  type: "ReLU"\n\
  bottom: "res4_conv2"\n\
  top: "res4_conv2"\n\
}\n\
layer {\n\
  name: "res4_conv3"\n\
  type: "Convolution"\n\
  bottom: "res4_conv2"\n\
  top: "res4_conv3"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 512\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res4_match_conv"\n\
  type: "Convolution"\n\
  bottom: "res4_bn"\n\
  top: "res4_match_conv"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 512\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 2\n\
  }\n\
}\n\
layer {\n\
  name: "res4_eletwise"\n\
  type: "Eltwise"\n\
  bottom: "res4_match_conv"\n\
  bottom: "res4_conv3"\n\
  top: "res4_eletwise"\n\
  eltwise_param {\n\
    operation: SUM\n\
  }\n\
}\n\
layer {\n\
  name: "res5_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res4_eletwise"\n\
  top: "res5_bn"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res5_scale"\n\
  type: "Scale"\n\
  bottom: "res5_bn"\n\
  top: "res5_bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res5_relu"\n\
  type: "ReLU"\n\
  bottom: "res5_bn"\n\
  top: "res5_bn"\n\
}\n\
layer {\n\
  name: "res5_conv1"\n\
  type: "Convolution"\n\
  bottom: "res5_bn"\n\
  top: "res5_conv1"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 128\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res5_conv1_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res5_conv1"\n\
  top: "res5_conv1"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res5_conv1_scale"\n\
  type: "Scale"\n\
  bottom: "res5_conv1"\n\
  top: "res5_conv1"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res5_conv1_relu"\n\
  type: "ReLU"\n\
  bottom: "res5_conv1"\n\
  top: "res5_conv1"\n\
}\n\
layer {\n\
  name: "res5_conv2"\n\
  type: "Convolution"\n\
  bottom: "res5_conv1"\n\
  top: "res5_conv2"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 128\n\
    pad: 1\n\
    kernel_size: 3\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res5_conv2_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res5_conv2"\n\
  top: "res5_conv2"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res5_conv2_scale"\n\
  type: "Scale"\n\
  bottom: "res5_conv2"\n\
  top: "res5_conv2"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res5_conv2_relu"\n\
  type: "ReLU"\n\
  bottom: "res5_conv2"\n\
  top: "res5_conv2"\n\
}\n\
layer {\n\
  name: "res5_conv3"\n\
  type: "Convolution"\n\
  bottom: "res5_conv2"\n\
  top: "res5_conv3"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 512\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res5_eletwise"\n\
  type: "Eltwise"\n\
  bottom: "res4_eletwise"\n\
  bottom: "res5_conv3"\n\
  top: "res5_eletwise"\n\
  eltwise_param {\n\
    operation: SUM\n\
  }\n\
}\n\
layer {\n\
  name: "res6_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res5_eletwise"\n\
  top: "res6_bn"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res6_scale"\n\
  type: "Scale"\n\
  bottom: "res6_bn"\n\
  top: "res6_bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res6_relu"\n\
  type: "ReLU"\n\
  bottom: "res6_bn"\n\
  top: "res6_bn"\n\
}\n\
layer {\n\
  name: "res6_conv1"\n\
  type: "Convolution"\n\
  bottom: "res6_bn"\n\
  top: "res6_conv1"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 128\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res6_conv1_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res6_conv1"\n\
  top: "res6_conv1"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res6_conv1_scale"\n\
  type: "Scale"\n\
  bottom: "res6_conv1"\n\
  top: "res6_conv1"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res6_conv1_relu"\n\
  type: "ReLU"\n\
  bottom: "res6_conv1"\n\
  top: "res6_conv1"\n\
}\n\
layer {\n\
  name: "res6_conv2"\n\
  type: "Convolution"\n\
  bottom: "res6_conv1"\n\
  top: "res6_conv2"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 128\n\
    pad: 1\n\
    kernel_size: 3\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res6_conv2_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res6_conv2"\n\
  top: "res6_conv2"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res6_conv2_scale"\n\
  type: "Scale"\n\
  bottom: "res6_conv2"\n\
  top: "res6_conv2"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res6_conv2_relu"\n\
  type: "ReLU"\n\
  bottom: "res6_conv2"\n\
  top: "res6_conv2"\n\
}\n\
layer {\n\
  name: "res6_conv3"\n\
  type: "Convolution"\n\
  bottom: "res6_conv2"\n\
  top: "res6_conv3"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 512\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res6_eletwise"\n\
  type: "Eltwise"\n\
  bottom: "res5_eletwise"\n\
  bottom: "res6_conv3"\n\
  top: "res6_eletwise"\n\
  eltwise_param {\n\
    operation: SUM\n\
  }\n\
}\n\
layer {\n\
  name: "res7_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res6_eletwise"\n\
  top: "res7_bn"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res7_scale"\n\
  type: "Scale"\n\
  bottom: "res7_bn"\n\
  top: "res7_bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res7_relu"\n\
  type: "ReLU"\n\
  bottom: "res7_bn"\n\
  top: "res7_bn"\n\
}\n\
layer {\n\
  name: "res7_conv1"\n\
  type: "Convolution"\n\
  bottom: "res7_bn"\n\
  top: "res7_conv1"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 128\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res7_conv1_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res7_conv1"\n\
  top: "res7_conv1"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res7_conv1_scale"\n\
  type: "Scale"\n\
  bottom: "res7_conv1"\n\
  top: "res7_conv1"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res7_conv1_relu"\n\
  type: "ReLU"\n\
  bottom: "res7_conv1"\n\
  top: "res7_conv1"\n\
}\n\
layer {\n\
  name: "res7_conv2"\n\
  type: "Convolution"\n\
  bottom: "res7_conv1"\n\
  top: "res7_conv2"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 128\n\
    pad: 1\n\
    kernel_size: 3\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res7_conv2_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res7_conv2"\n\
  top: "res7_conv2"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res7_conv2_scale"\n\
  type: "Scale"\n\
  bottom: "res7_conv2"\n\
  top: "res7_conv2"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res7_conv2_relu"\n\
  type: "ReLU"\n\
  bottom: "res7_conv2"\n\
  top: "res7_conv2"\n\
}\n\
layer {\n\
  name: "res7_conv3"\n\
  type: "Convolution"\n\
  bottom: "res7_conv2"\n\
  top: "res7_conv3"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 512\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res7_eletwise"\n\
  type: "Eltwise"\n\
  bottom: "res6_eletwise"\n\
  bottom: "res7_conv3"\n\
  top: "res7_eletwise"\n\
  eltwise_param {\n\
    operation: SUM\n\
  }\n\
}\n\
layer {\n\
  name: "res8_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res7_eletwise"\n\
  top: "res8_bn"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res8_scale"\n\
  type: "Scale"\n\
  bottom: "res8_bn"\n\
  top: "res8_bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res8_relu"\n\
  type: "ReLU"\n\
  bottom: "res8_bn"\n\
  top: "res8_bn"\n\
}\n\
layer {\n\
  name: "res8_conv1"\n\
  type: "Convolution"\n\
  bottom: "res8_bn"\n\
  top: "res8_conv1"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 256\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res8_conv1_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res8_conv1"\n\
  top: "res8_conv1"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res8_conv1_scale"\n\
  type: "Scale"\n\
  bottom: "res8_conv1"\n\
  top: "res8_conv1"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res8_conv1_relu"\n\
  type: "ReLU"\n\
  bottom: "res8_conv1"\n\
  top: "res8_conv1"\n\
}\n'
    return string



































def getResNet152v2Init():
    string = '\
layer {\n\
  name: "conv1"\n\
  type: "Convolution"\n\
  bottom: "image"\n\
  top: "conv1"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 64\n\
    pad: 3\n\
    kernel_size: 7\n\
    stride: 2\n\
  }\n\
}\n\
layer {\n\
  name: "conv1_bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv1"\n\
  top: "conv1"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "conv1_scale"\n\
  type: "Scale"\n\
  bottom: "conv1"\n\
  top: "conv1"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "conv1_relu"\n\
  type: "ReLU"\n\
  bottom: "conv1"\n\
  top: "conv1"\n\
}\n\
layer {\n\
  name: "pool1"\n\
  type: "Pooling"\n\
  bottom: "conv1"\n\
  top: "pool1"\n\
  pooling_param {\n\
    pool: MAX\n\
    kernel_size: 3\n\
    stride: 2\n\
  }\n\
}\n\
layer {\n\
  name: "res1_conv1"\n\
  type: "Convolution"\n\
  bottom: "pool1"\n\
  top: "res1_conv1"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 64\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res1_conv1_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res1_conv1"\n\
  top: "res1_conv1"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res1_conv1_scale"\n\
  type: "Scale"\n\
  bottom: "res1_conv1"\n\
  top: "res1_conv1"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res1_conv1_relu"\n\
  type: "ReLU"\n\
  bottom: "res1_conv1"\n\
  top: "res1_conv1"\n\
}\n\
layer {\n\
  name: "res1_conv2"\n\
  type: "Convolution"\n\
  bottom: "res1_conv1"\n\
  top: "res1_conv2"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 64\n\
    pad: 1\n\
    kernel_size: 3\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res1_conv2_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res1_conv2"\n\
  top: "res1_conv2"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res1_conv2_scale"\n\
  type: "Scale"\n\
  bottom: "res1_conv2"\n\
  top: "res1_conv2"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res1_conv2_relu"\n\
  type: "ReLU"\n\
  bottom: "res1_conv2"\n\
  top: "res1_conv2"\n\
}\n\
layer {\n\
  name: "res1_conv3"\n\
  type: "Convolution"\n\
  bottom: "res1_conv2"\n\
  top: "res1_conv3"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 256\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res1_match_conv"\n\
  type: "Convolution"\n\
  bottom: "pool1"\n\
  top: "res1_match_conv"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 256\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
    bias_filler {\n\
      type: "constant"\n\
      value: 0.2\n\
    }\n\
  }\n\
}\n\
layer {\n\
  name: "res1_eletwise"\n\
  type: "Eltwise"\n\
  bottom: "res1_match_conv"\n\
  bottom: "res1_conv3"\n\
  top: "res1_eletwise"\n\
  eltwise_param {\n\
    operation: SUM\n\
  }\n\
}\n\
layer {\n\
  name: "res2_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res1_eletwise"\n\
  top: "res2_bn"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res2_scale"\n\
  type: "Scale"\n\
  bottom: "res2_bn"\n\
  top: "res2_bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res2_relu"\n\
  type: "ReLU"\n\
  bottom: "res2_bn"\n\
  top: "res2_bn"\n\
}\n\
layer {\n\
  name: "res2_conv1"\n\
  type: "Convolution"\n\
  bottom: "res2_bn"\n\
  top: "res2_conv1"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 64\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res2_conv1_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res2_conv1"\n\
  top: "res2_conv1"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res2_conv1_scale"\n\
  type: "Scale"\n\
  bottom: "res2_conv1"\n\
  top: "res2_conv1"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res2_conv1_relu"\n\
  type: "ReLU"\n\
  bottom: "res2_conv1"\n\
  top: "res2_conv1"\n\
}\n\
layer {\n\
  name: "res2_conv2"\n\
  type: "Convolution"\n\
  bottom: "res2_conv1"\n\
  top: "res2_conv2"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 64\n\
    pad: 1\n\
    kernel_size: 3\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res2_conv2_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res2_conv2"\n\
  top: "res2_conv2"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res2_conv2_scale"\n\
  type: "Scale"\n\
  bottom: "res2_conv2"\n\
  top: "res2_conv2"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res2_conv2_relu"\n\
  type: "ReLU"\n\
  bottom: "res2_conv2"\n\
  top: "res2_conv2"\n\
}\n\
layer {\n\
  name: "res2_conv3"\n\
  type: "Convolution"\n\
  bottom: "res2_conv2"\n\
  top: "res2_conv3"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 256\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res2_eletwise"\n\
  type: "Eltwise"\n\
  bottom: "res1_eletwise"\n\
  bottom: "res2_conv3"\n\
  top: "res2_eletwise"\n\
  eltwise_param {\n\
    operation: SUM\n\
  }\n\
}\n\
layer {\n\
  name: "res3_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res2_eletwise"\n\
  top: "res3_bn"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res3_scale"\n\
  type: "Scale"\n\
  bottom: "res3_bn"\n\
  top: "res3_bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res3_relu"\n\
  type: "ReLU"\n\
  bottom: "res3_bn"\n\
  top: "res3_bn"\n\
}\n\
layer {\n\
  name: "res3_conv1"\n\
  type: "Convolution"\n\
  bottom: "res3_bn"\n\
  top: "res3_conv1"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 64\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res3_conv1_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res3_conv1"\n\
  top: "res3_conv1"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res3_conv1_scale"\n\
  type: "Scale"\n\
  bottom: "res3_conv1"\n\
  top: "res3_conv1"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res3_conv1_relu"\n\
  type: "ReLU"\n\
  bottom: "res3_conv1"\n\
  top: "res3_conv1"\n\
}\n\
layer {\n\
  name: "res3_conv2"\n\
  type: "Convolution"\n\
  bottom: "res3_conv1"\n\
  top: "res3_conv2"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 64\n\
    pad: 1\n\
    kernel_size: 3\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res3_conv2_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res3_conv2"\n\
  top: "res3_conv2"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res3_conv2_scale"\n\
  type: "Scale"\n\
  bottom: "res3_conv2"\n\
  top: "res3_conv2"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res3_conv2_relu"\n\
  type: "ReLU"\n\
  bottom: "res3_conv2"\n\
  top: "res3_conv2"\n\
}\n\
layer {\n\
  name: "res3_conv3"\n\
  type: "Convolution"\n\
  bottom: "res3_conv2"\n\
  top: "res3_conv3"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 256\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res3_eletwise"\n\
  type: "Eltwise"\n\
  bottom: "res2_eletwise"\n\
  bottom: "res3_conv3"\n\
  top: "res3_eletwise"\n\
  eltwise_param {\n\
    operation: SUM\n\
  }\n\
}\n\
layer {\n\
  name: "res4_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res3_eletwise"\n\
  top: "res4_bn"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res4_scale"\n\
  type: "Scale"\n\
  bottom: "res4_bn"\n\
  top: "res4_bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res4_relu"\n\
  type: "ReLU"\n\
  bottom: "res4_bn"\n\
  top: "res4_bn"\n\
}\n\
layer {\n\
  name: "res4_conv1"\n\
  type: "Convolution"\n\
  bottom: "res4_bn"\n\
  top: "res4_conv1"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 128\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res4_conv1_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res4_conv1"\n\
  top: "res4_conv1"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res4_conv1_scale"\n\
  type: "Scale"\n\
  bottom: "res4_conv1"\n\
  top: "res4_conv1"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res4_conv1_relu"\n\
  type: "ReLU"\n\
  bottom: "res4_conv1"\n\
  top: "res4_conv1"\n\
}\n\
layer {\n\
  name: "res4_conv2"\n\
  type: "Convolution"\n\
  bottom: "res4_conv1"\n\
  top: "res4_conv2"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 128\n\
    pad: 1\n\
    kernel_size: 3\n\
    stride: 2\n\
  }\n\
}\n\
layer {\n\
  name: "res4_conv2_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res4_conv2"\n\
  top: "res4_conv2"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res4_conv2_scale"\n\
  type: "Scale"\n\
  bottom: "res4_conv2"\n\
  top: "res4_conv2"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res4_conv2_relu"\n\
  type: "ReLU"\n\
  bottom: "res4_conv2"\n\
  top: "res4_conv2"\n\
}\n\
layer {\n\
  name: "res4_conv3"\n\
  type: "Convolution"\n\
  bottom: "res4_conv2"\n\
  top: "res4_conv3"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 512\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res4_match_conv"\n\
  type: "Convolution"\n\
  bottom: "res4_bn"\n\
  top: "res4_match_conv"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 512\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 2\n\
    bias_filler {\n\
      type: "constant"\n\
      value: 0.2\n\
    }\n\
  }\n\
}\n\
layer {\n\
  name: "res4_eletwise"\n\
  type: "Eltwise"\n\
  bottom: "res4_match_conv"\n\
  bottom: "res4_conv3"\n\
  top: "res4_eletwise"\n\
  eltwise_param {\n\
    operation: SUM\n\
  }\n\
}\n\
layer {\n\
  name: "res5_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res4_eletwise"\n\
  top: "res5_bn"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res5_scale"\n\
  type: "Scale"\n\
  bottom: "res5_bn"\n\
  top: "res5_bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res5_relu"\n\
  type: "ReLU"\n\
  bottom: "res5_bn"\n\
  top: "res5_bn"\n\
}\n\
layer {\n\
  name: "res5_conv1"\n\
  type: "Convolution"\n\
  bottom: "res5_bn"\n\
  top: "res5_conv1"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 128\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res5_conv1_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res5_conv1"\n\
  top: "res5_conv1"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res5_conv1_scale"\n\
  type: "Scale"\n\
  bottom: "res5_conv1"\n\
  top: "res5_conv1"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res5_conv1_relu"\n\
  type: "ReLU"\n\
  bottom: "res5_conv1"\n\
  top: "res5_conv1"\n\
}\n\
layer {\n\
  name: "res5_conv2"\n\
  type: "Convolution"\n\
  bottom: "res5_conv1"\n\
  top: "res5_conv2"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 128\n\
    pad: 1\n\
    kernel_size: 3\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res5_conv2_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res5_conv2"\n\
  top: "res5_conv2"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res5_conv2_scale"\n\
  type: "Scale"\n\
  bottom: "res5_conv2"\n\
  top: "res5_conv2"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res5_conv2_relu"\n\
  type: "ReLU"\n\
  bottom: "res5_conv2"\n\
  top: "res5_conv2"\n\
}\n\
layer {\n\
  name: "res5_conv3"\n\
  type: "Convolution"\n\
  bottom: "res5_conv2"\n\
  top: "res5_conv3"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 512\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res5_eletwise"\n\
  type: "Eltwise"\n\
  bottom: "res4_eletwise"\n\
  bottom: "res5_conv3"\n\
  top: "res5_eletwise"\n\
  eltwise_param {\n\
    operation: SUM\n\
  }\n\
}\n\
layer {\n\
  name: "res6_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res5_eletwise"\n\
  top: "res6_bn"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res6_scale"\n\
  type: "Scale"\n\
  bottom: "res6_bn"\n\
  top: "res6_bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res6_relu"\n\
  type: "ReLU"\n\
  bottom: "res6_bn"\n\
  top: "res6_bn"\n\
}\n\
layer {\n\
  name: "res6_conv1"\n\
  type: "Convolution"\n\
  bottom: "res6_bn"\n\
  top: "res6_conv1"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 128\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res6_conv1_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res6_conv1"\n\
  top: "res6_conv1"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res6_conv1_scale"\n\
  type: "Scale"\n\
  bottom: "res6_conv1"\n\
  top: "res6_conv1"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res6_conv1_relu"\n\
  type: "ReLU"\n\
  bottom: "res6_conv1"\n\
  top: "res6_conv1"\n\
}\n\
layer {\n\
  name: "res6_conv2"\n\
  type: "Convolution"\n\
  bottom: "res6_conv1"\n\
  top: "res6_conv2"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 128\n\
    pad: 1\n\
    kernel_size: 3\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res6_conv2_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res6_conv2"\n\
  top: "res6_conv2"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res6_conv2_scale"\n\
  type: "Scale"\n\
  bottom: "res6_conv2"\n\
  top: "res6_conv2"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res6_conv2_relu"\n\
  type: "ReLU"\n\
  bottom: "res6_conv2"\n\
  top: "res6_conv2"\n\
}\n\
layer {\n\
  name: "res6_conv3"\n\
  type: "Convolution"\n\
  bottom: "res6_conv2"\n\
  top: "res6_conv3"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 512\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res6_eletwise"\n\
  type: "Eltwise"\n\
  bottom: "res5_eletwise"\n\
  bottom: "res6_conv3"\n\
  top: "res6_eletwise"\n\
  eltwise_param {\n\
    operation: SUM\n\
  }\n\
}\n\
layer {\n\
  name: "res7_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res6_eletwise"\n\
  top: "res7_bn"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res7_scale"\n\
  type: "Scale"\n\
  bottom: "res7_bn"\n\
  top: "res7_bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res7_relu"\n\
  type: "ReLU"\n\
  bottom: "res7_bn"\n\
  top: "res7_bn"\n\
}\n\
layer {\n\
  name: "res7_conv1"\n\
  type: "Convolution"\n\
  bottom: "res7_bn"\n\
  top: "res7_conv1"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 128\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res7_conv1_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res7_conv1"\n\
  top: "res7_conv1"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res7_conv1_scale"\n\
  type: "Scale"\n\
  bottom: "res7_conv1"\n\
  top: "res7_conv1"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res7_conv1_relu"\n\
  type: "ReLU"\n\
  bottom: "res7_conv1"\n\
  top: "res7_conv1"\n\
}\n\
layer {\n\
  name: "res7_conv2"\n\
  type: "Convolution"\n\
  bottom: "res7_conv1"\n\
  top: "res7_conv2"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 128\n\
    pad: 1\n\
    kernel_size: 3\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res7_conv2_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res7_conv2"\n\
  top: "res7_conv2"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res7_conv2_scale"\n\
  type: "Scale"\n\
  bottom: "res7_conv2"\n\
  top: "res7_conv2"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res7_conv2_relu"\n\
  type: "ReLU"\n\
  bottom: "res7_conv2"\n\
  top: "res7_conv2"\n\
}\n\
layer {\n\
  name: "res7_conv3"\n\
  type: "Convolution"\n\
  bottom: "res7_conv2"\n\
  top: "res7_conv3"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 512\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res7_eletwise"\n\
  type: "Eltwise"\n\
  bottom: "res6_eletwise"\n\
  bottom: "res7_conv3"\n\
  top: "res7_eletwise"\n\
  eltwise_param {\n\
    operation: SUM\n\
  }\n\
}\n\
layer {\n\
  name: "res8_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res7_eletwise"\n\
  top: "res8_bn"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res8_scale"\n\
  type: "Scale"\n\
  bottom: "res8_bn"\n\
  top: "res8_bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res8_relu"\n\
  type: "ReLU"\n\
  bottom: "res8_bn"\n\
  top: "res8_bn"\n\
}\n\
layer {\n\
  name: "res8_conv1"\n\
  type: "Convolution"\n\
  bottom: "res8_bn"\n\
  top: "res8_conv1"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 128\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res8_conv1_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res8_conv1"\n\
  top: "res8_conv1"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res8_conv1_scale"\n\
  type: "Scale"\n\
  bottom: "res8_conv1"\n\
  top: "res8_conv1"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res8_conv1_relu"\n\
  type: "ReLU"\n\
  bottom: "res8_conv1"\n\
  top: "res8_conv1"\n\
}\n\
layer {\n\
  name: "res8_conv2"\n\
  type: "Convolution"\n\
  bottom: "res8_conv1"\n\
  top: "res8_conv2"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 128\n\
    pad: 1\n\
    kernel_size: 3\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res8_conv2_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res8_conv2"\n\
  top: "res8_conv2"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res8_conv2_scale"\n\
  type: "Scale"\n\
  bottom: "res8_conv2"\n\
  top: "res8_conv2"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res8_conv2_relu"\n\
  type: "ReLU"\n\
  bottom: "res8_conv2"\n\
  top: "res8_conv2"\n\
}\n\
layer {\n\
  name: "res8_conv3"\n\
  type: "Convolution"\n\
  bottom: "res8_conv2"\n\
  top: "res8_conv3"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 512\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res8_eletwise"\n\
  type: "Eltwise"\n\
  bottom: "res7_eletwise"\n\
  bottom: "res8_conv3"\n\
  top: "res8_eletwise"\n\
  eltwise_param {\n\
    operation: SUM\n\
  }\n\
}\n\
layer {\n\
  name: "res9_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res8_eletwise"\n\
  top: "res9_bn"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res9_scale"\n\
  type: "Scale"\n\
  bottom: "res9_bn"\n\
  top: "res9_bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res9_relu"\n\
  type: "ReLU"\n\
  bottom: "res9_bn"\n\
  top: "res9_bn"\n\
}\n\
layer {\n\
  name: "res9_conv1"\n\
  type: "Convolution"\n\
  bottom: "res9_bn"\n\
  top: "res9_conv1"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 128\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res9_conv1_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res9_conv1"\n\
  top: "res9_conv1"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res9_conv1_scale"\n\
  type: "Scale"\n\
  bottom: "res9_conv1"\n\
  top: "res9_conv1"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res9_conv1_relu"\n\
  type: "ReLU"\n\
  bottom: "res9_conv1"\n\
  top: "res9_conv1"\n\
}\n\
layer {\n\
  name: "res9_conv2"\n\
  type: "Convolution"\n\
  bottom: "res9_conv1"\n\
  top: "res9_conv2"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 128\n\
    pad: 1\n\
    kernel_size: 3\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res9_conv2_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res9_conv2"\n\
  top: "res9_conv2"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res9_conv2_scale"\n\
  type: "Scale"\n\
  bottom: "res9_conv2"\n\
  top: "res9_conv2"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res9_conv2_relu"\n\
  type: "ReLU"\n\
  bottom: "res9_conv2"\n\
  top: "res9_conv2"\n\
}\n\
layer {\n\
  name: "res9_conv3"\n\
  type: "Convolution"\n\
  bottom: "res9_conv2"\n\
  top: "res9_conv3"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 512\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res9_eletwise"\n\
  type: "Eltwise"\n\
  bottom: "res8_eletwise"\n\
  bottom: "res9_conv3"\n\
  top: "res9_eletwise"\n\
  eltwise_param {\n\
    operation: SUM\n\
  }\n\
}\n\
layer {\n\
  name: "res10_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res9_eletwise"\n\
  top: "res10_bn"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res10_scale"\n\
  type: "Scale"\n\
  bottom: "res10_bn"\n\
  top: "res10_bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res10_relu"\n\
  type: "ReLU"\n\
  bottom: "res10_bn"\n\
  top: "res10_bn"\n\
}\n\
layer {\n\
  name: "res10_conv1"\n\
  type: "Convolution"\n\
  bottom: "res10_bn"\n\
  top: "res10_conv1"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 128\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res10_conv1_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res10_conv1"\n\
  top: "res10_conv1"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res10_conv1_scale"\n\
  type: "Scale"\n\
  bottom: "res10_conv1"\n\
  top: "res10_conv1"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res10_conv1_relu"\n\
  type: "ReLU"\n\
  bottom: "res10_conv1"\n\
  top: "res10_conv1"\n\
}\n\
layer {\n\
  name: "res10_conv2"\n\
  type: "Convolution"\n\
  bottom: "res10_conv1"\n\
  top: "res10_conv2"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 128\n\
    pad: 1\n\
    kernel_size: 3\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res10_conv2_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res10_conv2"\n\
  top: "res10_conv2"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res10_conv2_scale"\n\
  type: "Scale"\n\
  bottom: "res10_conv2"\n\
  top: "res10_conv2"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res10_conv2_relu"\n\
  type: "ReLU"\n\
  bottom: "res10_conv2"\n\
  top: "res10_conv2"\n\
}\n\
layer {\n\
  name: "res10_conv3"\n\
  type: "Convolution"\n\
  bottom: "res10_conv2"\n\
  top: "res10_conv3"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 512\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res10_eletwise"\n\
  type: "Eltwise"\n\
  bottom: "res9_eletwise"\n\
  bottom: "res10_conv3"\n\
  top: "res10_eletwise"\n\
  eltwise_param {\n\
    operation: SUM\n\
  }\n\
}\n\
layer {\n\
  name: "res11_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res10_eletwise"\n\
  top: "res11_bn"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res11_scale"\n\
  type: "Scale"\n\
  bottom: "res11_bn"\n\
  top: "res11_bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res11_relu"\n\
  type: "ReLU"\n\
  bottom: "res11_bn"\n\
  top: "res11_bn"\n\
}\n\
layer {\n\
  name: "res11_conv1"\n\
  type: "Convolution"\n\
  bottom: "res11_bn"\n\
  top: "res11_conv1"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 128\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res11_conv1_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res11_conv1"\n\
  top: "res11_conv1"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res11_conv1_scale"\n\
  type: "Scale"\n\
  bottom: "res11_conv1"\n\
  top: "res11_conv1"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res11_conv1_relu"\n\
  type: "ReLU"\n\
  bottom: "res11_conv1"\n\
  top: "res11_conv1"\n\
}\n\
layer {\n\
  name: "res11_conv2"\n\
  type: "Convolution"\n\
  bottom: "res11_conv1"\n\
  top: "res11_conv2"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 128\n\
    pad: 1\n\
    kernel_size: 3\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res11_conv2_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res11_conv2"\n\
  top: "res11_conv2"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res11_conv2_scale"\n\
  type: "Scale"\n\
  bottom: "res11_conv2"\n\
  top: "res11_conv2"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res11_conv2_relu"\n\
  type: "ReLU"\n\
  bottom: "res11_conv2"\n\
  top: "res11_conv2"\n\
}\n\
layer {\n\
  name: "res11_conv3"\n\
  type: "Convolution"\n\
  bottom: "res11_conv2"\n\
  top: "res11_conv3"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 512\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res11_eletwise"\n\
  type: "Eltwise"\n\
  bottom: "res10_eletwise"\n\
  bottom: "res11_conv3"\n\
  top: "res11_eletwise"\n\
  eltwise_param {\n\
    operation: SUM\n\
  }\n\
}\n\
layer {\n\
  name: "res12_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res11_eletwise"\n\
  top: "res12_bn"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res12_scale"\n\
  type: "Scale"\n\
  bottom: "res12_bn"\n\
  top: "res12_bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res12_relu"\n\
  type: "ReLU"\n\
  bottom: "res12_bn"\n\
  top: "res12_bn"\n\
}\n\
layer {\n\
  name: "res12_conv1"\n\
  type: "Convolution"\n\
  bottom: "res12_bn"\n\
  top: "res12_conv1"\n\
  convolution_param {\n\
    bias_term: false\n\
    num_output: 256\n\
    pad: 0\n\
    kernel_size: 1\n\
    stride: 1\n\
  }\n\
}\n\
layer {\n\
  name: "res12_conv1_bn"\n\
  type: "BatchNorm"\n\
  bottom: "res12_conv1"\n\
  top: "res12_conv1"\n\
  batch_norm_param {\n\
    use_global_stats: true\n\
  }\n\
}\n\
layer {\n\
  name: "res12_conv1_scale"\n\
  type: "Scale"\n\
  bottom: "res12_conv1"\n\
  top: "res12_conv1"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "res12_conv1_relu"\n\
  type: "ReLU"\n\
  bottom: "res12_conv1"\n\
  top: "res12_conv1"\n\
}\n'
    return string

