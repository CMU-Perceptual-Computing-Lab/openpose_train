%% Visualize COFW_color

% Note: This dataset is not used (only 28 keypoints)

% load('/media/posefs3b/Users/gines/Datasets/face/tomas_ready/COFW_color/COFW_train_color.mat')
imageId = 1;

imshow(IsTr{imageId})
hold on

pts = phisTr(imageId,:)
pts = reshape(pts, [], 3);
pts = pts(:,1:2)


for i=1:size(pts,1)
    x = pts(i, 1)
    y = pts(i, 2)
    d = 3;
    r = 3;
    px = x-r;
    py = y-r;
    h = rectangle('Position',[px py d d],'Curvature',[1,1]);
    daspect([1,1,1])
end
