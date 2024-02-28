function img = mat2image(mat)
% Convert a matrix into an image, where
% X data is defined along V coordinate (columns) and
% Y data is defined along inverted U coordinate (rows)
%
%   ^ y             ^ i           | - - - - > v         
%   |               |             |                 
%   |               | - - > j     |               
%   | * *                         | * *
%   | *                           | *
%   | - - - - > x                 v  u
%
%  (x,y) -TRANSPOSE-> (i,j) -JFLIP-> (u,v)
%  (1,1)     -->      (1,1)   -->    (4,1)
%  (1,2)     -->      (2,1)   -->    (3,1)
%  (2,2)     -->      (2,2)   -->    (3,2)

img = flip(mat', 2);

img = flip(img, 1);

end