% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/laymanmetrics.R
\name{laymanMetrics}
\alias{laymanMetrics}
\title{Calculates the 6 Layman metrics on a vector of x and y data}
\usage{
laymanMetrics(x, y)
}
\arguments{
\item{x}{a vector of locations in the x-axis direction.}

\item{y}{a vector of locations in the y-axis direction.}
}
\value{
A vector of the 6 Layman metrics of dX_range, dY_range, TA,
CD, MNND and SDNND
}
\description{
This function takes two x and y vectors, and calculates the corresponding
6 Layman metrics based on these points. Note that for generality, the
original metrics of dC_range and dN_range have been renamed dX_range and
dY_range respectively. These modified names represent the x and y axes in
terms of the order in which the data have been entered, and relate typically
to how one plots the data. These x and y vectors could represent the means
of the group members comprising a community as is preferred under the SIBER
model framework. However, one could use them to calculate the point estimates
of the 6 Layman metrics for an entire group of data. In fact, you are free
to pass this function any set of \code{x} and \code{y} data you wish.
}
\examples{
x <- stats::runif(10)
y <- stats::runif(10)
laymanMetrics(x, y)

}
