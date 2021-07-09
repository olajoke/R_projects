###################################################################################################
# Authors: Y*** ****, Olajoke Oladipo, W*** 
# Project: Prototyping Data Science Products
# File: init__.R
# Description: project initialization
###################################################################################################
# Input: create_api.R
# Output: back end running logic
###################################################################################################

# sourcing necessary files ----
source("src/create_api.R")


# install necessary packages --- it would be better to create a function
library(plumber)
library(jsonlite)
library(caret)
library(dplyr)
library(plumber)
library(readr)
library(gbm)

# running the back-end (APIs) ---
r <- plumb("src/create_api.R")
# Where 'plumber.R' is the location of the file shown above

# Run r on port 8000
r$run(host = "0.0.0.0",  port = 8080)