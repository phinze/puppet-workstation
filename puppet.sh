if [[ $1 == "debug" ]]; then
  puppet apply --debug --trace --modulepath=modules/ puppet.pp
else
  puppet apply --modulepath=modules/ puppet.pp
fi
