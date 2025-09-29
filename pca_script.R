


#!/usr/bin/env Rscript

# PCA script with multiple hyperparameter sets from JSON
# Usage: Rscript pca_hyperparams.R hyperparams.json

suppressPackageStartupMessages(library(jsonlite))
suppressPackageStartupMessages(library(ggplot2))

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1) {
  stop("Usage: Rscript pca_hyperparams.R hyperparams.json")
}

json_file <- args[1]

# Read hyperparameter sets
hyperparams_list <- fromJSON(json_file)

# Load IRIS dataset
df <- datasets::iris
num_df <- df[, sapply(df, is.numeric), drop = FALSE]

# Define output directory
output_dir <- file.path(getwd(), "outputs")
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# Function to process one hyperparameter set
run_pca_with_hyperparams <- function(df, num_df, n_components, plot_components, output_dir, set_id) {
  
  if (n_components < 2 || n_components > ncol(num_df)) {
    warning(sprintf("Skipping hyperparameter set %d: invalid n_components", set_id))
    return(NULL)
  }
  
  # Compute PCA
  pca <- prcomp(num_df, center = TRUE, scale. = TRUE)
  
  # Keep only requested number of PCs
  pcs <- as.data.frame(pca$x[, 1:n_components, drop = FALSE])
  df_with_pcs <- cbind(df, pcs)
  
  # Save augmented dataframe
  csv_file <- file.path(output_dir, sprintf("iris_with_pcs_set%d.csv", set_id))
  write.csv(df_with_pcs, csv_file, row.names = FALSE)
  
  # Plot requested PCs
  pc_x <- paste0("PC", plot_components[1])
  pc_y <- paste0("PC", plot_components[2])
  
  if (!pc_x %in% colnames(df_with_pcs) || !pc_y %in% colnames(df_with_pcs)) {
    warning(sprintf("Skipping plot for hyperparameter set %d: PCs to plot not computed", set_id))
    return(NULL)
  }
  
  p <- ggplot(df_with_pcs, aes_string(x = pc_x, y = pc_y, color = "Species")) +
    geom_point(size = 2) +
    theme_minimal() +
    ggtitle(sprintf("PCA Hyperparam Set %d: %s vs %s", set_id, pc_x, pc_y))
  
  png_file <- file.path(output_dir, sprintf("iris_pca_plot_set%d.png", set_id))
  ggsave(png_file, plot = p, width = 6, height = 5, dpi = 300)
}

# Loop over hyperparameter sets
n <- nrow(hyperparams_list)
all_n_components <- hyperparams_list$n_components
all_plot_components <- hyperparams_list$plot_components

for (i in seq_len(n)) {
	
	cat(sprintf("Computing PCA with hyperparameter set %d\n", i))
	n_components <- all_n_components[[i]]
	plot_components <- all_plot_components[[i]]
  
  run_pca_with_hyperparams(
    df,
    num_df,
    n_components,
    plot_components,
    output_dir = output_dir,
    set_id = i
  )
}




















