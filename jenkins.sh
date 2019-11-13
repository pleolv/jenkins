#!/bin/sh 

# setup installation environment variables 
if [ ${BUILD_ONLY} ] && [ ${BUILD_ONLY} == "true" ]
then 
	echo "Buld is completed! You can find build package in ${PKG}/target/package/"
	exit 0
fi 

# copying installation files 
ssh ${SSH_USER}@${HOST} 'mkdir -p ~/install'

scp ${PKG}/target/package/*.tar.gz ${SSH_USER}@${HOST}:~/install

# clearing .install.source
ssh ${SSH_USER}@${HOST} "echo -n > ~/.install.source"

if [ ${SKIP_INSTALL} ] && [ ${SKIP_INSTALL} == "true" ]
then 
	echo "Installation is skipped! Package `ls ${PKG}/target/package/*.tar.gz` has been transfered to ${SSH_USER}@${HOST}:~/install"
	exit 0
fi 

# setup installation environment variables 
if [ ${PKG} ] && [ ${PKG} == "ECE" ]
then 
  if [ ${ECE_RESTART} ] 
  then
    ssh ${SSH_USER}@${HOST} "echo export ECE_RESTART=${ECE_RESTART} >> ~/.install.source"
  fi  
  if [ ${ECE_NO_PRICING_RELOAD} ] 
  then
    ssh ${SSH_USER}@${HOST} "echo export ECE_NO_PRICING_RELOAD=${ECE_NO_PRICING_RELOAD} >> ~/.install.source"
  fi
fi 

if [ ${PKG} ] && [ ${PKG} == "NoSQL" ]
then 
  if [ ${NOSQL_INITIATE} ] 
  then
    ssh ${SSH_USER}@${HOST} "echo export NOSQL_INITIATE=${NOSQL_INITIATE} >> ~/.install.source"
  fi  
  if [ ${NOSQL_RESTART} ] 
  then
    ssh ${SSH_USER}@${HOST} "echo export NOSQL_RESTART=${NOSQL_RESTART} >> ~/.install.source"
  fi  
fi 

if [ ${PKG} ] && [ ${PKG} == "Rundeck" ]
then 
  if [ ${RUNDECK_RESTART} ] 
  then
    ssh ${SSH_USER}@${HOST} "echo export RUNDECK_RESTART=${RUNDECK_RESTART} >> ~/.install.source"
  fi  
fi 

if [ ${POST_INSTALL_TASK} ] 
then 
  ssh ${SSH_USER}@${HOST} "echo export POST_INSTALL_TASK=${POST_INSTALL_TASK} >> ~/.install.source"
fi 
if [ ${INSTALL_DIR} ] 
then 
  ssh ${SSH_USER}@${HOST} "echo export INSTALL_DIR=${INSTALL_DIR} >> ~/.install.source"
fi 

ssh ${SSH_USER}@${HOST} << 'EOF'

if [ -f ~/.install.source ]; then
  source ~/.install.source
fi

cd ~/install
PACKAGE=$(ls *.tar.gz)
DIR=${PACKAGE/.tar.gz/}

mkdir $DIR
mv $PACKAGE $DIR
cd $DIR

tar zxf $PACKAGE
chmod u+x *.sh

if [ ${INSTALL_DIR} ] 
then
  ln -s ${PWD}/install_all.sh RELEASE/${INSTALL_DIR}/install_all.sh 
  ln -s ${PWD}/install_config.sh RELEASE/${INSTALL_DIR}/install_config.sh 
  ln -s ${PWD}/setup_logging.sh RELEASE/${INSTALL_DIR}/setup_logging.sh 
  cd RELEASE/${INSTALL_DIR}
fi  
sh install_all.sh
 
EOF
