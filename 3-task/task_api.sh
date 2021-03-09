#!/bin/bash

#create work directory with random name
workdir="/tmp/task-3-$(tr -dc A-Za-z0-9_- </dev/urandom | head -c 8 | xargs)"
mkdir ${workdir}

source task.func

#check input argument (assumes http-link to repozitory)
gh_usr_repo=$(inptchck ${@})

np=1
#try to download page whith pull requests
echo "Try to download all open pull requests from:"
echo "https://api.github.com/repos/${gh_usr_repo}/pulls"
echo
echo -n "Downloading pages: 1"
curl -s https://api.github.com/repos/${gh_usr_repo}/pulls?page=${np} > ${workdir}/pg1

#second page if exist
let np+=1
echo -n "... "
nextpr=$(curl -s https://api.github.com/repos/${gh_usr_repo}/pulls?page=${np})

#download all rest pages (if more then one) with pull requests list
while [ "$(echo ${nextpr} | jq -r '.[]')" != "" ]
do
    echo -n "${np} "
    echo ${nextpr} >> ${workdir}/pg${np}
    let np+=1
    nextpr=$(curl -s https://api.github.com/repos/${gh_usr_repo}/pulls?page=${np})
done    
echo -n "complited."

#parsing every downloaded file
for pgfile in $(ls ${workdir}/pg[0-9]*)
do
    #progress bar
    echo
    echo "Processing ${pgfile}..."

    for np in $(seq 0 29)
    do
        #if no more data (PR is empty) then exit from cycle
        [ "$(cat ${pgfile} | jq -r '.['${np}']')" = "null" ] && break
        #show the progress bar
        echo -n "#"
        
        #extract username of PR author 
        user_name=$(cat ${pgfile} | jq -r '.['${np}'] | .user.login')

        #is PR with label? 
        if [ "$(cat ${pgfile} | jq -r '.['${np}'] | .labels | .[]')" = "" ]
        then
            lbl_xst=false
        else
            lbl_xst=true
        fi

        #user's url
        user_url=$(cat ${pgfile} | jq -r '.['${np}'] | .user.url')

        #save parsing result
        echo "${user_name},${lbl_xst},${user_url}" >> ${workdir}/result
    done
done
#complite progress bar
for a in $(seq ${np} 29)
do
    echo -n "#"
done
sleep 1
echo

#set cycle dilimiter as "\n"
IFS=$'\n'
#find contributors with two or more pull requests
#display its login, name and number of user repositories
echo "The most active contributors with more then one pull request:"
echo -e "NMBR_PR LOGIN\t\t\tUSER_NAME\t\tNMBR_USR_REPOS"
for str in $(cat ${workdir}/result | cut -d, -f1,3 | sort | uniq -c)
do
    if [ $(echo ${str} | tr -s ' ' | cut -d" " -f2) -gt 1 ]
    then
        
        #display number of PR and user login
        _login=$(echo ${str} | tr -s ' ' | cut -d" " -f3 | cut -d, -f1)
        tabs ${#_login} $(echo ${str} | cut -d, -f1)
        echo -ne "\t"

        user_url=$(curl -s $(echo ${str} | cut -d, -f2))

        #display user name
        usr_nm=$(echo ${user_url} | jq -r '.name')
        [ "${usr_nm}" = "null" ] && usr_nm=
        tabs ${#usr_nm} ${usr_nm}

        #display number of user repositories
        nmbr_usr_rep=$(echo ${user_url} | jq -r '.public_repos')
        [ "${nmbr_usr_rep}" = "null" ] && nmbr_usr_rep=0
        echo -ne "\t${nmbr_usr_rep}"
        echo
    fi
done
echo
#pull requests with label
pr_labels ${workdir}
echo
echo

# #user may save result of parsing if he want
save_result ${workdir}

#clean up after itself
rm -rf ${workdir}

exit