randomTransform <- function( X, noiselevel ) {

  # Take a random transformation
  A <- matrix(rnorm(256*256),256,256)
  
  # Add noise
  nsamples <- dim(X)[2]
  E <- noiselevel * matrix(rnorm(256*nsamples),256,nsamples)
    
  # Compute outputs
  Y <- (A %*% X) + E

  # Return result
  Y
  
}


blur <- function( X, K ) {

  # Simple blurring filter
  B <- matrix(1/(K^2),K,K)
  
  # Construct the convolution matrix (assuming zero boundaries)
  A <- filter2matrix(B,16)

  # Calculate and return the blurred image
  Y <- A %*% X
  Y

}

mexicanhat <- function( X, K ) {

  # Simple mexican hat filter
  B <- matrix(0,K,K)
  B[(K+1)/2,(K+1)/2] <- 1
  B <- B-mean(B)
  
  # Construct the convolution matrix (assuming zero boundaries)
  A <- filter2matrix(B,16)

  # Calculate and return the blurred image
  Y <- A %*% X
  Y

}

motionblur <- function( X, K, mvec ) {

  # Normalize mvec
  mvec <- mvec/sqrt(sum(mvec^2))

  # Perpendicular
  pvec <- c(mvec[2],-mvec[1])  
  
  # Motion blurring filter
  B <- matrix(0,K,K)
  m <- (K+1)/2
  for (i in 1:K) {
    for (j in 1:K) {
      zvec <- c(i-m,j-m)
      mdir <- abs(sum(zvec*mvec))
      pdir <- abs(sum(zvec*pvec))
      if ((pdir<K/8))
      B[i,j] <- 1
    }
  }
  B <- B/sum(B)
  
  # Construct the convolution matrix (assuming zero boundaries)
  A <- filter2matrix(B,16)

  # Calculate and return the blurred image
  Y <- A %*% X
  Y

}



randomFilter <- function( X, K ) {

  # Random filter
  B <- matrix(rnorm(K*K),K,K)
  B <- B/sum(B)
  
  # Construct the convolution matrix (assuming zero boundaries)
  A <- filter2matrix(B,16)
    
  # Calculate and return the blurred image
  Y <- A %*% X
  Y

}

filter2matrix <- function( B, w ) {

  # Compute size of filter (assumed square, odd size)
  M <- dim(B)[1]

  # Construct the 2d filter matrix
  A <- matrix(0,w^2,w^2)
  for (i in 0:(w-1)) {
    for (j in 0:(w-1)) {
      for (k in 0:(w-1)) {
        for (l in 0:(w-1)) {
          diffx <- i-k
          diffy <- j-l
          if ((abs(diffx)<M/2) && (abs(diffy)<M/2)) {
            A[i*w+j+1,k*w+l+1] <- B[diffx+(M+1)/2,diffy+(M+1)/2]
          }
        }
      }
    }
  }
  A
  
}
