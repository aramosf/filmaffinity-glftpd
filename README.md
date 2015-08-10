
FilmAffinity scoring scrapper. 

This script is run outside glftpd chroot. 
Just call from crontab. IE:

30 * * * *       /home/glftpd/bin/filmaffinity.sh 2>&1 > /dev/null
1 0 * * 6       /home/glftpd/bin/filmaffinity_clean.sh 2>&1 > /dev/null

