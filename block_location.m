function [blockLocation]=block_location(blockWidth,blockHeight)
for i= 1:blockWidth
    for j= 1:blockHeight
    blockLocation(i,j) = {[i,j]};
    end
end