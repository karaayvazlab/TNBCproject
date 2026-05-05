// ============================================================
// CONFIG - Edit only this block
// ============================================================
def tissueFoldClass = "TissueFold"   // Classification or name label to detect folds
def tileSize = 512                    // Must match CreateTiles.groovy
// ============================================================

def hierarchy = getCurrentHierarchy()
def allAnnotations = getAnnotationObjects()

def tissueFolds = allAnnotations.findAll { annotation ->
    def name = annotation.getName()
    def classification = annotation.getPathClass()

    (name != null && name.contains(tissueFoldClass)) ||
    (classification != null && classification.toString().contains(tissueFoldClass))
}

print("Found ${tissueFolds.size()} TissueFold annotations")

if (tissueFolds.isEmpty()) {
    print("No TissueFold annotations found. Exiting.")
    return
}

def tiles = allAnnotations.findAll { it != null && !tissueFolds.contains(it) }

def toRemove = []

tiles.each { tile ->
    def tileGeometry = tile.getROI().getGeometry()
    tissueFolds.each { fold ->
        if (tileGeometry.intersects(fold.getROI().getGeometry())) {
            toRemove.add(tile)
        }
    }
}

toRemove.addAll(tissueFolds)

hierarchy.removeObjects(toRemove, true)
fireHierarchyUpdate()

print("Removed ${toRemove.size() - tissueFolds.size()} tiles and ${tissueFolds.size()} TissueFold annotations.")
print("Remaining tiles: ${tiles.size() - (toRemove.size() - tissueFolds.size())}")
