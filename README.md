# DreamkasRfCompiler
Компилятор приложений для касс "Дримкас РФ" и "Дримкас Интернет"

Работает в 32х битной версии Ubuntu 14.04

Необходимо установить пакеты:
libcloog-isl-dev
ibcap-dev
texinfo
cloog-isl
libsqlite3-dev
libgtk2.0-dev
libagg-dev
libfribidi-dev
libisl-dev
openssl
libisl

Содержимое архива распаковать в каталог /usr/local/ так чтобы 
получилось /usr/local/usr/<каталоги компилятора>

Перед сборкой пользовательского ПО проэкспортировать 
export LD_LIBRARY_PATH=/usr/local/usr/lib/
