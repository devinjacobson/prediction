randomModel <- function( xdim, ydim, noiselevel ) {

  # Generate covariance of x
  Bx <- matrix(rnorm(xdim*xdim),xdim,xdim)
  Cx <- Bx %*% t(Bx)
	
  # Generate the matrix for the transformation
  A <- matrix(rnorm(ydim*xdim),ydim,xdim)

  # Generate covariance of noise
  Be <- noiselevel * matrix(rnorm(ydim*ydim),ydim,ydim)
  Ce <- Be %*% t(Be)
      
  # Compute the covariance of Y
  Cy <- (A %*% Cx %*% t(A)) + Ce

  # Compute the cross-covariance
  Cyx <- A %*% Cx
  Cxy <- t(Cyx)

  # Return full model
  r <- list()
  r$Cx <- Cx
  r$Cy <- Cy
  r$Cxy <- Cxy
  r$Cyx <- Cyx
  r$Bx <- Bx
  r$Be <- Be
  r$A <- A
  r
  
}
