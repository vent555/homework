#!/bin/bash

#work directory generation
workdir="/tmp/task-3-$(tr -dc A-Za-z0-9_- </dev/urandom | head -c 8 | xargs)"
mkdir ${workdir}

#check input arguments
badargs=false
if [ ${#1} -gt 0 -a ${#2} -gt 0 ] 
then
    
    if echo $1 | egrep '^[0-9a-zA-Z]+[-_.]*[0-9a-zA-Z]+$' &>/dev/null
    then
        ghuser=$1
    else
        badargs=true
    fi

    if echo $2 | egrep '^[0-9a-zA-Z]+[-_.]*[0-9a-zA-Z]+$' &>/dev/null
    then
        ghrep=$2
    else
        badargs=true
    fi
    
else
    badargs=true
fi

if ${badargs}
then
    echo 'No arguments entered, assuming GitHub user and repository is schacon and blink respectivly.'
    ghuser=ant-design
    ghrep=ant-design
fi

#try to download page whith pull requests
echo "Try to download page whith open pull requests from https://github.com/${ghuser}/${ghrep}/pulls?q=is%3Aopen+"
curl https://github.com/${ghuser}/${ghrep}/pulls?q=is%3Aopen+ > ${workdir}/pg1

#looking for how much pages of pull requests
numb_pgs=$(cat ${workdir}/pg1 | awk -F'<' '/data-total-pages/ {print$5}' | awk -F'"' '/data-total-pages/ {print$4}')

#download all rest pages (if more then one) with pull requests list
if [ ${#numb_pgs} -gt 0 ]
then
    while [ ${numb_pgs} -gt 1 ]
    do
        curl "https://github.com/${ghuser}/${ghrep}/pulls?page=${numb_pgs}&q=is%3Aopen+" > ${workdir}/pg${numb_pgs}
        numb_pgs-=1
    done
fi

#all pullers
#cat ${workdir}/pg1 | awk -F'<' '/Open pull requests created by/ {print$2}' | awk -F'>' '{print$2}' > pullers

#initialise values:
#issue_value
issue_value=        #trash

#
for pgfile in $(ls ${workdir}/pg[0-9]*)
do
    #initialise values for each file:
    #variable stores issue number of pull request
    issue_value=
    user_name=
    lbl_xst=false
    chcks=0
    chcksok=0

    for str in $(cat ${pgfile})
    do

        #try to look for issue_value
        iss_val=$(echo ${str} | awk -F'"' '/div id="issue_/ {print$2}')

        #while issue_value is not assigned if statment will looking for first iteration
        if [ ${#issue_value} -eq 0 ]
        then
            [ ${#iss_val} -ne 0 ] && issue_value=${issue_val1}
        else
        #issue_value have a value already 
            
            #if we find out next issue_value then it is time to save all values!
            if [ ${#iss_val} -ne 0 ]
            then

                #save all
                echo "All variables are: user_name=${user_name}; lbl_xst=${lbl_xst}; ${chcksok} / ${chcks}"

            #else looking for another values and issue_value too
            else
                #
                #try to find user who created the pull request
                usr_nm=$(echo ${str} | awk -F'>|<' '/Open pull requests created by/ {print$3}')
                [ ${#usr_nm} -ne 0 ] && user_name=${usr_nm}
                
                #try to find if label exist
                issue_label=$(echo ${str} | awk '/IssueLabel/ {print}')
                [ ${#issue_label} -ne 0 ] && lbl_xst=true

                #if checks exist then let see how many and how many is ok
                chck_xst=$(echo ${str} | awk -F'"' '/checks OK/ {print$2}')
                if [ ${#chck_xst} -ne 0 ]
                then
                    chcks=$(echo ${chck_xst} | cut -d" " -f3)
                    chcksok=$(echo ${chck_xst} | cut -d" " -f1)
                fi
                
            fi
            



        fi

    done
done

#rm -rf ${workdir}

exit