#!/bin/bash

# untar your R installation
tar -xzf R413.tar.gz
tar -xzf packages_FITSio.tar.gz
# If selecting next line, also change "transfer_input_files" line in
# myscript.sub to transfer the file.
#
# tar -xzf packages_FITSio_tidyverse.tar.gz

# make sure the script will use your R installation, 
# and the working directory as its home location
export PATH=$PWD/R/bin:$PATH
export RHOME=$PWD/R
export R_LIBS=$PWD/packages

# run your script
Rscript myscript.R $1 $2 # note: the two actual command-line arguments
                         # are in myscript.sub's "arguments = " line
