# Tarea Lenguajes y Compiladores
Para correr el codigo tienen que instalar Ruby, en Linux es `sudo apt install ruby`, en windows buscan RubyInstaller en internet y siguen las instrucciones.

# Instalar paquetes
Para instalar la libreria de testing en Ruby, en Linux ejecutan `gem install rspec --user-install`, y para que luego puedan ejecutar el script, tienen que agregar 
```
export GEM_HOME="$(ruby -e 'puts Gem.user_dir')"
export PATH="$PATH:$GEM_HOME/bin"
```
al final de su archivo de ~/.bashrc
