# Ubuntu/Debian
sudo apt-get install flex bison cmake g++

# Fedora/RHEL
sudo dnf install flex bison cmake gcc-c++

chmod +x compilar.sh
./compilar.sh

cd build
./TrabalhoDeCompiladores ../exemplos/exemplo1.txt > exemplo1.cpp

./TrabalhoDeCompiladores ../exemplos/exemplo1.txt | tee exemplo1.cpp