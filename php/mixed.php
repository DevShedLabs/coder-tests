<?php

/*
 * Example mixed PHP / HTML / CSS 
 * 
 */

$page_title = 'Test mixed';

?>
<!DOCTYPE html>
<html lang="en">

<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title><?php echo $page_title; ?></title>

	<style>
		.container {
			margin: 2rem auto;
			text-align: center;
			max-width: 1200px;
		}
	</style>
</head>

<body>
	<main>
		<div class="container">
			<p><?php echo $undefined_var; ?></p>
		</div>
	</main>
	<footer>
		<p>Something for devs</p>
	</footer>
</body>

</html>