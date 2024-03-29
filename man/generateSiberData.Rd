% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/generateSiberData.R
\name{generateSiberData}
\alias{generateSiberData}
\title{A utility function to simulate isotope data for several communities}
\usage{
generateSiberData(
  n.groups = 3,
  n.communities = 2,
  n.obs = 30,
  mu.range = c(-1, 1, -1, 1),
  wishSigmaScale = 1
)
}
\arguments{
\item{n.groups}{the an integer specifying the number of groups per community
to simulate. Defaults to 3.}

\item{n.communities}{the number of communities to simulate data for. Defaults
to 2.}

\item{n.obs}{the number of observations to draw per group.}

\item{mu.range}{a vector of length 4, specifying the mix and max x and y
values to sample means from. Group means are sampled from a uniform
distribution within this range. The first two entries are the min and max
of the x-axis, and the second two the min and max of the y-axis. Defaults
to \code{c(-1, 1, -1, 1)}.}

\item{wishSigmaScale}{is a simple multiplier for the call to
\code{\link[stats:rWishart]{stats::rWishart()}} which scales the diagonal sigma matrix using
\code{wishSigmaScale * diag(2)} that is ultimately passed on to
\code{generateSiberGroup}.}
}
\value{
A data.frame object comprising a column of x and y data, a group
identifying column and a community identifying column, all of which are
numeric.
}
\description{
This function simulates data for a specified number of communities. It is a
wrapper function for \code{\link[=generateSiberCommunity]{generateSiberCommunity()}}.
}
\examples{
generateSiberData()

}
