
# STARTING UP:
#
# R
# > source('loadmain.R')
# > options(error=recover)
# > main(1)
# > main(2)
# etc...

# This function gets called by main() from prompt
# (after loadmain.R has been sourced as above)
runmain <- function( task, theseed=-1 ) {

  cat('--------------------------------------------------------\n')

  # Randomly/manually set seed for reproducibility (omit 'theseed' for 
  # random seed; specify 'theseed' to start from a specific seed)
  
  if (theseed != -1) {
    set.seed( theseed )
    cat('Using seed: ',theseed,'\n')
  }
  else {
    theseed <- floor(runif(1,0,1)*100000)
    cat('Randomly selected the seed: ',theseed,'\n')
    set.seed( theseed )
  }

  #------------------------------------------------------------------------
  # Task 1: This is just a simple demo of how to use the inference code
  #------------------------------------------------------------------------
  if (task==1) {
  
    #--- Parameters ---
  
  	# Dimension of X
  	n <- 10
  	
  	# Dimension of Y
  	m <- 8
  	
  	# Amount of noise
  	noiselevel <- 0.1
  	
  	# Number of samples
  	nsamples <- 100
  	
  	#--- Generate a random model ---
  	
  	# Input covariance matrix Cx is randomly selected
  	Bx <- matrix(rnorm(n*n),n,n)
  	Cx <- Bx %*% t(Bx)
  	
  	# Random transformation matrix A
  	A <- matrix(rnorm(m*n),m,n)
	
	# Noise covariance matrix Ce is randomly generated
  	Be <- noiselevel * matrix(rnorm(m*m),m,m)
  	Ce <- Be %*% t(Be)
  	
  	#--- Generate the sample data ---
  	
  	# The cause X and the noise E are gaussian with the above selected
  	# covariance matrices
  	Xdata <- Bx %*% matrix(rnorm(nsamples*n),n,nsamples)
  	Edata <- Be %*% matrix(rnorm(nsamples*m),m,nsamples)
  	
  	# The effect Y is given by the linear transform of X with additive
  	# independent noise
  	Ydata <- (A %*% Xdata) + Edata
  	
  	#--- Infer the direction, print out the result ---
  	
  	thresh <- 0.5
  	result <- alg1samples( Xdata, Ydata, 0,0, thresh )
  	print(result)

  	# Just to show that the method is symmetric with respect to order
  	# (i.e. is not biased to select the first variable as the cause)
  	# we do the same analysis but reverse the role of X and Y fed
  	# to the algorithm.  	
  	result <- alg1samples( Ydata, Xdata, 0,0, thresh )
  	print(result)

  }

  #------------------------------------------------------------------------
  # Task 2: Produces figures 1a and 1b of the paper
  #------------------------------------------------------------------------

  if (task==2) {

	#---------- How much detail? ------------
	
	# Set variable 'detail' as you wish:
	# TRUE:  computationally intensive, figures exactly as in paper
	# FALSE: quicker, approximate version for quick results
	detail <- FALSE

    #---------- Parameters of plot ----------

    if (detail) 
    {
      xdimvec<-c(2,3,4,5,6,7,8,9,10,12,14,16,18,20,25,30,35,40,45,50)
      ntries <- 1000
    }
    else 
    {
      xdimvec <- c(2,5,10,20,30,50)
      ntries <- 100
	}
	
    noiselevel <- 0.05
    ydimvec <- xdimvec
    nsamplesvec <- 2*xdimvec
    thresh <- 0.5
    
    #---------- Run the tests -----------

    # This will store the results
    r <- matrix(0,10,length(xdimvec))

    # Step through different parameter settings
    for (i in 1:length(xdimvec)) {

      # Set parameters
      xdim <- xdimvec[i]
      ydim <- ydimvec[i]
      nsamples <- nsamplesvec[i]
      
      # Run the simulation ntries times, store result
      r[,i] <- simulation( xdim, ydim, noiselevel, nsamples, ntries, thresh )

    }

    # Produce the plot
    drawplot( r, xdimvec, 2:3, xaxistitle='dimension' )
    drawplot( r, xdimvec, 2:3, TRUE, task, xaxistitle='dimension' )
    
  }

  #------------------------------------------------------------------------
  # Task 3: Produces figures 1c and 1d of the paper
  #------------------------------------------------------------------------

  if (task==3) {

	#---------- How much detail? ------------
	
	# Set variable 'detail' as you wish:
	# TRUE:  computationally intensive, figures exactly as in paper
	# FALSE: quicker, approximate version for quick results
	detail <- FALSE

    #---------- Parameters of plot ----------

    if (detail) 
    {
      ntries <- 10000
      noiselevelvec <- c(0,0.05,0.1,0.15,0.2,0.3,0.4,0.5,0.75,1,1.25,
  	                     1.5,1.75,2,2.25,2.5,2.75,3,3.5,4,4.5,5)
    }
    else 
    {
      ntries <- 100
      noiselevelvec <- c(0,0.1,0.2,0.5,1,2,3,4,5)
	}
	
    nsamples <- 1000
    xdim <- 10 
    ydim <- xdim
    thresh <- 0.5
    
    #---------- Run the tests -----------

    # This will store the results
    r <- matrix(0,10,length(noiselevelvec))

    # Step through different parameter settings
    for (i in 1:length(noiselevelvec)) {

      # Set parameters
      noiselevel <- noiselevelvec[i]
      
      # Run the simulation ntries times, store result
      r[,i] <- simulation( xdim, ydim, noiselevel, nsamples, ntries, thresh )

    }

    # Produce the plot
    drawplot( r, noiselevelvec, 2:3, covalso=TRUE, xaxistitle='sigma' )
    drawplot( r, noiselevelvec, 2:3, TRUE, task, covalso=TRUE,
              xaxistitle='sigma')
              
    print(r)
    
  }

  #------------------------------------------------------------------------
  # Task 4: Shows examples of filtered images (not shown in paper)
  #         for use in Subsection 4.2 in the paper
  #------------------------------------------------------------------------

  if (task==4) {
    
    # Load in the data
    D <- read.table('../zipdata/zip.train')

    # Select the first digit of 'thedigit' type
    thedigit <- 2
    
    # Select first datapoint of the digit
    X <- D[which(D[,1]==thedigit),2:257]
    X <- t(X[1,])
      
    # Normalize so black is zero
    X <- X+1

    # Store original
    Xorig <- X
    
    # Do different transformations
    for (i in 1:5) {

      X <- Xorig
      
      if (i<=3) transform <- 'filter'
      else if (i==4) transform <- 'blur'
      else transform <- 'motionblur'
      
      if (transform == 'random') {
        Y <- randomTransform( X, 0 )
      }
      else if (transform == 'filter') {
        K <- 3
        Y <- randomFilter( X, K )
      }
      else if (transform == 'blur') {
        K <- 3
        Y <- blur( X, K )
      }
      else if (transform == 'motionblur') {
        K <- 5
        Y <- motionblur( X, K, c(1,0) )
      }

      # Renormalize
      X <- X-1
      Y <- Y-1

      # Add some noise to X (otherwise Cx is often singular)
      noiselevel <- 0.01
      X <- X + noiselevel*matrix(rnorm(prod(dim(X))),dim(X)[1],dim(X)[2])    
    
      # Add some noise to Y (otherwise Cy is often singular)
      noiselevel <- 0.01
      Y <- Y + noiselevel*matrix(rnorm(prod(dim(Y))),dim(Y)[1],dim(Y)[2])    
    
      # Plot original and transformed
      cat('Showing original and transformed...',sep='')

      figure(2)
      imdata <- matrix(X,16,16)
      imdata <- imdata[1:16,16:1]
      image(imdata,col=gray(seq(0,1,len=256)))

      pdf(file = paste('digit2f',i,'original.pdf',sep=''))
      image(imdata,col=gray(seq(0,1,len=256)))          
      dev.off()
        
      figure(3)
      imdata <- matrix(Y,16,16)
      imdata <- imdata[1:16,16:1]
      image(imdata,col=gray(seq(0,1,len=256)))

      pdf(file = paste('digit2f',i,'filtered.pdf',sep=''))
      image(imdata,col=gray(seq(0,1,len=256)))          
      dev.off()

      cat('(press return to continue)',sep='')
      dummy <- readline()
        
    }
 
  }

  #------------------------------------------------------------------------
  # Task 5: Produce a summary table of digits data results; for the paper
  # Note: requires that the files zip.test and zip.train are in the 
  # directory ../zipdata/. The data files can be downloaded from
  # http://www-stat-class.stanford.edu/~tibs/ElemStatLearn/data.html
  #------------------------------------------------------------------------

  if (task==5) {

    #----------- Parameters -------------

    digits <- 0:9
    transformtypes <- c(rep('filter',8),'blur','motionblur')

    noiselevel <- 0.01
    thresh <- 0.5
    
    #----------- Run the experiments ---------
    
    # Load in the data
    D <- read.table('../zipdata/zip.train')

    # These will store the correct, wrong, and unknown numbers
    rc <- matrix(0,length(digits),length(transformtypes))
    rf <- rc
    ru <- rc

    # Run all combinations
    for (j in 1:length(transformtypes)) {
      for (i in 1:length(digits)) {
        
        # Parameters for this run
        thedigit <- digits[i]
        transform <- transformtypes[j]

        # Show progress
        cat(transform,thedigit,'\n',sep=' ')
        
        # Select only those datapoints corresponding to thedigit
        X <- D[which(D[,1]==thedigit),2:257]
        
        # Transpose to get samples as columns
        X <- t(X)
        nsamples <- dim(X)[2]

        # Normalize so black is zero
        X <- X+1

        # Select transform
        K <- 3
        if (transform == 'random') Y <- randomTransform( X, 0 )
        else if (transform == 'filter') Y <- randomFilter( X, K )
        else if (transform == 'blur') Y <- blur( X, K )
        else if (transform == 'motionblur') Y <- motionblur( X, K, c(1,1) )

        # Renormalize
        X <- X-1
        Y <- Y-1
        
        # Add some noise to X (otherwise Cx is often singular)
        X <- X + noiselevel*matrix(rnorm(prod(dim(X))),dim(X)[1],dim(X)[2])    

        # Add some noise to Y (otherwise Cy is often singular)
        Y <- Y + noiselevel*matrix(rnorm(prod(dim(Y))),dim(Y)[1],dim(Y)[2])    

        # Apply the algorithm
        alg1result <- alg1samples( X, Y, 0, 0, thresh )
        cat('alg1result =',alg1result,'\n')
        rc[i,j] <- alg1result[1]
        rf[i,j] <- alg1result[2]
        ru[i,j] <- alg1result[3]
        
      }
    }
    print(rc)
    print(rf)

  }




  #------------------------------------------------------------------------
  # Task 6: Apply the algorithm to precipitation data (Subsection 4.3) 
  #         (renormalize X)
  #------------------------------------------------------------------------
  
  if (task==6) 
  {
  
    # load the data 
    data <- read.table("../data_sets/precipitation_data.txt")

    sample_size <- length(data[,1])
    for (j in 1:sample_size) 
        data[j,] <-  as.numeric(data[j,])
    Xdata <- t(as.matrix(data[,1:3]))
    cat("X consists of altitude, longitude, latitude\n")

    Ydata <- t(as.matrix(data[,4:15]))
    cat("Y consists of precipitation in Jan, Feb, ... Dec\n")  
      

    thresh <- 0.5
      
  	result <- alg1samples( Xdata, Ydata, 1, 0, thresh)

    cat('\n')
    cat('Result:','\n') 
    print(result)

  }



  #------------------------------------------------------------------------
  # Task 7: Apply the algorithm to precipitation data (Subsection 4.3) 
  #         (renormalize X *and* Y)
  #------------------------------------------------------------------------
  
  if (task==7) 
  {
  
    # load the data 
    data <- read.table("../data_sets/precipitation_data.txt")

    sample_size <- length(data[,1])
    for (j in 1:sample_size) 
        data[j,] <-  as.numeric(data[j,])
    Xdata <- t(as.matrix(data[,1:3]))
    cat("X consists of altitude, longitude, latitude\n")

    Ydata <- t(as.matrix(data[,4:15]))
    cat("Y consists of precipitation in Jan, Feb, ... Dec\n")  
      

    thresh <- 0.5
      
  	result <- alg1samples( Xdata, Ydata, 1, 1, thresh)
    
    cat('\n')
    cat('Result:','\n') 
    print(result)

  }




  
  #------------------------------------------------------------------------
  # Task 8: Apply the algorithm to Chemnitz ozone data (Subsection 4.4)  
  #         (renormalize X and Y)  
  #------------------------------------------------------------------------
  
  if (task==8) 
  {
  
  	# load the data 
  	# (can be downloaded from:  http://www.mathe.tu-freiberg.de/Stoyan/umwdat.html)
    data <- read.table("../data_sets/Chemnitz_data.txt")
    for (j in 1:1440) 
      data[j,] <-  as.numeric(data[j,])

     
       
    Xdata <- t(as.matrix(data[1:1440,1:3]))
    cat("X consists of sin(phi_wind), cos(phi_wind), T","\n") 

    Ydata <- t(as.matrix(data[1:1440,5:11]))
    cat("Y consists of ozone, sulfur dioxid, dust, CO, NO_2, NO_x","\n")   
    
      #cat("length Xdata:",length(Xdata[,1]),'\n')


    thresh <- 0.5
      
  	result <- alg1samples( Xdata, Ydata, 1,1, thresh )

     cat('\n')
     cat('Result:','\n') 
     print(result)

  }	  
  
  #------------------------------------------------------------------------
  # Task 9: Apply the algorithm to Stock Return data (Subsection 4.5, Asia vs. Europe)
  #         (X and Y not renormalized) 
  #------------------------------------------------------------------------
  
  if (task==9) 
  {
  
    # load the data 
    data <- read.table("../data_sets/Stock_returns.txt")
    for (j in 1:2394)
      data[j,] <-  as.numeric(data[j,])

 
       
    Xdata <- t(as.matrix(data[1:2394,1:4]))
    cat("X consists of the Stock returns SH,HSI,TWI,N225","\n")

    Ydata <- t(as.matrix(data[1:2394,5:7]))
    cat("Y consists of the Stock retuns FTSE,DAX,CAC","\n")
    #cat("length Xdata:",length(Xdata[,1]),'\n')


    thresh <- 0.5
      
  	result <- alg1samples( Xdata, Ydata, 0, 0, thresh )
    
    cat('\n')
    cat('Result:','\n') 
    print(result)
  }
  



  
  #------------------------------------------------------------------------
  # Task 10: Apply the algorithm to Stock Return data (Subsection 4.5, Asia vs. (Europe & USA))
  #          (X  and Y not renormalized)   
  #------------------------------------------------------------------------
  
  if (task==10) 
  {
  
  	# load the data 
    data <- read.table("../data_sets/Stock_returns.txt")
    for (j in 1:2394)
      data[j,] <-  as.numeric(data[j,])

 
       
    Xdata <- t(as.matrix(data[1:2394,1:4]))
    cat("X consists of the Stock returns SH,HSI,TWI,N225","\n")

    Ydata <- t(as.matrix(data[1:2394,5:9]))
    cat("Y consists of the Stock retuns FTSE,DAX,CAC,DJ,NAS","\n")       


    thresh <- 0.5
      
  	result <- alg1samples( Xdata, Ydata, 0, 0, thresh )
    
    cat('\n')
    cat('Result:','\n') 
    print(result)
  }


#------------------------------------------------------------------------
  # Task 11: Apply the algorithm to precipitation data (Subsection 4.3) 
  #          (renormalize X, apply rotation test)
  #------------------------------------------------------------------------
  
  if (task==11) 
  {
  
    # load the data 
    data <- read.table("../data_sets/precipitation_data.txt")

    sample_size <- length(data[,1])
    for (j in 1:sample_size) 
        data[j,] <-  as.numeric(data[j,])
    Xdata <- t(as.matrix(data[,1:3]))
    cat("X consists of altitude, longitude, latitude\n")

    Ydata <- t(as.matrix(data[,4:15]))
    cat("Y consists of precipitation in Jan, Feb, ... Dec\n")  
      
      
  	result <- alg1samplesRot( Xdata, Ydata, 1, 0)

    cat('\n')
    cat('Result:','\n') 
    print(result)

  }



  #------------------------------------------------------------------------
  # Task 12: Apply the algorithm to precipitation data (Subsection 4.3) 
  #         (renormalize X *and* Y, apply rotation test)
  #------------------------------------------------------------------------
  
  if (task==12) 
  {
  
    # load the data 
    data <- read.table("../data_sets/precipitation_data.txt")

    sample_size <- length(data[,1])
    for (j in 1:sample_size) 
        data[j,] <-  as.numeric(data[j,])
    Xdata <- t(as.matrix(data[,1:3]))
    cat("X consists of altitude, longitude, latitude\n")

    Ydata <- t(as.matrix(data[,4:15]))
    cat("Y consists of precipitation in Jan, Feb, ... Dec\n")  
      

    thresh <- 0.5
      
  	result <- alg1samplesRot( Xdata, Ydata, 1, 1)
    
    cat('\n')
    cat('Result:','\n') 
    print(result)

  }



  
  #------------------------------------------------------------------------
  # Task 13: Apply the algorithm to Chemnitz ozone data (Subsection 4.4)  
  #         (renormalize X and Y, apply rotation test)  
  #------------------------------------------------------------------------
  
  if (task==13) 
  {
  
  	# load the data 
  	# (can be downloaded from:  http://www.mathe.tu-freiberg.de/Stoyan/umwdat.html)
    data <- read.table("../data_sets/Chemnitz_data.txt")
    for (j in 1:1440) 
      data[j,] <-  as.numeric(data[j,])

     
       
    Xdata <- t(as.matrix(data[1:1440,1:3]))
    cat("X consists of sin(phi_wind), cos(phi_wind), T","\n") 

    Ydata <- t(as.matrix(data[1:1440,5:11]))
    cat("Y consists of ozone, sulfur dioxid, dust, CO, NO_2, NO_x","\n")   
    
      #cat("length Xdata:",length(Xdata[,1]),'\n')


    thresh <- 0.5
      
  	result <- alg1samplesRot( Xdata, Ydata, 1,1)

     cat('\n')
     cat('Result:','\n') 
     print(result)

  }	  
  
  #------------------------------------------------------------------------
  # Task 14: Apply the algorithm to Stock Return data (Subsection 4.5, Asia vs. Europe)
  #         (X and Y not renormalized, apply rotation test) 
  #------------------------------------------------------------------------
  
  if (task==14) 
  {
  
    # load the data 
    data <- read.table("../data_sets/Stock_returns.txt")
    for (j in 1:2394)
      data[j,] <-  as.numeric(data[j,])

 
       
    Xdata <- t(as.matrix(data[1:2394,1:4]))
    cat("X consists of the Stock returns SH,HSI,TWI,N225","\n")

    Ydata <- t(as.matrix(data[1:2394,5:7]))
    cat("Y consists of the Stock retuns FTSE,DAX,CAC","\n")
    #cat("length Xdata:",length(Xdata[,1]),'\n')


    thresh <- 0.5
      
  	result <- alg1samplesRot( Xdata, Ydata, 0, 0)
    
    cat('\n')
    cat('Result:','\n') 
    print(result)
  }
  



  
  #------------------------------------------------------------------------
  # Task 15: Apply the algorithm to Stock Return data (Subsection 4.5, Asia vs. (Europe & USA))
  #          (X  and Y not renormalized, apply rotation test)   
  #------------------------------------------------------------------------
  
  if (task==15) 
  {
  
  	# load the data 
    data <- read.table("../data_sets/Stock_returns.txt")
    for (j in 1:2394)
      data[j,] <-  as.numeric(data[j,])

 
       
    Xdata <- t(as.matrix(data[1:2394,1:4]))
    cat("X consists of the Stock returns SH,HSI,TWI,N225","\n")

    Ydata <- t(as.matrix(data[1:2394,5:9]))
    cat("Y consists of the Stock retuns FTSE,DAX,CAC,DJ,NAS","\n")       


    thresh <- 0.5
      
  	result <- alg1samplesRot( Xdata, Ydata, 0, 0)
    
    cat('\n')
    cat('Result:','\n') 
    print(result)
  }




  
  ###############################################################
  # Output the used seed, to help if there was a lot of output...
  ###############################################################
  cat('[Seed used was: ',theseed,']\n')
  
}







