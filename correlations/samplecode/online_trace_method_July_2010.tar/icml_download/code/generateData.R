generateData <- function( model, nsamples ) {

  # Get the required matrices
  Bx <- model$Bx
  Be <- model$Be
  A <- model$A

  # Parameters
  xdim <- dim(A)[2]
  ydim <- dim(A)[1]
  
  # Generate the data
  X <- Bx %*% matrix(rnorm(nsamples*xdim),xdim,nsamples)
  E <- Be %*% matrix(rnorm(nsamples*ydim),ydim,nsamples)
  Y <- (A %*% X) + E

  # Return the data
  r <- list()
  r$X <- X
  r$Y <- Y
  r
  
}
