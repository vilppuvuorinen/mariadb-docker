#!/bin/bash
#
# A helper script to enable NSS wrapper bash extension.
# This script should be run in Dockerfile after APT installations since it breaks some package congigurations.
#
#################################################################################################################

# Copy unstable repos
cat <<EOF > /etc/apt/sources.list.d/unstable.list
deb     http://http.us.debian.org/debian    unstable main non-free contrib
deb-src http://http.us.debian.org/debian    unstable main non-free contrib

deb     http://ftp.us.debian.org/debian/    unstable main contrib non-free
deb-src http://ftp.us.debian.org/debian/    unstable main contrib non-free
EOF

# Copy unstable configs
cat <<EOF > /etc/apt/preferences.d/unstable.pref
Package: *
Pin: release a=unstable
Pin-Priority: 50
EOF

# Copy sh wrapper
cat <<\EOF > /opt/shell.sh
#!/bin/shell
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
envsubst < /tmp/passwd.template > /tmp/passwd
export LD_PRELOAD=libnss_wrapper.so
export NSS_WRAPPER_PASSWD=/tmp/passwd
export NSS_WRAPPER_GROUP=/etc/group

exec /bin/shell "$@"
EOF

# Copy bash wrapper
cat <<\EOF > /opt/bash.sh
#!/bin/bshell
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
envsubst < /tmp/passwd.template > /tmp/passwd
export LD_PRELOAD=libnss_wrapper.so
export NSS_WRAPPER_PASSWD=/tmp/passwd
export NSS_WRAPPER_GROUP=/etc/group

exec /bin/bshell "$@"
EOF

# Copy passwd template
cat <<\EOF > /tmp/passwd.template
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
sync:x:5:0:sync:/sbin:/bin/sync
shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
halt:x:7:0:halt:/sbin:/sbin/halt
mail:x:8:12:mail:/var/spool/mail:/sbin/nologin
operator:x:11:0:operator:/root:/sbin/nologin
games:x:12:100:games:/usr/games:/sbin/nologin
ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
nobody:x:99:99:Nobody:/:/sbin/nologin
mysql:x:${USER_ID}:${GROUP_ID}:MySQL user:${HOME}:/bin/bash
EOF

apt-get update
apt-get install -y gettext
apt-get install -y -t unstable libnss-wrapper
rm -rf /var/lib/apt/lists/*
rm -rf /etc/apt/sources.list.d/unstable.list
rm -rf /etc/apt/preferences.d/unstable.pref

mv /bin/sh /bin/shell
ln -s /opt/shell.sh /bin/sh
mv /bin/bash /bin/bshell
ln -s /opt/bash.sh /bin/bash

chmod -R a+x /opt/
