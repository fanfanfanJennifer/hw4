rm(list=ls())
library("FITSio")
file = dir("data/")
cB58=readFrameFromFITS("cB58_Lyman_break.fit")

#remove noise
exp = function(y, x){
  len=length(y)
  z=rep(0,len)
  z[1]=y[1]
  for (i in 2:len) {
    z[i]=x*y[i]+(1-x)*z[i-1]
  }
  return(z)
}

#finding local minimum
min = function(y){
  quantile = quantile(y, probs = 0.25)
  len = length(y)
  diff = diff(y)
  min_i = rep(0,len)
  for (i in 2:(len-2)) {
    if (diff[i]<0 & diff[i-1]<0 & diff[i+1]>0 & y[i+1]<quantile) {
      min_i[i+1]=i+1
    }
  }
  min_i=min_i[which(min_i!=0)]
  return(min_i)
}

#organize flux and find cB58 minimum index
cB58std = scale(cB58$FLUX)
cB58len = length(cB58$FLUX)
expcB58 = exp(cB58std, 0.05)
cB58min_i = which.min(expcB58)

#combine the empty values
distance = c()
spectrumID = c()
i = c()
for (name in file) {
  spectrum = readFrameFromFITS(paste("data", name, sep = "/"))
  
#remove empty observations from and_mask
  normal = length(which(spectrum$and_mask == 0))
  if (normal > cB58len) {
    spectrum$flux[which(spectrum$and_mask != 0)] = NA
    flux = na.omit(spectrum$flux)
  }
  else {
    flux = spectrum$flux
  }
  spectrum_standard = scale(flux)
  expspectrum=exp(spectrum_standard, 0.05)
  
#minimum expspectrum and correlation
  m = min(expspectrum)
  spectrumlength = length(expspectrum)
  m = m[which(m>cB58min_i)]
  m = m[which(m+cB58len<spectrumlength)] 
  top = -1
  for (tp in m) {
    start_i = tp-cB58min_i
    y = expspectrum[start_i:(start_i+cB58len-1)]
    cor = cor(expcB58, y, method = "pearson")
    if (cor > top) {
      top = cor
      begin_i = start_i
    }
  }
  distance = c(distance, top)
  distance = 1-distance
  spectrumID = c(spectrumID, name)
  i = c(i, begin_i)
}

#create dataframe
output <- data.frame(distance = distance, spectrumID = spectrumID, i = i)
output <- output[order(output$distance),]
write.csv(output, "hw4best100.csv", row.names = FALSE)
