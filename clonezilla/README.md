# Clonezilla S3/Backblaze configuration

Following Clonezilla instructions, we store an encrypted .passwd-s3fs.enc for accessing Backblaze.

When Clonezilla Live stops select `s3 server` (or similar) and before you run s3fs, download the file to your $HOME and decrypt it:

```shell
curl -fsSL -o- $url > $HOME/.passwd-s3fs.enc
openssl enc -decrypt -aes-256-cbc -pbkdf2 -in $HOME/.passwd-s3fs.enc -out $HOME/.passwd-s3fs
```

The `download-passwd-s3fs` scripts does the above for you. You can copy it to the Clonezilla Live USB drive for convenience.

Use [these instructions](https://clonezilla.org/liveusb.php) for creating a read/write USB drive.

## Generate the file url

Backblaze offers two way to generate links to files:

  * Login to the UI and get a link to the file from there
  * From the cli, and once the backblaze-b2 is authorized, run:
    ```shell
    backblaze-b2 make-friendly-url secrets-f3ba7cb4 .passwd-s3fs.enc
    ```
