HYBRID64 = "ybndrfg8ejkmcpqxot1uwisza345h769AHvWPEBZMTIDNYJRSlLKFXC2GVOQU0-_"

def hybrid64_encode(binaryData):
	encodedString = ""
	i = 0

	# Handle all of the pairs.
	while i + 1 < len(binaryData):
		int1 = ord(binaryData[i])
		int2 = ord(binaryData[i+1])

		char1 = HYBRID64[int1 >> 3]
		char2 = HYBRID64[((int1 & 0b111) << 2) | (int2 >> 6)]
		char3 = HYBRID64[int2 & 0b111111]

		encodedString += char1 + char2 + char3
		i += 2

	# Handle a trailing byte. i will either be zero or length - 1.
	if i != len(binaryData):
		int1 = ord(binaryData[len(binaryData) - 1])

		char1 = HYBRID64[int1 >> 3]
		char2 = HYBRID64[(int1 & 0b111) << 2]

		encodedString += char1 + char2

	return encodedString

def hybrid64_decode(encodedString):
	decodedData = ""
	i = 0

	# Handle all of the triplets.
	while i + 2 < len(encodedString):
		int1 = HYBRID64.index(encodedString[i])
		int2 = HYBRID64.index(encodedString[i+1])
		int3 = HYBRID64.index(encodedString[i+2])

		byte1 = chr((int1 << 3) | (int2 >> 2))
		byte2 = chr(((int2 & 0b11) << 6) | int3)

		decodedData += byte1 + byte2

		i += 3

	# Handle a trailing pair. i will either be zero or length - 2.
	if i != len(encodedString):
		int1 = HYBRID64.index(encodedString[len(encodedString)-2])
		int2 = HYBRID64.index(encodedString[len(encodedString)-1])

		byte1 = chr((int1 << 3) | (int2 >> 2))

		decodedData += byte1

	return decodedData

def hybrid64_ascii_encode(binaryData):
	encodedString = ""
	i = 0

	# Handle all of the pairs.
	while i + 1 < len(binaryData):
		int1 = ord(binaryData[i])
		int2 = ord(binaryData[i+1])

		# XOR the second byte to switch which groups of ASCII are always in
		# zbase32.
		int2 ^= 0b00100000

		char1 = HYBRID64[int1 >> 3]
		char2 = HYBRID64[((int1 & 0b111) << 2) | (int2 >> 6)]
		char3 = HYBRID64[int2 & 0b111111]

		encodedString += char1 + char2 + char3
		i += 2

	# Handle a trailing byte. i will either be zero or length - 1.
	if i != len(binaryData):
		int1 = ord(binaryData[len(binaryData) - 1])

		char1 = HYBRID64[int1 >> 3]
		char2 = HYBRID64[(int1 & 0b111) << 2]

		encodedString += char1 + char2

	return encodedString

def hybrid64_ascii_decode(encodedString):
	decodedData = ""
	i = 0

	# Handle all of the triplets.
	while i + 2 < len(encodedString):
		int1 = HYBRID64.index(encodedString[i])
		int2 = HYBRID64.index(encodedString[i+1])
		int3 = HYBRID64.index(encodedString[i+2])

		# XOR the third character's index to undo the XORing done in the encoder.
		int3 ^= 0b00100000

		byte1 = chr((int1 << 3) | (int2 >> 2))
		byte2 = chr(((int2 & 0b11) << 6) | int3)

		decodedData += byte1 + byte2

		i += 3

	# Handle a trailing pair. i will either be zero or length - 2.
	if i != len(encodedString):
		int1 = HYBRID64.index(encodedString[len(encodedString)-2])
		int2 = HYBRID64.index(encodedString[len(encodedString)-1])

		byte1 = chr((int1 << 3) | (int2 >> 2))

		decodedData += byte1

	return decodedData

if __name__ == "__main__":
	testString = "hybrid64"

	encoded = hybrid64_encode(testString)
	decoded = hybrid64_decode(encoded)
	print(encoded)
	print(decoded)

	encoded = hybrid64_ascii_encode(testString)
	decoded = hybrid64_ascii_decode(encoded)
	print(encoded)
	print(decoded)
