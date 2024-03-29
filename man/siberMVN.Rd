% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/siberMVN.R
\name{siberMVN}
\alias{siberMVN}
\title{Fit Bayesian bivariate normal distributions to each group in each community}
\usage{
siberMVN(siber, parms, priors)
}
\arguments{
\item{siber}{a siber object as created by \code{\link[=createSiberObject]{createSiberObject()}}}

\item{parms}{a list containing four items providing details of the
\code{\link[rjags:rjags-package]{rjags::rjags()}} run to be sampled.
\itemize{
\item \code{n.iter} The number of iterations to sample
\item \code{n.burnin} The number of iterations to discard as a burnin from the
start of sampling.
\item \code{n.thin} The number of samples to thin by.
\item \code{n.chains} The number of chains to fit.
}}

\item{priors}{a list of three items specifying the priors to be passed to
the jags model.
\itemize{
\item \code{R} The scaling vector for the diagonal of Inverse Wishart
distribution prior on the covariance matrix Sigma. Typically
set to a 2x2 matrix \code{matrix(c(1, 0, 0, 1), 2, 2)}.
\item \code{k} The degrees of freedom of the Inverse Wishart distribution for
the covariance matrix Sigma. Typically set to the dimensionality of Sigma,
which in this bivariate case is 2.
\item \code{tau} The precision on the normal prior on the means mu.
}}
}
\value{
A list of length equal to the total number of groups in all
communities. Each entry is named 1.1 1.2... 2.1.. with the first number
designating the community, and the second number the group within that
community. So, 2.3 would be the third group within the second community.
Each list entry is a 6 x n matrix representing the back-transformed posterior
distributions of the bivariate normal distribution, where n is the number of
posterior draws in the saved sample. The first two columns are the back-
transformed means, and the remaining four columns are the covariance matrix
Sigma in vector format. This vector converts to the covariance matrix as
\code{matrix(v[1:4], nrow = 2, ncol = 2)}.
}
\description{
This function loops over each community and then loops over each group
member, fitting a Bayesian multivariate (bivariate in this case) normal
distribution to each group of data. Not intended for direct calling by users.
}
