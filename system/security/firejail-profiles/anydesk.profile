# Allow access to specific system directories
whitelist /var/lib/AccountsService/users
whitelist /run/user/*

# Allow AnyDesk to create and manage its required directories
noblacklist /var
noblacklist /run
noblacklist /home

# Allow network access
netfilter
caps.drop all
caps.keep net_bind_service

# Use private temporary directory
private-tmp

# Optional: Restrict access to sensitive directories
noblacklist ${HOME}/.config/anydesk
noblacklist /etc

