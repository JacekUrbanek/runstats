
[![Travis build status](https://travis-ci.com/martakarass/runstats.svg?branch=master)](https://travis-ci.com/martakarass/runstats) [![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/martakarass/runstats?branch=master&svg=true)](https://ci.appveyor.com/project/martakarass/runstats) [![Coverage status](https://codecov.io/gh/martakarass/runstats/branch/master/graph/badge.svg)](https://codecov.io/github/martakarass/runstats?branch=master)

<!-- README.md is generated from README.Rmd. Please edit that file -->
runstats
========

Package `runstats` provides methods for fast computation of running sample statistics for time series. The methods utilize Convolution Theorem to compute convolutions via Fast Fourier Transform (FFT). Implemented running statistics include:

1.  mean,
2.  standard deviation,
3.  variance,
4.  covariance,
5.  correlation,
6.  Euclidean distance.

### Usage

``` r
install.packages("runstats")
library(runstats)

## Example: running correlation
x0 <- sin(seq(0, 2 * pi * 5, length.out = 1000))
x  <- x0 + rnorm(1000, sd = 0.1)
pattern <- x0[1:100]
out1 <- RunningCor(x, pattern)
out2 <- RunningCor(x, pattern, circular = TRUE)

## Example: running mean
x <- cumsum(rnorm(1000))
out1 <- RunningMean(x, W = 100)
out2 <- RunningMean(x, W = 100, circular = TRUE)
```

### Running statistics

To better explain the concept of running statistics, package's function `runstats.demo(func.name)` allow to vizualize how the output of each running statistics method is generated. To run the demo, use `func.name` being one of the methods' names:

1.  `"RunningMean"`,
2.  `"RunningSd"`,
3.  `"RunningVar"`,
4.  `"RunningCov"`,
5.  `"RunningCor"`,
6.  `"RunningL2Norm"`.

``` r
## Example: demo for running correlation method  
runstats.demo("RunningCor")
```

![](https://i.imgur.com/SrgUEdX.gif)

``` r
## Example: demo for running mean method 
runstats.demo("RunningMean")
```

![](https://i.imgur.com/gyaTrRz.gif)
