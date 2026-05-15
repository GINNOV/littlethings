<?php

$tileset = 'selur_v1';
$tileCount = 25;
// $rot = 1;
$out = imageCreateTrueColor(32, 32*$tileCount*4);
for($i = 0; $i != $tileCount; ++$i) {
	$tile = imageCreateFromPNG($tileset.'/'.$i.'.png');
	for($rot = 0; $rot != 4; ++$rot) {
		imageCopy($out, $tile, 0, $tileCount*32*$rot + 32*$i, 0, 0, 32, 32);
		$tile = imageRotate($tile, 270, 0);
	}
}

imagePNG($out, $tileset.'.png');


?>