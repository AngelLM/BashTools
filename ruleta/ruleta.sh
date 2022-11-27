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

function ctrl_c (){
  echo -e "\n\n${yellowColour}[!]${endColour}${grayColour} Saliendo...${endColour}\n"
  tput cnorm # Mostrar el cursor
  exit 1
}

# Ctrl+C
trap ctrl_c INT

function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}${purpleColour} $0${endColour}"
  echo -e "\t${purpleColour}-m)${endColour}${grayColour} Cantidad de dinero con el que se desa jugar${endColour}"
  echo -e "\t${purpleColour}-t)${endColour}${grayColour} Técnica a utilizar ${endColour}${greenColour}(martingala/inverseLabrouchere)${endColour}"
  echo -e "\t${purpleColour}-h)${endColour}${grayColour} Mostrar este panel de ayuda\n${endColour}"
}

function martingala (){
  #echo -e "\n${yellowColour}[+]${endColour}${grayColour} Vamos a jugar con la técnica ${endColour}${purpleColour} martingala${endColour}"
  echo -ne "${yellowColour}[?]${endColour}${grayColour} ¿Cuál quieres que sea la apuesta inicial? -> ${endColour}" && read initial_bet
  echo -ne "${yellowColour}[?]${endColour}${grayColour} ¿A qué quieres jugar ${endColour}${purpleColour}(${endColour}${blueColour}par${endColour}${purpleColour}/${endColour}${blueColour}impar${endColour}${purpleColour})${endColour}${grayColour}? -> ${endColour}" && read par_impar

  #echo -e "${yellowColour}[+]${endColour}${grayColour} Vamos a jugar con una cantidad inicial de ${endColour}${blueColour}$initial_bet€${endColour}${grayColour} a ${endColour}${blueColour}$par_impar${endColour}"
  
  tput civis # Ocultar el cursor

  current_bet=$initial_bet
  total_plays=0
  loss_plays=0
  loss_streak_numbers="[ "
  win_plays=0
  loss_streak=0
  win_streak=0
  best_streak=0
  worst_streak=0
  best_time_money=0

  while true; do
    money=$(($money-$current_bet))
    if [ $money -lt 0 ]; then
      loss_streak_numbers+="]"

      echo -e "\n${redColour}[!] No te queda dinero para seguir apostando. Total de jugadas: ${endColour}${yellowColour}$total_plays${endColour}"
      echo -e "\t${yellowColour}[*]${endColour} Última racha de jugadas perdidas: ${endColour}${yellowColour}$loss_streak${endColour}"
      echo -e "\t${yellowColour}[*]${endColour} Números de la última mala racha: ${endColour}${yellowColour}$loss_streak_numbers${endColour}"
      echo -e "\t${yellowColour}[*]${endColour} Total de jugadas perdidas: ${endColour}${yellowColour}$loss_plays${endColour}"
      echo -e "\t${yellowColour}[*]${endColour} Peor racha de jugadas perdidas: ${endColour}${yellowColour}$worst_streak${endColour}"
      echo -e "\t${yellowColour}[*]${endColour} Total de jugadas ganadas: ${endColour}${yellowColour}$win_plays${endColour}"
      echo -e "\t${yellowColour}[*]${endColour} Mejor racha de jugadas ganadas: ${endColour}${yellowColour}$best_streak${endColour}"
      echo -e "\t${yellowColour}[*]${endColour} Mejor marca de dinero: ${endColour}${yellowColour}$best_time_money${endColour}"
      
      tput cnorm
      exit 0
    else
      #echo -e "\n${yellowColour}[+]${endColour}${grayColour} Acabas de apostar ${endColour}${yellowColour}$current_bet€${endColour}${grayColour}, cantidad restante: ${endColour}${yellowColour}$money€${endColour}"
      random_number="$(($RANDOM % 37))"
      #echo -e "${yellowColour}[+]${endColour}${grayColour} Ha salido el número${endColour}${yellowColour} $random_number${endColour}"
      if [ "$par_impar" == "par" ]; then 
        if [ "$(($random_number%2))" -eq 0 ] ; then
          if [ "$random_number" -eq 0 ]; then
            #echo -e "${redColour}[+] Ha salido el 0, pierdes${endColour}"
            reward=0
            current_bet=$(($current_bet*2))
            
            win_streak=0
            let loss_plays+=1
            let loss_streak+=1
            if [ $loss_streak -gt $worst_streak ]; then
              worst_streak=$loss_streak
            fi
            loss_streak_numbers+="$random_number "
          else
            #echo -e "${greenColour}[+] El número que ha salido es par, ¡ganas!${endColour}"
            reward=$(($current_bet*2))
            current_bet=$initial_bet

            loss_streak=0
            let win_plays+=1
            let win_streak+=1
            if [ $win_streak -gt $best_streak ]; then
              best_streak=$win_streak
            fi
            loss_streak_numbers="[ "
          fi
        else
          #echo -e "${redColour}[+] El número que ha salido es impar, pierdes${endColour}"
          reward=0
          current_bet=$(($current_bet*2))

          win_streak=0
          let loss_plays+=1
          let loss_streak+=1
          if [ $loss_streak -gt $worst_streak ]; then
           worst_streak=$loss_streak
          fi
          loss_streak_numbers+="$random_number "

        fi
        #sleep 0.5
      else
        if [ "$(($random_number%2))" -eq 1 ] ; then
          #echo -e "${greenColour}[+] El número que ha salido es impar, ¡ganas!${endColour}"
          reward=$(($current_bet*2))
          current_bet=$initial_bet

          loss_streak=0
          let win_plays+=1
          let win_streak+=1
          if [ $win_streak -gt $best_streak ]; then
            best_streak=$win_streak
          fi
          loss_streak_numbers="[ "
        else
          #echo -e "${redColour}[+] El número que ha salido es par, pierdes${endColour}"
          reward=0
          current_bet=$(($current_bet*2))
          win_streak=0
          let loss_plays+=1
          let loss_streak+=1
          if [ $loss_streak -gt $worst_streak ]; then
            worst_streak=$loss_streak
          fi
          loss_streak_numbers+="$random_number "
        fi
        #sleep 0.5

      fi
      money=$(($money+reward))
      total_plays=$(($total_plays+1))
      if [ $money -gt $best_time_money ]; then
        best_time_money=$money
      fi
    fi
  done

  tput cnorm # Mostrar el cursor
}

function inverseLabrouchere(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Vamos a jugar con la técnica ${endColour}${purpleColour} Inverse Labrouchere${endColour}"
  echo -ne "${yellowColour}[?]${endColour}${grayColour} ¿A qué quieres jugar ${endColour}${purpleColour}(${endColour}${blueColour}par${endColour}${purpleColour}/${endColour}${blueColour}impar${endColour}${purpleColour})${endColour}${grayColour}? -> ${endColour}" && read par_impar

  declare -a my_sequence=(1 2 3 4)
  declare -i bet=0
  total_plays=0
  loss_plays=0
  loss_streak_numbers="[ "
  win_plays=0
  loss_streak=0
  win_streak=0
  best_streak=0
  worst_streak=0
  best_time_money=0


  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Comenzamos con la secuencia ${endColour}${BlueColour}[ ${my_sequence[@]} ]${endColour}"
  tput civis
  while true; do
    if [ ${#my_sequence[@]} -eq 1 ]; then
      bet=${my_sequence[0]}
    else
      bet=$((${my_sequence[0]}+${my_sequence[-1]}))
    fi
    
    money=$(($money-$bet))
    
    if [ "$money" -lt 0 ]; then
      loss_streak_numbers+="]"

      echo -e "\n${redColour}[!] No te queda dinero para seguir apostando. Total de jugadas: ${endColour}${yellowColour}$total_plays${endColour}"
      echo -e "\t${yellowColour}[*]${endColour} Última racha de jugadas perdidas: ${endColour}${yellowColour}$loss_streak${endColour}"
      echo -e "\t${yellowColour}[*]${endColour} Números de la última mala racha: ${endColour}${yellowColour}$loss_streak_numbers${endColour}"
      echo -e "\t${yellowColour}[*]${endColour} Total de jugadas perdidas: ${endColour}${yellowColour}$loss_plays${endColour}"
      echo -e "\t${yellowColour}[*]${endColour} Peor racha de jugadas perdidas: ${endColour}${yellowColour}$worst_streak${endColour}"
      echo -e "\t${yellowColour}[*]${endColour} Total de jugadas ganadas: ${endColour}${yellowColour}$win_plays${endColour}"
      echo -e "\t${yellowColour}[*]${endColour} Mejor racha de jugadas ganadas: ${endColour}${yellowColour}$best_streak${endColour}"
      echo -e "\t${yellowColour}[*]${endColour} Mejor marca de dinero: ${endColour}${yellowColour}$best_time_money${endColour}"
      
      tput cnorm
      exit 0
    else
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Apostamos ${endColour}${BlueColour}$bet€${endColour}${grayColour}. Dinero restante: ${endColour}${yellowColour}$money${endColour}"
      random_number="$(($RANDOM % 37))"
      if [ "$par_impar" == "par" ]; then
        if [ "$(($random_number%2))" -eq 0 ] ; then
          if [ "$random_number" -eq 0 ]; then
            echo -e "${redColour}[+] Ha salido el 0, pierdes${endColour}"
            reward=0
            if [ "${#my_sequence[@]}" -gt 2 ]; then
              unset my_sequence[0]
              unset my_sequence[-1]
              my_sequence=(${my_sequence[@]})
            else
              my_sequence=(1 2 3 4)
            fi
            
            win_streak=0
            let loss_plays+=1
            let loss_streak+=1
            if [ $loss_streak -gt $worst_streak ]; then
              worst_streak=$loss_streak
            fi
            loss_streak_numbers+="$random_number "
          else
            echo -e "${greenColour}[+] El número que ha salido es par, ¡ganas!${endColour}"
            reward=$(($bet*2))
            my_sequence+=($bet)

            loss_streak=0
            let win_plays+=1
            let win_streak+=1
            if [ $win_streak -gt $best_streak ]; then
              best_streak=$win_streak
            fi
            loss_streak_numbers="[ "
          fi
        else
          echo -e "${redColour}[+] El número que ha salido es impar, pierdes${endColour}"
          reward=0
            if [ "${#my_sequence[@]}" -gt 2 ]; then
              unset my_sequence[0]
              unset my_sequence[-1]
              my_sequence=(${my_sequence[@]})
            else
              my_sequence=(1 2 3 4)
            fi

          win_streak=0
          let loss_plays+=1
          let loss_streak+=1
          if [ $loss_streak -gt $worst_streak ]; then
           worst_streak=$loss_streak
          fi
          loss_streak_numbers+="$random_number "
        fi
      else
        if [ "$(($random_number%2))" -eq 1 ] ; then
          echo -e "${greenColour}[+] El número que ha salido es impar, ¡ganas!${endColour}"
          reward=$(($bet*2))
          my_sequence+=($bet)

          loss_streak=0
          let win_plays+=1
          let win_streak+=1
          if [ $win_streak -gt $best_streak ]; then
            best_streak=$win_streak
          fi
          loss_streak_numbers="[ "
        else
          echo -e "${redColour}[+] El número que ha salido es par, pierdes${endColour}"
          reward=0
            if [ "${#my_sequence[@]}" -gt 2 ]; then
              unset my_sequence[0]
              unset my_sequence[-1]
              my_sequence=(${my_sequence[@]})
            else
              my_sequence=(1 2 3 4)
            fi

          win_streak=0
          let loss_plays+=1
          let loss_streak+=1
          if [ $loss_streak -gt $worst_streak ]; then
           worst_streak=$loss_streak
          fi
          loss_streak_numbers+="$random_number "
        fi
      fi
      echo -e "${yellowColour}[+]${endColour}${grayColour} La secuencia ahora es: ${endColour}${BlueColour}[ ${my_sequence[@]} ]${endColour}"
      sleep 5
      money=$(($money+reward))
      total_plays=$(($total_plays+1))
      if [ $money -gt $best_time_money ]; then
        best_time_money=$money
      fi
    fi
  done
  tput cnorm
}
  


while getopts "m:t:h" arg; do
  case $arg in
    m) money=$OPTARG;;
    t) technique=$OPTARG;;
    h) helpPanel;;
  esac
done

if [ $money ] && [ $technique ]; then
  if [ "$technique" == "martingala" ]; then
    martingala
  elif [ "$technique" == "inverseLabrouchere" ]; then
    inverseLabrouchere
  else
    echo -e "${redColour}[!] La técnica introducida no existe${endColour}"
    helpPanel
  fi
else
  helpPanel
fi

