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

#echo "Watch connection state are you want to trace?"
#echo 'Enter 

sudo netstat -tunapl | awk '/'${_pid}'/ {print $5}' | cut -d: -f1 | sort | uniq -c | sort > t1.tmp

if [ $(wc -l t1.tmp | cut -d" " -f1) -gt 0 ]
then

  if [ -e t2.tmp ]
  then
    rm t2.tmp
  fi

  touch t2.tmp

  for IP in $(cat t1.tmp | egrep '([0-9]+\.){3}[0-9]+')
  do
    whois $IP | awk -F':' '/^Organization/ {print $2}' >> t2.tmp
  done

  echo ""
  echo "Your process have "$(wc -l t2.tmp | cut -d" " -f1)" esteblished connection(s)."
  echo "COUNT_CON  ORGANIZATION_NAME"
  cat t2.tmp | sort | uniq -c

else
  echo "There is no entries for your process."
fi

exit
