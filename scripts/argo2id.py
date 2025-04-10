from argon2 import PasswordHasher
import os

# Function to generate a random salt (16 bytes)
def generate_salt():
    return os.urandom(16)

# Function to hash the password with Argon2id and a salt
def hash_password(password, salt):
    # Create an Argon2 PasswordHasher instance with Argon2id mode
    ph = PasswordHasher(hash_len=32, time_cost=3, memory_cost=102400, parallelism=2)
    
    # Hash the password with the provided salt
    return ph.hash(password.encode())

# Function to verify a password against the stored hash
def verify_password(stored_hash, password):
    # Create an Argon2 PasswordHasher instance
    ph = PasswordHasher(hash_len=32, time_cost=3, memory_cost=102400, parallelism=2)
    
    try:
        # Verify the password against the stored hash
        ph.verify(stored_hash, password.encode())
        print("Password is valid!")
    except Exception as e:
        print("Password is invalid:", e)

# Example usage
if __name__ == "__main__":
    # Generate a random salt
    salt = generate_salt()

    # Example password
    password = input("Enter password to hash: ")

    # Hash the password using Argon2id
    hashed_password = hash_password(password, salt)
    
    # Output the salt and hashed password
    print(f"Salt: {salt.hex()}")
    print(f"Hashed Password: {hashed_password}")

    # Verify the password (simulate user re-entering the password for validation)
    verify_password(hashed_password, password)
