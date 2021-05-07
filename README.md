# Установка Terraform, Ansible


## Terraform
1.

    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
2.    

    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

3.

    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
4.

    sudo apt-get update && sudo apt-get install terraform

## Ansible
5.

    sudo apt install ansible

# Подготовка и настройка инфраструктуры

- Командой ```ssh-keygen -t rsa -m PEM -f sshkey``` создать private и public ключ для доступа к ресурсам.
- В файле terraform.tfvars задать AWS_ACCESS_KEY и SECRET_KEY полученные при создании IAM user, а также RDS_PASSWORD — пароль от базы данных. 
- В консоли ввести ```terraform init``` для загрузки плагина AWS.
- В консоли ввести ```terraform apply```  для создания ресурсов.


# Деплоймент


- Скопировать адреса, полученные после применения команды terraform apply. Пример адресов:
	``` 
    jenkins_instance_public_ip = "52.209.19.159"
	mysql-rds = "terraform-20210507174938774500000001.cb3e9cb9eatj.eu-west-	1.rds.amazonaws.com:3306"
	web_instance_public_ip = "54.246.246.116"
    ````

- Перейти по адресу jenkins_instance_public_ip : 8080 (http) в консоль управления Jenkins 

- Командой ssh -i sshkey ubuntu@jenkins_instance_public_ip подключиться к 	узлу с Jenkins и скопировать пароль из 		var/lib/jenkins/secrets/initialAdminPassword и вставить его в поле Administration 	password в браузере.

- Нажать Install suggested plugins.

- Ввести данные для admin.

-  Установить плагин SSH на странице доступных плагинов.

- В разделе manage Jenkins → manage Credentials → Global credentials добавить 	следующие credentials:
	Private SSH key (будет лежать в папке с terraform кодом) для доступа к 		web серверу.

- В разделе manage Jenkins → configure System→ SSH remote hosts добавить 	адрес web сервера web_instance_public_ip c указанием созданных ранее 	credentials.

- В разделе manage Jenkins → configure System→ GitHub нажать кнопку 	advanced и checkbox Specify another hook URL for GitHub configuration. 	Скопировать Hook URL.

- Перейти в репозиторий с блогом и добавить новый Webhook. В Payload URL 	вставить ранее полученный Hook URL.

- Перейти в Jenkins и добавить задачу с параметрами:
            
    Build Triggers: GitHub hook trigger for GITScm polling
    Build: execute shell script on remote host using ssh. 
    В поле command вставить скрипт  с заменой web_instance_public_ip,  DB_PASSWORD и mysql-rds на реальные значения:

		cd ~; if [ -d "./lab-ghost-docker-app" ]; then cd lab-ghost-docker-app; sudo docker-compose stop; cd ..; fi; sudo rm -rf lab-ghost-docker-app; git clone https://github.com/MIR321/lab-ghost-docker-app.git; cd lab-ghost-docker-app; sudo DB_CONNECTION_HOST="mysql-rds"  DB_USER="root" DB_PASSWORD="DB_PASSWORD" INSTANCE_IP="web_instance_public_ip" docker-compose up -d

- Перейти в Dashboard и нажать на Build Now для деплоя. Перейти в консоль и убедиться, что все контейнеры запущены без ошибок.

- Перейти по адресу  web_instance_public_ip:7676 и убедиться, что блог работает.

- Аналогично добавить задачу без триггера по коммиту для скрипта


    ```
    cd /; 
	if [ -d "/lab-ghost-docker-app" ]; then 
		cd lab-ghost-docker-app; 
		sudo docker-compose stop; 
		cd ..; 
	fi; 
	sudo rm -rf lab-ghost-docker-app; 
	sudo git clone https://github.com/MIR321/lab-ghost-docker-app.git; 
	cd lab-ghost-docker-app; 
	sudo DB_CONNECTION_HOST="terraform-20210507174938774500000001.cb3e9cb9eatj.eu-west-1.rds.amazonaws.com"  DB_USER="root" DB_PASSWORD="helloworld" INSTANCE_IP="34.254.159.231" docker-compose up -d; 
    ```

Страница администратора: web_instance_public_ip:7676/ghost 

Phpmyadmin: web_instance_public_ip:3333 