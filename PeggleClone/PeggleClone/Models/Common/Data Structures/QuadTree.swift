import Foundation
import CoreGraphics
// swiftlint:disable line_length
// Reference: https://gamedevelopment.tutsplus.com/tutorials/quick-tip-use-quadtrees-to-detect-likely-collisions-in-2d-space--gamedev-374
// swiftlint:enable line_length
// The main difference in my implementation is that I do not store the
// bounding boxes of each node, rather calculate it dynamically based on
// the root's bounding box. This is mainly a memory optimization.
// Other differences include how I handle retrieval of potential neighbors
// such as optimizing using the getSubdivisionOverlappingIndices method.

private let branchFactor = 4 // by definition of a quad tree

/// Maximum number of objects in a quad tree leaf node before it must split.
/// Only applicable if max depth is not reached, such that if a leaf node has reached maximum depth,
/// no further splitting will occur regardless of how many entities there are in a leaf node.
private let maxObjectsPerLeaf = 8

/// Maximum depth a quad tree node can reach.
/// An upper bound is placed on the maximum depth so that the quad tree does not become inefficient.
/// Given the nature of this game (Peggle), it is practically impossible for the maximum depth to be reached.
private let maxDepth = 5

/// A quad tree data structure that acts the "broad" sweep during collision detection.
class QuadTree<T>: NeighborFinder where T: Equatable, T: HasBoundingBox, T: AnyObject {
    typealias Element = T
    private enum ChildIndex: Int {
        case topLeft = 0
        case topRight
        case bottomLeft
        case bottomRight
    }

    class QuadTreeNode {
        unowned var tree: QuadTree?
        let depth: Int

        /// Child nodes.
        var children: [QuadTreeNode]?

        /// Entities associated with the current node.
        var entities = LinkedList<T>()

        init(depth: Int, tree: QuadTree? = nil) {
            self.depth = depth
            self.tree = tree
        }

        /// Whether the current node is a leaf node.
        var isLeaf: Bool {
            children == nil
        }

        /// Clears all children and objects stored.
        func removeAll() {
            entities = LinkedList()
            children = nil
        }

        /// Adds 4 subnodes to leaf node.
        private func split() {
            guard isLeaf else {
                fatalError("Only a leaf node can be split")
            }
            logger.debug("QuadTreeNodes at depth \(self.depth + 1) produced")
            children = Array(repeatingFactory: { QuadTreeNode(depth: depth + 1, tree: tree) }, count: branchFactor)
        }

        /// Determines which node an object belongs to. Returns nil
        /// when node cannot fit within a child node and hence must stay
        /// in the parent node.
        private func getSubdivisionIndex(ownBoundingBox: BoundingBox, objectBoundingBox: BoundingBox) -> Int? {
            var subdivisionIndex: Int?

            let horizontalMidpoint = ownBoundingBox.center.y
            let isInTopHalf = objectBoundingBox.bottom < horizontalMidpoint
            let isInBottomHalf = objectBoundingBox.top > horizontalMidpoint

            let verticalMidpoint = ownBoundingBox.center.x
            let isInLeftHalf = objectBoundingBox.right < verticalMidpoint
            let isInRightHalf = objectBoundingBox.left > verticalMidpoint

            if isInTopHalf && isInLeftHalf {
                subdivisionIndex = ChildIndex.topLeft.rawValue
            } else if isInTopHalf && isInRightHalf {
                subdivisionIndex = ChildIndex.topRight.rawValue
            } else if isInBottomHalf && isInLeftHalf {
                subdivisionIndex = ChildIndex.bottomLeft.rawValue
            } else if isInBottomHalf && isInRightHalf {
                subdivisionIndex = ChildIndex.bottomRight.rawValue
            }
            return subdivisionIndex
        }

        /// Returns indices corresponding to subdivisions of `ownBoundingBox` that
        /// `objectBoundingBox` can possibly overlap with.
        private func getSubdivisionOverlappingIndices(
            ownBoundingBox: BoundingBox,
            objectBoundingBox: BoundingBox
        ) -> Set<Int> {
            var subdivisionOverlappingIndices: Set<Int> = [0, 1, 2, 3]

            let horizontalMidpoint = ownBoundingBox.center.y
            let isInTopHalf = objectBoundingBox.bottom < horizontalMidpoint
            let isInBottomHalf = objectBoundingBox.top > horizontalMidpoint

            let verticalMidpoint = ownBoundingBox.center.x
            let isInLeftHalf = objectBoundingBox.right < verticalMidpoint
            let isInRightHalf = objectBoundingBox.left > verticalMidpoint

            if isInTopHalf {
                subdivisionOverlappingIndices.remove(ChildIndex.bottomLeft.rawValue
                )
                subdivisionOverlappingIndices.remove(ChildIndex.bottomRight.rawValue)
            }

            if isInBottomHalf {
                subdivisionOverlappingIndices.remove(ChildIndex.topLeft.rawValue)
                subdivisionOverlappingIndices.remove(ChildIndex.topRight.rawValue)
            }

            if isInLeftHalf {
                subdivisionOverlappingIndices.remove(ChildIndex.topRight.rawValue)
                subdivisionOverlappingIndices.remove(ChildIndex.bottomRight.rawValue)
            }

            if isInRightHalf {
                subdivisionOverlappingIndices.remove(ChildIndex.topLeft.rawValue)
                subdivisionOverlappingIndices.remove(ChildIndex.bottomLeft.rawValue)
            }

            return subdivisionOverlappingIndices
        }

        /// Calculates `self`'s bounding box based on which quarter of its parent node's bounding box it belongs to.
        private func calculateOwnBoundingBox(parentBoundingBox: BoundingBox, indexUnderParent: Int) -> BoundingBox {
            if depth == 0 {
                return parentBoundingBox
            }
            let ownBoundingBoxWidth = parentBoundingBox.width / 2
            let ownBoundingBoxHeight = parentBoundingBox.height / 2
            let topLeft: CGPoint
            switch indexUnderParent {
            case ChildIndex.topLeft.rawValue:
                topLeft = parentBoundingBox.topLeft
            case ChildIndex.topRight.rawValue:
                topLeft = parentBoundingBox.topLeft.translateX(x: ownBoundingBoxWidth)
            case ChildIndex.bottomLeft.rawValue:
                topLeft = parentBoundingBox.topLeft.translateY(y: ownBoundingBoxHeight)
            case ChildIndex.bottomRight.rawValue:
                topLeft = parentBoundingBox.topLeft.translate(dx: ownBoundingBoxWidth, dy: ownBoundingBoxHeight)
            default:
                fatalError("index should be one of 0, 1, 2, 3")
            }
            let ownBoundingBox = BoundingBox(topLeft: topLeft, width: ownBoundingBoxWidth, height: ownBoundingBoxHeight)
            return ownBoundingBox
        }

        /// Insert `entity` into this node or its children depending on
        /// the position of `entity` in this node's bounding box.
        func insert(entity: T, parentBoundingBox: BoundingBox, indexUnderParent: Int) {
            let ownBoundingBox = calculateOwnBoundingBox(
                parentBoundingBox: parentBoundingBox,
                indexUnderParent: indexUnderParent
            )

            if let unwrappedChildren = children {
                let subdivisionIndex = getSubdivisionIndex(
                    ownBoundingBox: ownBoundingBox,
                    objectBoundingBox: entity.boundingBox
                )
                if let unwrappedIndex = subdivisionIndex {
                    unwrappedChildren[unwrappedIndex].insert(
                        entity: entity,
                        parentBoundingBox: ownBoundingBox,
                        indexUnderParent: unwrappedIndex
                    )
                } else {
                    entities.append(entity)
                }
                return
            }

            entities.append(entity)
            guard entities.count > maxObjectsPerLeaf && depth < maxDepth else {
                return
            }

            split()
            guard let unwrappedChildren = children else {
                fatalError("Children should not be nil")
            }

            let reorganizedPegs = LinkedList<T>()
            while !(entities.isEmpty) {
                let removedPeg = entities.removeLast()
                let index = getSubdivisionIndex(
                    ownBoundingBox: ownBoundingBox,
                    objectBoundingBox: removedPeg.boundingBox
                )
                if let unwrappedIndex = index {
                    unwrappedChildren[unwrappedIndex].insert(
                        entity: removedPeg,
                        parentBoundingBox: ownBoundingBox,
                        indexUnderParent: unwrappedIndex
                    )
                } else {
                    reorganizedPegs.append(removedPeg)
                }
            }
            entities = reorganizedPegs
        }

        /// Returns entities possibly overlapping with `entity`.
        func retrieve(neigborsFor entity: T,
                      parentBoundingBox: BoundingBox,
                      indexUnderParent: Int) -> LinkedList<T> {
            let ownBoundingBox = calculateOwnBoundingBox(
                parentBoundingBox: parentBoundingBox, indexUnderParent: indexUnderParent
            )

            let neighbors = LinkedList<T>()

            func appendNeighborsFromSubdivisions(subdivisions: [QuadTreeNode], indices: Set<Int>) {
                for i in indices {
                    let subdivision = subdivisions[i]
                    let neighborsFromSubdivision = subdivision.retrieve(
                        neigborsFor: entity,
                        parentBoundingBox: ownBoundingBox,
                        indexUnderParent: i
                    )
                    neighbors.append(neighborsFromSubdivision)
                }
            }

            if let unwrappedChildren = children {
                let subdivisionIndices = getSubdivisionOverlappingIndices(
                    ownBoundingBox: ownBoundingBox,
                    objectBoundingBox: entity.boundingBox
                )
                appendNeighborsFromSubdivisions(subdivisions: unwrappedChildren, indices: subdivisionIndices)
            }
            neighbors.append(entities)
            return neighbors
        }

        func retrieve(neigborsForBoundingBox boundingBox: BoundingBox,
                      parentBoundingBox: BoundingBox,
                      indexUnderParent: Int) -> LinkedList<T> {
            let ownBoundingBox = calculateOwnBoundingBox(
                parentBoundingBox: parentBoundingBox, indexUnderParent: indexUnderParent
            )

            let neighbors = LinkedList<T>()

            func appendNeighborsFromSubdivisions(subdivisions: [QuadTreeNode], indices: Set<Int>) {
                for i in indices {
                    let subdivision = subdivisions[i]
                    let neighborsFromSubdivision = subdivision.retrieve(
                        neigborsForBoundingBox: boundingBox,
                        parentBoundingBox: ownBoundingBox,
                        indexUnderParent: i
                    )
                    neighbors.append(neighborsFromSubdivision)
                }
            }

            if let unwrappedChildren = children {
                let subdivisionIndices = getSubdivisionOverlappingIndices(
                    ownBoundingBox: ownBoundingBox,
                    objectBoundingBox: boundingBox
                )
                appendNeighborsFromSubdivisions(subdivisions: unwrappedChildren, indices: subdivisionIndices)
            }
            neighbors.append(entities)
            return neighbors
        }

        /// Searches for and removes `entity` from the subtree rooted at this node, provided that `entity` exists.
        func remove(entity: T, parentBoundingBox: BoundingBox, indexUnderParent: Int) {
            let ownBoundingBox = calculateOwnBoundingBox(
                parentBoundingBox: parentBoundingBox,
                indexUnderParent: indexUnderParent
            )
            let index = getSubdivisionIndex(ownBoundingBox: ownBoundingBox, objectBoundingBox: entity.boundingBox)
            if let unwrappedChildren = children, let unwrappedIndex = index {
                unwrappedChildren[unwrappedIndex].remove(
                    entity: entity,
                    parentBoundingBox: ownBoundingBox,
                    indexUnderParent: unwrappedIndex
                )
                return
            }
            entities.remove(byIdentity: entity)
        }
    }

    private var root: QuadTreeNode
    private var bounds: BoundingBox

    /// Creates a quad tree with dimensions given by `bounds`.
    init(bounds: BoundingBox) {
        root = QuadTreeNode(depth: 0)
        self.bounds = bounds
        root.tree = self
    }

    /// Inserts `entity` into the tree.
    /// - Warning: Does not check for existence of the `entity` in the tree,
    /// so duplicates can occur if tree is not used properly.
    func insert(entity: T) {
        root.insert(entity: entity, parentBoundingBox: bounds, indexUnderParent: -1)
    }

    /// Returns entities possibly overlapping with `entity`.
    /// - Note: Conversely, any entity not returned is guaranteed to not overlap with `entity`.
    func retrievePotentialNeighbors(for entity: T) -> AnySequence<T> {
        AnySequence(
            root.retrieve(neigborsFor: entity, parentBoundingBox: bounds, indexUnderParent: -1)
            .filter(predicate: { $0 !== entity })
        )
    }

    func retrievePotentialNeighbors(givenBoundingBox boundingBox: BoundingBox) -> AnySequence<T> {
        AnySequence(
            root.retrieve(neigborsForBoundingBox: boundingBox, parentBoundingBox: bounds, indexUnderParent: -1)
        )
    }

    /// Searches for and removes `entity` from the tree, provided that `entity` exists.
    func remove(entity: T) {
        root.remove(entity: entity, parentBoundingBox: bounds, indexUnderParent: -1)
    }

    /// Clears the tree.
    func removeAll() {
        root.removeAll()
    }

    func resize<C: Container>(with updatedBounds: BoundingBox, entities: C) where C.Element == T {
        removeAll()
        bounds = updatedBounds
        for entity in entities {
            insert(entity: entity)
        }
    }
}

// MARK: CustomDebugStringConvertible
extension QuadTree.QuadTreeNode: CustomDebugStringConvertible {
    var debugDescription: String {
        guard let unwrappedChildren = children else {
            return entities.count.description
        }

        let childrenDescriptions = unwrappedChildren.map {
            $0.debugDescription
        }

        let topLeftDesc = childrenDescriptions[QuadTree.ChildIndex.topLeft.rawValue]
        let topRightDesc = childrenDescriptions[QuadTree.ChildIndex.topRight.rawValue]
        let bottomLeftDesc = childrenDescriptions[QuadTree.ChildIndex.bottomLeft.rawValue]
        let bottomRightDesc = childrenDescriptions[QuadTree.ChildIndex.bottomRight.rawValue]

        let stringRep = """
        [\(entities.count.description):\
        \(topLeftDesc),\(topRightDesc),\(bottomLeftDesc),\(bottomRightDesc)]
        """
        return stringRep
    }
}

extension QuadTree: CustomDebugStringConvertible {
    var debugDescription: String {
        root.debugDescription
    }
}
