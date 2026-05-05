# QuPath TMA Tiling Pipeline

A scripts for tiling and exporting TMA (Tissue Microarray) whole slide images in QuPath.

## Pipeline Order

Run scripts in the following order:

| Step | Script | Description |
|------|--------|-------------|
| 1 | `01_CreateTiles.groovy` | Creates tiles inside annotations |
| 2 | `02_NameTiles.groovy` | Names tiles as `TMAID_CoreID_0001` |
| 3 | `03_RemoveTissueFolds.groovy` | Removes tiles overlapping tissue folds |
| 4 | `04_ExportTiles.groovy` | Exports tiles as `.tif` files |

## Configuration

Each script has a `CONFIG` block at the top. Edit only that block.

| Parameter | Script | Description |
|-----------|--------|-------------|
| `tileSize` | 01, 02, 03, 04 | Tile size in pixels (default: 512) |
| `tmaID` | 02 | Project name prefix (e.g. `TNBC`) |
| `tissueFoldClass` | 03 | Annotation label for tissue folds |
| `outputDir` | 04 | Output folder path |

## Classifiers

`classifiers/tnbc_mt.json` — Pixel classifier config for tissue detection.

## Output Format

```
TMAID_CoreID_0001.tif
TMAID_CoreID_0002.tif
```
