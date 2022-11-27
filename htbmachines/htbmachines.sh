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


function ctrl_c(){
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
  tput cnorm && exit 1
}

# Ctrl+C
trap ctrl_c INT


# Variables globales
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}"
  echo -e "\t${purpleColour}u)${endColour}${grayColour} Descargar o actualizar archivos necesarios${endColour}"
  echo -e "\t${purpleColour}m)${endColour}${grayColour} Buscar por un nombre de máquina${endColour}"
  echo -e "\t${purpleColour}i)${endColour}${grayColour} Buscar por dirección IP${endColour}"
  echo -e "\t${purpleColour}d)${endColour}${grayColour} Buscar por dificultad${endColour}"
  echo -e "\t${purpleColour}o)${endColour}${grayColour} Buscar por Sistema Operativo${endColour}"
  echo -e "\t${purpleColour}o)${endColour}${grayColour} Buscar por Skill${endColour}"
  echo -e "\t${purpleColour}y)${endColour}${grayColour} Buscar resolución de una máquina${endColour}"
  echo -e "\t${purpleColour}h)${endColour}${grayColour} Mostrar este panel de ayuda\n${endColour}"

}

function updateFiles(){
  tput civis
  if [ ! -f bundle.js ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Descargando archivos necesarios...${endColour}"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Todos los archivos han sido descargados${endColour}"
  else
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Comprobando si existen actualizaciones...${endColour}"
    curl -s $main_url > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
    md5_original_value=$(md5sum bundle.js | awk '{print $1}')
    if [ "$md5_temp_value" == "$md5_original_value" ]; then
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} No se han detectado actualizaciones, lo tienes todo al día ;)${endColour}"
      rm bundle_temp.js
    else
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Se han encontrado actualizaciones disponibles${endColour}"
      sleep 1
      rm bundle.js && mv bundle_temp.js bundle.js
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Los archivos han sido actualizados${endColour}"
    fi
  fi
  tput cnorm
}

function searchMachine (){
  machineName="$1"
  machineName_checker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//')"
  
  if [ "$machineName_checker" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando las propiedades de la maquina ${endColour}${blueColour}$machineName${endColour}${grayColour}:${endColour}\n"
  
    cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//'
  else
    echo -e "\n${redColour}[!] No existe ninguna máquina con el nombre ${endColour}${blueColour}$machineName${endColour}\n"
  fi
}

function searchIP (){
  ipAddress="$1"
  machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"
  if [ "$machineName" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} La máquina correspondiente a la ip ${endColour}${blueColour}$ipAddress${endColour}${grayColour} es: ${endColour}${redColour}$machineName${endColour}"
  else
    echo -e "\n${redColour}[!] No existe ninguna máquina con la dirección IP ${endColour}${blueColour}$ipAddress${endColour}\n"
  fi

} 

function searchLink (){
  machineName="$1"
  youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep "youtube" | awk 'NF{print $NF}')"
  if [ "$youtubeLink" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Resolución de la maquina ${endColour}${blueColour}$machineName${endColour}${grayColour}: ${endColour}${redColour}$youtubeLink${endColour}\n"
  else
    echo -e "\n${redColour}[!] No existe ninguna máquina llamada ${endColour}${blueColour}$machineName${endColour}\n"
  fi
  }

function searchDifficulty (){
  difficulty="$1"

  machinesFound="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

  if [ "$machinesFound" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Las máquinas encontradas de dificultad ${endColour}${blueColour}$difficulty${endColour}${grayColour} son:${endColour}\n"

    cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column

  else
    echo -e "\n${redColour}[!] No existe la dificultad ${endColour}${blueColour}$difficulty${endColour}\n"

  fi
}

function searchOS(){
  os="$1"
  machinesFound="$(cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "$machinesFound" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Las máquinas encontradas con sistema operativo ${endColour}${blueColour}$os${endColour}${grayColour} son:${endColour}\n"
    cat bundle.js | grep "so: \"$os\"" -B 4 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
  else
    echo -e "\n${redColour}[!] No existe el sistema operativo ${endColour}${blueColour}$os${endColour}\n"
  fi
}

function searchOSDifficulty(){
  difficulty="$1"
  os="$2"

  machinesFound="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "so: \"$os\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "$machinesFound" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Las máquinas encontradas de dificultad ${endColour}${blueColour}$difficulty${endColour}${grayColour} con sistema operativo ${endColour}${blueColour}$os${endColour}${grayColour} son:${endColour}\n"
    cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "so: \"$os\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
  else
    echo -e "\n${redColour}[!] El valor de la dificultad o del sistema operativo no es correcto${endColour}\n"
  fi
}

function searchSkill (){
  skill="$1"
  machinesFound="$(cat bundle.js | grep "skills:" -B 6 | grep "$skill" -i -B 6 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "$machinesFound" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Las máquinas encontradas con la Skill ${endColour}${blueColour}$skill${endColour}${grayColour} son:${endColour}\n"
  cat bundle.js | grep "skills:" -B 6 | grep "$skill" -i -B 6 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
  else
    echo -e "\n${redColour}[!] No existe la skill ${endColour}${blueColour}$skill${endColour}\n"
  fi
}

# Indicadores
declare -i parameter_counter=0

# Chivatos
declare -i chivato_difficulty=0
declare -i chivato_os=0

while getopts "m:ui:y:d:o:s:h" arg; do
  case $arg in
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress="$OPTARG"; let parameter_counter+=3;;
    y) machineName="$OPTARG"; let parameter_counter+=4;;
    d) difficulty="$OPTARG"; chivato_difficulty=1; let parameter_counter+=5;;
    o) os="$OPTARG"; chivato_os=1; let parameter_counter+=6;;
    s) skill="$OPTARG"; let parameter_counter+=7;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAddress
elif [ $parameter_counter -eq 4 ]; then
  searchLink $machineName
elif [ $parameter_counter -eq 5 ]; then
  searchDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
  searchOS $os
elif [ $parameter_counter -eq 7 ]; then
  searchSkill "$skill"
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_os -eq 1 ]; then
  searchOSDifficulty $difficulty $os
else
  helpPanel
fi
