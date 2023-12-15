#!/bin/bash

set -e
if [ ! -f /home/ec2-user/environment/cloud9-setup/resume-after-reboot ]
then    
   
   ### Code that should run before shell is rebooted. ###
    
   script="bash /home/ec2-user/environment/cloud9-setup/cloud9-setup.sh"
   echo "$script" >>  ~/.bashrc
   sudo touch /home/ec2-user/environment/cloud9-setup/resume-after-reboot
   source ~/.bashrc 
else
   sed -i '/bash/d' ~/.bashrc   
   sudo rm -f /home/ec2-user/environment/cloud9-setup/resume-after-reboot
   source ~/.bash_profile
    
   ### Code that should run after shell is restarted. ###

fi