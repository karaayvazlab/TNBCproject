# TMA Collagen Analysis Pipeline

End-to-end pipeline for collagen quantification from TMA whole slide images.

## Pipeline Overview

```
WSI (TMA)
   │
   ▼
[QuPath] → Tile creation & export
   │
   ▼
[ImageJ/Fiji] → Collagen channel extraction
   │
   ▼
[CurveAlign] → Fiber feature extraction (manual step)
   │
   ▼
[R] → Feature aggregation → BigMatrix.csv
```

## Tools

| Folder | Tool | Description |
|---|---|---|
| `qupath/` | QuPath | Tile creation, naming, export |
| `imagej/` | Fiji | Masson's Trichrome collagen extraction |
| `r/` | R | CurveAlign output aggregation |

## File Naming Convention

All files follow: `TMAID_CoreID_0001.tif`

## Quick Start

1. Run `qupath/scripts/` in order (01 → 04)
2. Run `imagej/macros/01_CollagenBatch.ijm` on exported tiles
3. Run CurveAlign on `_col.tif` files
4. Run `r/01_CollagenFeatures.R` on CurveAlign output
