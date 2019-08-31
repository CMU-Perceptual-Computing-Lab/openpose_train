function blendMask(image, mask, titleString)
    % Display image + mask
    addpath('../testing/util/'); % mat2im
    blendedImage = mat2im(mask, jet(100), [0 1]);
    blendedImage = (blendedImage + (single(image)/255)) / 2;
    imagesc(blendedImage),
    title(titleString)
end
