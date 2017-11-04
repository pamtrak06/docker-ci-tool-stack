#!/bin/bash
set -u
set -e

projectname="ci"
composename="docker-compose.yaml"
home_path=$PWD

function findCurrentOSType()
{
  osType=$(uname)
  case "$osType" in
    "Darwin")  
	  echo "OS: MacOSX detected"
    ;;
    "Linux")
      echo "OS: Linux detected"
    ;;
    *) 
     {
       echo "Unsupported OS, exiting"
       exit
     } ;;
  esac
}
	
findCurrentOSType

# create user jenkins and sonar on host machine
if id "jenkins" >/dev/null 2>&1; then
  echo "INFO: user jenkins exists"
else
  echo -e "ERROR: user jenkins does not exist, please add it"
  case "$osType" in
    "Darwin")
	{
  	  echo -e "\tsudo dscl . -create /Users/jenkins"
  	  echo -e "\tsudo dscl . -create /Users/jenkins UserShell /bin/bash"
	  echo -e "\tsudo dscl . -create /Users/jenkins RealName \"jenkins\""
	  echo -e "\tsudo dscl . -create /Users/jenkins UniqueID 1000"
	  echo -e "\tsudo dscl . -create /Users/jenkins PrimaryGroupID 1000"
	  echo -e "\tsudo dscl . -passwd /Users/jenkins"
    } ;;
    "Linux")
	{
	  echo -e "\tsudo useradd -u 1000 -g 1000 -d /home/jenkins jenkins"
	  echo -e "\tsudo usermod -aG docker jenkins"
    } ;;
  esac		  
  exit
fi

# check if edjanger is installed, if not install it
shopt -s expand_aliases
if [ ! -f "/opt/edjanger" ]; then
  edjanger_home=/opt/edjanger
else
  edjanger_home=/usr/local/bin/edjanger
fi

if [ ! -f "$edjanger_home/edjanger.alias" ]; then
  mkdir -p $edjanger_home && \
  git clone https://github.com/pamtrak06/edjanger.git $edjanger_home && \
  cd /usr/local/bin/edjanger && \
  chmod 755 scripts/*.sh; chmod 755 edjangerinstall.sh && \
  ./edjangerinstall.sh --alias && \
  cd $home_path
else
  echo -e "INFO: edjanger detected here: \"$edjanger_home\""
fi

. $edjanger_home/edjanger.alias

HOME_PATH=$PWD

# check if proxy env is available and/or required

# option : configure credentials in docker-compose.yaml

# option : configure ports mapping (sonar & jenkins)
echo -e "INFO: read parameters from docker-compose.properties and generate docker-compose.yaml..."
. docker-compose.properties && envsubst < "docker-compose.template" | tee "docker-compose.yaml" > /dev/null

# Function for docker-compose
function docker-compose-cmd {
  docker-compose -f $composename --project-name $projectname $@
}

# Function for docker build
function docker-build {
  cd $HOME_PATH/jenkins && edjangertemplate --configure=configuration && edjangerbuild
  cd $HOME_PATH/nexus && edjangertemplate --configure=configuration && edjangerbuild
  cd $HOME_PATH/sonar/sonar-db && edjangertemplate --configure=configuration && edjangerbuild
  cd $HOME_PATH/sonar/sonar-server && edjangertemplate --configure=configuration && edjangerbuild
  cd $HOME_PATH
}

# Function for docker build
function clean-workspace {
  find . -name "*.bak" -exec rm -rf {} \;
  find . -name "edjanger.properties" -exec rm -rf {} \;
}

clean-workspace
#docker-compose-cmd "down"
#docker-compose-cmd "pull"
#docker-compose-cmd "build"
docker-build
docker-compose-cmd "up -d"
docker-compose-cmd "logs -f --tail 100"

