% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bayesianOverlap.R
\name{bayesianOverlap}
\alias{bayesianOverlap}
\title{Calculate the overlap between two ellipses based on their posterior
distributions.}
\usage{
bayesianOverlap(
  ellipse1,
  ellipse2,
  ellipses.posterior,
  draws = 10,
  p.interval = 0.95,
  n = 100,
  do.plot = FALSE
)
}
\arguments{
\item{ellipse1}{character code of the form \code{"x.y"} where \code{x} is an
integer indexing the community, and \code{y} an integer indexing the group
within that community. This specifies the first of two ellipses whose
overlap will be compared.}

\item{ellipse2}{same as \code{ellipse1} specifying a second ellipse.}

\item{ellipses.posterior}{a list of posterior means and covariances fitted
using \code{\link[=siberEllipses]{siberEllipses()}}.}

\item{draws}{an integer specifying how many of the posterior draws are to be
used to estimate the posterior overlap. Defaults to \code{10} which uses
the first 10 draws. In all cases, the selection will be \code{1:draws} so
independence of the posterior draws is assumed. Setting to \code{NULL} will
use all the draws (WARNING - like to be very slow).}

\item{p.interval}{the prediction interval used to scale the ellipse as per
\code{\link[=addEllipse]{addEllipse()}}.}

\item{n}{the number of points on the edge of the ellipse used to define it.
Defaults to \code{100} as per \code{\link[=addEllipse]{addEllipse()}}.}

\item{do.plot}{logical switch to determine whether the corresponding ellipses
should be plotted or not. A use-case would be in conjunction with a low
numbered \code{draws} so as to visualise a relatively small number of the
posterior ellipses. Defaults to \code{FALSE}.}
}
\value{
A data.frame comprising three columns: the area of overlap, the area
of the first ellipse and the area of the second ellipse and as many rows as
specified by \code{draws}.
}
\description{
This function loops over the posterior distribution of the means and
covariances matrices of two specified groups.
}
