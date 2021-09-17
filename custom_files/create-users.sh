passwd -d root

# Create group lcls, if needed
egrep -i "lcls" /etc/group;
if [ ! $? -eq 0 ]; then
  groupadd lcls
  groupmod -g 2211 lcls
fi

# Create user laci, if needed
egrep -i "laci" /etc/passwd;
if [ ! $? -eq 0 ]; then
  useradd -g lcls -d /home/laci -m laci
  usermod -u 8412 laci
  passwd -d laci
fi
