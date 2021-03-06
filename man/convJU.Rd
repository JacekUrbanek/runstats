% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/core_func.R
\name{convJU}
\alias{convJU}
\title{Fast Sequences Convolution}
\usage{
convJU(x, y)
}
\arguments{
\item{x}{numeric sequence}

\item{y}{numeric sequence, of equal or shorter length than  \code{x} sequence}
}
\value{
numeric sequence
}
\description{
Computes convolutions of two sequences via Fast Fourier Transform
}
\details{
Use the Fast Fourier Transform to compute convolutions of two sequences.
If sequences are of different length, the shorter one get a suffix of 0's.
Following convention of \code{stats::convolve} function, if
\code{r <- convolve(x, y, type = "open")} and
\code{n <- length(x)},
\code{m <- length(y)},
then
\deqn{r[k] = \sum_i x[k-m+i] \cdot y[i])}
where the sum is over all valid indices \eqn{i}.

FFT formulation is useful for implementing an efficient numerical
convolution: the standard convolution algorithm has quadratic
computational complexity. From convolution theorem, the complexity of the
convolution can be reduced from
\eqn{O(n^{2})} to  \eqn{O(n\log n)} with fast Fourier transform.
}
\examples{
\dontrun{
x <- sin(seq(0, 1, length.out = 1000) * 2 * pi * 6)
y <- rep(1, 100)
convJU(x, y)
}

}
\keyword{internal}
