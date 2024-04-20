rm(list = ls())
options(repos = c(CRAN = "https://cloud.r-project.org"))

install.packages("FITSio")
library("FITSio")
# Accept command-line arguments
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2) {
  cat("usage: Rscript hw4.R <template spectrum> <data directory>\n")
  quit(status = 1)
}
template_spectrum <- args[1]
data_directory <- args[2]
# noise remove functions
# exp smoothing function
exp <- function(y, x) {
  len <- length(y)
  z <- rep(0, len)
  z[1] <- y[1]
  for (i in 2:len) {
    z[i] <- x * y[i] + (1 - x) * z[i - 1]
  }
  return(z)
}


# moving_average_denoise function
moving_average <- function(y, w) { # w is the window_size
  n <- length(y)
  z <- numeric(n)
  for (i in 1:n) {
    start <- max(1, i - w + 1)
    end <- min(n, i + w - 1)
    z[i] <- mean(y[start:end])
  }
  return(z)
}


# Read template spectrum
cB58 <- readFrameFromFITS(template_spectrum)


# Read other files
files <- list.files(data_directory, pattern = "\\.fits$", full.names = TRUE)

# Define distances and shifts
distances <- numeric(length(files))
shifts <- numeric(length(files))

# Search for the largest r
for (i in 1:length(files)) {
  # Read the ith spectrum
  data <- readFrameFromFITS(files[i])
  
  # Remove noise
  data$flux <- moving_average(data$flux, 9)
  # data$flux <- exp(data$flux, 0.1)
  
  # Define correlations vector
  if (length(data$flux) < length(cB58$FLUX)){
    correlations=0
    next
  }
  correlations <- numeric(length(data$flux) - length(cB58$FLUX) + 1)
  # Calculate correlations one by one
  for (j in 1:(length(data$flux) - length(cB58$FLUX) + 1)) {
    # Remove the data that and_mask !=0
    adjust_flux <- data$flux[j:(j + length(cB58$FLUX) - 1)]
    adjust_mask <- data$and_mask[j:(j + length(cB58$FLUX) - 1)]
    
    data_subset <- adjust_flux[adjust_mask == 0]
    cB58_subset <- cB58$FLUX[adjust_mask == 0]
    
    # Calculate the correlations for this data
    correlations[j] <- cor(cB58_subset, data_subset)
  }
  
  # Take the max correlations and mark the shift
  distances[i] <- max(correlations)
  if (length(correlations) == 0 || max(correlations, na.rm = TRUE) == 0 || any(is.na(correlations))) {
    shifts[i] <-0
  }else{
    shifts[i]<- which.max(correlations)
  }
}

# Write output to a CSV file
output_file <- paste0(data_directory, ".csv")
orders <- data.frame(distance = distances, spectrumID = basename(files), i = shifts)
orders <- orders[order(distances), decreasing=True]
write.csv(orders, file = output_file, row.names = FALSE)
