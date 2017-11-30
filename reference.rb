# coding: utf-8

HYBRID64 = "ybndrfg8ejkmcpqxot1uwisza345h769AHvWPEBZMTIDNYJRSlLKFXC2GVOQU0-_"

def hybrid64_encode(binaryData)
	encodedString = ""
	bytes = binaryData.bytes.to_a
	i = 0

	# Handle all of the pairs.
	while i + 1 < bytes.length
		int1 = bytes[i]
		int2 = bytes[i+1]

		char1 = HYBRID64[int1 >> 3]
		char2 = HYBRID64[((int1 & 0b111) << 2) | (int2 >> 6)]
		char3 = HYBRID64[int2 & 0b111111]

		encodedString += char1 + char2 + char3
		i += 2
	end

	# Handle a trailing byte. i will either be zero or length - 1.
	if i != bytes.length
		int1 = bytes[bytes.length - 1]

		char1 = HYBRID64[int1 >> 3]
		char2 = HYBRID64[(int1 & 0b111) << 2]

		encodedString += char1 + char2
	end

	return encodedString
end

def hybrid64_decode(encodedString)
	decodedData = ""
	i = 0

	# Handle all of the triplets.
	while i + 2 < encodedString.length
		int1 = HYBRID64.index(encodedString[i])
		int2 = HYBRID64.index(encodedString[i+1])
		int3 = HYBRID64.index(encodedString[i+2])

		byte1 = ((int1 << 3) | (int2 >> 2)).chr
		byte2 = (((int2 & 0b11) << 6) | int3).chr

		decodedData += byte1 + byte2
		i += 3
	end

	# Handle a trailing pair. i will either be zero or length - 2.
	if i != encodedString.length
		int1 = HYBRID64.index(encodedString[encodedString.length-2])
		int2 = HYBRID64.index(encodedString[encodedString.length-1])

		byte = ((int1 << 3) | (int2 >> 2)).chr

		decodedData += byte
	end

	return decodedData
end

def hybrid64_ascii_encode(binaryData)
	encodedString = ""
	bytes = binaryData.bytes.to_a
	i = 0

	# Handle all of the pairs.
	while i + 1 < bytes.length
		int1 = bytes[i]
		int2 = bytes[i+1]

		# XOR the second byte to switch which groups of ASCII are always in
		# zbase32.
		int2 ^= 0b00100000

		char1 = HYBRID64[int1 >> 3]
		char2 = HYBRID64[((int1 & 0b111) << 2) | (int2 >> 6)]
		char3 = HYBRID64[int2 & 0b111111]

		encodedString += char1 + char2 + char3
		i += 2
	end

	# Handle a trailing byte. i will either be zero or length - 1.
	if i != bytes.length
		int1 = bytes[bytes.length - 1]

		char1 = HYBRID64[int1 >> 3]
		char2 = HYBRID64[(int1 & 0b111) << 2]

		encodedString += char1 + char2
	end

	return encodedString
end

def hybrid64_ascii_decode(encodedString)
	decodedData = ""
	i = 0

	# Handle all of the triplets.
	while i + 2 < encodedString.length
		int1 = HYBRID64.index(encodedString[i])
		int2 = HYBRID64.index(encodedString[i+1])
		int3 = HYBRID64.index(encodedString[i+2])

		# XOR the third character's index to undo the XORing done in the encoder.
		int3 ^= 0b00100000

		byte1 = ((int1 << 3) | (int2 >> 2)).chr
		byte2 = (((int2 & 0b11) << 6) | int3).chr

		decodedData += byte1 + byte2
		i += 3
	end

	# Handle a trailing pair. i will either be zero or length - 2.
	if i != encodedString.length
		int1 = HYBRID64.index(encodedString[encodedString.length-2])
		int2 = HYBRID64.index(encodedString[encodedString.length-1])

		byte = ((int1 << 3) | (int2 >> 2)).chr

		decodedData += byte
	end

	return decodedData
end

testString = "hybrid64"

encoded = hybrid64_encode(testString)
decoded = hybrid64_decode(encoded)
puts encoded
puts decoded

encoded = hybrid64_ascii_encode(testString)
decoded = hybrid64_ascii_decode(encoded)
puts encoded
puts decoded
