<?php

/**
 * For fun
 * 
 * A binary tree is a hierarchical data structure where each node has at most two children, 
 * called the left child and the right child.
 * 
 * This example inverts the tree, showing both the original and the inverted version in a visual representation.
 * 
 */

declare(strict_types=1);

/** 
 * A binary-tree node with an integer value and optional children. 
 */
class Node
{
	public ?Node $left = null;
	public ?Node $right = null;

	/** Create a node without children. */
	public function __construct(public int $value) {}
}

/**
 * Invert a tree in place without recursive calls.
 * Time: O(N). Auxiliary space: O(N) in the worst case.
 */
function invertTreeIterative(?Node $root): ?Node
{
	if ($root === null) {
		return null;
	}

	$stack = [$root];

	while ($stack !== []) {
		$current = array_pop($stack);
		[$current->left, $current->right] = [$current->right, $current->left];

		if ($current->left !== null) {
			$stack[] = $current->left;
		}

		if ($current->right !== null) {
			$stack[] = $current->right;
		}
	}

	return $root;
}

/** 
 * Return path-to-value pairs, preserving left/right structure for verification. 
 */
function treeSnapshot(?Node $root): array
{
	$values = [];
	$stack = [[$root, 'root']];
	while ($stack !== []) {
		[$node, $path] = array_pop($stack);
		if ($node === null) {
			continue;
		}
		$values[$path] = $node->value;
		$stack[] = [$node->right, $path . '.R'];
		$stack[] = [$node->left, $path . '.L'];
	}

	return $values;
}

/** 
 * Escape text for HTML and SVG output. 
 */
function escape(string $text): string
{
	return htmlspecialchars($text, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

/** 
 * Render a connected SVG diagram and an accessible textual description. 
 */
function renderTree(?Node $root, string $id, string $title): string
{
	if ($root === null) {
		return '<p>Empty tree.</p>';
	}

	// Split each parent's horizontal interval equally, retaining missing slots.
	$stack = [[$root, 0, 640, 0, null, null, 'Root']];
	$edges = '';
	$nodes = '';
	$descriptions = [];
	$maxDepth = 0;

	while ($stack !== []) {
		[$node, $min, $max, $depth, $parentX, $parentY, $side] = array_pop($stack);

		$x = ($min + $max) / 2;
		$y = 48 + $depth * 110;
		$maxDepth = max($maxDepth, $depth);
		$empty = $node === null;
		$class = $empty ? 'edge empty-edge' : 'edge';

		if ($parentX !== null) {
			$labelX = ($parentX + $x) / 2;
			$labelY = ($parentY + $y) / 2;
			$edges .= '<line class="' . $class . '" x1="' . $parentX . '" y1="' . ($parentY + 24)
				. '" x2="' . $x . '" y2="' . ($y - 24) . '" />';
			$edges .= '<text class="edge-label" x="' . $labelX . '" y="' . $labelY . '">'
				. escape($side) . '</text>';
		}

		$nodes .= '<circle class="' . ($empty ? 'empty-node' : 'node') . '" cx="' . $x
			. '" cy="' . $y . '" r="24" />';

		$nodes .= '<text class="node-label" x="' . $x . '" y="' . $y . '">'
			. ($empty ? '∅' : escape((string) $node->value)) . '</text>';

		if ($empty) {
			continue;
		}

		$descriptions[] = 'Node ' . $node->value . ': left '
			. ($node->left === null ? 'empty' : $node->left->value) . ', right '
			. ($node->right === null ? 'empty' : $node->right->value) . ".\n";

		if ($node->left !== null || $node->right !== null) {
			$stack[] = [$node->right, $x, $max, $depth + 1, $x, $y, 'R'];
			$stack[] = [$node->left, $min, $x, $depth + 1, $x, $y, 'L'];
		}
	}

	$description = 'Root: ' . $root->value . '. ' . implode(' ', $descriptions);
	$height = 96 + $maxDepth * 110;

	return '<svg viewBox="0 0 640 ' . $height . '" role="img" aria-labelledby="'
		. escape($id) . '-title ' . escape($id) . '-desc">'
		. '<title id="' . escape($id) . '-title">' . escape($title) . '</title>'
		. '<desc id="' . escape($id) . '-desc">' . escape($description) . '</desc>'
		. $edges . $nodes . '</svg><details><summary>Text description</summary><p>'
		. nl2br(escape($description)) . '</p></details>';
}

/** 
 * Build a tree from level-order integers/nulls; null parents consume no child slots. 
 */
function buildTree(array $values): ?Node
{
	foreach ($values as $value) {
		if ($value !== null && !is_int($value)) {
			throw new InvalidArgumentException('Tree values must be integers or null.');
		}
	}

	$values = array_values($values);
	$root = isset($values[0]) ? new Node($values[0]) : null;
	$queue = $root === null ? [] : [$root];
	$index = 1;

	for ($head = 0; $head < count($queue); $head++) {

		foreach (['left', 'right'] as $side) {

			if ($index >= count($values)) {
				break;
			}
			$value = $values[$index++];

			if ($value !== null) {
				$child = new Node($value);
				$queue[$head]->{$side} = $child;
				$queue[] = $child;
			}
		}
	}
	foreach (array_slice($values, $index) as $value) {
		if ($value !== null) {
			throw new InvalidArgumentException('A non-empty node has no parent.');
		}
	}
	return $root;
}

/**
 * Serialize in level order, retaining interior nulls and omitting trailing nulls. 
 */
function treeValues(?Node $root): array
{
	$values = [];
	$queue = $root === null ? [] : [$root];

	for ($head = 0; $head < count($queue); $head++) {
		$node = $queue[$head];
		$values[] = $node === null ? null : $node->value;

		if ($node !== null) {
			$queue[] = $node->left;
			$queue[] = $node->right;
		}
	}

	while ($values !== [] && end($values) === null) {
		array_pop($values);
	}
	return $values;
}

/** 
 * Verify mirrored paths and double inversion independently of example values. 
 */
function verifyInversion(?Node $invertedRoot, array $originalSnapshot): void
{
	$expected = [];

	foreach ($originalSnapshot as $path => $value) {
		$expected[strtr($path, ['L' => 'R', 'R' => 'L'])] = $value;
	}

	$actual = treeSnapshot($invertedRoot);
	ksort($expected);
	ksort($actual);

	if ($actual !== $expected || invertTreeIterative(null) !== null) {
		throw new RuntimeException('Tree inversion failed the mirrored structure check.');
	}

	invertTreeIterative($invertedRoot);

	$restored = treeSnapshot($invertedRoot) === $originalSnapshot;

	invertTreeIterative($invertedRoot);

	if (!$restored) {
		throw new RuntimeException('Inverting twice did not restore the original tree.');
	}
}

// Edit this level-order array to try another tree. Use null for missing children.
$input = [4, 2, 7, 1, 3, 6, 9];
$input = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
$root = buildTree($input);
$originalSnapshot = treeSnapshot($root);
$inputValues = treeValues($root);
$originalDiagram = renderTree($root, 'original', 'Original tree');
invertTreeIterative($root);
verifyInversion($root, $originalSnapshot);
$outputValues = treeValues($root);
$invertedDiagram = renderTree($root, 'inverted', 'Inverted tree');

// Display a nice visual output.
?>
<!DOCTYPE html>
<html lang="en">

<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<meta name="description" content="Compare a binary tree before and after iterative inversion, with labeled branches and empty child positions.">
	<title>Binary tree inversion — visual comparison</title>
	<style>
				:root {
					color-scheme: light dark;
					--background: #f4f7fb;
					--surface: #ffffff;
					--text: #182638;
					--muted: #475569;
					--border: #cbd5e1;
					--accent: #1e40af;
					--node-fill: #eff6ff;
					--success: #166534;
					--radius: 1rem;
					--space: 1rem;
					--font: system-ui, sans-serif;
				}

				@media (prefers-color-scheme: dark) {
					:root {
						--background: #101827;
						--surface: #192537;
						--text: #f1f5f9;
						--muted: #cbd5e1;
						--border: #52647c;
						--accent: #93c5fd;
						--node-fill: #243b59;
						--success: #86efac;
					}
				}

				* {
					box-sizing: border-box;
				}

				body {
					margin: 0;
					background: var(--background);
					color: var(--text);
					font-family: var(--font);
					line-height: 1.6;
				}

				main {
					max-width: 85rem;
					margin: auto;
					padding: calc(var(--space) * 2) var(--space);
				}

				h1 {
					font-size: 2rem;
					line-height: 1.2;
				}

				h2 {
					margin-top: 0;
					font-size: 1.25rem;
				}

				p {
					color: var(--muted);
				}

				code {
					overflow-wrap: anywhere;
				}

				.comparison {
					display: grid;
					gap: var(--space);
					margin-block: calc(var(--space) * 2);
				}

				.tree-panel {
					min-width: 0;
					padding: var(--space);
					border: 1px solid var(--border);
					border-radius: var(--radius);
					background: var(--surface);
				}

				svg {
					display: block;
					width: 100%;
					height: auto;
				}

				.edge {
					stroke: var(--muted);
					stroke-width: 2;
				}

				.empty-edge,
				.empty-node {
					stroke-dasharray: 5 4;
				}

				.node {
					fill: var(--node-fill);
					stroke: var(--accent);
					stroke-width: 2;
				}

				.empty-node {
					fill: var(--surface);
					stroke: var(--muted);
					stroke-width: 2;
				}

				.node-label,
				.edge-label {
					fill: var(--text);
					text-anchor: middle;
					dominant-baseline: middle;
					font-family: var(--font);
				}

				.node-label {
					font-size: 20px;
					font-weight: 700;
				}

				.edge-label {
					font-size: 16px;
					font-weight: 600;
					stroke: var(--surface);
					stroke-width: 6;
					paint-order: stroke;
				}

				summary {
					cursor: pointer;
					padding-block: var(--space);
					color: var(--accent);
				}

				:focus-visible {
					outline: 3px solid var(--accent);
					outline-offset: 4px;
				}

				.checks {
					color: var(--success);
					font-weight: 600;
				}

				.skip-link {
					position: absolute;
					top: 0;
					left: var(--space);
					padding: var(--space);
					background: var(--surface);
					color: var(--accent);
					transform: translateY(-110%);
				}

				.skip-link:focus {
					transform: translateY(0);
				}

				@media (min-width: 60rem) {
					.comparison {
						grid-template-columns: repeat(2, minmax(0, 1fr));
					}
				}
			
	</style>
</head>

<body>
	<a class="skip-link" href="#main-content">Skip to comparison</a>
	<main id="main-content" tabindex="-1">
		<header>
			<h1>Binary tree inversion</h1>
			<p>Every node swaps its left and right children. The root is the first input value, not necessarily 4.</p>
		</header>
		<p><strong>Legend:</strong> L = left child · R = right child · dashed ∅ = empty child slot. Leaves have no children.</p>
		<div class="comparison">
			<section class="tree-panel" aria-labelledby="original-heading">
				<h2 id="original-heading">Before — original tree</h2>
				<p>Input: <code><?= escape(json_encode($inputValues, JSON_THROW_ON_ERROR)) ?></code></p>
				<?= $originalDiagram ?>
			</section>
			<section class="tree-panel" aria-labelledby="inverted-heading">
				<h2 id="inverted-heading">After — inverted tree</h2>
				<p>Output: <code><?= escape(json_encode($outputValues, JSON_THROW_ON_ERROR)) ?></code></p>
				<?= $invertedDiagram ?>
			</section>
		</div>
		<p>Arrays are read level by level, left to right. Use <code>null</code> for missing children; missing parents do not consume child slots.</p>
		<p class="checks">✓ Structure checks passed: mirrored paths, empty input, and original restored after two inversions.</p>
	</main>
</body>

</html>