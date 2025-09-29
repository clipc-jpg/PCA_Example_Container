#!/usr/bin/env Rscript

# Shiny app for creating PCA hyperparameter config files
# with validation before allowing download

library(shiny)
library(shinyjs)
library(jsonlite)

interop_mode <- "--colony-interop" %in% commandArgs(trailingOnly = TRUE)

# defines ui
source("shiny_ui.R")

#defines server
source("shiny_server.R")

shinyApp(ui, server, options = list(port = 9283))

