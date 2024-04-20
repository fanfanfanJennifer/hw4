rm(list = ls())
options(repos = c(CRAN = "https://cloud.r-project.org"))

install.packages("FITSio")
library("FITSio")
args = (commandArgs(trailingOnly = TRUE))
if (length(args) == 2) {
  process = as.numeric(args[1])
  dir = args[2]
} else {
  cat('usage: Rscript myscript.R <process> <dir>\n', file = stderr())
  stop()
}

cB58 = readFrameFromFITS("cB58_Lyman_break.fit")
n = dim(cB58)[1]
files = list.files(dir)
n_files = length(files)
distances = vector(mode = "numeric", length = n_files)
best_shift = vector(mode = "numeric", length = n_files)
new_cB58 = (cB58$FLUX - mean(cB58$FLUX)) / sd(cB58$FLUX)
for (i in 1:n_files) {
  path = paste0(dir, "/", files[i])
  data = readFrameFromFITS(path)
  spec = data$flux
  mind = Inf
  besti = 1
  if (length(spec) < length(new_cB58)) {
    next
  } else {
    for (point in 1:(length(spec) - n + 1)) {
      new_spec = (spec[point:(point + n - 1)] - mean(spec[point:(point + n - 1)])) /sd(spec[point:(point + n - 1)])
      d = sqrt(sum((new_cB58 - new_spec) ^ 2))
      if (is.na(d)) {
        next
      } else {
        if (d < mind) {
          mind = d
          besti = point
        }
      }
      distances[i] = mind
      best_shift[i] = besti
    }
  }
}
for (i in 1:(length(distances))) {
  if (distances[i] == 0) {
    distances[i] == Inf
  }
}
distance = sort(distances, decreasing = FALSE)
spectrumID = noquote(files[order(distances)])
i = best_shift[order(distances)]
df = data.frame(distance, spectrumID, i)
daf = df[df$distance > 0,]
names(daf) = NULL
write.csv(daf, file = paste0(dir, ".csv"), row.names = FALSE)
