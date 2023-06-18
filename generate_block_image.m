%% function generate_block_image
% generates a test image that is of a given size with N blocks with size
% specified by block_size array
%   inputs:
%       im_size = [dim1_size dim2_size] of overall image
%       block_size = N x 2 array; block_size(:,1) and block_size(:,2) are the block sizes of the two dimensions
%       block_loc = N x 2 array; block_loc(:,1) and block_loc(:,2) are the center indices of the blocks
%   outputs:
%       im = output image

function im = generate_block_image(im_size,block_size,block_loc)
    im = zeros(im_size);
    block_ind = zeros(size(block_size,1),4);
    block_ind(:,1) = block_loc(:,1)-floor(block_size(:,1)./2);
    block_ind(:,2) = block_ind(:,1)+block_size(:,1)-1;
    block_ind(:,3) = block_loc(:,2)-floor(block_size(:,2)./2);
    block_ind(:,4) = block_ind(:,3)+block_size(:,2)-1;

    for i = 1:size(block_size,1)
        im(block_ind(i,1):block_ind(i,2),block_ind(i,3):block_ind(i,4)) = 1;
    end
end