#!/bin/bash
#########################
# by: jisd      
# at: 2018.6.14        
# in: jinan 
#########################
sshInst()
{
       yum remove openssh -y
       yum install gcc openssl-devel zlib-devel -y
       Openssh_URL = https://fastly.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-7.7p1.tar.gz
       wget -P /mnt/ $Openssh_URL
       tar zxvf openssh-7.7p1.tar.gz -C /mnt/
       cd /mnt/openssh-7.7p1
       ./configure
       make && make install
  
}
  

  
CHG_SSHD()
{
##Chenge /etc/init.d/sshd
       chmod +x /etc/init.d/sshd
       OPT_VALUE='OPTIONS="-f /etc/ssh/sshd_config"'
       OPT_EXIST=`grep "${OPT_VALUE}" /etc/init.d/sshd`
        if [ -z "${OPT_EXIST}" ];then
                sed -i '/$SSHD $OPTIONS &&/i\\t'"${OPT_VALUE}"'' /etc/init.d/sshd
        else
                echo ${OPT_EXIST}
        fi
        PATH_EXIST=`grep "${NPATH}" /etc/init.d/sshd`
        if [ -n "${PATH_EXIST}"  ];then
                echo "${PATH_EXIST}"
        else
                sed -i "s:${OPATH}:${NPATH}:" /etc/init.d/sshd
        fi
              echo "/etc/init.d/sshd file changes completed."
}
CHG_CONF()
{
##Chenge /etc/ssh/sshd_config 
       cp sshd_config /etc/ssh/sshd_config
       sed -i '/#PermitRootLogin/i\PermitRootLogin yes' /etc/ssh/sshd_config
       PATH_EXIST=`grep "${NPATH}" /etc/ssh/sshd_config`
       if [ -z "${PATH_EXIST}" ];then
              sed -i "s:${OPATH}:${NPATH}:" /etc/ssh/sshd_config
       else
              echo "${PATH_EXIST}"
       fi
       echo "/etc/ssh/sshd_config file changes completed."
}
  
OPATH=/usr/
NPATH=/usr/local/
echo -n "The SSH current version is:" 
ssh -V 
while true;do
    echo -n "Continue to update?(yes/no)"
    read INPUT
    case $INPUT in
        Y|y|YES|yes)
            sshInst
      echo -n "Press any key to continue....."
      read AnyKey
  
      cp /usr/local/bin/ssh /usr/bin/ssh
      echo "Copying ssh....Done."
      cp /usr/local/etc/ssh_host_ecdsa_key.pub /etc/ssh/ssh_host_ecdsa_key.pub
      echo "Copying ssh_host_ecdsa_key.pub....Done."
      cp /mnt/openssh-7.7p1/contrib/redhat/sshd.init /etc/init.d/sshd
      echo "Copying sshd....Done."
      CHG_SSHD
      CHG_CONF
      break;;
        N|n|NO|no)
          echo exited
          exit ;;
        "")
      break;;
  esac
done
chkconfig --add sshd
chkconfig sshd on
service sshd start
echo "Operation is completed."

