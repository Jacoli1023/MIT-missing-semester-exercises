# Lecture 9: [Security and Cryptography](https://missing.csail.mit.edu/2020/security/)

## Entropy

1. **Suppose a password is chosen as a concatenation of four lower-case
    dictionary words, where each word is selected uniformly at random from a
    dictionary of size 100,000. An example of such a password is
    `correcthorsebatterystaple`. How many bits of entropy does this have?**

    Solution:\
    This would be _log<sub>2</sub>(# of possibilities)_, where the number of possibilities is 100,000<sup>4</sup>. This is about 66 bits of entropy.

    ---
1. **Consider an alternative scheme where a password is chosen as a sequence
    of 8 random alphanumeric characters (including both lower-case and
    upper-case letters). An example is `rg8Ql34g`. How many bits of entropy
    does this have?**

    Solution:\
    One random alphanumeric character has 62 possible characters. For 8 of these characters, we would then have 62<sup>8</sup> possiblities. Taking the log function of that that would give us about 48 bits of entropy.

    ---
1. **Which is the stronger password?**
    
    Solution:\
    The one with more bits of entropy is the stronger password, thus it is the 4 random lower-case dictionary words.

    ---
1. **Suppose an attacker can try guessing 10,000 passwords per second. On
    average, how long will it take to break each of the passwords?**

    The first one would take about 234 million years at 10,000 guesses/sec.
    The second one would take about 893 years at 10,000 guess/sec.

---
## Cryptographic hash functions

1. Download a Debian image from a
   [mirror](https://www.debian.org/CD/http-ftp/) (e.g. [from this Argentinean
   mirror](http://debian.xfree.com.ar/debian-cd/current/amd64/iso-cd/)).
   Cross-check the hash (e.g. using the `sha256sum` command) with the hash
   retrieved from the official Debian site (e.g. [this
   file](https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS)
   hosted at `debian.org`, if you've downloaded the linked file from the
   Argentinean mirror).

   Solution:\
   After downloading the Argentinian mirror and the SHA256SUMS file from the Argentinian mirror (using the `curl` command, if you wish), you can compare the SHA-1 hash of the disc image with the corresponding one in the SHA256SUMS file. Thus it would look like so:

    ```bash
    $ sed '/debian-12/!d' SHA256SUMS | shasum --check
    debian-12.10.0-amd64-netinst.iso: OK
    ```

    I am running on Linux, so I did not look for the `mac` or the `edu` files in my `sed` command. The `shasum --check` command reads the SHA sums from the input, and searches the directory for any file with a matching checksum.

---
## Symmetric cryptography

1. **Encrypt a file with AES encryption, using
   [OpenSSL](https://www.openssl.org/): `openssl aes-256-cbc -salt -in {input
   filename} -out {output filename}`. Look at the contents using `cat` or
   `hexdump`. Decrypt it with `openssl aes-256-cbc -d -in {input filename} -out
   {output filename}` and confirm that the contents match the original using
   `cmp`.**

   Solution:\
   I've created a [top secret file](./top-secret-info.txt) that houses all my private and secret information. I then [encrypt it](./top-secret-info.enc.txt) using the provided command, and opening the file, indeed, reveals gibberish. I can then [decrypt it](./top-secret-info.dec.txt) and use the `cmp` command, which should have a 0 return code.

    ```bash
    $ cmp top-secret-info.dec.txt top-secret-info.txt
    $ echo $?
    0
    ```

---
## Asymmetric cryptography

1. **Set up [SSH
    keys](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2)
    on a computer you have access to (not Athena, because Kerberos interacts
    weirdly with SSH keys). Make sure
    your private key is encrypted with a passphrase, so it is protected at
    rest.**

    Skipped, as I already have `ssh` set up on my computer.

    ---
1. **[Set up GPG](https://www.digitalocean.com/community/tutorials/how-to-use-gpg-to-encrypt-and-sign-messages)**

    I also already have GPG set up.

    ---
1. **Send Anish an encrypted email ([public key](https://keybase.io/anish)).**

    Solution:\
    First we'd have to import Anish's public key, which can be done via this command:
    ```bash
    $ curl https://keybase.io/anish/pgp_keys.asc | gpg --import
    ```

    From there we can encrpyt and send a message to Anish using the following command:
    ```bash
    $ gpg --encrypt --sign --armor -r me@anishathalye.com top-secret-info.txt
    ```

    Unfortunately, Anish's public key expired in January, and I am unable to send my top secret encrypted message.

    ---
1. **Sign a Git commit with `git commit -S` or create a signed Git tag with
    `git tag -s`. Verify the signature on the commit with `git show
    --show-signature` or on the tag with `git tag -v`.**

    Solution:
