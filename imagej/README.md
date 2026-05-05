# ImageJ TMA Collagen Pipeline

Batch macro for collagen quantification from Masson's Trichrome stained TMA tiles.

## What it does

Processes `.tif` tiles exported from QuPath and isolates the collagen channel using the following steps:

1. **RGB Color Deconvolution** — separates stain channels from the RGB image
2. **Channel Merge** — recombines channels for dichromacy simulation
3. **Dichromacy (Deuteranope)** — simulates red-green color blindness to enhance blue/collagen contrast
4. **Color Deconvolution** — applies Masson's Trichrome-specific vectors to isolate collagen signal
5. **Contrast adjustment** — applies grayscale LUT and sets min/max range (55–255)
6. **Save** — exports result as `_col.tif`

## Usage

1. Open Fiji
2. `Plugins → Macros → Run`
3. Select input folder containing QuPath `.tif` tiles
4. Wait — output folder is created automatically inside the input folder

## Input / Output

| | Format |
|---|---|
| Input | `TMAID_CoreID_0001.tif` |
| Output | `TMAID_CoreID_0001_col.tif` |

Output folder is created automatically as `<inputfolder>/<inputfolder>_collagen/`.

## Dependencies

- Fiji (ImageJ2)
- `Colour Deconvolution2` plugin
- `Dichromacy` plugin
