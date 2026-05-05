# Environment cleanup
rm(list = ls())
library(moments)

# ============== SETTINGS ==============
ca_out_path    <- 'C:/Users/YourName/CA_Out'
output_path    <- 'C:/Users/YourName/Output'
bigmatrix_path <- 'C:/Users/YourName/BigMatrix'

# Parameters to exclude from output
remove_params <- c('end point row', 'end point col', 'fiber weight',
                   'nearest dist to bound', 'inside epi region',
                   'nearest relative boundary angle', 'extension point distance',
                   'extension point angle', 'boundary point row', 'boundary point col')
# =======================================

# Create output directories
if (!dir.exists(output_path))    dir.create(output_path,    recursive = TRUE)
if (!dir.exists(bigmatrix_path)) dir.create(bigmatrix_path, recursive = TRUE)

# Locate all fibFeatures CSV files
all_files <- list.files(ca_out_path,
    pattern   = '.*_col_fibFeatures\\.csv$',
    full.names = TRUE)

# Extract unique core IDs (e.g. TNBC_A1 from TNBC_A1_0001_col_fibFeatures.csv)
core_ids <- unique(gsub(
    '^(.*?)_[0-9]+_col_fibFeatures\\.csv$', '\\1',
    basename(all_files)))
cat('Total cores:', length(core_ids), '\n')
cat('Core IDs:', paste(core_ids, collapse = ', '), '\n')

all_core_data <- list()

for (core_id in core_ids) {
  cat('\nProcessing:', core_id, '...')

  tryCatch({
    pattern    <- paste0('^', core_id, '_[0-9]+_col_fibFeatures\\.csv$')
    tile_files <- list.files(ca_out_path, pattern = pattern, full.names = TRUE)

    if (length(tile_files) == 0) { cat(' SKIPPED - No tiles\n'); next }

    # Read feature names
    feat_names_file   <- gsub('fibFeatures', 'fibFeatNames', tile_files[1])
    param_names       <- read.csv(feat_names_file)
    param_names_clean <- gsub('^f[0-9]+\\s*:\\s*', '', param_names[,1])

    # Process each tile
    tile_results <- lapply(tile_files, function(file) {
      tryCatch({
        tile_id      <- gsub('_col_fibFeatures.csv', '', basename(file))
        data         <- read.csv(file)[, -1]
        fiber_count  <- nrow(data)

        medians    <- sapply(data, median,   na.rm = TRUE)
        kurtoses   <- sapply(data, kurtosis, na.rm = TRUE)
        skewnesses <- sapply(data, skewness, na.rm = TRUE)
        variances  <- sapply(data, var,      na.rm = TRUE)

        feature_results <- c()
        for (i in 1:length(medians)) {
          fn <- param_names_clean[i]
          feature_results <- c(feature_results,
            setNames(medians[i],    paste0(fn, '_median')),
            setNames(kurtoses[i],   paste0(fn, '_kurtosis')),
            setNames(skewnesses[i], paste0(fn, '_skewness')),
            setNames(variances[i],  paste0(fn, '_variance')))
        }

        # Read alignment stats file
        stats_file <- gsub('fibFeatures', 'stats', file)
        if (file.exists(stats_file)) {
          stats_data   <- read.delim(stats_file, header = FALSE, sep = '\t')
          stats_values <- setNames(stats_data$V2[1:8], stats_data$V1[1:8])
        } else {
          stats_values <- rep(NA, 8)
          names(stats_values) <- c('Mean', 'Median', 'Variance', 'Std Dev',
            'Coef of Alignment', 'Skewness', 'Kurtosis', 'Omni Test')
        }

        return(c(Tile_ID = tile_id, Fiber_Number = fiber_count,
                 feature_results, stats_values))
      }, error = function(e) NULL)
    })

    tile_results <- tile_results[!sapply(tile_results, is.null)]
    if (length(tile_results) == 0) { cat(' ERROR - All tiles failed\n'); next }

    # Build per-core data frame
    final_df <- as.data.frame(do.call(rbind, tile_results),
                              stringsAsFactors = FALSE)
    final_df[, 2:ncol(final_df)] <- lapply(final_df[, 2:ncol(final_df)], as.numeric)

    # Remove boundary-related columns
    cols_to_remove <- unlist(lapply(remove_params, function(p)
      paste0(p, c('_median', '_kurtosis', '_skewness', '_variance'))))
    final_df <- final_df[, !colnames(final_df) %in% cols_to_remove]

    final_df <- cbind(CoreID = core_id, final_df)

    # Save per-core CSV
    write.csv(final_df,
              file.path(output_path, paste0(core_id, '.csv')),
              row.names = FALSE)

    all_core_data[[core_id]] <- final_df
    cat(' SUCCESS -', nrow(final_df), 'tiles\n')

  }, error = function(e) cat(' ERROR -', e$message, '\n'))
}

# Build and save BigMatrix
cat('\n=== Creating BigMatrix ===\n')
if (length(all_core_data) > 0) {
  bigmatrix      <- do.call(rbind, all_core_data)
  bigmatrix_file <- file.path(bigmatrix_path, 'BigMatrix.csv')
  write.csv(bigmatrix, bigmatrix_file, row.names = FALSE)
  cat('BigMatrix saved:', nrow(bigmatrix), 'rows,',
      ncol(bigmatrix), 'columns\n')
  cat('\n=== Core Distribution ===\n')
  print(table(bigmatrix$CoreID))
} else {
  cat('ERROR: No core data!\n')
}
