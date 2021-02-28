function [refernceImage]=reference_image(subImage,coverImage)
% Make a reference image which marks predicted pixels by "Inf" and "-Inf"
[row,col]=size(subImage);
refernceImage=zeros(512,512);
for i=1:row
    for j=1:col
        coverBlock=subImage{i,j};
        [row0,col0]=size(coverBlock);
        orderImageblock=coverBlock(:);
        [~,blockNum]=size(orderImageblock');
        [b,c]=sort(orderImageblock');
        b(1)=-Inf; % Minimum predicted pixel is marked by -Inf
        b(blockNum)=Inf;% Maximum predicted pixel is marked by Inf
        for k=1:blockNum
            CorderImageblock(c(k))=b(k);
        end
        CorderImageblock=CorderImageblock';
        subImage1{i,j}=reshape(CorderImageblock,row0,col0); % Recover the block
    end
end

maxWidthIndex=(floor(512/row0)-1)*row0+1;
maxHeightIndex=(floor(512/col0)-1)*col0+1;
for i=1:row0:maxWidthIndex
    for  j=1:col0:maxHeightIndex
        ii=ceil(i/row0);
        jj=ceil(j/col0);
        refernceImage(i:i+row0-1,j:j+col0-1) = subImage1{ii,jj};
    end
end
row=maxWidthIndex+row0;
col=maxHeightIndex+col0;

refernceImage(row:512,:)=coverImage(row:512,:);
refernceImage(:,col:512)=coverImage(:,col:512);

