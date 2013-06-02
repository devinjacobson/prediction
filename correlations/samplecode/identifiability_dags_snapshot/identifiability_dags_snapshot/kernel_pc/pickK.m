% picks number of clusters for k-means clustering
function k = pickK(X)

a = 1;
n = size(X,1);
b = n;
step = 2;

v = sum(diag(diag(var(X))));

while (step>1&&b<=n)
   
    step = max(round((b-a+1)/10),1);
    
    for k=a:step:b
       
        [idx, c, sumd] = kmeans(X,k,'EmptyAction','drop','MaxIter',1000,'Display','off');
%        [idx, c, sumd] = kmeans(X,k=k,maxloops=1000);
        
        c = sum(sumd)/n;
        
        if (k~=a)
            if ((lastc-c)/v<.05)
                k = k-step;
                break;
            end
        end
        
        lastc = c;
        
    end
    
    a = k;
    b = k+step;
  
end
