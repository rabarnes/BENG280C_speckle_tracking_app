close all force; clear; clc;

% %% Original image generation
% im_stack = [];
% % Image size
% im_size = [256 200];
% % Size of blocks
% block_size = [3 3];
% 
% block_loc1 = [127 127];
% block_loc2 = [50,50];
% for i = 1:12
%     im = generate_block_image(im_size,[block_size;block_size],[block_loc1;block_loc2]);
%     im_stack = cat(3,im_stack,im);
%     block_loc1 = block_loc1+[round(randi([-6,6])) round(randi([-6,6]))];
%     block_loc2 = block_loc2+[round(randi([-6,6])) round(randi([-6,6]))];
% end
% 
% gui = SptrackGUI("test",im_stack,[1 1]);

gui = PatientGUI("Patient 1");