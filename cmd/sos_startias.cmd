export XDG_RUNTIME_DIR=/run/ias/\n
systemctl enable ias-earlyapp\n
systemctl start ias-earlyapp\n
systemctl enable ias\n
systemctl start ias\n
