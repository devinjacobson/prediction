drawplot <- function( r, x, fignum, topdf=FALSE, plotnum=0, covalso=FALSE,
                      xaxistitle='x' ) {

  # Re-compute ntries
  ntries <- sum(r[1:3,1])

  # Normalize to get ratios
  r <- r/ntries

  # Line width
  linewidth <- 3
  fsize <- 26
  height <- 8
  
  # Select correct figure
  if (topdf==FALSE) figure( fignum[1] )
  else {
    pdf(file = paste('plot',plotnum,'.pdf',sep=''),pointsize=fsize,
        height=height)
  }
  
  # Plot correct and wrong
  plot(x,r[1,],type='l',col='green',ylim=c(0,1),lwd=linewidth,
       xlab=xaxistitle,ylab='performance')
  matplot(x,r[2,],add=TRUE,type='l',col='red',lwd=linewidth)
  if (covalso) {
    matplot(x,r[6,],add=TRUE,type='l',col='green',lty=2,lwd=linewidth)
    matplot(x,r[7,],add=TRUE,type='l',col='red',lty=2,lwd=linewidth)
  }
    
  
  if (topdf) {
    dev.off()
  }

  # Select correct figure
  if (topdf==FALSE) figure( fignum[2] )
  else {
    pdf(file = paste('plot',plotnum,'values.pdf',sep=''),pointsize=fsize,
        height=height)
  }

  if (covalso) {
    ymaxabs <- max(abs(r[c(4,5,9,10),]))
  }
  else {
    ymaxabs <- max(abs(r[c(4,5),]))
  }
    
  # Plot correct and wrong
  plot(x,r[4,],type='l',col='green',ylim=c(-ymaxabs,ymaxabs),lwd=linewidth,
       xlab=xaxistitle,ylab='value of delta')
  matplot(x,r[5,],add=TRUE,type='l',col='red',lwd=linewidth)
  if (covalso) {
    matplot(x,r[9,],add=TRUE,type='l',col='green',lty=2,lwd=linewidth)
    matplot(x,r[10,],add=TRUE,type='l',col='red',lty=2,lwd=linewidth)
  }
    
  if (topdf) {
    dev.off()
  }

  
}
