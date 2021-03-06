


#' @title
#' Fast Sequences Convolution
#'
#' @description
#' Computes convolutions of two sequences via Fast Fourier Transform
#'
#' @details
#' Use the Fast Fourier Transform to compute convolutions of two sequences.
#' If sequences are of different length, the shorter one get a suffix of 0's.
#' Following convention of \code{stats::convolve} function, if
#' \code{r <- convolve(x, y, type = "open")} and
#' \code{n <- length(x)},
#' \code{m <- length(y)},
#' then
#' \deqn{r[k] = \sum_i x[k-m+i] \cdot y[i])}
#' where the sum is over all valid indices \eqn{i}.
#'
#' FFT formulation is useful for implementing an efficient numerical
#' convolution: the standard convolution algorithm has quadratic
#' computational complexity. From convolution theorem, the complexity of the
#' convolution can be reduced from
#' \eqn{O(n^{2})} to  \eqn{O(n\log n)} with fast Fourier transform.
#'
#' @param x numeric sequence
#' @param y numeric sequence, of equal or shorter length than  \code{x} sequence
#'
#' @return numeric sequence
#'
#' @keywords internal
#'
#' @examples \dontrun{
#' x <- sin(seq(0, 1, length.out = 1000) * 2 * pi * 6)
#' y <- rep(1, 100)
#' convJU(x, y)
#' }
#'
convJU <- function(x, y){

  N1 <- length(x)
  N2 <- length(y)
  if (N2 > N1) stop("y must be of shorter of equal length than x")

  y0 <- append(y, rep(0, N1 - N2))

  out <- convolve(x, y0)
  out <- out[1:N1]

  return(out)
}





#' @title
#' Fast Running Mean Computation
#'
#' @description
#' Computes running sample mean of a sequence in a fixed width window. Uses
#' convolution implementation via Fast Fourier Transform.
#'
#' @details
#' The length of output vector equals the length of \code{x} vector.
#' Parameter \code{circular} determines whether \code{x} sequence is assumed to have a  circular nature.
#' Assume \eqn{l_x} is the length of sequence \code{x}, \code{W} is a fixed length of \code{x} sequence window.
#'
#' If \code{circular} equals \code{TRUE} then
#'   \itemize{
#'     \item first element of the output sequence corresponds to sample mean of \code{x[1:W]},
#'     \item last element of the output sequence corresponds to sample mean of \code{c(x[l_x], x[1:(W - 1)])}.
#'   }
#'
#' If \code{circular} equals \code{FALSE} then
#'   \itemize{
#'     \item first element of the output sequence corresponds to sample mean of \code{x[1:W]},
#'     \item \eqn{l_x - W + 1}-th element of the output sequence corresponds to
#'     sample mean of \code{x[(l_x - W + 1):l_x]},
#'     \item last \code{W-1} elements of the output sequence are filled with \code{NA}.
#'   }
#'
#' @param x A numeric vector.
#' @param W A numeric scalar; width of \code{x} window over which sample mean is computed.
#' @param circular Logical; whether running sample mean is computed assuming
#' circular nature of  \code{x} sequence (see Details).
#'
#' @return A numeric vector.
#'
#' @examples
#' x <- rnorm(10)
#' RunningMean(x, 3, circular = FALSE)
#' RunningMean(x, 3, circular = TRUE)
#'
#' @export
#'
RunningMean <- function(x, W, circular = FALSE){

  ## constant value=1 segment
  win <- rep(1, W)

  ## mean of x (running mean)
  meanx <- convJU(x, win)/W

  ## trim outout tail if not circular
  if (!circular) meanx[(length(x) - W + 2) : length(x)] <- NA

  return(meanx)
}



#' @title
#' Fast Running Variance Computation
#'
#' @description
#' Computes running sample variance of a sequence in a fixed width window. Uses
#' convolution implementation via Fast Fourier Transform.
#'
#' @details
#' The length of output vector equals the length of \code{x} vector.
#' Parameter \code{circular} determines whether \code{x} sequence is assumed to have a  circular nature.
#' Assume \eqn{l_x} is the length of sequence \code{x}, \code{W} is a fixed length of \code{x} sequence window.
#'
#' If \code{circular} equals \code{TRUE} then
#'   \itemize{
#'     \item first element of the output sequence corresponds to sample variance of \code{x[1:W]},
#'     \item last element of the output sequence corresponds to sample variance of \code{c(x[l_x], x[1:(W - 1)])}.
#'   }
#'
#' If \code{circular} equals \code{FALSE} then
#'   \itemize{
#'     \item first element of the output sequence corresponds to sample variance of \code{x[1:W]},
#'     \item the \eqn{l_x - W + 1}-th element of the output sequence corresponds to sample variance of \code{x[(l_x - W + 1):l_x]},
#'     \item last \code{W-1} elements of the output sequence are filled with \code{NA}.
#'   }
#'
#' @param x A numeric vector.
#' @param W A numeric scalar; width of \code{x} window over which sample variance is computed.
#' @param circular Logical; whether running sample variance is computed assuming
#' circular nature of  \code{x} sequence (see Details).
#'
#' @return A numeric vector.
#'
#' @examples
#' x <- rnorm(10)
#' RunningVar(x, W = 3, circular = FALSE)
#' RunningVar(x, W = 3, circular = TRUE)

#'
#' @export
#'
RunningVar <- function(x, W, circular = FALSE){

  ## constant value=1 segment
  win <- rep(1, W)

  # unbiased estimator of variance given as
  # S^2 = \frac{\sum X^2 - \frac{(\sum X)^2}{N}}{N-1}
  sigmax2 <- (convJU(x^2, win) - ((convJU(x, win))^2)/W)/(W - 1)

  ## correct numerical errors, if any
  sigmax2[sigmax2 < 0] <- 0

  if (!circular) sigmax2[(length(x) - W + 2) : length(x)] <- NA

  return(sigmax2)
}




#' @title
#' Fast Running Standard Deviation Computation
#'
#' @description
#' Computes running sample standard deviation of a sequence in a fixed width window. Uses
#' convolution implementation via Fast Fourier Transform.
#'
#' @details
#' The length of output vector equals the length of \code{x} vector.
#' Parameter \code{circular} determines whether \code{x} sequence is assumed to have a  circular nature.
#' Assume \eqn{l_x} is the length of sequence \code{x}, \code{W} is a fixed length of \code{x} sequence window.
#'
#' If \code{circular} equals \code{TRUE} then
#'   \itemize{
#'     \item first element of the output sequence corresponds to sample standard deviation of \code{x[1:W]},
#'     \item last element of the output sequence corresponds to sample standard deviation of \code{c(x[l_x], x[1:(W - 1)])}.
#'   }
#'
#' If \code{circular} equals \code{FALSE} then
#'   \itemize{
#'     \item first element of the output sequence corresponds to sample standard deviation of \code{x[1:W]},
#'     \item the \eqn{l_x - W + 1}-th element of the output sequence corresponds to sample standard deviation of \code{x[(l_x - W + 1):l_x]},
#'     \item last \code{W-1} elements of the output sequence are filled with \code{NA}.
#'   }
#'
#' @param x A numeric vector.
#' @param W A numeric scalar; width of \code{x} window over which sample variance is computed.
#' @param circular Logical; whether  running sample standard deviation is computed assuming
#' circular nature of  \code{x} sequence (see Details).
#'
#' @return A numeric vector.
#'
#' @examples
#' x <- rnorm(10)
#' RunningSd(x, 3, circular = FALSE)
#' RunningSd(x, 3, circular = FALSE)
#'
#' @export
#'
RunningSd <- function(x, W, circular = FALSE){

  sigmax2 <- RunningVar(x, W, circular)
  sigmax  <- sqrt(sigmax2)

  return(sigmax)
}





#' @title
#' Fast Running Covariance Computation
#'
#' @description
#' Computes running covariance between time-series and short-time pattern.  Uses
#' convolution implementation via Fast Fourier Transform.
#'
#' @details
#' Computes running covariance between time-series (\code{x}) and short-time pattern (\code{y}).
#'
#' The length of output vector equals the length of \code{x}.
#' Parameter \code{circular} determines whether \code{x} time-series is assumed to have a  circular nature.
#' Assume \eqn{l_x} is the length of time-series \code{x}, \eqn{l_y} is the length of short-time pattern \code{y}.
#'
#'   If \code{circular} equals \code{TRUE} then
#'   \itemize{
#'     \item first element of the output vector corresponds to sample covariance between \code{x[1:l_y]} and \code{y},
#'     \item last element of the output vector corresponds to sample covariance between \code{c(x[l_x], x[1:(l_y - 1)])}  and \code{y}.
#'   }
#'
#' If \code{circular} equals \code{FALSE} then
#'   \itemize{
#'     \item first element of the output vector corresponds to sample covariance between \code{x[1:l_y]} and \code{y},
#'     \item the \eqn{l_x - W + 1}-th last element of the output vector corresponds to sample covariance between \code{x[(l_x - l_y + 1):l_x]},
#'     \item last \code{W-1} elements of the output vector are filled with \code{NA}.

#'   }
#'
#' @param x A numeric vector.
#' @param y A numeric vector, of equal or shorter length than  \code{x}.
#' @param circular Logical; whether  running variance is computed assuming
#' circular nature of  \code{x} time-series (see Details).
#'
#' @return A numeric vector.
#'
#' @import stats
#'
#' @examples
#' x <- sin(seq(0, 1, length.out = 1000) * 2 * pi * 6)
#' y <- x[1:100]
#' out1 <- RunningCov(x, y, circular = TRUE)
#' out2 <- RunningCov(x, y, circular = FALSE)
#' plot(out1, type = "l"); points(out2, col = "red")
#'
#' @export
#'
RunningCov = function(x, y, circular = FALSE){

  if (length(x) < length(y)) stop("Vector x should be no shorter than vector y")

  ## constant value=1 segment of length equal to length of vector y
  W   <- length(y)
  win <- rep(1, W)

  ## mean of x (running mean), mean of y
  meanx <- convJU(x, win)/W
  meany <- mean(y)

  ## unbiased estimator of sample covariance
  covxy <- (convJU(x, y) - W * meanx * meany)/(W - 1)

  ## trim outout tail if not circular
  if (!circular) covxy[(length(x) - W + 2) : length(x)] <- NA

  return(covxy)
}




#' @title
#' Fast Running Correlation Computation
#'
#' @description
#' Computes running correlation between time-series and short-time pattern.  Uses
#' convolution via Fast Fourier Transform.
#'
#' @details
#' Computes running correlation between time-series ( \code{x}) and short-time pattern ( \code{y}).
#' The length of output vector equals the length of \code{x}.
#' Parameter \code{circular} determines whether \code{x} sequence is assumed to have a  circular nature.
#' Assume \eqn{l_x} is the length of time-series \code{x}, \eqn{l_y} is the length of short-time pattern \code{y}.
#'
#' If \code{circular} equals \code{TRUE} then
#'   \itemize{
#'     \item first element of the output vector corresponds to sample correlation between \code{x[1:l_y]} and \code{y},
#'     \item last element of the output vector corresponds to sample correlation between \code{c(x[l_x], x[1:(l_y - 1)])}  and \code{y}.
#'   }
#'
#' If \code{circular} equals \code{FALSE} then
#'   \itemize{
#'     \item first element of the output vector corresponds to sample correlation between \code{x[1:l_y]} and \code{y},
#'     \item the \eqn{l_x - W + 1}-th element of the output vector corresponds to sample correlation between \code{x[(l_x - l_y + 1):l_x]},
#'     \item last \code{W-1} elements of the output vector are filled with \code{NA}.
#'   }
#'
#' @param x A numeric vector.
#' @param y A numeric vector, of equal or shorter length than  \code{x}.
#' @param circular logical; whether  running correlation is computed assuming
#' circular nature of  \code{x} time-series (see Details).
#'
#' @return A numeric vector.
#'
#' @examples
#' x <- sin(seq(0, 1, length.out = 1000) * 2 * pi * 6)
#' y <- x[1:100]
#' out1 <- RunningCor(x, y, circular = TRUE)
#' out2 <- RunningCor(x, y, circular = FALSE)
#' plot(out1, type = "l"); points(out2, col = "red")
#'
#' @export
#'
RunningCor = function(x, y, circular = FALSE){

  if (length(x) < length(y)) stop("Vector x should be no shorter than vector y")

  ## unbiased estimator of sample covariance
  covxy <- RunningCov(x, y, circular)

  ## sigma x (running sigma), sigma y
  W <- length(y)
  sigmax <- RunningSd(x, W, circular)
  sigmay <- sd(y)

  ## cor(x,y)
  corxy <- covxy/(sigmax * sigmay)
  corxy[sigmax == 0] <- 0
  corxy[corxy > 1] <- 1

  return(corxy)
}




#' @title
#' Fast Running L2 Norm Computation
#'
#' @description
#' Computes running L2 norm between between time-series and short-time pattern.  Uses
#' convolution via Fast Fourier Transform.
#'
#' @details
#' Computes running L2 norm between between time-series and short-time pattern.
#' The length of output vector equals the length of \code{x}.
#' Parameter \code{circular} determines whether \code{x} time-series is assumed to have a  circular nature.
#' Assume \eqn{l_x} is the length of time-series \code{x}, \eqn{l_y} is the length of short-time pattern \code{y}.
#'
#' If \code{circular} equals \code{TRUE} then
#'   \itemize{
#'     \item first element of the output vector corresponds to sample L2 norm between \code{x[1:l_y]} and \code{y},
#'     \item last element of the output vector corresponds to sample L2 norm between \code{c(x[l_x], x[1:(l_y - 1)])}  and \code{y}.
#'   }
#'
#' If \code{circular} equals \code{FALSE} then
#'   \itemize{
#'     \item first element of the output vector corresponds to sample L2 norm between \code{x[1:l_y]} and \code{y},
#'     \item the \eqn{l_x - W + 1}-th element of the output vector corresponds to sample L2 norm between \code{x[(l_x - l_y + 1):l_x]},
#'     \item last \code{W-1} elements of the output vector are filled with \code{NA}.
#'   }
#'
#' @param x A numeric vector.
#' @param y A numeric vector, of equal or shorter length than  \code{x}.
#' @param circular logical; whether  running  L2 norm  is computed assuming
#' circular nature of  \code{x} time-series (see Details).
#'
#' @return A numeric vector.
#'
#' @examples
#' ## Ex.1.
#' x <- sin(seq(0, 1, length.out = 1000) * 2 * pi * 6)
#' y1 <- x[1:100] + rnorm(100)
#' y2 <- rnorm(100)
#' out1 <- RunningL2Norm(x, y1)
#' out2 <- RunningL2Norm(x, y2)
#' plot(out1, type = "l"); points(out2, col = "blue")
#' ## Ex.2.
#' x <- sin(seq(0, 1, length.out = 1000) * 2 * pi * 6)
#' y <- x[1:100] + rnorm(100)
#' out1 <- RunningL2Norm(x, y, circular = TRUE)
#' out2 <- RunningL2Norm(x, y, circular = FALSE)
#' plot(out1, type = "l"); points(out2, col = "red")
#' @export
#'
RunningL2Norm <- function(x, y, circular = FALSE){

  N1 <- length(x)
  N2 <- length(y)

  m <- rep(1, N2)

  d <- convJU(x^2, m)  - 2 * convJU(x, y) + sum(y^2)
  d[d < 0] <- 0
  d <- sqrt(d)
  d <- d[1:N1]

  ## trim outout tail if not circular
  if (!circular) d[(N1 - N2 + 2) : N1] <- NA

  return(d)
}
