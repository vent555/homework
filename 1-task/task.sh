#!/bin/bash
echo
echo "Script will show informathion for Firefox process"
echo "unless you enter another process name or ID as argument."
echo

if [ ${#@} -gt 0 ] 
then

  if echo $@ | egrep '^[1-9].[0-9]*$' &>/dev/null
  then
    echo "You have entered PID as argument."
  else
    echo "Possible, you have entered process name."
  fi

  _pid=$@

else

  echo 'No valid argument entered, process name is "firefox"'
  _pid=firefox

fi

netstat -tunapl 2>/dev/null | awk '/'${_pid}'/ {print $5}' | cut -d: -f1 | sort | uniq > /tmp/t1.tmp

if [ $(wc -l /tmp/t1.tmp | cut -d" " -f1) -gt 0 ]
then

  if [ -e /tmp/t2.tmp ]
  then
    rm /tmp/t2.tmp
  fi

  touch /tmp/t2.tmp

  for IP in $(cat /tmp/t1.tmp)
  do
    whois $IP | awk -F':' '/^Organization/ {print $2}' >> /tmp/t2.tmp
  done

  echo
  echo "Your process have "$(wc -l /tmp/t2.tmp | cut -d" " -f1)" esteblished connection(s)."
  echo "COUNT_CON  ORGANIZATION_NAME"
  cat /tmp/t2.tmp | sort | uniq -c

else
  echo "There is no entries for your process."
fi

rm -f /tmp/t[12].tmp

exit
