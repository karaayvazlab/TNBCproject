// ============================================================
// CONFIG - Edit only this block
// ============================================================
def tileSize = 512   // Tile size (pixels)
// ============================================================

def annotations = getAnnotationObjects()
def totalTiles = 0

print("Creating ${tileSize}x${tileSize} tiles inside ${annotations.size()} annotations...")

annotations.each { annotation ->
    def annotationROI = annotation.getROI()
    def minX = annotationROI.getBoundsX()
    def minY = annotationROI.getBoundsY()
    def maxX = minX + annotationROI.getBoundsWidth()
    def maxY = minY + annotationROI.getBoundsHeight()

    for (int y = minY; y < maxY; y += tileSize) {
        for (int x = minX; x < maxX; x += tileSize) {
            def tileROI = ROIs.createRectangleROI(x, y, tileSize, tileSize, annotationROI.getImagePlane())
            def centerX = x + tileSize / 2
            def centerY = y + tileSize / 2

            if (annotationROI.contains(centerX, centerY)) {
                def tile = PathObjects.createAnnotationObject(tileROI)
                annotation.addChildObject(tile)
                totalTiles++
            }
        }
    }
}

fireHierarchyUpdate()
print("Created ${totalTiles} tiles.")
