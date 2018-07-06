# donasktello_infra
## Д/3 №3
Для подключения к хосту someinternalhost были проделаны следующие шаги:
* На инстанс бастиона были добавлены метки открытых портов http, https, для установки VPN сервера
* Установлен Pritunl VPN сервер на инстансе бастиона
* Сконфигурирован Pritunl сервер(создана организация, пользователь, сервер)
* Запущен Pritunl сервер на бастионе
* Создано правило фаервола для проекта с рабочим портом Pritunl сервера
* Это правило добавлено в теги сети бастион инстанса
* Скачан и проверен на OpenVPN клиенте конфигурационный файл для подключения к Pritunl серверу

### Получившаяся конфигурация:
bastion_IP = 35.206.144.90

someinternalhost_IP = 10.132.0.3
## Д/3 №4
Для деплоя приложения на gcp сервер были проделаны следующие шаги:
* Установлен и сконфигурирован `gcloud`
* Создан тестовый инстанс из `gcloud CLI`
* Вручную установлен ruby и сопутствующие ему пакеты на сервере
* Вручную установлен mongoDB и запущен в systemctl
* Вручную склонировал и запущен сервер приложения
* Создано правило фаервола в GCP и открыт дефолтный порт 9292 для доступа к приложению
* Декомпозированы скрипты по тематике(ruby, mongoDB, deploy) в bash

### Получившаяся конфигурация:
```
testapp_IP = 35.195.41.223

testapp_port = 9292 
```

### Дополнительное задание: startup скрипт 
* Написан startup баш скрипт для установки прикладных программ и последующего запуска приложения на сервере.
* Запускать через `gcloud CLI` 
     ```
    gcloud compute instances create reddit-app\
      --boot-disk-size=10GB \
      --image-family ubuntu-1604-lts \
      --image-project=ubuntu-os-cloud \
      --machine-type=g1-small \
      --tags puma-server \
      --restart-on-failure \
      --metadata-from-file startup-script=./startup.sh
    ```
### Дополнительное задание: puma-server правило из консоли
* Запускать через `gcloud CLI`  
 
  ```
  gcloud compute firewall-rules create 'default-puma-server' --allow tcp:9292 \
  --source-ranges='0.0.0.0/0' \
  --target-tags='puma-server'
  ```
## Д/3 №5
При сборке image обаза для инстанса с помощью сервиса Packer были проделаны шаги
* Установлен и подвязан Packer для общения его с GCP
* Создан базовый шаблон reddit-app c ruby и mongodb провижинерами
* Создан файл variables.json и пример файла для параметризации образа
* Свалидирован reddit-base image и запечён в GCP images
* На основе этого image создан instance vm
* Добавлены опции image_description, disk_size, disk_type, network, tags

### Дополнительное задание: reddit-full на основе reddit-base 
* Создан образ reddit-full на основе запечённого образа reddit-base с провижинерам деплоя
### Дополнительное задание: shell-script для создания instance vm
* Запускать через `gcloud CLI` 
     ```
    gcloud compute instances create reddit-app \
    --boot-disk-size=10GB \
    --image-family=reddit-full \
    --image-project=infra-207412 \
    --machine-type=g1-small \
    --tags puma-server \
    --restart-on-failure
    ```
## Д/3 №6
В рамках начала работы с terraform было сделано:
- Установлен terraform версии 0.11.7
- Terraform установлен и инициализирован под Google директивой provider в конфигурационном файле
- В файле main.tf прописал compute_instance, отвечающий за создание инстанса vm
- Разобран воркфлоу terraform: команды(plan, apply, show), файл, хранящий состояние(.tfstate)
- Прописаны output переменные инстанса(external_ip)
- Создано ресурс compute_firewall для доступа к приложению, развёрнутому на пуме
- Прописаны провижионеры для инстанса(puma.service и deploy.sh)
- Создан файл параметризации ресурсов variables.tf и прописаны нужные переменные

### Дополнительное задание *:
Терраформ видит разницу tfstate файла с развёрнутым инстансом, поэтому, чтобы добиться идемпотентности,
нужно либо прописать все ключи по IaC парадигме, либо при следующем apply state проекта будет синхронизирован по IaC
и все изменения проделанные в вебе пропадут.  
### Дополнительное задание **:
Главная проблема, что это приложения с разной БД. Менее значительная проблема, что придётся отлеживать эквивалентность
IaC обоих ресурсов.
## Д/3 №7
Для того, чтобы добиться модульности в терраформ проекте были проделаны следующие шаги:
- Добавлен ресурс `google_compute_firewall` дефолтного правила firewall по ssh(Для того, чтобы вытащить правило создающееся по умолчанию применить
  команду `terraform import resource_name resource_id`)
- Создан ресурс `google_compute_address` внешнего IP c зависимостью app от этого ресурса
- Главный шаблон декомпозирован на 2 инстанса: для апп и для бд
- Для каждого из инстансов созданы отдельные образы пакера, бд и апп, соответственно
- Для инстанса бд создан ресурс google_compute_firewall для доступа к МонгоДБ
- Создан модуль ДБ со своими файлами(main, outputs, variable)
- Создан модуль APP со своими файлами(main, outputs, variable)
- Создан модуль VPC со своими файлами(main, outputs, variable)
- Созданы два окружения(prod, stage) со своими параметрами к подгружаемым модулям
- Написан код для создания storage bucket
### Дополнительное задание *:
- Настроено хранение стейт файла в файле backend.tf
- При одновременном выполнении `terraform apply` с 2 мест выводится ошибка
```
Acquiring state lock. This may take a few moments...

Error: Error locking state: Error acquiring the state lock: writing "gs://donasktello-reddit-app/prod/default.tflock" failed: googleapi: Error 412: Precondition Failed, conditionNotMet
Lock Info:
  ID:        1530896882840085
  Path:      gs://donasktello-reddit-app/prod/default.tflock
  Operation: OperationTypeApply
  Who:       donasktello@Viacheslavs-MacBook-Pro.local
  Version:   0.11.7
  Created:   2018-07-06 17:08:02.649972895 +0000 UTC
  Info:      


Terraform acquires a state lock to protect the state from being written
by multiple users at the same time. Please resolve the issue above and try
again. For most commands, you can disable locking with the "-lock=false"
flag, but this is not recommended.
 
```
### Дополнительное задание *:
- Добавлены провижинеры для модулей дб и апп
- У апп объявлена зависимость на инициализацию модуля дб, для получения адрес дб
- Использован template provider `template_file` для параметризации системд юнитов.
