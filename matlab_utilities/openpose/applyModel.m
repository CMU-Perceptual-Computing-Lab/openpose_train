function heatMaps = applyModel(image, param, net)
    %% Search thourgh a range of scales and average results

    %% Parameters - model + boxsize
    model = param.model;
    boxsize = model.boxsize;

    % set the center and roughly scale range (overwrite the config!) according to the rectangle
    % use given scale
    scaleImage = param.model.boxsize / size(image, 1);
    scaleRatios = param.scale_search * scaleImage;
    assert(numel(param.scale_search) > 0, 'numel(param.scale_search) > 0');
    numberScales = length(scaleRatios);

    %% heatMapsPerScale{s} = heatMaps for specific scale s
    padding = cell(numberScales, 1);
    heatMapsPerScale = cell(numberScales, 1);
    for s = 1:length(scaleRatios)
        scale = scaleRatios(s);
        imageForNet = imresize(image, scale); % Resize worse (no smooth borders)
        % Estimate bounding box
        bbox = [boxsize, max(size(imageForNet, 2), boxsize)];
        % Alternative: if scale < 1 no resized to net size, but 0.2mAP worse
        % boxsizeHeight = min(boxsize, 8*round(imagesSizes{s}(1)/8));
        % boxsizeWidth = min(boxsize, 8*round(imagesSizes{s}(2)/8));
        % bbox = [boxsizeHeight, max(imagesSizes{s}(2), boxsizeWidth)];
        % Pad image
        [imageForNet, padding{s}] = padImage(imageForNet, model.padValue, bbox);
        % [0, 255] to [-0.5, 0.5]
        imageForNet = double(imageForNet)/256 - 0.5;
        % [x,y] to [y,x]
        imageForNet = permute(imageForNet, [2 1 3]);
        % Grey to RGB
        if size(imageForNet,3) == 1
            imageForNet = repmat(imageForNet, 1,1,3);
        end
        % RGB to BGR
        imageForNet = imageForNet(:,:,[3 2 1]); % BGR for OpenCV (used in Caffe net)
        % Security checks
        assert(numel(imageForNet) < 11184000, 'Image too big: numel(imageForNet) > 11184000');
        % Apply deep net
        net.blob_vec(1).reshape([size(imageForNet) 1])
        net.reshape()
        heatMapsPerScale{s} = applyNet(imageForNet, net);
        % Resize back heatMaps
        netDecreaseFactor = size(imageForNet,1) / size(heatMapsPerScale{s},1); % 8
        heatMapsPerScale{s} = resize(heatMapsPerScale{s}, netDecreaseFactor);
        heatMapsPerScale{s} = unpadImage(heatMapsPerScale{s}, padding{s});
        heatMapsPerScale{s} = imresize(heatMapsPerScale{s}, [size(image,2) size(image,1)]);
    end

    %% heatMaps = mean heatMapsPerScale per scale
    heatMaps = heatMapsPerScale{1};
    for s = 2:numel(heatMapsPerScale)
        heatMaps = heatMaps + heatMapsPerScale{s};
    end
    heatMaps = permute(heatMaps, [2 1 3]) / numel(heatMapsPerScale);
end

function imageOutput = resize(imageInput, scaleX, scaleY)
    % Better than imresize because we are not crating abrupt edges in the
    % sides of the image
    % Initialize scaleX, scaleY
    if ~exist('scaleY', 'var')
        if numel(scaleX) == 1
            scaleY = scaleX;
        else
            scaleY = scaleX(2);
            scaleX = scaleX(1);
        end
    end
    affineMatrix = affine2d([scaleX 0 0; 0 scaleY 0; 0 0 1]);
    imageOutput = imwarp(imageInput, affineMatrix, 'Interp', 'cubic', 'FillValues', 0);
end

function heatMaps = applyNet(images, net)
    inputData = {single(images)};
    % do forward pass to get scores
    % scores are now Width x Height x Channels x Num
    heatMaps = net.forward(inputData);
    heatMaps = cat(3, heatMaps{2}(:,:,1:end-1), heatMaps{1});
end

function [imagePadded, pad] = padImage(image, padValue, bbox)
    h = size(image, 1);
    h = min(bbox(1), h);
    w = size(image, 2);
    bbox(1) = ceil(bbox(1)/8)*8;
    bbox(2) = max(bbox(2), w);
    bbox(2) = ceil(bbox(2)/8)*8;
    pad(1) = 0;
    pad(2) = 0;
    pad(3) = bbox(1)-h;
    pad(4) = bbox(2)-w;

    imagePadded = image;
    padDown = repmat(imagePadded(end,:,:), [pad(3) 1 1])*0 + padValue;
    imagePadded = [imagePadded; padDown];
    padRight = repmat(imagePadded(:,end,:), [1 pad(4) 1])*0 + padValue;
    imagePadded = [imagePadded, padRight];
end

function heatMaps = unpadImage(heatMaps, pad)
    numberPoints = size(heatMaps,3)-1;
    heatMaps = permute(heatMaps, [2 1 3]);
    if pad(1) < 0
        padup = cat(3, zeros(-pad(1), size(heatMaps,2), numberPoints), ones(-pad(1), size(heatMaps,2), 1));
        heatMaps = [padup; heatMaps]; % pad up
    elseif pad(1) > 0
        heatMaps(1:pad(1),:,:) = []; % crop up
    end

    if pad(2) < 0
        padleft = cat(3, zeros(size(heatMaps,1), -pad(2), numberPoints), ones(size(heatMaps,1), -pad(2), 1));
        heatMaps = [padleft heatMaps]; % pad left
    elseif pad(2) > 0
        heatMaps(:,1:pad(2),:) = []; % crop left
    end

    if pad(3) < 0
        paddown = cat(3, zeros(-pad(3), size(heatMaps,2), numberPoints), ones(-pad(3), size(heatMaps,2), 1));
        heatMaps = [heatMaps; paddown]; % pad down
    elseif pad(3) > 0
        heatMaps(end-pad(3)+1:end, :, :) = []; % crop down
    end

    if pad(4) < 0
        padright = cat(3, zeros(size(heatMaps,1), -pad(4), numberPoints), ones(size(heatMaps,1), -pad(4), 1));
        heatMaps = [heatMaps padright]; % pad right
    elseif pad(4) > 0
        heatMaps(:,end-pad(4)+1:end, :) = []; % crop right
    end
    heatMaps = permute(heatMaps, [2 1 3]);
end
