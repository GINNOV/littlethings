import binascii
from Crypto.Cipher import AES

class MaskEncryption:
    KEY = binascii.unhexlify("32672f7974ad43451d9c6c894a0e8764")
    BLOCK_SIZE = 16

    @classmethod
    def encrypt_aes_128_hex(cls, hexstring):
        """
        Encrypts a hex string using AES-128.
        The length of the hex string must be divisible by 32 (16 bytes).
        """
        try:
            data = binascii.unhexlify(hexstring)
            return cls.encrypt_aes_128(data)
        except binascii.Error as e:
            raise ValueError(f"Invalid hex string: {e}")

    @classmethod
    def encrypt_aes_128(cls, data):
        """
        Encrypts data using AES-128 in ECB mode.
        The length of the data must be exactly 16 bytes.
        """
        if len(data) != cls.BLOCK_SIZE:
            raise ValueError(f"Data length must be {cls.BLOCK_SIZE} bytes")

        cipher = AES.new(cls.KEY, AES.MODE_ECB)
        return cipher.encrypt(data)

    @classmethod
    def decrypt_aes_128_ecb(cls, data):
        """
        Decrypts data using AES-128 in ECB mode.
        The length of the data must be divisible by 16 bytes.
        """
        if len(data) % cls.BLOCK_SIZE != 0:
            raise ValueError(f"Data length must be divisible by {cls.BLOCK_SIZE}")

        cipher = AES.new(cls.KEY, AES.MODE_ECB)
        return cipher.decrypt(data)

def must(action, err):
    """Raises an exception if err is not None."""
    if err:
        raise Exception(f"Failed to {action}: {err}")

# Example usage
if __name__ == "__main__":
    # Test encryption
    test_hex = "0123456789abcdef0123456789abcdef"
    encrypted_hex = MaskEncryption.encrypt_aes_128_hex(test_hex)
    print(f"Encrypted (hex): {binascii.hexlify(encrypted_hex).decode()}")

    # Test decryption
    decrypted = MaskEncryption.decrypt_aes_128_ecb(encrypted_hex)
    print(f"Decrypted: {binascii.hexlify(decrypted).decode()}")

    # Test with raw bytes
    test_bytes = b"1234567890123456"
    encrypted_bytes = MaskEncryption.encrypt_aes_128(test_bytes)
    print(f"Encrypted (bytes): {binascii.hexlify(encrypted_bytes).decode()}")

    decrypted_bytes = MaskEncryption.decrypt_aes_128_ecb(encrypted_bytes)
    print(f"Decrypted (bytes): {decrypted_bytes.decode()}")