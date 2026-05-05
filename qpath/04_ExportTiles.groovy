// ============================================================
// CONFIG - Edit only this block
// ============================================================
def outputDir = new File("C:/Users/YourName/output")   // Output directory
def tileSize = 512                                       // Must match CreateTiles.groovy
// ============================================================

import qupath.lib.regions.RegionRequest
import javax.imageio.ImageIO

def imageData = getCurrentImageData()
def server = imageData.getServer()
def hierarchy = getCurrentHierarchy()

def tiles = hierarchy.getAllObjects(false).findAll {
    it.getClass().getSimpleName() == "PathAnnotationObject" &&
    it.getROI().getBoundsWidth() == tileSize &&
    it.getName() != null &&
    !it.getName().isEmpty()
}

print("Exporting ${tiles.size()} tiles...")

outputDir.mkdirs()

tiles.eachWithIndex { tile, idx ->
    def roi = tile.getROI()
    def request = RegionRequest.createInstance(server.getPath(), 1.0, roi)
    def img = server.readRegion(request)

    def fileName = "${tile.getName()}.tif"
    def outputFile = new File(outputDir, fileName)

    ImageIO.write(img, "TIFF", outputFile)

    if (idx % 100 == 0)
        print("Exported ${idx} / ${tiles.size()} tiles...")
}

print("Done! Exported ${tiles.size()} tiles to ${outputDir}")
