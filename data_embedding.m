function [PSNR] = data_embedding(predictionErrorSort,secretdata,EC)
[row]=size(predictionErrorSort);
ECnum=0;
distortion=0;
for i=1:row
    
    if predictionErrorSort(i)==-1 || predictionErrorSort(i)==1
        ECnum=ECnum+1;
        distortion=distortion+secretdata(ECnum);
    elseif predictionErrorSort(i)<-1 || predictionErrorSort(i)>1
        distortion=distortion+1;
    end
    if ECnum >= EC
        break;
    end
end
if ECnum < EC
      PSNR=-Inf;
else
  PSNR=10*log10(255^2/( ((distortion) /(512*512))));  
end
end
