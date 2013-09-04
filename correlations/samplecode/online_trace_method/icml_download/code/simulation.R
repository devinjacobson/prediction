simulation <- function( xdim, ydim, noiselevel, nsamples, ntries, thresh ) {

  # Stores the results
  alg1s <- c(0,0,0,0,0) # algorithm 1, samples
  alg1c <- c(0,0,0,0,0) # algorithm 1, true covariances
  
  # Test the desired number of cases
  for (i in 1:ntries) {

    # Show progress
    cat('\n(',i,'):\n',sep='')
      
    # Generate a model
    model <- randomModel( xdim, ydim, noiselevel )

    # Generate data
    data <- generateData( model, nsamples )

    # Perform the inference
    alg1s <- alg1s + alg1samples( data$X, data$Y, 0,0, thresh )
    alg1c <- alg1c + alg1cov( model$Cx, model$Cy, model$Cxy, thresh, 0,0 )
        
  }

  # Summarize results
  cat('alg1s:',alg1s[1:3],'with scores',alg1s[4:5]/ntries,'\n')
  cat('alg1c:',alg1c[1:3],'with scores',alg1c[4:5]/ntries,'\n')
  
  # Return both samples-based and covariance-based results
  r <- c(alg1s,alg1c)
  r
  
}
