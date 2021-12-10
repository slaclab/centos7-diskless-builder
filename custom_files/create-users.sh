passwd -d root

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
