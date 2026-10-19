# RSA Cryptography & OpenSSL

**Academic topic and reproducible portfolio demonstration**  
**Charoskhon Farkhadova | Webster University in Tashkent | Cybersecurity / Cryptography**

## Overview

This repository explores public-key cryptography using OpenSSL. It connects concepts from my university RSA/OpenSSL materials to a reproducible demonstration of encryption, decryption, digital signatures, and signature verification.

**Authorship note:** The university materials covered RSA key generation, key management, encryption and signatures. The Bash script is a *new portfolio learning demonstration* illustrating those topics, not an original export of my submitted assignment.

## Demonstration

1. Generate a temporary **3072-bit RSA key pair**.
2. Encrypt a short fictional message using the public key and **RSA-OAEP with SHA-256**.
3. Decrypt with the private key and compare results.
4. Sign the message with **RSA-PSS and SHA-256**; verify with the public key.
5. Tamper with the message and confirm verification fails.

The script deletes temporary key files and outputs when it exits. No private key is committed.

## Run locally

Requires Bash, OpenSSL 3.x, and common Unix tools (Linux, macOS, or a Unix-like Windows shell).

```bash
git clone https://github.com/requiembby/rsa-cryptography-openssl.git
cd rsa-cryptography-openssl
bash scripts/run_demo.sh
```

Expected output includes:

```text
PASS: decrypted text matches the original.
Verified OK
PASS: signature verification rejects the modified message.
```

## Files

- [scripts/run_demo.sh](scripts/run_demo.sh): functional OpenSSL demonstration
- [examples/message.txt](examples/message.txt): fictional short example message
- [docs/cryptography-notes.md](docs/cryptography-notes.md): explanations and security limitations
- [.gitignore](.gitignore): helps avoid accidentally committing secrets and generated keys

## Security concepts

| Goal | Public key | Private key |
| --- | --- | --- |
| Confidentiality (RSA-OAEP) | Encrypts a small message | Decrypts it |
| Authenticity and integrity (RSA-PSS) | Verifies a signature | Creates a signature |

**A signature does not encrypt a message. Encryption alone does not establish who sent it.** For large data, production designs generally use a secure hybrid encryption protocol with an authenticated symmetric cipher.

## Scope and verification

This local demonstration passed its encryption, decryption, signature, and tamper-detection checks using OpenSSL 3.5.5. It is not production-ready security software or a cryptographic audit. Keys are for local temporary practice only. Original third-party instructional slides and private keys are not redistributed.

[GitHub](https://github.com/requiembby) · [LinkedIn](https://www.linkedin.com/in/charoskhon-farkhadova-2148a9307/)