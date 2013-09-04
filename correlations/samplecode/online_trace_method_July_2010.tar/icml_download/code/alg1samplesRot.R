alg1samplesRot <- function( X, Y, renormX, renormY) {

  # Number of samples is number of columns of X
  nsamples <- dim(X)[2]
  
  # Check that we have the same number of columns in Y!
  nsamplesy <- dim(Y)[2]
  if (nsamples != nsamplesy)
  	stop("alg1samples: X and Y should have same number of columns");
  
  # Subtract mean from each row of both X and Y
  X <- X-rowMeans(X)
  Y <- Y-rowMeans(Y)
  
  # Simple estimates of covariances
  eCx <- (X %*% t(X))/(nsamples-1)
  eCy <- (Y %*% t(Y))/(nsamples-1)
  eCxy <- (X %*% t(Y))/(nsamples-1)

  # Proceed with algorithm 1 based on these covariance matrices
  # (i.e. the rest of alg 1 is implemented in the function alg1cov)
  r <- alg1covRot( eCx, eCy, eCxy, renormX, renormY, samples=TRUE )
  
  # Note: the subroutine alg1cov.R contains 2 possible decision rules:   
  # first, the original one that computes only Delta (rot=0), and 
  # second, the rotation test (rot=1)

  # Return the result
  r
  
}
