#!/bin/bash

# untar your R installation
tar -xzf R413.tar.gz
tar -xzf packages.tar.gz

export PATH=$PWD/R/bin:$PATH
export RHOME=$PWD/R
export R_LIBS=$PWD/packages

tar -xvzf $2.tgz

# run your script
Rscript hw4.R $1 $2 


