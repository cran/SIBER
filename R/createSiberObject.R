#' Read in SIBER format data and generate the SIBER object
#'
#' This function takes raw isotope data and creates a SIBER object which
#' contains information in a structured manner that enables other functions to
#' loop over groups and communities, fit Bayesian ellipses, and afterwards,
#' generate various plots, and additional analyses on the posterior
#' distributions.
#' 
#' @name createSiberObject
#' @param data.in Specified In a basic R data.frame or matrix comprising 4
#'   columns. The first two of which are typically isotope tracers, then the
#'   third is a column that indicates the group membership, and the fourth
#'   column indicates the community membership of an observation. Communities
#'   labels should be entered  as sequential numbers. As of v2.0.1 group labels
#'   can be entered as strings and/or numbers and need not be sequential.
#' @return A siber list object, that contains data that helps with various model
#'   fitting and plotting. 
#'   * `original.data` The original data as
#'   passed into this function
#'   * `iso.summary` The max, min, mean and
#'   median of the isotope data useful for plotting
#'   * `sample.sizes` The
#'   number of observations tabulated by group and community
#'   * `raw.data` A list object of length equal to the number of communities
#' @examples
#' data(demo.siber.data)
#' my.siber.data <- createSiberObject(demo.siber.data)
#' names(my.siber.data)
#'
#' @export

## Define a set of global variables so tidyverse calls don't generate
# "no visible binding for global variable" warnings.
if(getRversion() >= "2.15.1")  utils::globalVariables(c("iso1", 
                                                        "iso2",
                                                        "group", 
                                                        "community"))

createSiberObject <- function (data.in) {

  
  # Check that the data.in object is a data.frame object only
  # If it is a tibble, then coerce to data.frame only and 
  # return a warning.
  if (any(class(data.in) %in% c("spec_tbl_df","tbl_df","tbl"))){
    warning("The data object supplied is of class tibble. 
            This has likely occurred owing to use of the 
            readr::read_csv() function to import the data. 
            The dataset has been coerced to an object of 
            class data.frame only using as.data.frame().
            You should check that this conversion has no 
            unintended consequences, and ideally you should
            convert it before passing it to createSiberObject 
            which will prevent this warning and allow you to 
            check that there has been no undesired change to the 
            data.")
    data.in <- as.data.frame(data.in)
  }
  
# Check that the column headers have exactly the correct string
if (!all(names(data.in) == c("iso1", "iso2", "group", "community"))){
  stop('The header names in your data file must match 
        c("iso1", "iso2", "group", "community") exactly')
}

# error if community is not a sequential numeric vector
# if (!is.numeric(data.in$community)){
#   stop('The community column must be a sequential numeric vector 
#        indicating the community membership of each observation.')
# } 
  
# force group and community variable to be factors
data.in$group <- as.factor(data.in$group)
data.in$community <- as.factor(data.in$community)
  
# create an object that is a list, into which the raw data, 
# its transforms, and various calculated metrics can be stored.
siber <- list()

# keep the original data in its original format just in case
# In fact, it can be easier to work with this format, as tapply
# works well on it. I half wonder if i could just keep all the data like this
# if i were able to use tapply more effectively on multiple inputs.
siber$original.data <- data.in

# store all the grouping labels
siber$all.groups <- levels(data.in$group)

# store all the community labels
siber$all.communities <- levels(data.in$community)


# some basic summary stats helpful for plotting
my.summary <- function(x){
	c(min = min(x), max = max(x), mean = mean(x), median = stats::median(x))
}

siber$iso.summary <- apply(data.in[,1:2], 2, my.summary)

siber$sample.sizes <- tapply(data.in[,1], 
                             list(data.in[,4], data.in[,3]), 
                             length)

if (any(siber$sample.sizes < 5, na.rm = TRUE)){
  warning("At least one of your groups has less than 5 observations.
          The absolute minimum sample size for each group is 3 in order
          for the various ellipses and corresponding metrics to be 
          calculated. More reasonably though, a minimum of 5 data points
          are required to calculate the two means and the 2x2 covariance 
          matrix and not run out of degrees of freedom. Check the item 
          named 'sample.sizes' in the object returned by this function 
          in order to locate the offending group. Bear in mind that NAs in 
          the sample.size matrix simply indicate groups that are not 
          present in that community, and is an acceptable data structure 
          for these analyses.")
}

# store the raw data as list split by the community variable
# and rename the list components
siber$raw.data <- split(data.in, data.in$community)
#names(siber$raw.data) <- paste("community", 
#                               unique(data.in$community), sep = "")

# how many communities are there
siber$n.communities <- length(unique(data.in$community))

# now many groups are in each community
siber$n.groups <- matrix(NA, 2, length(siber$raw.data), 
	                     dimnames = list(c("community", "n.groups"), 
                                       rep("", siber$n.communities)))
siber$n.groups[1, ] <- unique(data.in$community)
siber$n.groups[2, ] <- tapply(data.in$group, data.in$community, 
	                           function(x){length(unique(x))})

# ------------------------------------------------------------------------------
# create empty arrays in which to store the Maximum Likelihood estimates
# of the means and covariances for each group.
siber$ML.mu  <- list()
siber$ML.cov <- list()

siber$group.names <- list()

for (i in 1:siber$n.communities){

	siber$ML.mu[[i]]  <- array(NA, dim=c(1, 2, siber$n.groups[2,i]) )
	siber$ML.cov[[i]] <- array(NA, dim=c(2, 2, siber$n.groups[2,i]) )
}


# loop over each community and extract the Maximum Likelihood estimates
# of the location (their simple independent means) and covariance 
# matrix of each group that comprises the community.
# I hvae done this as a loop, as I cant see how to be clever
# and use some of the apply() or analogue functions.
for (i in 1:siber$n.communities) {
  
  siber$group.names[[i]] <- unique(siber$raw.data[[i]]$group)

	for (j in 1:siber$n.groups[2,i]) {

		# AJ - issue - (group == j)
		tmp <- subset(siber$raw.data[[i]], 
		              siber$raw.data[[i]]$group == siber$group.names[[i]][j])	
		
	    mu.tmp <- colMeans(cbind(tmp$iso1, tmp$iso2))
	    cov.tmp <- stats::cov(cbind(tmp$iso1, tmp$iso2))

	    siber$ML.mu[[i]][,,j] <- mu.tmp
	    siber$ML.cov[[i]][,,j] <- cov.tmp
	
	} # end of loop over groups
  
  # Add names to the dimensions of the array
  dimnames(siber$ML.mu[[i]]) <- list(NULL, 
                                     c("iso1", "iso2"), 
                                     siber$group.names[[i]])
  dimnames(siber$ML.cov[[i]]) <- list(c("iso1", "iso2"), 
                                      c("iso1", "iso2"), 
                                      siber$group.names[[i]])
} # end of loop over communities

names(siber$ML.mu) <- siber$all.communities
names(siber$ML.cov) <- siber$all.communities

# ------------------------------------------------------------------------------
# create z-score transformed versions of the raw data.
# we can then use the saved information in the mean and 
# covariances for each group stored in ML.mu and ML.cov
# to backtransform them later.

# first create a copy of the raw data into a list zscore.data
siber$zscore.data <-  siber$raw.data

for (i in 1:siber$n.communities) {
  
  # BUG - discovered 2020/5/11 per emails with Edward Doherty.
  # Incorrect ordering by tapply() meant z-scores were not correctly
  # applied within groups.
  
  
  # -- BUGGED CODE BEGIN --
  # apply z-score transform to each group within the community via tapply()
  # using the function scale()
  # siber$zscore.data[[i]][,1] <- unlist(tapply(siber$raw.data[[i]]$iso1,
  # 	                                          siber$raw.data[[i]]$group,
  # 	                                          scale))
  # siber$zscore.data[[i]][,2] <- unlist(tapply(siber$raw.data[[i]]$iso2,
  # 	                                          siber$raw.data[[i]]$group,
  # 	                                          scale))
  # 
  # -- BUGGED CODE END --
  
  
  
  
  
  ## -- HOT FIX BEGIN -- 
  # (plan to tidyverse the whole package)
  
  # take the raw data, group by "group" and 
  # transform iso1 and iso2 by scaling them and
  # finally converting to data.frame.
  siber$zscore.data[[i]] <- siber$raw.data[[i]] %>%
    group_by(group) %>% mutate(iso1 = scale(iso1),
                               iso2 = scale(iso2)) %>%
    data.frame()
  # 
  ## -- HOT FIX END   --

	
}

return(siber)

} # end of function




