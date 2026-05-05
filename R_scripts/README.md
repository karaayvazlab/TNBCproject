# R - Collagen Feature Extraction

Processes CurveAlign (CA) output files and builds a feature matrix per core.

## What it does

1. Finds all `_col_fibFeatures.csv` files in the CA output folder
2. For each core, aggregates tile-level fiber statistics (median, kurtosis, skewness, variance)
3. Appends alignment stats from `_stats` files
4. Saves a per-core CSV and a combined `BigMatrix.csv`

## Usage

1. Run `01_CollagenFeatures.R` in R or RStudio
2. Edit the `SETTINGS` block at the top:

| Parameter | Description |
|---|---|
| `ca_out_path` | Folder containing CA output CSV files |
| `output_path` | Folder for per-core CSVs |
| `bigmatrix_path` | Folder for BigMatrix.csv |

## Input / Output

| | Format |
|---|---|
| Input | `TMAID_CoreID_0001_col_fibFeatures.csv` |
| Output (per core) | `CoreID.csv` |
| Output (combined) | `BigMatrix.csv` |

## Dependencies

```r
install.packages("moments")
```
