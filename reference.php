<?php

const HYBRID64 = "ybndrfg8ejkmcpqxot1uwisza345h769AHvWPEBZMTIDNYJRSlLKFXC2GVOQU0-_";

function hybrid64_encode($binaryData) {
	$encodedString = "";

	// Handle all of the pairs.
	for ($i = 0; $i + 1 < strlen($binaryData); $i += 2) {
		$int1 = ord($binaryData[$i]);
		$int2 = ord($binaryData[$i+1]);

		$char1 = HYBRID64[$int1 >> 3];
		$char2 = HYBRID64[(($int1 & 0b111) << 2) | ($int2 >> 6)];
		$char3 = HYBRID64[$int2 & 0b111111];

		$encodedString .= $char1 . $char2 . $char3;
	}

	// Handle a trailing byte. $i will either be zero or length - 1.
	if ($i != strlen($binaryData)) {
		$int1 = ord($binaryData[strlen($binaryData) - 1]);

		$char1 = HYBRID64[$int1 >> 3];
		$char2 = HYBRID64[($int1 & 0b111) << 2];

		$encodedString .= $char1 . $char2;
	}

	return $encodedString;
}

function hybrid64_decode($encodedString) {
	$decodedData = "";

	// Handle all of the triplets.
	for ($i = 0; $i + 2 < strlen($encodedString); $i += 3) {
		$int1 = strpos(HYBRID64, $encodedString[$i]);
		$int2 = strpos(HYBRID64, $encodedString[$i+1]);
		$int3 = strpos(HYBRID64, $encodedString[$i+2]);

		$byte1 = chr(($int1 << 3) | ($int2 >> 2));
		$byte2 = chr((($int2 & 0b11) << 6) | $int3);

		$decodedData .= $byte1 . $byte2;
	}

	// Handle a trailing pair. $i will either be zero or length - 2.
	if ($i != strlen($encodedString)) {
		$int1 = strpos(HYBRID64, $encodedString[strlen($encodedString)-2]);
		$int2 = strpos(HYBRID64, $encodedString[strlen($encodedString)-1]);

		$byte1 = chr(($int1 << 3) | ($int2 >> 2));

		$decodedData .= $byte1;
	}

	return $decodedData;
}

function hybrid64_ascii_encode($binaryData) {
	$encodedString = "";

	// Handle all of the pairs.
	for ($i = 0; $i + 1 < strlen($binaryData); $i += 2) {
		$int1 = ord($binaryData[$i]);
		$int2 = ord($binaryData[$i+1]);

		// XOR the second byte to switch which groups of ASCII are always in
		// zbase32.
		$int2 ^= 0b00100000;

		$char1 = HYBRID64[$int1 >> 3];
		$char2 = HYBRID64[(($int1 & 0b111) << 2) | ($int2 >> 6)];
		$char3 = HYBRID64[$int2 & 0b111111];

		$encodedString .= $char1 . $char2 . $char3;
	}

	// Handle a trailing byte. $i will either be zero or length - 1.
	if ($i != strlen($binaryData)) {
		$int1 = ord($binaryData[strlen($binaryData) - 1]);

		$char1 = HYBRID64[$int1 >> 3];
		$char2 = HYBRID64[($int1 & 0b111) << 2];

		$encodedString .= $char1 . $char2;
	}

	return $encodedString;
}

function hybrid64_ascii_decode($encodedString) {
	$decodedData = "";

	// Handle all of the triplets.
	for ($i = 0; $i + 2 < strlen($encodedString); $i += 3) {
		$int1 = strpos(HYBRID64, $encodedString[$i]);
		$int2 = strpos(HYBRID64, $encodedString[$i+1]);
		$int3 = strpos(HYBRID64, $encodedString[$i+2]);

		// XOR the third character's index to undo the XORing done in the encoder.
		$int3 ^= 0b00100000;

		$byte1 = chr(($int1 << 3) | ($int2 >> 2));
		$byte2 = chr((($int2 & 0b11) << 6) | $int3);

		$decodedData .= $byte1 . $byte2;
	}

	// Handle a trailing pair. $i will either be zero or length - 2.
	if ($i != strlen($encodedString)) {
		$int1 = strpos(HYBRID64, $encodedString[strlen($encodedString)-2]);
		$int2 = strpos(HYBRID64, $encodedString[strlen($encodedString)-1]);

		$byte1 = chr(($int1 << 3) | ($int2 >> 2));

		$decodedData .= $byte1;
	}

	return $decodedData;
}

$testString = "hybrid64";

$encoded = hybrid64_encode($testString);
$decoded = hybrid64_decode($encoded);
echo $encoded, "\n", $decoded, "\n";

$encoded = hybrid64_ascii_encode($testString);
$decoded = hybrid64_ascii_decode($encoded);
echo $encoded, "\n", $decoded, "\n";
