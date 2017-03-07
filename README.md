# hybrid64

hybrid64 is a binary-to-text encoding scheme that builds on ideas from [base32](https://tools.ietf.org/html/rfc4648#section-6), [zbase32](http://philzimmermann.com/docs/human-oriented-base-32-encoding.txt), and [base64](https://tools.ietf.org/html/rfc4648#section-4). It provides higher efficiency than either base32 or zbase32 in terms of number of characters in the output and guarantees that the majority of the characters in output fall within the human-friendly alphabet used by zbase32.

## Background on base32, zbase32, and base64

Read about [base32](https://tools.ietf.org/html/rfc4648#section-6), [zbase32](http://philzimmermann.com/docs/human-oriented-base-32-encoding.txt), and [base64](https://tools.ietf.org/html/rfc4648#section-4) to get a better idea about how they relate to hybrid64. The most interesting details when considering them in the context of hybrid64 are that zbase32 is similar to base32 but makes it "[as convenient as possible for human users to manipulate](http://philzimmermann.com/docs/human-oriented-base-32-encoding.txt)," and base64 uses an alphabet that is twice as large but more efficient than either of those two.

## hybrid 64

### Algorithm Overview

hybrid64 works on two-byte pairs from the input moving from beginning to end. It splits each two-byte pair into three partitions: two, five-bit partitions and one, six-bit partition. Each of these partitions is interpreted as an integer that is used as an index to map the bits in each partition to a character in the hybrid64 alphabet. It uses the first partition from the input pair to map to the first character of the output triplet, the next partition from the input pair to map to the second character of the output triplet, and the final partition from the input pair to map to the third character of the output triplet. For input with an odd number of bytes, the bits of the nonexistent second byte of the last input "pair" are assumed to be zeroes, and the third character of the output triplet for that "pair" is omitted. Like zbase32 but unlike base32 and base64, padding characters are not used in hybrid64.

In the following diagram, the As denote the bits of the first byte of the input pair, the Bs denote the bits of second byte of the input pair, the Xs denote the bits used for the first partition, the Ys denote the bits used for the second partition, and the Zs denote the bits used for the third partition. The bits are ordered from most significant to least significant.

```
AAAAAAAABBBBBBBB
XXXXXYYYYYZZZZZZ
```

Since hybrid64 uses a pair of two bytes rather than larger groups, its implementations for encoding and decoding are simpler.

### Alphabet

The hybrid64 alphabet in order is:

```
ybndrfg8ejkmcpqxot1uwisza345h769AHvWPEBZMTIDNYJRSlLKFXC2GVOQU0-_
```

hybrid64 uses a 64-character alphabet. Specifically, it uses the characters in the [URL and file name safe alphabet for base64](https://tools.ietf.org/html/rfc4648#section-5). It differs in how the alphabet is ordered, however. The first 32 characters in the hybrid64 alphabet are the characters from the zbase32 alphabet in the same order. The remaining 32 characters, which are only used for the third character in an output triplet, are then ordered in a way so that the less ambiguous characters, as described below, are used for the most used punctuation and letters in English text when encoded in ASCII.

The questions used to roughly define ambiguity for the purposes of hybrid64 are:

- If the character is an uppercase letter, does it look like its lowercase equivalent but does the lowercase equivalent have a descender?
- If the character is an uppercase letter, does it look like its lowercase equivalent?
- If the character is a letter, does it look like a number, e.g., B, Z, l, or S?
- Is the character largely circular, e.g., C, D, G, O, Q, U, 0?
- Is the character similar to a vertical bar, e.g., I, l, or 1?
- Is the character commonly confused with others when written, e.g., U, V, u, or v?
- Is the character a non-alphanumeric symbol?

The final 32 characters, ordered from least ambiguous to most ambiguous as described above, are:

```
AEFHRTJKLMNPWXYBSZ2VvCDGIlOQU0-_
```

### hybrid64-ascii for ASCII-like text

For human-language text encoded in ASCII, or text encoded in UTF-8 if the text mostly contains letters in the English alphabet, there's an elegant way to boost the number of characters in the output that occur in the zbase32 alphabet: the second byte of an input pair can be XORed with `0b00100000` (32) before mapping it to a character in the hybrid64 alphabet. This guarantees that the ASCII characters from 32 (space) to 63 (?) and 96 (`) to 127 (DEL) will be in the zbase32 alphabet. These two groups contain most punctuation and symbols, all numbers, and all lowercase letters of the English alphabet.

The reason the first group (32-63) is guaranteed to be in the zbase32 alphabet is because each of those characters will be changed to numbers between 0 and 31, which is the range of the zbase32 alphabet within the hybrid64 alphabet.

The reason the second group (96-127) is guaranteed to be in the zbase32 alphabet is because each of those characters will be changed to numbers between 64 (`0b01000000`) and 95 (`0b01011111`). Since the two most significant bits of the second byte of an input pair are used in the second character in an output triplet, 64 and 95 are equivalent to the numbers from 0 to 31 as far as the third output character in the output triplet is concerned.

Additionally, uppercase letters encoded using hybrid64-ascii get to benefit from the bias that is used in generic hybrid64 to display less ambiguous characters for lowercase letters that occur most frequently in English text. This is possible because the bit positions of the uppercase and lowercase characters in ASCII are the same except for the same bit that gets XORed in hybrid64-ascii.

Decoding from hybrid64-ascii is similar to encoding to hybrid64-ascii: map the third character of a triplet from the encoded data to its index in the hybrid64 alphabet and XOR it with `0b00100000` (32).

If the input is ASCII text but is primarily uppercase letters, it may be better to use generic hybrid64 since all of them will be encoded using a character in the zbase32 alphabet.

### Miscellaneous Stats and Notes

- The average efficiency in terms of number of characters in the output compared to the number of characters in the input is around 63% for base32, 63% for zbase32, 75% for base64, and 67% for hybrid64. hybrid64's efficiency is far more stable than the others, and it can be just as or more efficient than base64 for many small data lengths.
- Around 67% of the characters in the output of hybrid64 are guaranteed to be in the alphabet used by zbase32. For random input, the expected amount is around 83%. For English text using hybrid64-ascii, the amount can be considerably higher, with both the United States Declaration of Independence and the Gettysburg Address at around 99%.
- Whenever possible, data encoded in hybrid64 should be displayed using a typeface that makes it easy to distinguish problematic characters such as I, l, 1, O, and 0.

###  Reference Implementations

The reference implementations are included to make it easier to understand the encoding and decoding algorithms as implemented in various programming languages. They aren't intended to be used in production. Proper implementations should be optimized, validate input, etc.

### References

- [The Base16, Base32, and Base64 Data Encodings](https://tools.ietf.org/html/rfc4648)
- [Base 32 Encoding](https://tools.ietf.org/html/rfc4648#section-6)
- [Base 64 Encoding](https://tools.ietf.org/html/rfc4648#section-4)
- [human-oriented base-32 encoding](http://philzimmermann.com/docs/human-oriented-base-32-encoding.txt)
- [Letter frequency](https://en.wikipedia.org/wiki/Letter_frequency)
- [English Letter Frequency Counts: Mayzner Revisited](http://norvig.com/mayzner.html)
- [Essays about Computer Security, p. 181](http://www.cl.cam.ac.uk/~mgk25/lee-essays.pdf)

### License

This work is available under a BSD license as described in the LICENSE.txt file.
