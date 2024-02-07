
## Function 12. Perlin noise
#' @title Perlin-noise for elevation and slope
#' @description
#' This function creates slope and elevation with 2-D autocorrelation and noise.
#' Collectively it is called Perlin noise
#' @param n Size of the grid in the vector field on one dimension
#' @param m Size of the grid in the vector field on the other dimension
#' @param N Size of the final image
#' @param M Size of the final image on the other dimension
#'
#' @return
#' `numeric` matrix of size N-1 x M-1
#' @export
perlin_noise <- function( 
    n = 5,   m = 7,    
    N = 100, M = 100
) {
  # For each point on this n*m grid, choose a unit 1 vector
  vector_field <- apply(
    array( rnorm( 2 * n * m ), dim = c(2,n,m) ),
    2:3,
    function(u) u / sqrt(sum(u^2))
  )
  f <- function(x, y) {
    # Find the grid cell in which the point (x,y) is
    i <- floor(x)
    j <- floor(y)
    stopifnot( i >= 1 || j >= 1 || i < n || j < m )
    # The 4 vectors, from the vector field, at the vertices of the square
    v1 <- vector_field[, i, j]
    v2 <- vector_field[, i+1, j]
    v3 <- vector_field[, i, j+1]
    v4 <- vector_field[, i+1, j+1]
    # Vectors from the point to the vertices
    u1 <- c(x,y) - c(i, j)
    u2 <- c(x,y) - c(i+1, j)
    u3 <- c(x,y) - c(i, j+1)
    u4 <- c(x,y) - c(i+1, j+1)
    # Scalar products
    a1 <- sum( v1 * u1 )
    a2 <- sum( v2 * u2 )
    a3 <- sum( v3 * u3 )
    a4 <- sum( v4 * u4 )
    # Weighted average of the scalar products
    s <- function(p) 3 * p^2 - 2 * p^3
    p <- s( x - i )
    q <- s( y - j )
    b1 <- (1-p)*a1 + p*a2
    b2 <- (1-p)*a3 + p*a4
    (1-q) * b1 + q * b2
  }
  xs <- seq(from = 1, to = n, length = N+1)[-(N+1)]
  ys <- seq(from = 1, to = m, length = M+1)[-(M+1)]
  return(outer( xs, ys, Vectorize(f) ))
}
