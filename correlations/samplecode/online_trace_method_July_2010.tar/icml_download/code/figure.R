# This function works just like matlab's figure() except that:
# - N=1 produces an error (use only id's 2 and up)
# - Windows are open so that there always exist id's 2...N
#   i.e. don't use N=1000!

figure <- function( N ) {

  # make sure we have at least (N-1) graphics windows open
  repeat {
    if (length(dev.list())<(N-1)) { X11(); next }
    break
  }

  # set the currently active window
  dev.set(which=N)
  
}
