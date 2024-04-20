rm(list=ls())

args = (commandArgs(trailingOnly=TRUE))
if(length(args) == 2){
  process = as.numeric(args[1])
  dir = args[2]
} else {
  cat('usage: Rscript myscript.R <process> <output tfile>\n', file=stderr())
  stop()
}

cat("Hello, world (stdout).\n") # This line goes to stdout. Next lines goes to outfile.

# sink(file=outfile) # send stdout to outfile from now on
require("FITSio")
if (require("FITSio")) { # require() is like library(), but returns TRUE or FALSE
  print("Loaded package FITSio.")
} else {
  print("Failed to load package FITSio.")  
}

cat(sep="", "Hello from the R job in process=", process, ".\n")
cB58 = readFrameFromFITS("cB58_Lyman_break.fit") # use FITSio package
print("cB58 done!")
# grab the data
data = list.files(dir)
print(head(data))
print("3586 data done!")

n = nrow(cB58)
# print("nrow of cB58 is:"); print(n)
n_data = length(data)
# n_data = 3
distances = numeric(n_data)
best_shift = numeric(n_data)
new_cB58 = scale(cB58$FLUX)
# print("new_cB58 is:"); print(head(new_cB58))

for (i in 1:n_data) {
  path = paste0(dir,"/",data[i])
  spectrum <- readFrameFromFITS(path)
  #skip some bad data
  if (sum(spectrum$and_mask != 0) > 0.6 * nrow(spectrum)) {
    distances[i]=70
    next
  }
  # Outliers
  spectrum$flux[spectrum$and_mask == 1] <- NA  # Set the outlier to NA or some other appropriate value
  # Use mean substitution of adjacent values for outliers
  na_indices <- which(is.na(spectrum$flux))
  
  # Replace missing value
  for (na_index in na_indices) {
    if (na_index > 1 && na_index < length(spectrum$flux)) {
      spectrum$flux[na_index] <- mean(c(spectrum$flux[na_index - 1], spectrum$flux[na_index + 1]), na.rm = TRUE)
    } else if (na_index == 1) {
      spectrum$flux[na_index] <- spectrum$flux[na_index + 1]
    } else if (na_index == length(spectrum$flux)) {
      spectrum$flux[na_index] <- spectrum$flux[na_index - 1]
    }
  }
  
  spec <- spectrum$flux
  min_d <- Inf
  best_i <-  1
  for (j in 1:(length(spec)-n+1)) {
    new_spec <- scale(spec[j:(j + n - 1)])
    d <- sqrt(sum((new_cB58-new_spec)^2))
    if (d <= min_d) {
      min_d <- d
      best_i <- j
    }
  }
  distances[i] <- min_d
  best_shift[i] <- best_i
}
print("the loop is done!")

sorted_indices <- order(distances)
distance <- distances[sorted_indices]
spectrumID <- data[sorted_indices]
i <- best_shift[sorted_indices]

df <- data.frame(distance, spectrumID, i)

write.csv(df, file = paste0(dir, ".csv"), row.names = FALSE)

# print("fitting is done!")

cat("\n")
# To make the next tidyverse line work, uncomment it and use the posted
#   packages_FITSio_tidyverse.tar.gz
# file instead of packages_FITSio.tar.gz. Also change 
# "request_disk = 1MB" to "request_disk = 1GB" in myscript.sub.
# mtcars %>% summarize(mean_mpg=mean(mpg), sd_mpg=sd(mpg)) # use tidyverse

sink() # stop sending stdout to outfile
