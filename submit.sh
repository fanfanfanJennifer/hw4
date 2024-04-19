#!/bin/bash

# This script isn't necesary. I wrote it only to document how to use
# the "condor_submit" command to run "myscript.sub".

condor_submit myscript.sub

# Note that using the tidyverse requires changing three files:
# - Include packages_FITSio_tidyverse.tar.gz among the transfer_input_files
#   in the ".sub" script.
# - Use tar to unpack the file in the ".sh" script that calls the ".R" script.
# - Use library() or require() to load the package in the ".R" script as usual.

# Using a package other than tidyverse requires changing these same
# three files. It also requires revising install_R.sh to refer to your
# package and then using interactive.sub to run install_R.sh (once) to
# produce a "packages_..._.tar.gz" file containing your package.
