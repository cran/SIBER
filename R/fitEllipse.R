#' Fit a multivariate normal distribution to x and y data using jags
#'
#' This function contains and defines the jags model script used to fit a
#' bivariate normal distribution to a vector of x and y data. Although not
#' intended for direct calling by users, it presents a quick way to fit a model
#' to a single group of data. Advanced users should be able to manipulate the
#' contained jags model to fit more complex models using different likelihoods,
#' such as multivariate lognormal distributions, multivariate gamma
#' distributions etc...
#'
#' @param x a vector of data representing the x-axis
#' @param y a vector of data representing the y-axis
#' @param parms a list containing four items providing details of the
#'   [rjags::rjags()] run to be sampled.
#'   
#'   * `n.iter` The number of iterations to sample
#'   
#'   * `n.burnin` The number of iterations to discard as a burnin from the 
#'   start of sampling.
#'   
#'   * `n.thin` The number of samples to thin by.
#'   
#'   * `n.chains` The number of chains to fit.
#'   
#' @param priors a list of three items specifying the priors to be passed to the
#'   jags model. 
#'   
#'   * `R` The scaling vector for the diagonal of
#'   Inverse Wishart distribution prior on the covariance matrix Sigma.
#'   Typically set to a 2x2 matrix `matrix(c(1, 0, 0, 1), 2, 2)`.
#'   
#'   * `k` The
#'   degrees of freedom of the Inverse Wishart distribution for the covariance
#'   matrix Sigma. Typically set to the dimensionality of Sigma, which in this
#'   bivariate case is 2.
#'   
#'   * `tau` The precision on the normal prior on the
#'   means mu.
#'   
#' @param id a character string to prepend to the raw saved jags model output.
#'   This is typically passed on from the calling function
#'   [siberMVN()] and identifies the community and group with an
#'   integer labelling system. Defaults to NULL which will prevent the output
#'   object being saved even if \code{parms$save.output} is set to `TRUE`.
#'   The file itself will be saved to the user-specified location via
#'   `parms$save.dir`.
#' @return A mcmc.list object of posterior samples created by jags.
#' @examples
#' x <- stats::rnorm(50)
#' y <- stats::rnorm(50)
#' parms <- list()
#' parms$n.iter <- 2 * 10^3
#' parms$n.burnin <- 500
#' parms$n.thin <- 2
#' parms$n.chains <- 2
#' priors <- list()
#' priors$R <- 1 * diag(2)
#' priors$k <- 2
#' priors$tau.mu <- 1.0E-3
#' fitEllipse(x, y, parms, priors)
#'
#' @export

fitEllipse <- function (x, y, parms, priors, id = NULL) 
{
  
  # some input argument checking
  if (!is.null(parms$save.output) && parms$save.output && 
      is.null(parms$save.dir)) {
    stop("You set parms$save.output <- T, so you must provide 
         a valid directory in which to save the files. This might 
         be parms$save.dir <- getwd() to set it to your current 
         working directory.")
  }

  # ----------------------------------------------------------------------------
  # JAGS code for fitting Inverse Wishart version of SIBER to a single group
  # ----------------------------------------------------------------------------
  
  modelstring <- '
    
    model {
    # ----------------------------------
    # define the priors
    # ----------------------------------
    
    # this loop defines the priors for the means
    for (i in 1:n.iso) {
      mu[i] ~ dnorm (0, tau.mu)
    }
    
    # prior for the precision matrix
    tau[1:n.iso,1:n.iso] ~ dwish(R[1:n.iso,1:n.iso],k)
    
    # convert to covariance matrix
    Sigma2[1:n.iso, 1:n.iso] <- inverse(tau[1:n.iso, 1:n.iso]) 
    
    # calculate correlation coefficient
    # rho <- Sigma2[1,2]/sqrt(Sigma2[1,1]*Sigma 2[2,2])
    
    #----------------------------------------------------
    # specify the likelihood of the observed data
    #----------------------------------------------------
    
    for(i in 1:n.obs) {                             
      Y[i,1:2] ~ dmnorm(mu[1:n.iso],tau[1:n.iso,1:n.iso])
    }
    
    
    
  }' # end of jags model script
  
  
  # ----------------------------------------------------------------------------
  # Prepare objects for passing to jags
  # ----------------------------------------------------------------------------
  
  
  Y = cbind(x,y)
  n.obs <- nrow(Y)
  n.iso <- ncol(Y)
  
  jags.data <- list("Y"= Y, "n.obs" = n.obs, "n.iso" = n.iso,
                    "R"= priors$R, "k" = priors$k, "tau.mu" = priors$tau.mu)
  
  inits <- list(
    list(mu = stats::rnorm(2,0,1)),
    list(mu = stats::rnorm(2,0,1))
  )
  
  
  # monitor all the parameters
  parameters <- c("mu","Sigma2")
  
  model_connection <- textConnection(modelstring)
  
  model <- rjags::jags.model(model_connection,
                             data = jags.data, n.chains = parms$n.chains)
  
  output <- rjags::coda.samples(model = model,
                                variable.names = c("mu",'Sigma2'),
                                n.iter = parms$n.iter,
                                thin = parms$n.thin
                                )
  
  if (!is.null(id) && !is.null(parms$save.output) && parms$save.output) {
    save(output, 
         file = paste0(parms$save.dir, "/jags_output_", id, ".RData"))
    }
  
  #print(summary(output))
  #print(dim(output[[1]]))
  
  

  close(model_connection)
  
  return(output)


}






