export XDG_RUNTIME_DIR=/run/ias/

export XDG_RUNTIME_DIR=/run/ias/
systemctl status ias
q
systemctl status ias-earlyapp
q
echo "PermitRootLogin yes" > /etc/ssh/sshd_config
ip addr
