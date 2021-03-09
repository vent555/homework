#!/bin/bash

#work directory generation
workdir="/tmp/task-3-$(tr -dc A-Za-z0-9_- </dev/urandom | head -c 8 | xargs)"
mkdir ${workdir}

source task.func

#check input argument (assumes http-link to repozitory)
gh_usr_repo=$(inptchck ${@})

#try to download page whith pull requests
echo "Try to download page with open pull requests from:"
echo "https://github.com/${gh_usr_repo}/pulls?q=is%3Aopen+"
curl -s https://github.com/${gh_usr_repo}/pulls?q=is%3Aopen+ > ${workdir}/pg1
echo

#looking for how much pages of pull requests
numb_pgs=$(cat ${workdir}/pg1 | awk -F'<' '/data-total-pages/ {print$5}' | awk -F'"' '/data-total-pages/ {print$4}')

#download all rest pages (if more then one) with pull requests list
if [ ${#numb_pgs} -gt 0 ]
then
    np=${numb_pgs}
    echo "More then one page with pull requests. Downloading all pages..."
    echo -n "${np} "
    while [ ${np} -gt 1 ]
    do
        curl -s "https://github.com/${gh_usr_repo}/pulls?page=${np}&q=is%3Aopen+" > ${workdir}/pg${np}
        let np-=1
        echo -n "${np} "
    done
fi
echo

#set cycle dilimiter as "\n"
IFS=$'\n'
#save result of parsing here
touch ${workdir}/result

#parsing every downloaded file
for pgfile in $(ls ${workdir}/pg[0-9]*)
do
    #initialise values for each file:
    #variable stores issue number of pull request
    issue_value=
    #who created pull request
    user_name=
    #is PR with label?
    lbl_xst=false
    #how many checks in total
    chcks=0
    #how many checks is OK
    chcksok=0
    
    #progress bar
    np=0
    numb_lines=$(wc -l ${pgfile} | cut -d" " -f1)
    let step=${numb_lines}/50
    echo "Processing ${pgfile}..."

    for str in $(cat ${pgfile})
    do

        #show the progress bar
        [[ ${np}%${step} -eq 0 ]] && echo -n "#"
        let np+=1
        
        #try to look for issue_value
        iss_val=$(echo ${str} | awk -F'"' '/div id="issue_/ {print$2}')
        #echo "iss_val=${iss_val}"
        #echo "issue_value=${issue_value}"

        #while issue_value is not assigned if statment will looking for first iteration
        if [ ${#issue_value} -eq 0 ]
        then
             [ ${#iss_val} -ne 0 ] && issue_value=${iss_val}
        else
         #issue_value have a value already 
            
            #if we find out next issue_value then it is time to save all values!
            if [ ${#iss_val} -ne 0 ]
            then

                #save all
                echo "${user_name},${lbl_xst},${chcksok} / ${chcks}" >> ${workdir}/result

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
    echo
    #save last values for every file
    echo "${user_name},${lbl_xst},${chcksok} / ${chcks}" >> ${workdir}/result
done
echo

#find contributors with two or more pull requests
echo "The most active contributors with more then one pull request:"
echo "NMBR_PR USER_NAME"
for str in $(cat ${workdir}/result | cut -d, -f1 | sort | uniq -c)
do
    [ $(echo ${str} | tr -s ' ' | cut -d" " -f2) -gt 1 ] && echo ${str}
done
echo

#pull requests with label
pr_labels ${workdir}
echo
echo

#display checks of every open PR
echo "User's PR with checks:"
echo -e "USER_NAME\t\tCHEKS_OK / CHECKS"
for str in $(cat ${workdir}/result | cut -d, -f1,3 | sort)
do
    #check if PR have chcks
    if [ -n $(echo ${str} | cut -d, -f2) ]
    then
        #
        usr_nm=$(echo ${str} | cut -d, -f1)
        tabs ${#usr_nm} ${usr_nm}
        echo -ne "\t"
        echo ${str} | cut -d, -f2
    fi
done
echo

#user may seve result of parsing if he want
save_result ${workdir}

#clean up after itself
rm -rf ${workdir}

exit