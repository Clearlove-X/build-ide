if [ ! -d "/home/ide-settings/extensions" ]
        then
                mkdir -p /home/ide-settings
                tar zxvf /tmp/extensions.tar.gz -C /home/ide-settings/
                rm /tmp/extensions.tar.gz
fi      
if [ ! -f "/home/ide-settings/User/argv.json" ]
        then    
                mkdir -p /home/ide-settings/User
                cd /home/ide-settings/User
                echo '{\n  "locale": "zh-cn"\n} ' > argv.json
fi      
if [ ! -f "/home/ide-settings/User/settings.json" ]
        then    
                mkdir -p /home/ide-settings/User
                cd /home/ide-settings/User
                echo '{\n  "java.home": "/opt/java/openjdk-11",\n  "browser-preview.startUrl": "http://git.inspur.com",\n  "terminal.integrated.shell.linux": "/bin/bash"\n}' > settings.json
fi 
code-server --port 8088 --user-data-dir /home/ide-settings
