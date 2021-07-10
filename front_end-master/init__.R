###################################################################################################
# Author: Y********, Olajoke Oladipo, W***********
# Project: Prototyping Data Science Products
# File: init__.R
# Description: project initialisation
###################################################################################################
# Input: config.R
# Output: front end running logic
###################################################################################################

# sourcing necessary files ----
source("src/config.R")
source("src/run_shiny.R")
# install necessary packages --- it would be better to create a function
library(keyring)
library(shiny)
library(shinyWidgets)
library(shinythemes)
library(shinyjs)
library(shinyBS)
library(shinycssloaders)
library(DT)
library(tidyverse)
library(httr)
library(RPostgres)
library(RPostgreSQL)
library(DBI)
library(dplyr)
#library(plumber)

# running the front-end ---
run_shiny_front(external_ip, port)
