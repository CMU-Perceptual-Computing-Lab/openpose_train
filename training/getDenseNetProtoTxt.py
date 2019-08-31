def getDenseNet121Init():
    string = '\
layer {\n\
  name: "conv1"\n\
  type: "Convolution"\n\
  bottom: "image"\n\
  top: "conv1"\n\
  convolution_param {\n\
    num_output: 64\n\
    bias_term: false\n\
    pad: 3\n\
    kernel_size: 7\n\
    stride: 2\n\
  }\n\
}\n\
layer {\n\
  name: "conv1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv1"\n\
  top: "conv1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv1/scale"\n\
  type: "Scale"\n\
  bottom: "conv1/bn"\n\
  top: "conv1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu1"\n\
  type: "ReLU"\n\
  bottom: "conv1/bn"\n\
  top: "conv1/bn"\n\
}\n\
layer {\n\
  name: "pool1"\n\
  type: "Pooling"\n\
  bottom: "conv1/bn"\n\
  top: "pool1"\n\
  pooling_param {\n\
    pool: MAX\n\
    kernel_size: 3\n\
    stride: 2\n\
    pad: 1\n\
    # ceil_mode: false\n\
    round_mode: FLOOR\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_1/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "pool1"\n\
  top: "conv2_1/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_1/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv2_1/x1/bn"\n\
  top: "conv2_1/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu2_1/x1"\n\
  type: "ReLU"\n\
  bottom: "conv2_1/x1/bn"\n\
  top: "conv2_1/x1/bn"\n\
}\n\
layer {\n\
  name: "conv2_1/x1"\n\
  type: "Convolution"\n\
  bottom: "conv2_1/x1/bn"\n\
  top: "conv2_1/x1"\n\
  convolution_param {\n\
    num_output: 128\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_1/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv2_1/x1"\n\
  top: "conv2_1/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_1/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv2_1/x2/bn"\n\
  top: "conv2_1/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu2_1/x2"\n\
  type: "ReLU"\n\
  bottom: "conv2_1/x2/bn"\n\
  top: "conv2_1/x2/bn"\n\
}\n\
layer {\n\
  name: "conv2_1/x2"\n\
  type: "Convolution"\n\
  bottom: "conv2_1/x2/bn"\n\
  top: "conv2_1/x2"\n\
  convolution_param {\n\
    num_output: 32\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_2_1"\n\
  type: "Concat"\n\
  bottom: "pool1"\n\
  bottom: "conv2_1/x2"\n\
  top: "concat_2_1"\n\
}\n\
layer {\n\
  name: "conv2_2/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_2_1"\n\
  top: "conv2_2/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_2/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv2_2/x1/bn"\n\
  top: "conv2_2/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu2_2/x1"\n\
  type: "ReLU"\n\
  bottom: "conv2_2/x1/bn"\n\
  top: "conv2_2/x1/bn"\n\
}\n\
layer {\n\
  name: "conv2_2/x1"\n\
  type: "Convolution"\n\
  bottom: "conv2_2/x1/bn"\n\
  top: "conv2_2/x1"\n\
  convolution_param {\n\
    num_output: 128\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_2/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv2_2/x1"\n\
  top: "conv2_2/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_2/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv2_2/x2/bn"\n\
  top: "conv2_2/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu2_2/x2"\n\
  type: "ReLU"\n\
  bottom: "conv2_2/x2/bn"\n\
  top: "conv2_2/x2/bn"\n\
}\n\
layer {\n\
  name: "conv2_2/x2"\n\
  type: "Convolution"\n\
  bottom: "conv2_2/x2/bn"\n\
  top: "conv2_2/x2"\n\
  convolution_param {\n\
    num_output: 32\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_2_2"\n\
  type: "Concat"\n\
  bottom: "concat_2_1"\n\
  bottom: "conv2_2/x2"\n\
  top: "concat_2_2"\n\
}\n\
layer {\n\
  name: "conv2_3/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_2_2"\n\
  top: "conv2_3/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_3/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv2_3/x1/bn"\n\
  top: "conv2_3/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu2_3/x1"\n\
  type: "ReLU"\n\
  bottom: "conv2_3/x1/bn"\n\
  top: "conv2_3/x1/bn"\n\
}\n\
layer {\n\
  name: "conv2_3/x1"\n\
  type: "Convolution"\n\
  bottom: "conv2_3/x1/bn"\n\
  top: "conv2_3/x1"\n\
  convolution_param {\n\
    num_output: 128\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_3/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv2_3/x1"\n\
  top: "conv2_3/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_3/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv2_3/x2/bn"\n\
  top: "conv2_3/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu2_3/x2"\n\
  type: "ReLU"\n\
  bottom: "conv2_3/x2/bn"\n\
  top: "conv2_3/x2/bn"\n\
}\n\
layer {\n\
  name: "conv2_3/x2"\n\
  type: "Convolution"\n\
  bottom: "conv2_3/x2/bn"\n\
  top: "conv2_3/x2"\n\
  convolution_param {\n\
    num_output: 32\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_2_3"\n\
  type: "Concat"\n\
  bottom: "concat_2_2"\n\
  bottom: "conv2_3/x2"\n\
  top: "concat_2_3"\n\
}\n\
layer {\n\
  name: "conv2_4/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_2_3"\n\
  top: "conv2_4/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_4/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv2_4/x1/bn"\n\
  top: "conv2_4/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu2_4/x1"\n\
  type: "ReLU"\n\
  bottom: "conv2_4/x1/bn"\n\
  top: "conv2_4/x1/bn"\n\
}\n\
layer {\n\
  name: "conv2_4/x1"\n\
  type: "Convolution"\n\
  bottom: "conv2_4/x1/bn"\n\
  top: "conv2_4/x1"\n\
  convolution_param {\n\
    num_output: 128\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_4/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv2_4/x1"\n\
  top: "conv2_4/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_4/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv2_4/x2/bn"\n\
  top: "conv2_4/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu2_4/x2"\n\
  type: "ReLU"\n\
  bottom: "conv2_4/x2/bn"\n\
  top: "conv2_4/x2/bn"\n\
}\n\
layer {\n\
  name: "conv2_4/x2"\n\
  type: "Convolution"\n\
  bottom: "conv2_4/x2/bn"\n\
  top: "conv2_4/x2"\n\
  convolution_param {\n\
    num_output: 32\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_2_4"\n\
  type: "Concat"\n\
  bottom: "concat_2_3"\n\
  bottom: "conv2_4/x2"\n\
  top: "concat_2_4"\n\
}\n\
layer {\n\
  name: "conv2_5/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_2_4"\n\
  top: "conv2_5/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_5/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv2_5/x1/bn"\n\
  top: "conv2_5/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu2_5/x1"\n\
  type: "ReLU"\n\
  bottom: "conv2_5/x1/bn"\n\
  top: "conv2_5/x1/bn"\n\
}\n\
layer {\n\
  name: "conv2_5/x1"\n\
  type: "Convolution"\n\
  bottom: "conv2_5/x1/bn"\n\
  top: "conv2_5/x1"\n\
  convolution_param {\n\
    num_output: 128\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_5/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv2_5/x1"\n\
  top: "conv2_5/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_5/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv2_5/x2/bn"\n\
  top: "conv2_5/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu2_5/x2"\n\
  type: "ReLU"\n\
  bottom: "conv2_5/x2/bn"\n\
  top: "conv2_5/x2/bn"\n\
}\n\
layer {\n\
  name: "conv2_5/x2"\n\
  type: "Convolution"\n\
  bottom: "conv2_5/x2/bn"\n\
  top: "conv2_5/x2"\n\
  convolution_param {\n\
    num_output: 32\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_2_5"\n\
  type: "Concat"\n\
  bottom: "concat_2_4"\n\
  bottom: "conv2_5/x2"\n\
  top: "concat_2_5"\n\
}\n\
layer {\n\
  name: "conv2_6/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_2_5"\n\
  top: "conv2_6/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_6/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv2_6/x1/bn"\n\
  top: "conv2_6/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu2_6/x1"\n\
  type: "ReLU"\n\
  bottom: "conv2_6/x1/bn"\n\
  top: "conv2_6/x1/bn"\n\
}\n\
layer {\n\
  name: "conv2_6/x1"\n\
  type: "Convolution"\n\
  bottom: "conv2_6/x1/bn"\n\
  top: "conv2_6/x1"\n\
  convolution_param {\n\
    num_output: 128\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_6/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv2_6/x1"\n\
  top: "conv2_6/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_6/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv2_6/x2/bn"\n\
  top: "conv2_6/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu2_6/x2"\n\
  type: "ReLU"\n\
  bottom: "conv2_6/x2/bn"\n\
  top: "conv2_6/x2/bn"\n\
}\n\
layer {\n\
  name: "conv2_6/x2"\n\
  type: "Convolution"\n\
  bottom: "conv2_6/x2/bn"\n\
  top: "conv2_6/x2"\n\
  convolution_param {\n\
    num_output: 32\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_2_6"\n\
  type: "Concat"\n\
  bottom: "concat_2_5"\n\
  bottom: "conv2_6/x2"\n\
  top: "concat_2_6"\n\
}\n\
layer {\n\
  name: "conv2_blk/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_2_6"\n\
  top: "conv2_blk/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_blk/scale"\n\
  type: "Scale"\n\
  bottom: "conv2_blk/bn"\n\
  top: "conv2_blk/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu2_blk"\n\
  type: "ReLU"\n\
  bottom: "conv2_blk/bn"\n\
  top: "conv2_blk/bn"\n\
}\n\
layer {\n\
  name: "conv2_blk"\n\
  type: "Convolution"\n\
  bottom: "conv2_blk/bn"\n\
  top: "conv2_blk"\n\
  convolution_param {\n\
    num_output: 128\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "pool2"\n\
  type: "Pooling"\n\
  bottom: "conv2_blk"\n\
  top: "pool2"\n\
  pooling_param {\n\
    pool: AVE\n\
    kernel_size: 2\n\
    stride: 2\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_1/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "pool2"\n\
  top: "conv3_1/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_1/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_1/x1/bn"\n\
  top: "conv3_1/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_1/x1"\n\
  type: "ReLU"\n\
  bottom: "conv3_1/x1/bn"\n\
  top: "conv3_1/x1/bn"\n\
}\n\
layer {\n\
  name: "conv3_1/x1"\n\
  type: "Convolution"\n\
  bottom: "conv3_1/x1/bn"\n\
  top: "conv3_1/x1"\n\
  convolution_param {\n\
    num_output: 128\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_1/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv3_1/x1"\n\
  top: "conv3_1/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_1/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_1/x2/bn"\n\
  top: "conv3_1/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_1/x2"\n\
  type: "ReLU"\n\
  bottom: "conv3_1/x2/bn"\n\
  top: "conv3_1/x2/bn"\n\
}\n\
layer {\n\
  name: "conv3_1/x2"\n\
  type: "Convolution"\n\
  bottom: "conv3_1/x2/bn"\n\
  top: "conv3_1/x2"\n\
  convolution_param {\n\
    num_output: 32\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_3_1"\n\
  type: "Concat"\n\
  bottom: "pool2"\n\
  bottom: "conv3_1/x2"\n\
  top: "concat_3_1"\n\
}\n\
layer {\n\
  name: "conv3_2/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_3_1"\n\
  top: "conv3_2/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_2/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_2/x1/bn"\n\
  top: "conv3_2/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_2/x1"\n\
  type: "ReLU"\n\
  bottom: "conv3_2/x1/bn"\n\
  top: "conv3_2/x1/bn"\n\
}\n\
layer {\n\
  name: "conv3_2/x1"\n\
  type: "Convolution"\n\
  bottom: "conv3_2/x1/bn"\n\
  top: "conv3_2/x1"\n\
  convolution_param {\n\
    num_output: 128\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_2/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv3_2/x1"\n\
  top: "conv3_2/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_2/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_2/x2/bn"\n\
  top: "conv3_2/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_2/x2"\n\
  type: "ReLU"\n\
  bottom: "conv3_2/x2/bn"\n\
  top: "conv3_2/x2/bn"\n\
}\n\
layer {\n\
  name: "conv3_2/x2"\n\
  type: "Convolution"\n\
  bottom: "conv3_2/x2/bn"\n\
  top: "conv3_2/x2"\n\
  convolution_param {\n\
    num_output: 32\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_3_2"\n\
  type: "Concat"\n\
  bottom: "concat_3_1"\n\
  bottom: "conv3_2/x2"\n\
  top: "concat_3_2"\n\
}\n\
layer {\n\
  name: "conv3_3/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_3_2"\n\
  top: "conv3_3/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_3/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_3/x1/bn"\n\
  top: "conv3_3/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_3/x1"\n\
  type: "ReLU"\n\
  bottom: "conv3_3/x1/bn"\n\
  top: "conv3_3/x1/bn"\n\
}\n\
layer {\n\
  name: "conv3_3/x1"\n\
  type: "Convolution"\n\
  bottom: "conv3_3/x1/bn"\n\
  top: "conv3_3/x1"\n\
  convolution_param {\n\
    num_output: 128\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_3/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv3_3/x1"\n\
  top: "conv3_3/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_3/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_3/x2/bn"\n\
  top: "conv3_3/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_3/x2"\n\
  type: "ReLU"\n\
  bottom: "conv3_3/x2/bn"\n\
  top: "conv3_3/x2/bn"\n\
}\n\
layer {\n\
  name: "conv3_3/x2"\n\
  type: "Convolution"\n\
  bottom: "conv3_3/x2/bn"\n\
  top: "conv3_3/x2"\n\
  convolution_param {\n\
    num_output: 32\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_3_3"\n\
  type: "Concat"\n\
  bottom: "concat_3_2"\n\
  bottom: "conv3_3/x2"\n\
  top: "concat_3_3"\n\
}\n\
layer {\n\
  name: "conv3_4/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_3_3"\n\
  top: "conv3_4/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_4/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_4/x1/bn"\n\
  top: "conv3_4/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_4/x1"\n\
  type: "ReLU"\n\
  bottom: "conv3_4/x1/bn"\n\
  top: "conv3_4/x1/bn"\n\
}\n\
layer {\n\
  name: "conv3_4/x1"\n\
  type: "Convolution"\n\
  bottom: "conv3_4/x1/bn"\n\
  top: "conv3_4/x1"\n\
  convolution_param {\n\
    num_output: 128\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_4/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv3_4/x1"\n\
  top: "conv3_4/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_4/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_4/x2/bn"\n\
  top: "conv3_4/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_4/x2"\n\
  type: "ReLU"\n\
  bottom: "conv3_4/x2/bn"\n\
  top: "conv3_4/x2/bn"\n\
}\n\
layer {\n\
  name: "conv3_4/x2"\n\
  type: "Convolution"\n\
  bottom: "conv3_4/x2/bn"\n\
  top: "conv3_4/x2"\n\
  convolution_param {\n\
    num_output: 32\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_3_4"\n\
  type: "Concat"\n\
  bottom: "concat_3_3"\n\
  bottom: "conv3_4/x2"\n\
  top: "concat_3_4"\n\
}\n\
layer {\n\
  name: "conv3_5/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_3_4"\n\
  top: "conv3_5/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_5/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_5/x1/bn"\n\
  top: "conv3_5/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_5/x1"\n\
  type: "ReLU"\n\
  bottom: "conv3_5/x1/bn"\n\
  top: "conv3_5/x1/bn"\n\
}\n\
layer {\n\
  name: "conv3_5/x1"\n\
  type: "Convolution"\n\
  bottom: "conv3_5/x1/bn"\n\
  top: "conv3_5/x1"\n\
  convolution_param {\n\
    num_output: 128\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_5/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv3_5/x1"\n\
  top: "conv3_5/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_5/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_5/x2/bn"\n\
  top: "conv3_5/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_5/x2"\n\
  type: "ReLU"\n\
  bottom: "conv3_5/x2/bn"\n\
  top: "conv3_5/x2/bn"\n\
}\n\
layer {\n\
  name: "conv3_5/x2"\n\
  type: "Convolution"\n\
  bottom: "conv3_5/x2/bn"\n\
  top: "conv3_5/x2"\n\
  convolution_param {\n\
    num_output: 32\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_3_5"\n\
  type: "Concat"\n\
  bottom: "concat_3_4"\n\
  bottom: "conv3_5/x2"\n\
  top: "concat_3_5"\n\
}\n\
layer {\n\
  name: "conv3_6/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_3_5"\n\
  top: "conv3_6/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_6/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_6/x1/bn"\n\
  top: "conv3_6/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_6/x1"\n\
  type: "ReLU"\n\
  bottom: "conv3_6/x1/bn"\n\
  top: "conv3_6/x1/bn"\n\
}\n\
layer {\n\
  name: "conv3_6/x1"\n\
  type: "Convolution"\n\
  bottom: "conv3_6/x1/bn"\n\
  top: "conv3_6/x1"\n\
  convolution_param {\n\
    num_output: 128\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_6/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv3_6/x1"\n\
  top: "conv3_6/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_6/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_6/x2/bn"\n\
  top: "conv3_6/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_6/x2"\n\
  type: "ReLU"\n\
  bottom: "conv3_6/x2/bn"\n\
  top: "conv3_6/x2/bn"\n\
}\n\
layer {\n\
  name: "conv3_6/x2"\n\
  type: "Convolution"\n\
  bottom: "conv3_6/x2/bn"\n\
  top: "conv3_6/x2"\n\
  convolution_param {\n\
    num_output: 32\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_3_6"\n\
  type: "Concat"\n\
  bottom: "concat_3_5"\n\
  bottom: "conv3_6/x2"\n\
  top: "concat_3_6"\n\
}\n\
layer {\n\
  name: "conv3_7/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_3_6"\n\
  top: "conv3_7/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_7/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_7/x1/bn"\n\
  top: "conv3_7/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_7/x1"\n\
  type: "ReLU"\n\
  bottom: "conv3_7/x1/bn"\n\
  top: "conv3_7/x1/bn"\n\
}\n\
layer {\n\
  name: "conv3_7/x1"\n\
  type: "Convolution"\n\
  bottom: "conv3_7/x1/bn"\n\
  top: "conv3_7/x1"\n\
  convolution_param {\n\
    num_output: 128\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_7/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv3_7/x1"\n\
  top: "conv3_7/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_7/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_7/x2/bn"\n\
  top: "conv3_7/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_7/x2"\n\
  type: "ReLU"\n\
  bottom: "conv3_7/x2/bn"\n\
  top: "conv3_7/x2/bn"\n\
}\n\
layer {\n\
  name: "conv3_7/x2"\n\
  type: "Convolution"\n\
  bottom: "conv3_7/x2/bn"\n\
  top: "conv3_7/x2"\n\
  convolution_param {\n\
    num_output: 32\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_3_7"\n\
  type: "Concat"\n\
  bottom: "concat_3_6"\n\
  bottom: "conv3_7/x2"\n\
  top: "concat_3_7"\n\
}\n\
layer {\n\
  name: "conv3_8/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_3_7"\n\
  top: "conv3_8/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_8/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_8/x1/bn"\n\
  top: "conv3_8/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_8/x1"\n\
  type: "ReLU"\n\
  bottom: "conv3_8/x1/bn"\n\
  top: "conv3_8/x1/bn"\n\
}\n\
layer {\n\
  name: "conv3_8/x1"\n\
  type: "Convolution"\n\
  bottom: "conv3_8/x1/bn"\n\
  top: "conv3_8/x1"\n\
  convolution_param {\n\
    num_output: 128\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_8/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv3_8/x1"\n\
  top: "conv3_8/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_8/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_8/x2/bn"\n\
  top: "conv3_8/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_8/x2"\n\
  type: "ReLU"\n\
  bottom: "conv3_8/x2/bn"\n\
  top: "conv3_8/x2/bn"\n\
}\n\
layer {\n\
  name: "conv3_8/x2"\n\
  type: "Convolution"\n\
  bottom: "conv3_8/x2/bn"\n\
  top: "conv3_8/x2"\n\
  convolution_param {\n\
    num_output: 32\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_3_8"\n\
  type: "Concat"\n\
  bottom: "concat_3_7"\n\
  bottom: "conv3_8/x2"\n\
  top: "concat_3_8"\n\
}\n\
layer {\n\
  name: "conv3_9/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_3_8"\n\
  top: "conv3_9/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_9/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_9/x1/bn"\n\
  top: "conv3_9/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_9/x1"\n\
  type: "ReLU"\n\
  bottom: "conv3_9/x1/bn"\n\
  top: "conv3_9/x1/bn"\n\
}\n\
layer {\n\
  name: "conv3_9/x1"\n\
  type: "Convolution"\n\
  bottom: "conv3_9/x1/bn"\n\
  top: "conv3_9/x1"\n\
  convolution_param {\n\
    num_output: 128\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_9/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv3_9/x1"\n\
  top: "conv3_9/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_9/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_9/x2/bn"\n\
  top: "conv3_9/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_9/x2"\n\
  type: "ReLU"\n\
  bottom: "conv3_9/x2/bn"\n\
  top: "conv3_9/x2/bn"\n\
}\n\
layer {\n\
  name: "conv3_9/x2"\n\
  type: "Convolution"\n\
  bottom: "conv3_9/x2/bn"\n\
  top: "conv3_9/x2"\n\
  convolution_param {\n\
    num_output: 32\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_3_9"\n\
  type: "Concat"\n\
  bottom: "concat_3_8"\n\
  bottom: "conv3_9/x2"\n\
  top: "concat_3_9"\n\
}\n\
layer {\n\
  name: "conv3_10/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_3_9"\n\
  top: "conv3_10/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_10/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_10/x1/bn"\n\
  top: "conv3_10/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_10/x1"\n\
  type: "ReLU"\n\
  bottom: "conv3_10/x1/bn"\n\
  top: "conv3_10/x1/bn"\n\
}\n\
layer {\n\
  name: "conv3_10/x1"\n\
  type: "Convolution"\n\
  bottom: "conv3_10/x1/bn"\n\
  top: "conv3_10/x1"\n\
  convolution_param {\n\
    num_output: 128\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_10/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv3_10/x1"\n\
  top: "conv3_10/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_10/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_10/x2/bn"\n\
  top: "conv3_10/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_10/x2"\n\
  type: "ReLU"\n\
  bottom: "conv3_10/x2/bn"\n\
  top: "conv3_10/x2/bn"\n\
}\n\
layer {\n\
  name: "conv3_10/x2"\n\
  type: "Convolution"\n\
  bottom: "conv3_10/x2/bn"\n\
  top: "conv3_10/x2"\n\
  convolution_param {\n\
    num_output: 32\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_3_10"\n\
  type: "Concat"\n\
  bottom: "concat_3_9"\n\
  bottom: "conv3_10/x2"\n\
  top: "concat_3_10"\n\
}\n\
layer {\n\
  name: "conv3_11/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_3_10"\n\
  top: "conv3_11/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_11/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_11/x1/bn"\n\
  top: "conv3_11/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_11/x1"\n\
  type: "ReLU"\n\
  bottom: "conv3_11/x1/bn"\n\
  top: "conv3_11/x1/bn"\n\
}\n\
layer {\n\
  name: "conv3_11/x1"\n\
  type: "Convolution"\n\
  bottom: "conv3_11/x1/bn"\n\
  top: "conv3_11/x1"\n\
  convolution_param {\n\
    num_output: 128\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_11/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv3_11/x1"\n\
  top: "conv3_11/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_11/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_11/x2/bn"\n\
  top: "conv3_11/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_11/x2"\n\
  type: "ReLU"\n\
  bottom: "conv3_11/x2/bn"\n\
  top: "conv3_11/x2/bn"\n\
}\n\
layer {\n\
  name: "conv3_11/x2"\n\
  type: "Convolution"\n\
  bottom: "conv3_11/x2/bn"\n\
  top: "conv3_11/x2"\n\
  convolution_param {\n\
    num_output: 32\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_3_11"\n\
  type: "Concat"\n\
  bottom: "concat_3_10"\n\
  bottom: "conv3_11/x2"\n\
  top: "concat_3_11"\n\
}\n\
layer {\n\
  name: "conv3_12/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_3_11"\n\
  top: "conv3_12/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_12/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_12/x1/bn"\n\
  top: "conv3_12/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_12/x1"\n\
  type: "ReLU"\n\
  bottom: "conv3_12/x1/bn"\n\
  top: "conv3_12/x1/bn"\n\
}\n\
layer {\n\
  name: "conv3_12/x1"\n\
  type: "Convolution"\n\
  bottom: "conv3_12/x1/bn"\n\
  top: "conv3_12/x1"\n\
  convolution_param {\n\
    num_output: 128\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_12/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv3_12/x1"\n\
  top: "conv3_12/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_12/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_12/x2/bn"\n\
  top: "conv3_12/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_12/x2"\n\
  type: "ReLU"\n\
  bottom: "conv3_12/x2/bn"\n\
  top: "conv3_12/x2/bn"\n\
}\n\
layer {\n\
  name: "conv3_12/x2"\n\
  type: "Convolution"\n\
  bottom: "conv3_12/x2/bn"\n\
  top: "conv3_12/x2"\n\
  convolution_param {\n\
    num_output: 32\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_3_12"\n\
  type: "Concat"\n\
  bottom: "concat_3_11"\n\
  bottom: "conv3_12/x2"\n\
  top: "concat_3_12"\n\
}\n\
layer {\n\
  name: "conv3_blk/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_3_12"\n\
  top: "conv3_blk/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_blk/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_blk/bn"\n\
  top: "conv3_blk/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_blk"\n\
  type: "ReLU"\n\
  bottom: "conv3_blk/bn"\n\
  top: "conv3_blk/bn"\n\
}\n\
layer {\n\
  name: "conv3_blk"\n\
  type: "Convolution"\n\
  bottom: "conv3_blk/bn"\n\
  top: "conv3_blk"\n\
  convolution_param {\n\
    num_output: 256\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n'
    return string


































def getDenseNet169Init():
    string = '\
\n'
    return string



































def getDenseNet201Init():
    string = '\
\n'
    return string



































def getDenseNet161v2Init():
    string = '\
layer {\n\
  name: "conv1"\n\
  type: "Convolution"\n\
  bottom: "image"\n\
  top: "conv1"\n\
  convolution_param {\n\
    num_output: 96\n\
    bias_term: false\n\
    pad: 3\n\
    kernel_size: 7\n\
    stride: 2\n\
  }\n\
}\n\
layer {\n\
  name: "conv1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv1"\n\
  top: "conv1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv1/scale"\n\
  type: "Scale"\n\
  bottom: "conv1/bn"\n\
  top: "conv1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu1"\n\
  type: "ReLU"\n\
  bottom: "conv1/bn"\n\
  top: "conv1/bn"\n\
}\n\
layer {\n\
  name: "pool1"\n\
  type: "Pooling"\n\
  bottom: "conv1/bn"\n\
  top: "pool1"\n\
  pooling_param {\n\
    pool: MAX\n\
    kernel_size: 3\n\
    stride: 2\n\
    pad: 1\n\
    # ceil_mode: false\n\
    round_mode: FLOOR\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_1/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "pool1"\n\
  top: "conv2_1/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_1/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv2_1/x1/bn"\n\
  top: "conv2_1/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu2_1/x1"\n\
  type: "ReLU"\n\
  bottom: "conv2_1/x1/bn"\n\
  top: "conv2_1/x1/bn"\n\
}\n\
layer {\n\
  name: "conv2_1/x1"\n\
  type: "Convolution"\n\
  bottom: "conv2_1/x1/bn"\n\
  top: "conv2_1/x1"\n\
  convolution_param {\n\
    num_output: 192\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_1/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv2_1/x1"\n\
  top: "conv2_1/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_1/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv2_1/x2/bn"\n\
  top: "conv2_1/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu2_1/x2"\n\
  type: "ReLU"\n\
  bottom: "conv2_1/x2/bn"\n\
  top: "conv2_1/x2/bn"\n\
}\n\
layer {\n\
  name: "conv2_1/x2"\n\
  type: "Convolution"\n\
  bottom: "conv2_1/x2/bn"\n\
  top: "conv2_1/x2"\n\
  convolution_param {\n\
    num_output: 48\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_2_1"\n\
  type: "Concat"\n\
  bottom: "pool1"\n\
  bottom: "conv2_1/x2"\n\
  top: "concat_2_1"\n\
}\n\
layer {\n\
  name: "conv2_2/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_2_1"\n\
  top: "conv2_2/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_2/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv2_2/x1/bn"\n\
  top: "conv2_2/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu2_2/x1"\n\
  type: "ReLU"\n\
  bottom: "conv2_2/x1/bn"\n\
  top: "conv2_2/x1/bn"\n\
}\n\
layer {\n\
  name: "conv2_2/x1"\n\
  type: "Convolution"\n\
  bottom: "conv2_2/x1/bn"\n\
  top: "conv2_2/x1"\n\
  convolution_param {\n\
    num_output: 192\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_2/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv2_2/x1"\n\
  top: "conv2_2/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_2/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv2_2/x2/bn"\n\
  top: "conv2_2/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu2_2/x2"\n\
  type: "ReLU"\n\
  bottom: "conv2_2/x2/bn"\n\
  top: "conv2_2/x2/bn"\n\
}\n\
layer {\n\
  name: "conv2_2/x2"\n\
  type: "Convolution"\n\
  bottom: "conv2_2/x2/bn"\n\
  top: "conv2_2/x2"\n\
  convolution_param {\n\
    num_output: 48\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_2_2"\n\
  type: "Concat"\n\
  bottom: "concat_2_1"\n\
  bottom: "conv2_2/x2"\n\
  top: "concat_2_2"\n\
}\n\
layer {\n\
  name: "conv2_3/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_2_2"\n\
  top: "conv2_3/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_3/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv2_3/x1/bn"\n\
  top: "conv2_3/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu2_3/x1"\n\
  type: "ReLU"\n\
  bottom: "conv2_3/x1/bn"\n\
  top: "conv2_3/x1/bn"\n\
}\n\
layer {\n\
  name: "conv2_3/x1"\n\
  type: "Convolution"\n\
  bottom: "conv2_3/x1/bn"\n\
  top: "conv2_3/x1"\n\
  convolution_param {\n\
    num_output: 192\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_3/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv2_3/x1"\n\
  top: "conv2_3/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_3/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv2_3/x2/bn"\n\
  top: "conv2_3/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu2_3/x2"\n\
  type: "ReLU"\n\
  bottom: "conv2_3/x2/bn"\n\
  top: "conv2_3/x2/bn"\n\
}\n\
layer {\n\
  name: "conv2_3/x2"\n\
  type: "Convolution"\n\
  bottom: "conv2_3/x2/bn"\n\
  top: "conv2_3/x2"\n\
  convolution_param {\n\
    num_output: 48\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_2_3"\n\
  type: "Concat"\n\
  bottom: "concat_2_2"\n\
  bottom: "conv2_3/x2"\n\
  top: "concat_2_3"\n\
}\n\
layer {\n\
  name: "conv2_4/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_2_3"\n\
  top: "conv2_4/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_4/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv2_4/x1/bn"\n\
  top: "conv2_4/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu2_4/x1"\n\
  type: "ReLU"\n\
  bottom: "conv2_4/x1/bn"\n\
  top: "conv2_4/x1/bn"\n\
}\n\
layer {\n\
  name: "conv2_4/x1"\n\
  type: "Convolution"\n\
  bottom: "conv2_4/x1/bn"\n\
  top: "conv2_4/x1"\n\
  convolution_param {\n\
    num_output: 192\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_4/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv2_4/x1"\n\
  top: "conv2_4/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_4/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv2_4/x2/bn"\n\
  top: "conv2_4/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu2_4/x2"\n\
  type: "ReLU"\n\
  bottom: "conv2_4/x2/bn"\n\
  top: "conv2_4/x2/bn"\n\
}\n\
layer {\n\
  name: "conv2_4/x2"\n\
  type: "Convolution"\n\
  bottom: "conv2_4/x2/bn"\n\
  top: "conv2_4/x2"\n\
  convolution_param {\n\
    num_output: 48\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_2_4"\n\
  type: "Concat"\n\
  bottom: "concat_2_3"\n\
  bottom: "conv2_4/x2"\n\
  top: "concat_2_4"\n\
}\n\
layer {\n\
  name: "conv2_5/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_2_4"\n\
  top: "conv2_5/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_5/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv2_5/x1/bn"\n\
  top: "conv2_5/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu2_5/x1"\n\
  type: "ReLU"\n\
  bottom: "conv2_5/x1/bn"\n\
  top: "conv2_5/x1/bn"\n\
}\n\
layer {\n\
  name: "conv2_5/x1"\n\
  type: "Convolution"\n\
  bottom: "conv2_5/x1/bn"\n\
  top: "conv2_5/x1"\n\
  convolution_param {\n\
    num_output: 192\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_5/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv2_5/x1"\n\
  top: "conv2_5/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_5/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv2_5/x2/bn"\n\
  top: "conv2_5/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu2_5/x2"\n\
  type: "ReLU"\n\
  bottom: "conv2_5/x2/bn"\n\
  top: "conv2_5/x2/bn"\n\
}\n\
layer {\n\
  name: "conv2_5/x2"\n\
  type: "Convolution"\n\
  bottom: "conv2_5/x2/bn"\n\
  top: "conv2_5/x2"\n\
  convolution_param {\n\
    num_output: 48\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_2_5"\n\
  type: "Concat"\n\
  bottom: "concat_2_4"\n\
  bottom: "conv2_5/x2"\n\
  top: "concat_2_5"\n\
}\n\
layer {\n\
  name: "conv2_6/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_2_5"\n\
  top: "conv2_6/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_6/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv2_6/x1/bn"\n\
  top: "conv2_6/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu2_6/x1"\n\
  type: "ReLU"\n\
  bottom: "conv2_6/x1/bn"\n\
  top: "conv2_6/x1/bn"\n\
}\n\
layer {\n\
  name: "conv2_6/x1"\n\
  type: "Convolution"\n\
  bottom: "conv2_6/x1/bn"\n\
  top: "conv2_6/x1"\n\
  convolution_param {\n\
    num_output: 192\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_6/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv2_6/x1"\n\
  top: "conv2_6/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_6/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv2_6/x2/bn"\n\
  top: "conv2_6/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu2_6/x2"\n\
  type: "ReLU"\n\
  bottom: "conv2_6/x2/bn"\n\
  top: "conv2_6/x2/bn"\n\
}\n\
layer {\n\
  name: "conv2_6/x2"\n\
  type: "Convolution"\n\
  bottom: "conv2_6/x2/bn"\n\
  top: "conv2_6/x2"\n\
  convolution_param {\n\
    num_output: 48\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_2_6"\n\
  type: "Concat"\n\
  bottom: "concat_2_5"\n\
  bottom: "conv2_6/x2"\n\
  top: "concat_2_6"\n\
}\n\
layer {\n\
  name: "conv2_blk/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_2_6"\n\
  top: "conv2_blk/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv2_blk/scale"\n\
  type: "Scale"\n\
  bottom: "conv2_blk/bn"\n\
  top: "conv2_blk/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu2_blk"\n\
  type: "ReLU"\n\
  bottom: "conv2_blk/bn"\n\
  top: "conv2_blk/bn"\n\
}\n\
layer {\n\
  name: "conv2_blk"\n\
  type: "Convolution"\n\
  bottom: "conv2_blk/bn"\n\
  top: "conv2_blk"\n\
  convolution_param {\n\
    num_output: 192\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "pool2"\n\
  type: "Pooling"\n\
  bottom: "conv2_blk"\n\
  top: "pool2"\n\
  pooling_param {\n\
    pool: AVE\n\
    kernel_size: 2\n\
    stride: 2\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_1/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "pool2"\n\
  top: "conv3_1/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_1/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_1/x1/bn"\n\
  top: "conv3_1/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_1/x1"\n\
  type: "ReLU"\n\
  bottom: "conv3_1/x1/bn"\n\
  top: "conv3_1/x1/bn"\n\
}\n\
layer {\n\
  name: "conv3_1/x1"\n\
  type: "Convolution"\n\
  bottom: "conv3_1/x1/bn"\n\
  top: "conv3_1/x1"\n\
  convolution_param {\n\
    num_output: 192\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_1/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv3_1/x1"\n\
  top: "conv3_1/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_1/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_1/x2/bn"\n\
  top: "conv3_1/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_1/x2"\n\
  type: "ReLU"\n\
  bottom: "conv3_1/x2/bn"\n\
  top: "conv3_1/x2/bn"\n\
}\n\
layer {\n\
  name: "conv3_1/x2"\n\
  type: "Convolution"\n\
  bottom: "conv3_1/x2/bn"\n\
  top: "conv3_1/x2"\n\
  convolution_param {\n\
    num_output: 48\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_3_1"\n\
  type: "Concat"\n\
  bottom: "pool2"\n\
  bottom: "conv3_1/x2"\n\
  top: "concat_3_1"\n\
}\n\
layer {\n\
  name: "conv3_2/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_3_1"\n\
  top: "conv3_2/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_2/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_2/x1/bn"\n\
  top: "conv3_2/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_2/x1"\n\
  type: "ReLU"\n\
  bottom: "conv3_2/x1/bn"\n\
  top: "conv3_2/x1/bn"\n\
}\n\
layer {\n\
  name: "conv3_2/x1"\n\
  type: "Convolution"\n\
  bottom: "conv3_2/x1/bn"\n\
  top: "conv3_2/x1"\n\
  convolution_param {\n\
    num_output: 192\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_2/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv3_2/x1"\n\
  top: "conv3_2/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_2/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_2/x2/bn"\n\
  top: "conv3_2/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_2/x2"\n\
  type: "ReLU"\n\
  bottom: "conv3_2/x2/bn"\n\
  top: "conv3_2/x2/bn"\n\
}\n\
layer {\n\
  name: "conv3_2/x2"\n\
  type: "Convolution"\n\
  bottom: "conv3_2/x2/bn"\n\
  top: "conv3_2/x2"\n\
  convolution_param {\n\
    num_output: 48\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_3_2"\n\
  type: "Concat"\n\
  bottom: "concat_3_1"\n\
  bottom: "conv3_2/x2"\n\
  top: "concat_3_2"\n\
}\n\
layer {\n\
  name: "conv3_3/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_3_2"\n\
  top: "conv3_3/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_3/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_3/x1/bn"\n\
  top: "conv3_3/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_3/x1"\n\
  type: "ReLU"\n\
  bottom: "conv3_3/x1/bn"\n\
  top: "conv3_3/x1/bn"\n\
}\n\
layer {\n\
  name: "conv3_3/x1"\n\
  type: "Convolution"\n\
  bottom: "conv3_3/x1/bn"\n\
  top: "conv3_3/x1"\n\
  convolution_param {\n\
    num_output: 192\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_3/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv3_3/x1"\n\
  top: "conv3_3/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_3/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_3/x2/bn"\n\
  top: "conv3_3/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_3/x2"\n\
  type: "ReLU"\n\
  bottom: "conv3_3/x2/bn"\n\
  top: "conv3_3/x2/bn"\n\
}\n\
layer {\n\
  name: "conv3_3/x2"\n\
  type: "Convolution"\n\
  bottom: "conv3_3/x2/bn"\n\
  top: "conv3_3/x2"\n\
  convolution_param {\n\
    num_output: 48\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_3_3"\n\
  type: "Concat"\n\
  bottom: "concat_3_2"\n\
  bottom: "conv3_3/x2"\n\
  top: "concat_3_3"\n\
}\n\
layer {\n\
  name: "conv3_4/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_3_3"\n\
  top: "conv3_4/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_4/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_4/x1/bn"\n\
  top: "conv3_4/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_4/x1"\n\
  type: "ReLU"\n\
  bottom: "conv3_4/x1/bn"\n\
  top: "conv3_4/x1/bn"\n\
}\n\
layer {\n\
  name: "conv3_4/x1"\n\
  type: "Convolution"\n\
  bottom: "conv3_4/x1/bn"\n\
  top: "conv3_4/x1"\n\
  convolution_param {\n\
    num_output: 192\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_4/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv3_4/x1"\n\
  top: "conv3_4/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_4/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_4/x2/bn"\n\
  top: "conv3_4/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_4/x2"\n\
  type: "ReLU"\n\
  bottom: "conv3_4/x2/bn"\n\
  top: "conv3_4/x2/bn"\n\
}\n\
layer {\n\
  name: "conv3_4/x2"\n\
  type: "Convolution"\n\
  bottom: "conv3_4/x2/bn"\n\
  top: "conv3_4/x2"\n\
  convolution_param {\n\
    num_output: 48\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_3_4"\n\
  type: "Concat"\n\
  bottom: "concat_3_3"\n\
  bottom: "conv3_4/x2"\n\
  top: "concat_3_4"\n\
}\n\
layer {\n\
  name: "conv3_5/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_3_4"\n\
  top: "conv3_5/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_5/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_5/x1/bn"\n\
  top: "conv3_5/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_5/x1"\n\
  type: "ReLU"\n\
  bottom: "conv3_5/x1/bn"\n\
  top: "conv3_5/x1/bn"\n\
}\n\
layer {\n\
  name: "conv3_5/x1"\n\
  type: "Convolution"\n\
  bottom: "conv3_5/x1/bn"\n\
  top: "conv3_5/x1"\n\
  convolution_param {\n\
    num_output: 192\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_5/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv3_5/x1"\n\
  top: "conv3_5/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_5/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_5/x2/bn"\n\
  top: "conv3_5/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_5/x2"\n\
  type: "ReLU"\n\
  bottom: "conv3_5/x2/bn"\n\
  top: "conv3_5/x2/bn"\n\
}\n\
layer {\n\
  name: "conv3_5/x2"\n\
  type: "Convolution"\n\
  bottom: "conv3_5/x2/bn"\n\
  top: "conv3_5/x2"\n\
  convolution_param {\n\
    num_output: 48\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_3_5"\n\
  type: "Concat"\n\
  bottom: "concat_3_4"\n\
  bottom: "conv3_5/x2"\n\
  top: "concat_3_5"\n\
}\n\
layer {\n\
  name: "conv3_6/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_3_5"\n\
  top: "conv3_6/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_6/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_6/x1/bn"\n\
  top: "conv3_6/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_6/x1"\n\
  type: "ReLU"\n\
  bottom: "conv3_6/x1/bn"\n\
  top: "conv3_6/x1/bn"\n\
}\n\
layer {\n\
  name: "conv3_6/x1"\n\
  type: "Convolution"\n\
  bottom: "conv3_6/x1/bn"\n\
  top: "conv3_6/x1"\n\
  convolution_param {\n\
    num_output: 192\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_6/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv3_6/x1"\n\
  top: "conv3_6/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_6/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_6/x2/bn"\n\
  top: "conv3_6/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_6/x2"\n\
  type: "ReLU"\n\
  bottom: "conv3_6/x2/bn"\n\
  top: "conv3_6/x2/bn"\n\
}\n\
layer {\n\
  name: "conv3_6/x2"\n\
  type: "Convolution"\n\
  bottom: "conv3_6/x2/bn"\n\
  top: "conv3_6/x2"\n\
  convolution_param {\n\
    num_output: 48\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_3_6"\n\
  type: "Concat"\n\
  bottom: "concat_3_5"\n\
  bottom: "conv3_6/x2"\n\
  top: "concat_3_6"\n\
}\n\
layer {\n\
  name: "conv3_7/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_3_6"\n\
  top: "conv3_7/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_7/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_7/x1/bn"\n\
  top: "conv3_7/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_7/x1"\n\
  type: "ReLU"\n\
  bottom: "conv3_7/x1/bn"\n\
  top: "conv3_7/x1/bn"\n\
}\n\
layer {\n\
  name: "conv3_7/x1"\n\
  type: "Convolution"\n\
  bottom: "conv3_7/x1/bn"\n\
  top: "conv3_7/x1"\n\
  convolution_param {\n\
    num_output: 192\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_7/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv3_7/x1"\n\
  top: "conv3_7/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_7/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_7/x2/bn"\n\
  top: "conv3_7/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_7/x2"\n\
  type: "ReLU"\n\
  bottom: "conv3_7/x2/bn"\n\
  top: "conv3_7/x2/bn"\n\
}\n\
layer {\n\
  name: "conv3_7/x2"\n\
  type: "Convolution"\n\
  bottom: "conv3_7/x2/bn"\n\
  top: "conv3_7/x2"\n\
  convolution_param {\n\
    num_output: 48\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_3_7"\n\
  type: "Concat"\n\
  bottom: "concat_3_6"\n\
  bottom: "conv3_7/x2"\n\
  top: "concat_3_7"\n\
}\n\
layer {\n\
  name: "conv3_8/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_3_7"\n\
  top: "conv3_8/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_8/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_8/x1/bn"\n\
  top: "conv3_8/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_8/x1"\n\
  type: "ReLU"\n\
  bottom: "conv3_8/x1/bn"\n\
  top: "conv3_8/x1/bn"\n\
}\n\
layer {\n\
  name: "conv3_8/x1"\n\
  type: "Convolution"\n\
  bottom: "conv3_8/x1/bn"\n\
  top: "conv3_8/x1"\n\
  convolution_param {\n\
    num_output: 192\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_8/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv3_8/x1"\n\
  top: "conv3_8/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_8/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_8/x2/bn"\n\
  top: "conv3_8/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_8/x2"\n\
  type: "ReLU"\n\
  bottom: "conv3_8/x2/bn"\n\
  top: "conv3_8/x2/bn"\n\
}\n\
layer {\n\
  name: "conv3_8/x2"\n\
  type: "Convolution"\n\
  bottom: "conv3_8/x2/bn"\n\
  top: "conv3_8/x2"\n\
  convolution_param {\n\
    num_output: 48\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_3_8"\n\
  type: "Concat"\n\
  bottom: "concat_3_7"\n\
  bottom: "conv3_8/x2"\n\
  top: "concat_3_8"\n\
}\n\
layer {\n\
  name: "conv3_9/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_3_8"\n\
  top: "conv3_9/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_9/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_9/x1/bn"\n\
  top: "conv3_9/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_9/x1"\n\
  type: "ReLU"\n\
  bottom: "conv3_9/x1/bn"\n\
  top: "conv3_9/x1/bn"\n\
}\n\
layer {\n\
  name: "conv3_9/x1"\n\
  type: "Convolution"\n\
  bottom: "conv3_9/x1/bn"\n\
  top: "conv3_9/x1"\n\
  convolution_param {\n\
    num_output: 192\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_9/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv3_9/x1"\n\
  top: "conv3_9/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_9/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_9/x2/bn"\n\
  top: "conv3_9/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_9/x2"\n\
  type: "ReLU"\n\
  bottom: "conv3_9/x2/bn"\n\
  top: "conv3_9/x2/bn"\n\
}\n\
layer {\n\
  name: "conv3_9/x2"\n\
  type: "Convolution"\n\
  bottom: "conv3_9/x2/bn"\n\
  top: "conv3_9/x2"\n\
  convolution_param {\n\
    num_output: 48\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_3_9"\n\
  type: "Concat"\n\
  bottom: "concat_3_8"\n\
  bottom: "conv3_9/x2"\n\
  top: "concat_3_9"\n\
}\n\
layer {\n\
  name: "conv3_10/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_3_9"\n\
  top: "conv3_10/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_10/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_10/x1/bn"\n\
  top: "conv3_10/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_10/x1"\n\
  type: "ReLU"\n\
  bottom: "conv3_10/x1/bn"\n\
  top: "conv3_10/x1/bn"\n\
}\n\
layer {\n\
  name: "conv3_10/x1"\n\
  type: "Convolution"\n\
  bottom: "conv3_10/x1/bn"\n\
  top: "conv3_10/x1"\n\
  convolution_param {\n\
    num_output: 192\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_10/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv3_10/x1"\n\
  top: "conv3_10/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_10/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_10/x2/bn"\n\
  top: "conv3_10/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_10/x2"\n\
  type: "ReLU"\n\
  bottom: "conv3_10/x2/bn"\n\
  top: "conv3_10/x2/bn"\n\
}\n\
layer {\n\
  name: "conv3_10/x2"\n\
  type: "Convolution"\n\
  bottom: "conv3_10/x2/bn"\n\
  top: "conv3_10/x2"\n\
  convolution_param {\n\
    num_output: 48\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_3_10"\n\
  type: "Concat"\n\
  bottom: "concat_3_9"\n\
  bottom: "conv3_10/x2"\n\
  top: "concat_3_10"\n\
}\n\
layer {\n\
  name: "conv3_11/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_3_10"\n\
  top: "conv3_11/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_11/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_11/x1/bn"\n\
  top: "conv3_11/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_11/x1"\n\
  type: "ReLU"\n\
  bottom: "conv3_11/x1/bn"\n\
  top: "conv3_11/x1/bn"\n\
}\n\
layer {\n\
  name: "conv3_11/x1"\n\
  type: "Convolution"\n\
  bottom: "conv3_11/x1/bn"\n\
  top: "conv3_11/x1"\n\
  convolution_param {\n\
    num_output: 192\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_11/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv3_11/x1"\n\
  top: "conv3_11/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_11/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_11/x2/bn"\n\
  top: "conv3_11/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_11/x2"\n\
  type: "ReLU"\n\
  bottom: "conv3_11/x2/bn"\n\
  top: "conv3_11/x2/bn"\n\
}\n\
layer {\n\
  name: "conv3_11/x2"\n\
  type: "Convolution"\n\
  bottom: "conv3_11/x2/bn"\n\
  top: "conv3_11/x2"\n\
  convolution_param {\n\
    num_output: 48\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_3_11"\n\
  type: "Concat"\n\
  bottom: "concat_3_10"\n\
  bottom: "conv3_11/x2"\n\
  top: "concat_3_11"\n\
}\n\
layer {\n\
  name: "conv3_12/x1/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_3_11"\n\
  top: "conv3_12/x1/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_12/x1/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_12/x1/bn"\n\
  top: "conv3_12/x1/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_12/x1"\n\
  type: "ReLU"\n\
  bottom: "conv3_12/x1/bn"\n\
  top: "conv3_12/x1/bn"\n\
}\n\
layer {\n\
  name: "conv3_12/x1"\n\
  type: "Convolution"\n\
  bottom: "conv3_12/x1/bn"\n\
  top: "conv3_12/x1"\n\
  convolution_param {\n\
    num_output: 192\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_12/x2/bn"\n\
  type: "BatchNorm"\n\
  bottom: "conv3_12/x1"\n\
  top: "conv3_12/x2/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_12/x2/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_12/x2/bn"\n\
  top: "conv3_12/x2/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_12/x2"\n\
  type: "ReLU"\n\
  bottom: "conv3_12/x2/bn"\n\
  top: "conv3_12/x2/bn"\n\
}\n\
layer {\n\
  name: "conv3_12/x2"\n\
  type: "Convolution"\n\
  bottom: "conv3_12/x2/bn"\n\
  top: "conv3_12/x2"\n\
  convolution_param {\n\
    num_output: 48\n\
    bias_term: false\n\
    pad: 1\n\
    kernel_size: 3\n\
  }\n\
}\n\
layer {\n\
  name: "concat_3_12"\n\
  type: "Concat"\n\
  bottom: "concat_3_11"\n\
  bottom: "conv3_12/x2"\n\
  top: "concat_3_12"\n\
}\n\
layer {\n\
  name: "conv3_blk/bn"\n\
  type: "BatchNorm"\n\
  bottom: "concat_3_12"\n\
  top: "conv3_blk/bn"\n\
  batch_norm_param {\n\
    eps: 1e-5\n\
  }\n\
}\n\
layer {\n\
  name: "conv3_blk/scale"\n\
  type: "Scale"\n\
  bottom: "conv3_blk/bn"\n\
  top: "conv3_blk/bn"\n\
  scale_param {\n\
    bias_term: true\n\
  }\n\
}\n\
layer {\n\
  name: "relu3_blk"\n\
  type: "ReLU"\n\
  bottom: "conv3_blk/bn"\n\
  top: "conv3_blk/bn"\n\
}\n\
layer {\n\
  name: "conv3_blk"\n\
  type: "Convolution"\n\
  bottom: "conv3_blk/bn"\n\
  top: "conv3_blk"\n\
  convolution_param {\n\
    num_output: 384\n\
    bias_term: false\n\
    kernel_size: 1\n\
  }\n\
}\n'
    return string

