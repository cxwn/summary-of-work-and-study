#!/bin/bash
DelUsername=('lihui' 'durh' 'xiaoya') #delete the users
ChangeUsername='wuyx'   #just modify an user
NewUsername='lihui'
for User in ${DelUsername[@]}
    do  
        id $User>&/dev/null
        if [ $? -eq 0 ] ;then
            userdel -r $User
            echo -e "\033[47;31m The account $User had been deleted!  \033[0m"
        else
            echo "The account is not existent.Please check!"
        fi  
    done
id $ChangeUsername>&/dev/null
if [ $? -eq 0 ] ;then
    rm -rf /home/$ChangeUsername
    usermod $ChangeUsername -l $NewUsername
    mv /home/$ChangeUsername /home/$NewUsername #重命名被修改用户的home目录
    echo 'Neoby123'|passwd $NewUsername --stdin #修改新用户的密码
else
    echo "The account is not existent.Please check!"
fi  
sed -i 's/lihui,//g' /etc/sudoers
sed -i '/^Cmnd_Alias DELEGATING/d' /etc/sudoers
sed -i '/^Cmnd_Alias PROCESSES/d' /etc/sudoers
sed -i '/^Cmnd_Alias SOFTWARE/d' /etc/sudoers
sed -i '/^Cmnd_Alias STORAGE/d' /etc/sudoers
sed -i '/DEVOPS/d' /etc/sudoers  #删除带DEVOPS的行
sed -i 's/wuyx/lihui/g' /etc/sudoers #把所有的wuyx替换成lihui