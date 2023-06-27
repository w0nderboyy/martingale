#!/bin/bash
#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

techniques_array=("martingale" "labrouchere" "inverseLabrouchere")

#Indicadores
declare -i odd_counter=0
declare -i even_counter=0
declare -a bad_numbers=()  
#Funciones
function helpPanel(){
	echo -e "\n${grayColour}You need to specify BOTH parameters to play:${endColour}"
	echo -e "\t${yellowColour}-m: Amount of money to play the game.${endColour}"
	echo -e "\t${yellowColour}-t: Technique: ${techniques_array[@]}.${endColour}"
}

function loss(){
	bet=$(($bet*2))
	echo -e "${redColour}LOST. Bank: $remain. Next bet $bet${endColour}"
}

function win(){
	reward=$(($bet*2))
	remain="$(($remain+$reward))"
	bet=$initial_bet
	echo -e "${greenColour}WON. Bank: $remain${endColour}"
}

# if [[ even_or_odd != "even" && even_or_odd != "odd" ]]; then
# 	echo "Please select a valid option (even or odd)."
# 	return
# fi
function martingale(){
	echo -n "Initial bet: " && read initial_bet
	echo -n "even or odd?: " && read even_or_odd
	echo -e "${greenColour}Initial bet $initial_bet. Betting to $even_or_odd${endColour}"
	remain=$money_amount
	bet=$initial_bet
	while [[ $remain -ge 1  && $remain -ge $bet ]]; do
		remain=$(($remain-$bet))
		random_number="$(($RANDOM % 37))"
		echo -e "${yellowColour}Money: $remain${endColour}"
		echo -e "${yellowColour}Bet: $bet${endColour}"
		echo -e "${yellowColour}Number: $random_number${endColour}"
		if [[ $random_number -eq 0 ]]; then
			loss $remain $reward $bet
			bad_numbers+=( $random_number )  
		elif [[ "$(($random_number % 2))" -eq 0 ]]; then
			even_counter+=1
			if [[ $even_or_odd == "even" ]]; then
				win $reward $remain $bet
				unset bad_numbers
			else
				loss $remain $reward $bet
				bad_numbers+=( $random_number )
			fi
		else
			odd_counter+=1
			if [[ $even_or_odd == "odd" ]]; then
				win $reward $remain $bet
				unset bad_numbers
			else
				loss $remain $reward $bet
				bad_numbers+=( $random_number )
			fi
		fi
		
		# sleep 1.4
	done
	echo -e "${yellowColour}EVENS=$even_counter.ODDS=$odd_counter${endColour}"
	echo -e "${yellowColour}Initial amount=$money_amount. BANK=$remain.${endColour}"
	echo -e "${yellowColour}Loser Sequence=${bad_numbers[@]}${endColour}"
	if [[ $money_amount -eq $remain ]]; then
		echo -e "${yellowColour}NO MONEY LOST. NO MONEY MADE${endColour}"
	elif [[ $money_amount -gt $remain ]]; then
		echo -e "${redColour}YOU LOST $(($money_amount-$remain))${endColour}"
	else
		echo -e "${greenColour}YOU WON $(($remain-$money_amount))${endColour}"
	fi

}




while getopts "m:t:h" arg; do
	case $arg in
		m) money_amount=$OPTARG;;
		t) technique=$OPTARG;;
		h) help=1;;
	esac
done

if [[ $money_amount ]]; then
	if [[ $(echo ${techniques_array[@]} | fgrep -w ${technique}) ]]; then 
		echo -e "${greenColour}WELCOME TO RULET GAME${endColour}"
		echo -e "${greenColour}Money: $ ${money_amount}${endColour}"
		echo -e "${yellowColour}Technique: ${technique}${endColour}"

		if [[ $technique == "martingale" ]]; then
			martingale $money_amount
		fi
	else
		helpPanel
	fi
else
	if [[ ! $help ]]; then
		helpPanel
	else
		helpPanel
	fi
fi
