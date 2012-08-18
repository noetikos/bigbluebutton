BigBlueButton - открытое мультиплатформенное программное обеспечение для дистанционного обучения. Данная система вебинаров поддерживает показ слайдов (PDF и другие документы, которые открываются в OpenOffice) с доской для работы, изображение веб-камеры, голосовой чат (FreeSWITCH) и показ экрана ведущего. Имеется возможность записывать вебинары (слайды, голос и чат). В классе идеально иметь не больше 25 человек.
  * Код и инструкции на [Google Code] (http://code.google.com/p/bigbluebutton/)
  * [Видеоинструкции] (http://www.bigbluebutton.org/videos/)
  * [Демо](http://demo.bigbluebutton.org/)
  * Инструкцию по установке смотрите ниже.
  
Лицензия: LGPL 2.1+. BigBlueButton и логотип BigBlueButton являются торговыми марками BigBlueButton Inc.

Копия BigBlueButton для локальных изменений на серверах Noetikos
================================================================

Проверьте, добавлен ли оригинальный репозиторий bigbluebutton для отслеживания изменений в нем. В командной строке проекта команда

	$ git remote -v
	
должна давать следующий ответ:

	origin    https://github.com/noetikos/bigbluebutton.git (fetch)
	origin    https://github.com/noetikos/bigbluebutton.git (push)
	upstream  https://github.com/bigbluebutton/bigbluebutton.git (fetch)
	upstream  https://github.com/bigbluebutton/bigbluebutton.git (push)
	
В противином случае добавьте оригинальный репозиторий:

	$ git remote add upstream https://github.com/bigbluebutton/bigbluebutton.git
	
Перед обновлением локальных файлов обратитесь к оригинальному репозиторию для получения изменений:

	$ git fetch upstream
	
Проверьте локальные ветки (?):

	$ git branch -va
	
Переключаемся на локальную ветку:

	$ git checkout master
	
Вносим изменения из оригинального репозитория, не теряя при этом локальных изменений:

	$ git merge upstream/master
	
  * Подробнее о синхронизации [на английском] (https://help.github.com/articles/syncing-a-fork)

Создание веток локальных изменений BigBlueButton
================================================

Ветки позволяют тестировать изменения файлов без угрозы всему проекту - это закладка на последний коммит в той ветке. Это особенно хорошо для командной работы. Создайте ветку:

	$ git branch mybranch
	
или сразу с переключением на нее:

	$ git checkout -b mybranch
	
Для переключения между ветками используйте команды:

	$ git checkout mybranch
	$ git checkout master
	
Для внесения изменений в основную ветку используйте команды:

	$ git checkout master
	$ git merge mybranch
	
Для удаления ветки:
	$ git branch -d mybranch
	
Не забывайте делать коммиты перед переключением на другую ветку.

  * Подробнее о копиях проектов [на английском] (https://help.github.com/articles/fork-a-repo)
  * Если вы создали копию и хотите предложить Noetikos улучшения, воспользуйтесь [инструкцией на английском] (https://help.github.com/articles/using-pull-requests)
  * [Справка Github для Windows на английком] (http://windows.github.com/help.html)

Изменение веб-интерфейса
========================

Страница index.html находятся на сервере в директории /var/www/bigbluebutton-default/index.html Для перенаправления на API Demo используется следующий код:

	<!DOCTYPE html>
	<html>
		<head>
			<meta http-equiv="Refresh" content="0;url=/demo/demo1.jsp" />
		</head>
	</html>

Файлы Demo API находятся на сервере в директории /var/lib/tomcat6/webapps/demo/

Внимание! Для изменения файлов через sftp (например, FileZilla) нужно установить права записи на эти файлы. Для этого в Putty следует изменить права доступа для соответствующих файлов от имени root для логина ubuntu:

	$ sudo chgrp ubuntu file/folder
	$ sudo chmod 774 file/folder
		
Установка BigBlueButton на Ubuntu 10.04
=======================================

Информация для создания системы вебинаров BigBlueButton 0.80 на собственном сервере:
  * ОС Ubuntu 10.04 32-bit или 64-bit (сервер или виртуальная машина) с правами доступа root (login as ubuntu) - на Amazon EC2 это ami-3e02f257
  * 2 GB памяти (4 GB предпочтительнее - на Amazon EC2 это платный вариант instance c1.medium и выше)
  * Двухъядерный ЦПУ 2.6 GHZ (четыре ядра предпочтительнее)
  * Открытые порты 80 (HTTP), 9123 (Desktop Sharing), and 1935 (RTMP) - TCP (см. ниже, как это сделать в Amazon EC2)
  * Порт 80 не должен использоваться другим приложением. Для проверки введите:
  
	$ sudo apt-get install lsof
	$ lsof -i :80
		
  * 50G дискового пространства для записи (?) 
  * Локализация сервера должна быть en_US.UTF-8. Для проверки введите:
  
	$ cat /etc/default/locale
	LANG="en_US.UTF-8"
	
Сперва даем серверу доступ к репозитарию BigBlueButton
	
	$ wget http://ubuntu.bigbluebutton.org/bigbluebutton.asc -O- | sudo apt-key add -
	$ echo "deb http://ubuntu.bigbluebutton.org/lucid_dev_08/ bigbluebutton-lucid main" | sudo tee /etc/apt/sources.list.d/bigbluebutton.list
	$ echo "deb http://us.archive.ubuntu.com/ubuntu/ lucid multiverse" | sudo tee -a /etc/apt/sources.list
	
Обновляем сервер:

	$ sudo apt-get update
	$ sudo apt-get dist-upgrade
	
(после этого может понадобиться перезагрузить сервер)

Устанавливаем Ruby:
	
	$ sudo apt-get install zlib1g-dev libssl-dev libreadline5-dev libyaml-dev build-essential bison checkinstall libffi5 gcc checkinstall libreadline5 libyaml-0-2
	$ wget http://bigbluebutton.googlecode.com/files/08_ruby_install.sh
	$ chmod +x 08_ruby_install.sh
	$ ./08_ruby_install.sh

Проверяем версию Ruby и установку gem:

	$ ruby -v
	ruby 1.9.2p290 (2011-07-09 revision 32553)
	$ gem -v
	1.3.7
	$ sudo gem install hello
	Successfully installed hello-0.0.1
	1 gem installed
	Installing ri documentation for hello-0.0.1...
	Installing RDoc documentation for hello-0.0.1...
	
Если ошибок нет, то устанавливаем BigBlueButton:

	$ sudo apt-get install bigbluebutton
	
На запрос наберите Y и нажмите Enter.
Установите демо-файлы:
	
	$ sudo apt-get install bbb-demo
	
Перезапускаем софт:

	$ sudo bbb-conf --clean
	$ sudo bbb-conf --check
	
Подробнее [на английском] (http://code.google.com/p/bigbluebutton/wiki/InstallationUbuntu)
О работе с виртуальной машиной [на английском] (http://code.google.com/p/bigbluebutton/wiki/BigBlueButtonVM)
	
Запуск BigBlueButton
====================

Вводим IP-адрес Elastic IP, прикрепленный к серверу в случае использования Amazon EC2 (здесь может быть любой адрес, прикрепленный к серверу)

	$ sudo bbb-conf --setip <ip/hostname>
	
Этот же адрес ввести в админке Wordpress (в конце обязательно добавить /bigbluebutton/) вместе с salt, данные можно узнать командой

	$ bbb-conf --salt
	
Для сброса используйте команду

	$ sudo bbb-conf --setsalt new_salt
	
Стандартная комната - dtutor, пароль для входа зрителей - noetikos

[Плагин для WordPress] (http://wordpress.org/extend/plugins/bigbluebutton/)

После смены IP-адреса следует поменять его и в mod_rewrite для сайта в .htaccess для доступа по адресу /webinar (см. разработку плагина для соответствия дизайна сайту в соседнем репозитории организации)

Планы на будущее
================

  * Создать страницу проекта на github или собственном сайте - [инструкция на английком] (https://help.github.com/articles/setting-up-a-custom-domain-with-pages)
  * Написать инструкции по установке Amazon EC2