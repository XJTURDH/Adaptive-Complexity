function [predictionErrorSorted] = adaptive_complexity(subImage,referenceImageMAP)
%% Calculate the adaptive contextPixels
[row,col]=size(subImage);
[row0,col0]=size(subImage{1,1});
[blockLocation]=block_location(row0,col0);
contextPixels={};
num=0;
for i=1:row
    for j=1:col
        coverImage=subImage{i,j};
        orderImageblock=coverImage(:);
        [~,blockNum]=size(orderImageblock');
        [b,c]=sort(orderImageblock');
        
        orderBlockLocation=blockLocation(:);
        orderBlockLocation=orderBlockLocation';
%% Calculate the index of bounding box 
        [coordinate11,~]=min([orderBlockLocation{c(1,1)}(1),orderBlockLocation{c(1,2)}(1)]);
        [coordinate12,~]=max([orderBlockLocation{c(1,1)}(1),orderBlockLocation{c(1,2)}(1)]);
        [coordinate21,~]=min([orderBlockLocation{c(1,1)}(2),orderBlockLocation{c(1,2)}(2)]);
        [coordinate22,~]=max([orderBlockLocation{c(1,1)}(2),orderBlockLocation{c(1,2)}(2)]);
        
        [coordinate31,~]=min([orderBlockLocation{c(1,blockNum-1)}(1),orderBlockLocation{c(1,blockNum)}(1)]);
        [coordinate32,~]=max([orderBlockLocation{c(1,blockNum-1)}(1),orderBlockLocation{c(1,blockNum)}(1)]);
        [coordinate41,~]=min([orderBlockLocation{c(1,blockNum-1)}(2),orderBlockLocation{c(1,blockNum)}(2)]);
        [coordinate42,~]=max([orderBlockLocation{c(1,blockNum-1)}(2),orderBlockLocation{c(1,blockNum)}(2)]);
        
%% Mark the context pixels
        if i==1 || i==row || j==1 ||j==col
            % Process the pixels on the image edges
            map1=Inf*ones(row0,col0);
            map2=Inf*ones(row0,col0);
            for m=1:row0
                for n=1:col0
                    
                    if m<=coordinate11+1&& m>=coordinate11-1 && n<=coordinate21+1 && n>=coordinate21-1
                        map1(m,n)=1;
                    end
                    if m<=coordinate12+1&& m>=coordinate12-1 && n<=coordinate22+1 && n>=coordinate22-1
                        map1(m,n)=1;
                    end
                    if m<=coordinate12 && m>=coordinate11 && n<=coordinate22 && n>=coordinate21
                        map1(m,n)=1;
                    end
                    
                    %
                    if m<=coordinate31+1&& m>=coordinate31-1 && n<=coordinate41+1 && n>=coordinate41-1
                        map2(m,n)=1;
                    end
                    
                    if m<=coordinate32+1&& m>=coordinate32-1 && n<=coordinate42+1 && n>=coordinate42-1
                        map2(m,n)=1;
                    end
                    
                    if m<=coordinate32 && m>=coordinate31 && n<=coordinate42 && n>=coordinate41
                        map2(m,n)=1;
                    end
                end
            end
            
            complexity_area1=map1.*referenceImageMAP{i,j};
            complexity_area2=map2.*referenceImageMAP{i,j};
            
            num=num+1;
            predictionError(num)=b(1,1)-b(1,2);
            contextPixels{num}=complexity_area1(:)';
            num=num+1;
            predictionError(num)=b(1,blockNum)-b(1,blockNum-1);
            contextPixels{num}=complexity_area2(:)';
            
        else
           
            
            map1=Inf*ones(row0+2,col0+2);
            map2=Inf*ones(row0+2,col0+2);
            coordinate11=coordinate11+1;
            coordinate12=coordinate12+1;
            coordinate21=coordinate21+1;
            coordinate22=coordinate22+1;
            
            coordinate31=coordinate31+1;
            coordinate32=coordinate32+1;
            coordinate41=coordinate41+1;
            coordinate42=coordinate42+1;
            
            for m=1:row0+2
                for n=1:col0+2
                    if m<=coordinate11+1&& m>=coordinate11-1 && n<=coordinate21+1 && n>=coordinate21-1
                        map1(m,n)=1;
                    end
                    
                    if m<=coordinate12+1&& m>=coordinate12-1 && n<=coordinate22+1 && n>=coordinate22-1
                        map1(m,n)=1;
                    end
                    
                    if m<=coordinate12 && m>=coordinate11 && n<=coordinate22 && n>=coordinate21
                        map1(m,n)=1;
                    end
                    %%%%
                    if m<=coordinate31+1&& m>=coordinate31-1 && n<=coordinate41+1 && n>=coordinate41-1
                        map2(m,n)=1;
                    end
                    
                    if m<=coordinate32+1&& m>=coordinate32-1 && n<=coordinate42+1 && n>=coordinate42-1
                        map2(m,n)=1;
                    end
                    
                    if m<=coordinate32 && m>=coordinate31 && n<=coordinate42 && n>=coordinate41
                        map2(m,n)=1;
                    end
                end
            end
            complexity_area1=map1.*referenceImageMAP{i,j};
            complexity_area2=map2.*referenceImageMAP{i,j};
            
            
            num=num+1;
            predictionError(num)=b(1,1)-b(1,2);
            contextPixels{num}=complexity_area1(:)';
            num=num+1;
            predictionError(num)=b(1,blockNum)-b(1,blockNum-1);
            contextPixels{num}=complexity_area2(:)';
        end
        
        
    end
end

%% Calculate the complexity by using context pixels
[~,numerror]=size(contextPixels);
COM={};
for i=1:numerror
    com=contextPixels{i};
    [~,numref]=size(com);
    flag=0;
    for j=1:numref
        if com(j)~=Inf && com(j)~=-Inf && ~isnan(com(j))
            flag=flag+1;
            COM{i}(flag)=com(j);
        end
    end
    [sorted,~]=sort(COM{i});
    [~,row]=size(sorted);
    COMPLEXITY(i)=(sorted(row)-sorted(1))/row;
end

%% Sort prediction errors according to complexity
[~,location]=sort(COMPLEXITY);
[~,a]=size(predictionError);
for i=1: a
    predictionErrorSorted(i,1) = predictionError(1,location(1,i));
end
end
