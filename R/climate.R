## Function 10. Power law noise from Kimmer & Koening
#' @title Power law Noise from Kimmer & Koening
#' @description
#' From tuneR package (implemented in the file Waveforms.R in tuneR source)
#'
#' Based on Timmer & Koening (1995)
#' @param alpha the slope of the power distribution (called omega in whitehead)
#' @param N the length of the timeserie to generate
#' @export
TK95 <- function(N, alpha = 1){ 
  f <- seq(from=0, to=pi, length.out=(N/2+1))[-c(1,(N/2+1))] # Fourier frequencies
  f_ <- 1 / f^alpha # Power law
  RW <- sqrt(0.5*f_) * rnorm(N/2-1) # for the real part
  IW <- sqrt(0.5*f_) * rnorm(N/2-1) # for the imaginary part
  fR <- complex(real=c(rnorm(1), RW, rnorm(1), RW[(N/2-1):1]), 
                imaginary=c(0, IW, 0, -IW[(N/2-1):1]),
                length.out=N)
  # Those complex numbers that are to be back transformed for
  # Fourier Frequencies 0, 2pi/N, 2*2pi/N, ..., pi, ..., 2pi-1/N 
  # Choose in a way that frequencies are complex-conjugated and symmetric around pi 
  # 0 and pi do not need an imaginary part
  reihe <- fft(fR, inverse=TRUE) # go back into time domain
  return(Re(reihe)) # imaginary part is 0
}

## Function 11. Environment generator
#' @title Environment generator
#' @description
#' Return a list of optimum as a \eqn{1/f_{noise}} of \eqn{N} steps with \eqn{sd = \delta} and
#' the slope of its spectrum decompoistion = -\eqn{\omega} + possibility to increase
#' the mean of the environment at a rate vt (in wich case the slop may not be -omega)
#' @param omega the slope of the power distribution (called omega in whitehead)
#' @param delta the standard deviation of the global environmental fluctuation 
#' @param N the length of the timeserie to generate
#' @param vt if not NULL, the  mean of the optimum increase at a rate vt  
#' @return a list of N optima theta
#' @export
environment <- function(N, omega, delta, vt=NULL){
  ts <- TK95(N, omega)
  ts <- delta * ts/sd(ts)
  if(!is.null(vt)) {
    ts = ts + vt*1:N
  }
  return(ts)
}
