#!/snap/bin/kotlin
import java.io.File

// Compilation instructions:
// - compile with "kotlinc <in.kt> -include-runtime -d <out.jar>"
// - run with "java -jar <out.jar>"

class TreeNode() {
    var value: Int? = null // only leaves have value
    var depth: Int = 0
    // if a tree has one of the following, it must have both
    var leftChild:  TreeNode? = null
    var rightChild: TreeNode? = null

    fun updateDepths() {
        leftChild?.depth = this.depth + 1
        leftChild?.updateDepths()
        rightChild?.depth = this.depth + 1
        rightChild?.updateDepths()
    }

    fun isPair(): Boolean {
        return (leftChild?.value != null && rightChild?.value != null)
    }

    override fun toString(): String {
        if (value != null) {
            return "${value}"
        } else {
            return "[${leftChild?.toString()},${rightChild?.toString()}]"
        }
    }

    fun copy(): TreeNode {
        var result = TreeNode()
        result.value = value
        result.depth = depth
        result.leftChild = leftChild?.copy()
        result.rightChild = rightChild?.copy()
        return result
    }
}

fun parseTree(s: String): TreeNode {
    var result = TreeNode()
    if (s.first().isDigit()) {
        result.value = s.toInt()
    } else {
        // split into left part and right part
        var nested = 0
        var comma = -1
        s.forEachIndexed {index, c ->
            when (c) {
            '[' -> {nested++}
            ']' -> {nested--}
            ',' -> {if (nested == 1) {comma = index}}
            }
        }
        result.leftChild = parseTree(s.substring(1, comma))
        result.rightChild = parseTree(s.substring(comma + 1, s.length - 1))
    }
    result.updateDepths()
    return result
}

fun getLeafList(tree: TreeNode?): ArrayList<TreeNode> {
    // walk the tree and get a list of ordered nodes
    var result = ArrayList<TreeNode>()
    if (tree != null) {
        if (tree.value != null) {
            result.add(tree)
        } else {
            result.addAll(getLeafList(tree.leftChild))
            result.addAll(getLeafList(tree.rightChild))
        }
    }
    return result
}

fun maybeExplode(root: TreeNode, tree: TreeNode): Boolean {
    if (tree.isPair() && tree.depth >= 4) {
        // this node explodes
        val leaves = getLeafList(root)
        val leftChild: TreeNode = tree.leftChild ?: TreeNode()
        val leftChildIndex = leaves.indexOf(leftChild)
        val rightChild: TreeNode = tree.rightChild ?: TreeNode()
        val rightChildIndex = leaves.indexOf(rightChild)
        // left value gets added to neighbour
        if (leftChildIndex > 0) {
            leaves[leftChildIndex - 1].value = (leaves[leftChildIndex - 1].value ?: 0) + (leftChild.value ?: 0)
        }
        // right value gets added to neighbour
        if (rightChildIndex < leaves.size - 1) {
            leaves[rightChildIndex + 1].value = (leaves[rightChildIndex + 1].value ?: 0) + (rightChild.value ?: 0)
        }
        // this node becomes a 0
        tree.leftChild = null
        tree.rightChild = null
        tree.value = 0
        return true
    } else {
        if (tree.leftChild == null || tree.rightChild == null) {
            return false
        }
        if (maybeExplode(root, (tree.leftChild ?: TreeNode()))) {
            return true
        }
        if (maybeExplode(root, (tree.rightChild ?: TreeNode()))) {
            return true
        }
    }
    return false
}

fun maybeSplit(tree: TreeNode): Boolean {
    if ((tree.value ?: 0) >= 10) {
        // this node splits
        val orig: Int = tree.value ?: 0
        var leftChild = TreeNode()
        leftChild.value = orig / 2
        tree.leftChild = leftChild
        var rightChild = TreeNode()
        rightChild.value = (orig / 2) + (orig % 2)
        tree.rightChild = rightChild
        tree.value = null
        tree.updateDepths()
        return true
    } else {
        if (tree.leftChild == null || tree.rightChild == null) {
            return false
        }
        if (maybeSplit(tree.leftChild ?: TreeNode())) {
            return true
        }
        if (maybeSplit(tree.rightChild ?: TreeNode())) {
            return true
        }
    }
    return false
}

fun reduceSnailfish(root: TreeNode): Boolean {
    // returns true if anything happened
    if (maybeExplode(root, root)) {
        return true
    }
    if (maybeSplit(root)) {
        return true
    }
    return false
}

fun addSnailfish(a: TreeNode, b: TreeNode): TreeNode {
    var result = TreeNode()
    result.leftChild = a.copy()
    result.rightChild = b.copy()
    result.updateDepths()
    while (reduceSnailfish(result)) {}
    return result
}

fun magnitude(tree: TreeNode?): Int {
    if (tree == null) {
        return 0
    } else {
        return (tree.value ?:
            (3 * magnitude(tree.leftChild)) + (2 * magnitude(tree.rightChild)))
    }
}

fun main() {
    val input = File("input18.txt").readLines().map { line: String -> parseTree(line) }
    // part 1
    val result = input.reduce { a, b -> addSnailfish(a, b) }
    println("${magnitude(result)}")
    // part 2
    val maxSum = (input.map { a ->
        (input.map { b ->
            if (a == b) {
                0
            } else {
                magnitude(addSnailfish(a, b))
            }
        }).reduce { x, y -> if (x > y) x else y }
    }).reduce { x, y -> if ( x > y) x else y }
    println("${maxSum}")
}

main()
