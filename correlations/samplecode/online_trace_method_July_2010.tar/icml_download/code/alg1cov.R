alg1cov <- function( Cx, Cy, Cxy, thresh, renormX, renormY, samples=FALSE ) {

  # This will hold the result
  r <- c(0,0,0,0,0)
  
  # Compute further matrices
  Cyx <- t(Cxy)
  A <- Cyx %*% solve(Cx)
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
    


  # Compute the two things to be compared
  v1 <- lnt(A %*% Cx %*% t(A)) - lnt(Cx) - lnt(A %*% t(A))
  v2 <- lnt(Ai %*% Cy %*% t(Ai)) - lnt(Cy) - lnt(Ai %*% t(Ai))
  
  # Diagnostic output
  #if (samples) {
  #  cat('alg1samples:\n')
  #  cat('v1=',v1,'\n')
  #  cat('v2=',v2,'\n')
  #} else {
  #  cat('alg1model:\n')
  #  cat('v1=',v1,'\n')
  #  cat('v2=',v2,'\n')
  #}
    
  # Take the decision:
  if (abs(v1)>abs(v2)*(1+thresh)) r[2] <- 1 # y is the cause
  else if (abs(v2)>abs(v1)*(1+thresh)) r[1] <- 1 # x is the cause
  else r[3] <- 1 # unknown

  # Also record the values v1 and v2
  r[4] <- v1
  r[5] <- v2
  
  # Return the result
 
  r
  
}

# helper function for alg1cov: 
# computes the trace of a matrix C divided by the dimension
normalizedtrace <- function( C ) {

  retval <- sum(diag(C))/(dim(C)[1])
  retval

}

# helper function for alg1cov: 
# computes the log of the normalizedtrace (see above)
lnt <- function(x) {
  
  val <- log(normalizedtrace(x))
  val
  
}
