% Main.m: Provides example code for performing adaptive complexity for
% Pixel-Value-Ordering method, as described in the paper: 

% Z. Pan, X. Gao, E. Gao and G. Fan, "Adaptive Complexity for 
% Pixel-Value-Ordering Based Reversible Data Hiding," IEEE Signal
% Processing Letters, vol. 27, pp. 915-919, 2020, doi:
% 10.1109/LSP.2020.2996507.  

% Author: X.Gao
% Date: 27 Jan. 2021

%% Load the cover image
image = imread('4.2.04.tiff');
coverImage = double(rgb2gray(image));
[A,B] = size(coverImage);

%% Location map
LM = zeros(1,512*512);
index = 0;
for i = 2:A-2
    for j = 2:B-2
        index = index+1;
        if coverImage(i,j) == 0
            coverImage(i,j) = 1;
            LM(index) = 1;
        else
            if coverImage(i,j) == 255
                coverImage(i,j) = 254;
                LM(index) = 1;
            end
        end
    end
end
xC = cell(1,1);
xC{1} = LM;
locationMap = arith07(xC);
mapLength=8*length(locationMap);

%% Secret data
X = randperm(512*512);
M = zeros(512,512);
for i = 1:512
    for j = 1:512
        M(i,j) = mod(X(512*(i-1)+j),2);
    end
end
secretData=M(:);

blockNum=0;
PSNR_buf=[];
for blockHeight= 2:5
    for blockWidth=2:5
        blockNum=blockNum+1;

        subImage={};
%% Divide the image into blocks
        maxWidthIndex=(floor(512/blockWidth)-1)*blockWidth+1;
        maxHeightIndex=(floor(512/blockHeight)-1)*blockHeight+1;
        subimageNum=0;
        for i=1:blockWidth:maxWidthIndex
            for  j=1:blockHeight:maxHeightIndex
                ii=ceil(i/blockWidth);
                jj=ceil(j/blockHeight);
                subImage(ii,jj) = { coverImage(i:i+blockWidth-1,j:j+blockHeight-1)};
            end
        end
        
        
%% Adaptive complexity
        % Reference image
        [referenceImage]=reference_image(subImage,coverImage);
        % Divide the reference image into blocks
        for i=1:blockWidth:maxWidthIndex
            for  j=1:blockHeight:maxHeightIndex
                ii=ceil(i/blockWidth);
                jj=ceil(j/blockHeight);
                if i==1|| j==1||i==maxWidthIndex||j==maxHeightIndex
                    referenceImageMAP(ii,jj) = { referenceImage(i:i+blockWidth-1,j:j+blockHeight-1)};
                else
                    referenceImageMAP(ii,jj) = { referenceImage(i-1:i+blockWidth,j-1:j+blockHeight)};
                end
                
            end
        end
        
        % Calculate the complexity by adaptive complexity method
        [predictionErrorSorted] = adaptive_complexity(subImage,referenceImageMAP);
        
        
%% Secret data embedding
        num=0;
        for EC=2000:1000:32000
            num=num+1;
            PSNRBuf(num,1)=EC;
            [PSNRBuf(num,blockNum+1)] = data_embedding(predictionErrorSorted,secretData,EC+mapLength);
        end
    end
end

%% Choose the best result
PSNR(:,1)=PSNRBuf(:,1);
[row,col]=size(PSNRBuf);
for i=1:row
    PSNR(i,2)=max(PSNRBuf(i,2:col));
end
