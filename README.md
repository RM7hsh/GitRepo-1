# Что делает скрипт?

Скрипт проверят состояние сервера. Например: 
сколько в нем свободной ОП, какой у него ip address, название хоста и так далее

# Как запустить скрипт?
Чтобы запустить скрипт сначало сделайте его испольяемым:
```sh
sudo chmod +x /opt/labs/server-baseline-check/server-baseline-check.sh
sudo /opt/labs/server-baseline-check/server-baseline-check.sh
```

# Что означает OK/WARN?
OK означает что сервисы ssh и qemu-guest-agent запущены
WARN если один из этих сервисов не запущено
Hello
