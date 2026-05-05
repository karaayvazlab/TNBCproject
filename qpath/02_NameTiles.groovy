// ============================================================
// CONFIG - Edit only this block
// ============================================================
def tmaID = "TNBC"       // TMA project ID
def tileSize = 512        // Must match CreateTiles.groovy
// ============================================================

def hierarchy = getCurrentHierarchy()

def allTiles = hierarchy.getAllObjects(false).findAll {
    it.getClass().getSimpleName() == "PathAnnotationObject" &&
    it.getROI().getBoundsWidth() == tileSize
}

def cores = hierarchy.getAllObjects(false).findAll {
    it.getClass().getSimpleName() == "TMACoreObject"
}

print("Found ${allTiles.size()} tiles")
print("Found ${cores.size()} cores")

def totalAssigned = 0

cores.each { core ->
    def coreID = core.getName().replace("-", "")  // e.g. A-1 → A1
    def coreTiles = allTiles.findAll { tile ->
        def cx = tile.getROI().getCentroidX()
        def cy = tile.getROI().getCentroidY()
        core.getROI().contains(cx, cy)
    }

    coreTiles.eachWithIndex { tile, idx ->
        def tileName = String.format("%s_%s_%04d", tmaID, coreID, idx + 1)
        tile.setName(tileName)
        totalAssigned++
    }

    print("${coreID}: ${coreTiles.size()} tiles")
}

fireHierarchyUpdate()
print("Assigned ${totalAssigned} tiles total.")
