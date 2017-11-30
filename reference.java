public class reference {

	public static final String HYBRID64 = "ybndrfg8ejkmcpqxot1uwisza345h769AHvWPEBZMTIDNYJRSlLKFXC2GVOQU0-_";

	public static String encode(byte[] binaryData) {
		String encodedString = "";
		int i = 0;

		// Handle all of the pairs.
		for (i = 0; i + 1 < binaryData.length; i += 2) {
			int int1 = binaryData[i];
			int int2 = binaryData[i+1];

			char char1 = HYBRID64.charAt(int1 >> 3);
			char char2 = HYBRID64.charAt(((int1 & 0b111) << 2) | (int2 >> 6));
			char char3 = HYBRID64.charAt(int2 & 0b111111);

			encodedString = encodedString + char1 + char2 + char3;
		}

		// Handle a trailing byte. i will either be zero or length - 1.
		if (i != binaryData.length) {
			int int1 = binaryData[binaryData.length - 1];

			char char1 = HYBRID64.charAt(int1 >> 3);
			char char2 = HYBRID64.charAt((int1 & 0b111) << 2);

			encodedString = encodedString + char1 + char2;
		}

		return encodedString;
	}

	public static byte[] decode(String string) {
		String decodedData = "";
		int i = 0;

		// Handle all of the triplets.
		for (i = 0; i + 2 < string.length(); i += 3) {
			int int1 = HYBRID64.indexOf(string.charAt(i));
			int int2 = HYBRID64.indexOf(string.charAt(i+1));
			int int3 = HYBRID64.indexOf(string.charAt(i+2));

			char byte1 = (char) ((int1 << 3) | (int2 >> 2));
			char byte2 = (char) (((int2 & 0b11) << 6) | int3);

			decodedData = decodedData + byte1 + byte2;
		}

		// Handle a trailing pair. i will either be zero or length - 2.
		if (i != string.length()) {
			int int1 = HYBRID64.indexOf(string.charAt(string.length()-2));
			int int2 = HYBRID64.indexOf(string.charAt(string.length()-1));

			char byte1 = (char) ((int1 << 3) | (int2 >> 2));

			decodedData = decodedData + byte1;
		}

		return decodedData.getBytes();
	}

	public static String asciiEncode(byte[] binaryData) {
		String encodedString = "";
		int i = 0;

		// Handle all of the pairs.
		for (i = 0; i + 1 < binaryData.length; i += 2) {
			int int1 = binaryData[i];
			int int2 = binaryData[i+1];

			// XOR the second byte to switch which groups of ASCII are always in
			// zbase32.
			int2 ^= 0b00100000;

			char char1 = HYBRID64.charAt(int1 >> 3);
			char char2 = HYBRID64.charAt(((int1 & 0b111) << 2) | (int2 >> 6));
			char char3 = HYBRID64.charAt(int2 & 0b111111);

			encodedString = encodedString + char1 + char2 + char3;
		}

		// Handle a trailing byte. i will either be zero or length - 1.
		if (i != binaryData.length) {
			int int1 = binaryData[binaryData.length - 1];

			char char1 = HYBRID64.charAt(int1 >> 3);
			char char2 = HYBRID64.charAt((int1 & 0b111) << 2);

			encodedString = encodedString + char1 + char2;
		}

		return encodedString;
	}

	public static byte[] asciiDecode(String string) {
		String decodedData = "";
		int i = 0;

		// Handle all of the triplets.
		for (i = 0; i + 2 < string.length(); i += 3) {
			int int1 = HYBRID64.indexOf(string.charAt(i));
			int int2 = HYBRID64.indexOf(string.charAt(i+1));
			int int3 = HYBRID64.indexOf(string.charAt(i+2));

			// XOR the third character's index to undo the XORing done in the encoder.
			int3 ^= 0b00100000;

			char byte1 = (char) ((int1 << 3) | (int2 >> 2));
			char byte2 = (char) (((int2 & 0b11) << 6) | int3);

			decodedData = decodedData + byte1 + byte2;
		}

		// Handle a trailing pair. i will either be zero or length - 2.
		if (i != string.length()) {
			int int1 = HYBRID64.indexOf(string.charAt(string.length()-2));
			int int2 = HYBRID64.indexOf(string.charAt(string.length()-1));

			char byte1 = (char) ((int1 << 3) | (int2 >> 2));

			decodedData = decodedData + byte1;
		}

		return decodedData.getBytes();
	}

	public static void main(String[] args) {
		String testString = "hybrid64";

		String encoded = reference.encode(testString.getBytes());
		String decoded = new String(reference.decode(encoded));
		System.out.println(encoded);
		System.out.println(decoded);

		encoded = reference.asciiEncode(testString.getBytes());
		decoded = new String(reference.asciiDecode(encoded));
		System.out.println(encoded);
		System.out.println(decoded);
	}

}
