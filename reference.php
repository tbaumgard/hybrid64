<?php

const HYBRID64 = "ybndrfg8ejkmcpqxot1uwisza345h769AHvWPEBZMTIDNYJRSlLKFXC2GVOQU0-_";

function hybrid64_encode($binary) {
	$length = strlen($binary);
	$result = "";

	// Handle all of the pairs.
	for ($i = 0; $i + 1 < $length; $i += 2) {
		$byte1 = ord($binary[$i]);
		$byte2 = ord($binary[$i+1]);

		$char1 = HYBRID64[$byte1 >> 3];
		$char2 = HYBRID64[(($byte1 & 0b111) << 2) | ($byte2 >> 6)];
		$char3 = HYBRID64[$byte2 & 0b111111];

		$result .= $char1 . $char2 . $char3;
	}

	// Handle a trailing byte. $i will either be zero or $length - 1.
	if ($i != $length) {
		$byte = ord($binary[$length - 1]);

		$char1 = HYBRID64[$byte >> 3];
		$char2 = HYBRID64[($byte & 0b111) << 2];

		$result .= $char1 . $char2;
	}

	return $result;
}

function hybrid64_decode($string) {
	$length = strlen($string);
	$result = "";

	// Handle all of the triplets.
	for ($i = 0; $i + 2 < $length; $i += 3) {
		$char1 = strpos(HYBRID64, $string[$i]);
		$char2 = strpos(HYBRID64, $string[$i+1]);
		$char3 = strpos(HYBRID64, $string[$i+2]);

		$byte1 = chr(($char1 << 3) | ($char2 >> 2));
		$byte2 = chr((($char2 & 0b11) << 6) | $char3);

		$result .= $byte1 . $byte2;
	}

	// Handle a trailing pair. $i will either be zero or $length - 2.
	if ($i != $length) {
		$char1 = strpos(HYBRID64, $string[$length-2]);
		$char2 = strpos(HYBRID64, $string[$length-1]);

		$byte = chr(($char1 << 3) | ($char2 >> 2));

		$result .= $byte;
	}

	return $result;
}

function hybrid64_ascii_encode($binary) {
	$length = strlen($binary);
	$result = "";

	// Handle all of the pairs.
	for ($i = 0; $i + 1 < $length; $i += 2) {
		$byte1 = ord($binary[$i]);
		$byte2 = ord($binary[$i+1]);

		// XOR the second byte to switch which groups of ASCII are always in
		// zbase32.
		$byte2 ^= 0b00100000;

		$char1 = HYBRID64[$byte1 >> 3];
		$char2 = HYBRID64[(($byte1 & 0b111) << 2) | ($byte2 >> 6)];
		$char3 = HYBRID64[$byte2 & 0b111111];

		$result .= $char1 . $char2 . $char3;
	}

	// Handle a trailing byte. $i will either be zero or $length - 1.
	if ($i != $length) {
		$byte = ord($binary[$length - 1]);

		$char1 = HYBRID64[$byte >> 3];
		$char2 = HYBRID64[($byte & 0b111) << 2];

		$result .= $char1 . $char2;
	}

	return $result;
}

function hybrid64_ascii_decode($string) {
	$length = strlen($string);
	$result = "";

	// Handle all of the triplets.
	for ($i = 0; $i + 2 < $length; $i += 3) {
		$char1 = strpos(HYBRID64, $string[$i]);
		$char2 = strpos(HYBRID64, $string[$i+1]);
		$char3 = strpos(HYBRID64, $string[$i+2]);

		// XOR the third character's index to undo the XORing done in the encoder.
		$char3 ^= 0b00100000;

		$byte1 = chr(($char1 << 3) | ($char2 >> 2));
		$byte2 = chr((($char2 & 0b11) << 6) | $char3);

		$result .= $byte1 . $byte2;
	}

	// Handle a trailing pair. $i will either be zero or $length - 2.
	if ($i != $length) {
		$char1 = strpos(HYBRID64, $string[$length-2]);
		$char2 = strpos(HYBRID64, $string[$length-1]);

		$byte = chr(($char1 << 3) | ($char2 >> 2));

		$result .= $byte;
	}

	return $result;
}
