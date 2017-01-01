# FilmAffinity glftpd script

This script runs outside glftpd chroot.
Just call from crontab. IE:

### Installation

```sh
$ crontab -e
```

```
30 * * * *       /home/glftpd/bin/filmaffinity.sh 2>&1 > /dev/null
1 0 * * 6       /home/glftpd/bin/filmaffinity_clean.sh 2>&1 > /dev/null
```
