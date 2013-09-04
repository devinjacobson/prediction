alg1covRot <- function( Cx, Cy, Cxy, renormX, renormY, samples=FALSE ) {

  
  # This will hold the result
  r <- c(0,0,0,0,0)
   
  # specify number of rotations  
  rot_number=10000
  
  xdim=length(Cx[,1])
  ydim=length(Cy[,1])  

 
  # Compute further matrices
  Cyx <- t(Cxy)
  
  # structure matrix from X to Y 
  A <- Cyx %*% solve(Cx)    

  # structure matrix from Y to X
  Ai <- Cxy %*% solve(Cy)
  


  if  (renormX==1)
     R_inv_X=diag((diag(Cx))^{1/2})
    else R_inv_X= diag((diag(Cx))^{0})
  if  (renormY==1)
     R_inv_Y=diag((diag(Cy))^{1/2})
    else R_inv_Y= diag((diag(Cy))^{0})

     Rx=solve(R_inv_X) 
     Ry=solve(R_inv_Y) 

     # renormalize if this was desired (if this was not desired the above ensures that Rx=id and Ry=id) 
     Cx  <- Rx %*% Cx %*% Rx
     A <-  Ry %*% A %*%  R_inv_X

     Cy  <- Ry %*% Cy %*%Ry
     Ai <- Rx %*% Ai %*%  R_inv_Y
    

  # Compute the two Deltas
  v1 <- lnt(A %*% Cx %*% t(A)) - lnt(Cx) - lnt(A %*% t(A))
  v2 <- lnt(Ai %*% Cy %*% t(Ai)) - lnt(Cy) - lnt(Ai %*% t(Ai))
  
  
  # initialization of counter variables
 
  XeY_larger=0
  XeY_smaller=0
  YeX_larger=0
  YeX_smaller=0

  # apply rot_number many random rotations to Cx and Cy to generate a null distribution 
  
  # initialize vector for the results of comparing Deltas   
  v1rot=matrix(0,rot_number,1)  
  v2rot=matrix(0,rot_number,1) 
 
  for (j in 1:rot_number)   

  { 
 
  # generate random rotation
   Bx <- matrix(rnorm(xdim*xdim),xdim,xdim)
   By <- matrix(rnorm(ydim*ydim),ydim,ydim)

   DX=t(Bx) %*% Bx
   DY=t(By) %*% By
   DX.eig <- eigen(DX)
   DY.eig <- eigen(DY)

   DX.sqrt <- DX.eig$vectors %*% diag(sqrt(DX.eig$values)) %*% solve(DX.eig$vectors)
   DY.sqrt <- DY.eig$vectors %*% diag(sqrt(DY.eig$values)) %*% solve(DY.eig$vectors)


   UX=Bx %*% solve(DX.sqrt)
   UY=By %*% solve(DY.sqrt)

   v1_rot= lnt(A %*% UX %*% Cx %*% t(UX) %*% t(A)) - lnt(Cx) - lnt(A %*% t(A))
   v2_rot= lnt(Ai %*% UY %*%  Cy %*%  t(UY) %*% t(Ai)) - lnt(Cy) - lnt(Ai %*% t(Ai))

   v1rot[j] <- v1_rot 
   v2rot[j] <- v2_rot
 
   if (v1> v1_rot) 
      {
        XeY_larger=XeY_larger+1
      }  
   else if (v1< v1_rot) 
      {
        XeY_smaller=XeY_smaller+1
      }  
     
  
   if (v2> v2_rot) 
      {
        YeX_larger=YeX_larger+1
      }  
   else
      { 
       if (v2< v2_rot) 
      {
        YeX_smaller=YeX_smaller+1
      }  
     
      }
   }  # for loop 


   # it is also possible to generate histograms showing the results of the rotation tests if you
   # remove the #-signs 

   #hist(v1rot,breaks=40)
   #pdf('distribution_v1.pdf',width=5,height=5)
   #hist(v1rot,breaks=40)
   #dev.off()

   #pdf('distribution_v2.pdf',width=5,height=5)
   #hist(v2rot,breaks=40)
   #dev.off()

   p_value_XeY=min(XeY_larger,XeY_smaller)/rot_number
   p_value_YeX=min(YeX_larger,YeX_smaller)/rot_number
   
   r[4] <- p_value_XeY
   r[5] <- p_value_YeX
 

   if ((XeY_larger+XeY_smaller!=0)  & (YeX_larger+YeX_smaller !=0))  
       {
       if (XeY_larger==0)       
         {
          Quotient_XeY=XeY_larger/XeY_smaller
         }
       else  Quotient_XeY=XeY_smaller/XeY_larger 

       if (YeX_larger==0)   
         {
          Quotient_YeX=YeX_larger/YeX_smaller
         }
       else  Quotient_YeX=YeX_smaller/YeX_larger  
        
        q_XeY=abs(log(Quotient_XeY))       
        q_YeX=abs(log(Quotient_YeX))    
        
      }  # end if
   

 
    # r[4] <- q_XeY
    # r[5] <- q_YeX
     
  
    if ( r[4] > r[5] )
       {
        r[1] =1
       }
    else if ( r[4] < r[5]  )
       {
        r[2]=1
       } 
    else 
       {
       r[3]=1
       }
      
  
  # Return the result
  r  
}
