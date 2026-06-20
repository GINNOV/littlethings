<?php

define('LOGIC_VOID', 0);
define('LOGIC_GRASS', 1);
define('LOGIC_VILLAGE', 2);
define('LOGIC_ROAD', 3);
define('LOGIC_BONUS', 4);
define('LOGIC_SWAMP', 5);
define('LOGIC_WATER', 6);

	$counts = [ 0,
		2, 4, 1, 3, 5, 2,
		1, 3, 2, 3, 3, 3,
		2, 3, 2, 3, 1, 3,
		2, 1, 8, 9, 4, 1
	];

	$logic = [
		[
			LOGIC_VOID,			LOGIC_VOID,			LOGIC_VOID,
			LOGIC_VOID,			LOGIC_VOID,			LOGIC_VOID,
			LOGIC_VOID,			LOGIC_VOID,			LOGIC_VOID
		],
		[
			LOGIC_GRASS,		LOGIC_GRASS,		LOGIC_GRASS,
			LOGIC_GRASS,		LOGIC_SWAMP,		LOGIC_GRASS,
			LOGIC_GRASS,		LOGIC_ROAD ,		LOGIC_GRASS
		],
		[
			LOGIC_GRASS,		LOGIC_GRASS,		LOGIC_GRASS,
			LOGIC_GRASS,		LOGIC_SWAMP,		LOGIC_GRASS,
			LOGIC_GRASS,		LOGIC_GRASS,		LOGIC_GRASS
		],
		[
			LOGIC_BONUS,		LOGIC_VILLAGE,		LOGIC_VILLAGE,
			LOGIC_VILLAGE,		LOGIC_VILLAGE,		LOGIC_VILLAGE,
			LOGIC_VILLAGE,		LOGIC_VILLAGE,		LOGIC_VILLAGE
		],
		[
			LOGIC_GRASS,		LOGIC_ROAD,			LOGIC_GRASS,
			LOGIC_GRASS,		LOGIC_ROAD,			LOGIC_VILLAGE,
			LOGIC_GRASS,		LOGIC_ROAD,			LOGIC_GRASS
		],
		[
			LOGIC_GRASS,		LOGIC_VILLAGE,		LOGIC_GRASS,
			LOGIC_GRASS,		LOGIC_GRASS,		LOGIC_GRASS,
			LOGIC_GRASS,		LOGIC_GRASS,		LOGIC_GRASS
		],
		[
			LOGIC_GRASS,		LOGIC_GRASS,		LOGIC_GRASS,
			LOGIC_VILLAGE,		LOGIC_BONUS,		LOGIC_VILLAGE,
			LOGIC_GRASS,		LOGIC_GRASS,		LOGIC_GRASS
		],
		[
			LOGIC_GRASS,		LOGIC_GRASS,		LOGIC_GRASS,
			LOGIC_VILLAGE,		LOGIC_VILLAGE,		LOGIC_VILLAGE,
			LOGIC_GRASS,		LOGIC_GRASS,		LOGIC_GRASS
		],
		[
			LOGIC_GRASS,		LOGIC_GRASS,		LOGIC_GRASS,
			LOGIC_VILLAGE,		LOGIC_GRASS,		LOGIC_VILLAGE,
			LOGIC_GRASS,		LOGIC_GRASS,		LOGIC_GRASS
		],
		[
			LOGIC_GRASS,		LOGIC_GRASS,		LOGIC_GRASS,
			LOGIC_GRASS,		LOGIC_GRASS,		LOGIC_VILLAGE,
			LOGIC_GRASS,		LOGIC_VILLAGE,		LOGIC_GRASS
		],
		[
			LOGIC_GRASS,		LOGIC_VILLAGE,		LOGIC_GRASS,
			LOGIC_GRASS,		LOGIC_ROAD,			LOGIC_ROAD,
			LOGIC_GRASS,		LOGIC_ROAD,			LOGIC_GRASS
		],
		[
			LOGIC_GRASS,		LOGIC_ROAD,			LOGIC_GRASS,
			LOGIC_ROAD,			LOGIC_ROAD,			LOGIC_VILLAGE,
			LOGIC_GRASS,		LOGIC_GRASS,		LOGIC_GRASS
		],
		[
			LOGIC_GRASS,		LOGIC_ROAD,			LOGIC_GRASS,
			LOGIC_ROAD,			LOGIC_ROAD,		LOGIC_VILLAGE,
			LOGIC_GRASS,		LOGIC_ROAD,			LOGIC_GRASS
		],
		[
			LOGIC_BONUS,		LOGIC_VILLAGE,		LOGIC_GRASS,
			LOGIC_VILLAGE,		LOGIC_GRASS,		LOGIC_GRASS,
			LOGIC_GRASS,		LOGIC_GRASS,		LOGIC_GRASS
		],
		[
			LOGIC_VILLAGE,		LOGIC_VILLAGE,		LOGIC_GRASS,
			LOGIC_VILLAGE,		LOGIC_GRASS,		LOGIC_GRASS,
			LOGIC_GRASS,		LOGIC_GRASS,		LOGIC_GRASS
		],
		[
			LOGIC_BONUS,		LOGIC_VILLAGE,		LOGIC_GRASS,
			LOGIC_VILLAGE,		LOGIC_ROAD,			LOGIC_ROAD,
			LOGIC_GRASS,		LOGIC_ROAD,			LOGIC_GRASS
		],
		[
			LOGIC_VILLAGE,		LOGIC_VILLAGE,		LOGIC_GRASS,
			LOGIC_VILLAGE,		LOGIC_ROAD,			LOGIC_ROAD,
			LOGIC_GRASS,		LOGIC_ROAD,			LOGIC_GRASS
		],
		[
			LOGIC_BONUS,		LOGIC_VILLAGE,		LOGIC_VILLAGE,
			LOGIC_VILLAGE,		LOGIC_VILLAGE,		LOGIC_VILLAGE,
			LOGIC_GRASS,		LOGIC_GRASS,		LOGIC_GRASS
		],
		[
			LOGIC_VILLAGE,		LOGIC_VILLAGE,		LOGIC_VILLAGE,
			LOGIC_VILLAGE,		LOGIC_VILLAGE,		LOGIC_VILLAGE,
			LOGIC_GRASS,		LOGIC_GRASS,		LOGIC_GRASS
		],
		[
			LOGIC_BONUS,		LOGIC_VILLAGE,		LOGIC_VILLAGE,
			LOGIC_VILLAGE,		LOGIC_VILLAGE,			LOGIC_VILLAGE,
			LOGIC_GRASS,		LOGIC_ROAD,			LOGIC_GRASS
		],
		[
			LOGIC_VILLAGE,		LOGIC_VILLAGE,		LOGIC_VILLAGE,
			LOGIC_VILLAGE,		LOGIC_VILLAGE,			LOGIC_VILLAGE,
			LOGIC_GRASS,		LOGIC_ROAD,			LOGIC_GRASS
		],
		[
			LOGIC_GRASS,		LOGIC_ROAD,			LOGIC_GRASS,
			LOGIC_GRASS,		LOGIC_ROAD,			LOGIC_GRASS,
			LOGIC_GRASS,		LOGIC_ROAD,			LOGIC_GRASS
		],
		[
			LOGIC_GRASS,		LOGIC_GRASS,		LOGIC_GRASS,
			LOGIC_GRASS,			LOGIC_ROAD,			LOGIC_ROAD,
			LOGIC_GRASS,		LOGIC_ROAD,			LOGIC_GRASS
		],
		[
			LOGIC_GRASS,		LOGIC_GRASS,		LOGIC_GRASS,
			LOGIC_ROAD,			LOGIC_GRASS,		LOGIC_ROAD,
			LOGIC_GRASS,		LOGIC_ROAD,			LOGIC_GRASS
		],
		[
			LOGIC_GRASS,		LOGIC_ROAD,			LOGIC_GRASS,
			LOGIC_ROAD,			LOGIC_GRASS,		LOGIC_ROAD,
			LOGIC_GRASS,		LOGIC_ROAD,			LOGIC_GRASS
		],
	
	];
	
$chunkTypes = 25;
for($i = 0; $i != $chunkTypes; ++$i) {
	$logic[1*$chunkTypes+$i] = [
		$logic[$i][6], $logic[$i][3], $logic[$i][0],
		$logic[$i][7], $logic[$i][4], $logic[$i][1],
		$logic[$i][8], $logic[$i][5], $logic[$i][2]
	];
	$logic[2*$chunkTypes+$i] = [
		$logic[$i][8], $logic[$i][7], $logic[$i][6],
		$logic[$i][5], $logic[$i][4], $logic[$i][3],
		$logic[$i][2], $logic[$i][1], $logic[$i][0]
	];
	$logic[3*$chunkTypes+$i] = [
		$logic[$i][2], $logic[$i][5], $logic[$i][8],
		$logic[$i][1], $logic[$i][4], $logic[$i][7],
		$logic[$i][0], $logic[$i][3], $logic[$i][6]
	];
	$counts[0*$chunkTypes+$i] = $counts[$i];
	$counts[1*$chunkTypes+$i] = $counts[$i];
	$counts[2*$chunkTypes+$i] = $counts[$i];
	$counts[3*$chunkTypes+$i] = $counts[$i];
}

$out = fOpen('tiles.dat', 'wb');
for($i = 0; $i != $chunkTypes*4; ++$i) {
	fWrite($out, chr($i));
	fWrite($out, chr($counts[$i]));
	for($j = 0; $j != 9; ++$j) {
		fWrite($out, chr($logic[$i][$j]));
	}
}
fClose($out);
?>