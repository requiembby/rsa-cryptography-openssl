# Technical Notes: RSA & OpenSSL

## Source and implementation distinction

The RSA/OpenSSL coursework presentation introduces RSA private and public key generation, encryption, OpenSSL command-line usage, message digests, and digital signatures. The included Bash script is a **new illustrative portfolio implementation**, not the original university submission or an unchanged coursework codebase.

## Confidentiality: RSA-OAEP

RSA public-key encryption uses the recipient's public key to encrypt data, and the corresponding private key to decrypt. This demonstration selects OAEP padding with SHA-256 and MGF1 using SHA-256. Encryption is randomized, so repeated encryptions of the same message generally produce different ciphertext.

RSA encryption supports only relatively short messages. Production encryption for larger data normally uses a reviewed **hybrid scheme** with authenticated symmetric encryption; do not manually split files into raw RSA blocks.

## Authenticity and integrity: RSA-PSS

A digital signature is generated using a private key and verified using the matching public key. This demonstration uses RSA-PSS with SHA-256. It additionally modifies the signed message to demonstrate that verification fails after tampering.

**A signature is not encryption.** The verifier must also have a trustworthy copy of the public key to establish which identity, if any, the key belongs to.

## Safety considerations

- Use modern schemes such as OAEP for RSA encryption and PSS for new RSA signatures.
- Avoid the deprecated OpenSSL `rsautl` command and insecure textbook/raw RSA examples for new work; this demo uses `pkeyutl` and `dgst` instead.
- Generate keys using a secure randomness source and use encrypted or managed private-key storage for persistent real keys.
- The demo generates an **unencrypted temporary private key** with restrictive file permissions for local testing only, and removes it on exit. It should not be repurposed as a persistent identity key.
- Never publish personal keys, passwords, production secrets, private systems, or copyrighted course materials.

## Reproduction

Run the script from the repository root with:

```bash
bash scripts/run_demo.sh
```

Successful checks compare the original and decrypted messages, verify the untampered signature, and reject a modified message.

## Limitations

Tested locally with OpenSSL 3.5.5 on Linux. Unix command-line utilities are required. This exercise does not establish the strength of any external system, verify key identity, provide a full cryptographic protocol, or represent security consulting experience.
