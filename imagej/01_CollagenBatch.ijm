// COLLAGEN BATCH PROCESSING - MASSON'S TRICHROME
// ================================================
// USAGE:
// 1. Open Fiji
// 2. Plugins -> Macros -> Run
// 3. Select input folder (contains .tif tiles from QuPath)
// 4. Wait!

// Input folder selection
inputDir = getDirectory("Select input folder (QuPath tile folder)");

print("\\Clear");
print("===========================================");
print("COLLAGEN BATCH PROCESSING - MASSON'S TRICHROME");
print("===========================================");
print("Selected folder: " + inputDir);

// Output folder: inputDir + _collagen
folderName = File.getName(inputDir);
collagenDir = inputDir + folderName + "_collagen" + File.separator;
File.makeDirectory(collagenDir);

if (!File.exists(collagenDir)) {
    print("ERROR: Could not create output folder!");
    print("Attempted path: " + collagenDir);
    exit();
}

print("Output folder: " + collagenDir);
print("Output folder created OK");

// Count TIF files
list = getFileList(inputDir);
Array.sort(list);
tifCount = 0;
for (i = 0; i < list.length; i++) {
    if (!File.isDirectory(inputDir + list[i])) {
        if (endsWith(list[i], ".tif") || endsWith(list[i], ".tiff")) {
            tifCount++;
        }
    }
}
print("Found " + tifCount + " TIF files");
print("===========================================");
print(" ");

setBatchMode(true);

totalProcessed = 0;
totalErrors = 0;

print("Starting batch processing...");
print(" ");

for (i = 0; i < list.length; i++) {
    if (File.isDirectory(inputDir + list[i])) {
        continue;
    }

    if (endsWith(list[i], ".tif") || endsWith(list[i], ".tiff")) {

        fullPath = inputDir + list[i];

        if (totalProcessed % 100 == 0 && totalProcessed > 0) {
            print("Progress: " + totalProcessed + "/" + tifCount + " images processed");
        }

        open(fullPath);
        if (nImages == 0) {
            print("  ERROR: Could not open: " + list[i]);
            totalErrors++;
            continue;
        }
        originalTitle = getTitle();

        // Step 1: RGB Color Deconvolution
        run("Colour Deconvolution2", "vectors=RGB output=8bit_Transmittance simulated cross hide");

        colour1Name = originalTitle + "-(Colour_1)";
        colour2Name = originalTitle + "-(Colour_2)";
        colour3Name = originalTitle + "-(Colour_3)";

        if (!isOpen(colour1Name) || !isOpen(colour2Name) || !isOpen(colour3Name)) {
            print("  ERROR: RGB Deconvolution failed for: " + list[i]);
            while (nImages > 0) { close(); }
            totalErrors++;
            continue;
        }

        // Step 2: Merge channels
        run("Merge Channels...", "c1=[" + colour3Name + "] c2=[" + colour2Name + "] c3=[" + colour1Name + "] create ignore");
        compositeName = "Composite (RGB)";

        // Step 3: RGB Color
        run("RGB Color");

        // Step 4: Dichromacy (Deuteranope)
        run("Dichromacy", "simulate=Deuteranope create");
        deuteranopeName = compositeName + "-Deuteranope";
        wait(100);

        if (!isOpen(deuteranopeName)) {
            print("  ERROR: Dichromacy failed for: " + list[i]);
            while (nImages > 0) { close(); }
            totalErrors++;
            continue;
        }

        // Step 5: Color Deconvolution (Masson's Trichrome vectors)
        selectWindow(deuteranopeName);
        run("Colour Deconvolution", "vectors=[User values] [r1]=0.57 [g1]=0.648 [b1]=0.505 [r2]=0.794 [g2]=0.556 [b2]=0.244 [r3]=0.618 [g3]=0.585 [b3]=0.525");

        finalColour2 = deuteranopeName + "-(Colour_2)";

        if (!isOpen(finalColour2)) {
            print("  ERROR: Final deconvolution failed for: " + list[i]);
            while (nImages > 0) { close(); }
            totalErrors++;
            continue;
        }

        // Close unnecessary windows
        if (isOpen(deuteranopeName + "-(Colour_1)")) { selectWindow(deuteranopeName + "-(Colour_1)"); close(); }
        if (isOpen(deuteranopeName + "-(Colour_3)")) { selectWindow(deuteranopeName + "-(Colour_3)"); close(); }
        if (isOpen(deuteranopeName)) { selectWindow(deuteranopeName); close(); }
        if (isOpen("Colour Deconvolution")) { selectWindow("Colour Deconvolution"); close(); }
        if (isOpen(compositeName)) { selectWindow(compositeName); close(); }
        if (isOpen(originalTitle)) { selectWindow(originalTitle); close(); }

        // Step 6: Final processing
        selectWindow(finalColour2);
        run("Grays");
        run("Invert");
        run("Enhance Contrast...", "saturated=0.35");
        resetMinAndMax();
        setMinAndMax(55, 255);
        run("Apply LUT");

        // Output filename: TMAID_CoreID_0001_col.tif
        filename = list[i];
        dotIndex = lastIndexOf(filename, ".");
        basename = substring(filename, 0, dotIndex);
        outputName = basename + "_col.tif";
        outputPath = collagenDir + outputName;

        saveAs("Tiff", outputPath);

        if (!File.exists(outputPath)) {
            print("  ERROR: Failed to save: " + outputName);
            totalErrors++;
        } else {
            totalProcessed++;
        }

        close();
    }
}

setBatchMode(false);

print(" ");
print("===========================================");
print("DONE!");
print("===========================================");
print("Total processed: " + totalProcessed + " images");
print("Total errors: " + totalErrors);
print("Output: " + collagenDir);
print("===========================================");

beep();
