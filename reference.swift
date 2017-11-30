import Foundation

let HYBRID64 = "ybndrfg8ejkmcpqxot1uwisza345h769AHvWPEBZMTIDNYJRSlLKFXC2GVOQU0-_"

func hybrid64_encode(binaryData: Data) -> String {
	var encodedString = ""
	var i = 0

	// Handle all of the pairs.
	while i + 1 < binaryData.count {
		let int1 = Int(binaryData[i])
		let int2 = Int(binaryData[i+1])

		let charIndex1 = HYBRID64.index(HYBRID64.startIndex, offsetBy: int1 >> 3)
		let charIndex2 = HYBRID64.index(HYBRID64.startIndex, offsetBy: ((int1 & 0b111) << 2) | (int2 >> 6))
		let charIndex3 = HYBRID64.index(HYBRID64.startIndex, offsetBy: int2 & 0b111111)

		let char1 = String(HYBRID64[charIndex1])
		let char2 = String(HYBRID64[charIndex2])
		let char3 = String(HYBRID64[charIndex3])

		encodedString += char1 + char2 + char3
		i += 2
	}

	// Handle a trailing byte. i will either be zero or length - 1.
	if i != binaryData.count {
		let int1 = Int(binaryData[binaryData.count - 1])

		let charIndex1 = HYBRID64.index(HYBRID64.startIndex, offsetBy: int1 >> 3)
		let charIndex2 = HYBRID64.index(HYBRID64.startIndex, offsetBy: (int1 & 0b111) << 2)

		let char1 = String(HYBRID64[charIndex1])
		let char2 = String(HYBRID64[charIndex2])

		encodedString += char1 + char2
	}

	return encodedString
}

func hybrid64_decode(encodedString: String) -> Data {
	var decodedData = Data()
	var i = 0

	// Handle all of the triplets.
	while i + 2 < encodedString.count {
		let encodedStringIndex1 = encodedString.index(encodedString.startIndex, offsetBy: i)
		let encodedStringIndex2 = encodedString.index(encodedString.startIndex, offsetBy: i+1)
		let encodedStringIndex3 = encodedString.index(encodedString.startIndex, offsetBy: i+2)

		let int1 = HYBRID64.index(of: encodedString[encodedStringIndex1])!.encodedOffset
		let int2 = HYBRID64.index(of: encodedString[encodedStringIndex2])!.encodedOffset
		let int3 = HYBRID64.index(of: encodedString[encodedStringIndex3])!.encodedOffset

		let byte1 = UInt8((int1 << 3) | (int2 >> 2))
		let byte2 = UInt8(((int2 & 0b11) << 6) | int3)

		decodedData.append(byte1)
		decodedData.append(byte2)

		i += 3
	}

	// Handle a trailing pair. i will either be zero or length - 2.
	if i != encodedString.count {
		let encodedStringIndex1 = encodedString.index(encodedString.endIndex, offsetBy: -2)
		let encodedStringIndex2 = encodedString.index(encodedString.endIndex, offsetBy: -1)

		let int1 = HYBRID64.index(of: encodedString[encodedStringIndex1])!.encodedOffset
		let int2 = HYBRID64.index(of: encodedString[encodedStringIndex2])!.encodedOffset

		let byte1 = UInt8((int1 << 3) | (int2 >> 2))

		decodedData.append(byte1)
	}

	return decodedData
}

func hybrid64_ascii_encode(binaryData: Data) -> String {
	var encodedString = ""
	var i = 0

	// Handle all of the pairs.
	while i + 1 < binaryData.count {
		let byte1 = Int(binaryData[i])

		// XOR the second byte to switch which groups of ASCII are always in
		// zbase32.
		let byte2 = Int(binaryData[i+1]) ^ 0b00100000

		let charIndex1 = HYBRID64.index(HYBRID64.startIndex, offsetBy: byte1 >> 3)
		let charIndex2 = HYBRID64.index(HYBRID64.startIndex, offsetBy: ((byte1 & 0b111) << 2) | (byte2 >> 6))
		let charIndex3 = HYBRID64.index(HYBRID64.startIndex, offsetBy: byte2 & 0b111111)

		let char1 = String(HYBRID64[charIndex1])
		let char2 = String(HYBRID64[charIndex2])
		let char3 = String(HYBRID64[charIndex3])

		encodedString += char1 + char2 + char3
		i += 2
	}

	// Handle a trailing byte. i will either be zero or length - 1.
	if i != binaryData.count {
		let byte = Int(binaryData[binaryData.count - 1])

		let charIndex1 = HYBRID64.index(HYBRID64.startIndex, offsetBy: byte >> 3)
		let charIndex2 = HYBRID64.index(HYBRID64.startIndex, offsetBy: (byte & 0b111) << 2)

		let char1 = String(HYBRID64[charIndex1])
		let char2 = String(HYBRID64[charIndex2])

		encodedString += char1 + char2
	}

	return encodedString
}

func hybrid64_ascii_decode(encodedString: String) -> Data {
	var decodedData = Data()
	var i = 0

	// Handle all of the triplets.
	while i + 2 < encodedString.count {
		let encodedStringIndex1 = encodedString.index(encodedString.startIndex, offsetBy: i)
		let encodedStringIndex2 = encodedString.index(encodedString.startIndex, offsetBy: i+1)
		let encodedStringIndex3 = encodedString.index(encodedString.startIndex, offsetBy: i+2)

		let int1 = HYBRID64.index(of: encodedString[encodedStringIndex1])!.encodedOffset
		let int2 = HYBRID64.index(of: encodedString[encodedStringIndex2])!.encodedOffset

		// XOR the third character's index to undo the XORing done in the encoder.
		let int3 = HYBRID64.index(of: encodedString[encodedStringIndex3])!.encodedOffset ^ 0b00100000

		let byte1 = UInt8((int1 << 3) | (int2 >> 2))
		let byte2 = UInt8(((int2 & 0b11) << 6) | int3)

		decodedData.append(byte1)
		decodedData.append(byte2)

		i += 3
	}

	// Handle a trailing pair. i will either be zero or length - 2.
	if i != encodedString.count {
		let encodedStringIndex1 = encodedString.index(encodedString.endIndex, offsetBy: -2)
		let encodedStringIndex2 = encodedString.index(encodedString.endIndex, offsetBy: -1)

		let int1 = HYBRID64.index(of: encodedString[encodedStringIndex1])!.encodedOffset
		let int2 = HYBRID64.index(of: encodedString[encodedStringIndex2])!.encodedOffset

		let byte1 = UInt8((int1 << 3) | (int2 >> 2))

		decodedData.append(byte1)
	}

	return decodedData
}

let testString = "hybrid64"

var encoded = hybrid64_encode(binaryData: testString.data(using: .utf8)!)
var decoded = String(data: hybrid64_decode(encodedString: encoded), encoding: .utf8)!
print(encoded)
print(decoded)

encoded = hybrid64_ascii_encode(binaryData: testString.data(using: .utf8)!)
decoded = String(data: hybrid64_ascii_decode(encodedString: encoded), encoding: .utf8)!
print(encoded)
print(decoded)
