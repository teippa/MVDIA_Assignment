function C = grayThreshCrop(I)
% Function which returns a cropped image of the input image. Resulting
% image is grayscale and size of 227x227. 
% 
% This function can be used directly as an input to the transform function
% (to apply transformations on imagedatastore)

    newSize = [227 227];
    
    if (size(I, 3) > 1 )
        I = rgb2gray(I);
    end

    I = imresize(I, newSize);
    
    mask = createMask(I);
    
    C = cropToMask(I, mask);
    C = imresize(C, newSize);
end


function mask = createMask(I)

    % Detect the thresholding value. 100px removed from the top to try to
    % exclude the white scale information text from the thresholding 
    % calculations
    level = graythresh(I(100:end, :));
    
    % Binarizing the image according to the threshold value
    mask = ~imbinarize(I,level);

    % Removing stray pixels from the binarized mask image
    mask = imerode(mask, ones(2));
    
end

function C = cropToMask(I, mask)
    
    % Calculating "side profiles" of the mask
    a = sum(mask,1);
    b = sum(mask,2);
    
    padding = 20; % add some space around the detected plankton mask
    
    % Finding the corners of the crop area
    edges = [
        find(a, 1, "first") - padding % left
        find(a, 1, "last") + padding  % right
        find(b, 1, "first") - padding % top
        find(b, 1, "last") + padding  % bottom
        ];
    
    % The added padding may make cropping to exceed image borders, this
    % prevents that
    for i = 1:4
        if (edges(i) > size(I, 1))
            edges(i) = size(I, 1);
        elseif (edges(i) < 1)
            edges(i) = 1;
        end
    end
    
    C = I( ...
        edges(3) : edges(4), ...
        edges(1) : edges(2) ...
        );

end