# Create a password for the root user
passwd -d root
echo Creating password for user root.
sed -i s/^root:[^:]*:/root:'$5$cUbknFhsjO1AdUNM$SQPkWyiRotZc2FHPJf3Syyc30i0Egtyc7NVWhPnI.h6':/1 etc/shadow

# Create group lcls, if needed
egrep -i "lcls" /etc/group;
if [ ! $? -eq 0 ]; then
  groupadd lcls
  groupmod -g 2211 lcls
fi

# Create group facet, if needed
egrep -i "facet" /etc/group;
if [ ! $? -eq 0 ]; then
  groupadd facet
  groupmod -g 2376 facet
fi

# Create group acctest, if needed
egrep -i "acctest" /etc/group;
if [ ! $? -eq 0 ]; then
  groupadd acctest
  groupmod -g 2459 acctest
fi

# Create group qb, if needed
egrep -i "qb" /etc/group;
if [ ! $? -eq 0 ]; then
  groupadd qb
  groupmod -g 1080 qb
fi

# Create user laci, if needed
egrep -i "laci" /etc/passwd;
if [ ! $? -eq 0 ]; then
  useradd -g lcls --shel /bin/sh -d /home/laci -m laci
  usermod -u 8412 laci
  passwd -d laci
fi

# Create user flaci, if needed
egrep -i "flaci" /etc/passwd;
if [ ! $? -eq 0 ]; then
  useradd -g facet --shel /bin/sh -d /home/flaci -m flaci
  usermod -u 11121 flaci
  passwd -d flaci
fi

# Create user acctf, if needed
egrep -i "acctf" /etc/passwd;
if [ ! $? -eq 0 ]; then
  useradd -g acctest --shel /bin/sh -d /home/acctf -m acctf
  usermod -u 11846 acctf
  passwd -d acctf
fi

# Create user spear, if needed
egrep -i "spear" /etc/passwd;
if [ ! $? -eq 0 ]; then
  useradd -g qb --shel /bin/sh -d /home/spear -m spear
  usermod -u 7753 spear
  passwd -d spear
fi

# Create sudoers file
echo Creating sudoers file.
chmod 0440 etc/sudoers
chown root:root etc/sudoers
