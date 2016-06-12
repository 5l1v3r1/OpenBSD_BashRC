export PKG_PATH=ftp://mirror.planetunix.net/pub/OpenBSD/`uname -r`/packages/`machine -a`/

export PROMPT_COMMAND='PS1="`
if [[ \$? = "0" ]];
then echo "\\[\\033[0;32m\\]";
else echo "\\[\\033[0;31m\\]";
fi`[\u@\h \w]\[\e[m\] "'
export PS1

port_add () {
    # Get the arg
    port="$1"

    # Make sure we have the right number of args
    if [ $# -ne 1 ]; then
        echo "Usage: port_add <port>"
        echo "Example: port_add net/wget"
        return 0
    fi

    # Make sure the port exists
    if [ ! -f "/usr/ports/$port/Makefile" ]; then
        echo "Port is not found! Check path (i.e.: \"net/wget\")"
        return 1
    fi    

    # Install time
    pushd . >/dev/null
    
    cd "/usr/ports/$port"
    
    SUDO=`which sudo` make -j `sysctl hw.ncpu | cut -d "=" -f 2` install

    popd > /dev/null
}

port_updateCVS () {
    pushd . >/dev/null

    cd /usr/ports
    sudo cvs up -rOPENBSD_`uname -r | tr '.' '_'` -Pd
    
    sudo chgrp -R wheel .
    sudo find . -type d -exec chmod g+w {} \;

    popd > /dev/null

}

port_search () {
    action="$1"
    term="$2"

    # Make sure we have the right number of args
    if [ $# -ne 2 ]; then
        echo "Usage: port_search <name/keyword> <search term>"
        return 1
    fi

    pushd . >/dev/null

    cd /usr/ports
    
    make search $1=$2

    popd > /dev/null
}

port_init () {
    pushd . >/dev/null    
    cd /usr
    sudo cvs -qd anoncvs@anoncvs3.usa.openbsd.org:/cvs get -rOPENBSD_`uname -r | tr '.' '_'` -P ports 
    sudo chgrp -R wheel ports    
    sudo find ports -type d -exec chmod g+w {} \;
    popd
}

initial_setup () {
    # performs initial setup from a base BSD

    pushd . >/dev/null

    # Make sure bash is default
    chsh -s `which bash`

    sudo pkg_add wget

    read -p "Install Multi-Processing Kernel? " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd /
        sudo wget "http://ftp5.usa.openbsd.org/pub/OpenBSD/`uname -r`/`uname -p`/bsd.mp"
        echo "set image /bsd.mp" | sudo tee -a /etc/boot.conf
        
        read -p "Rebooting to start multi-processing kernel. Press any key to continue. " -n 1 -r
        shutdown -r now
    fi

    
    # Probably want to init the ports
    port_init

    # List of default ports to build
    declare -a default_ports=("sysutils/colorls" "net/curl" "lang/python" "editors/vim" "devel/py-pip" "devel/gmake" "devel/py-virtualenv" "devel/gdb" "devel/cmake" "devel/git")

    # Loop through the default ports, installing as we go
    for port in "${default_ports[@]}"
    do
       port_add $port
    done

    # Explicitly adding python3 pip
    FLAVOR="python3" port_add devel/py-pip
    FLAVOR="python3" port_add devel/py-virtualenv

    # Install wrapper
    sudo pip3 install virtualenvwrapper
    mkdir $HOME/.virtualenvs
    echo "export WORKON_HOME=\$HOME/.virtualenvs" >> ~/.bashrc
    echo "source `whereis virtualenvwrapper.sh`" >> ~/.bashrc
    echo "export VIRTUALENVWRAPPER_PYTHON=`ls -1 /usr/local/bin/python3?? | sort | tail -1`" >> ~/.bashrc

    popd .
}

# Alias to colorls if we can
type colorls >/dev/null 2>&1 && alias ls='colorls -G'

# Add virtualenv wrapper if available
type /usr/local/bin/virtualenvwrapper.sh >/dev/null 2>&1 && source /usr/local/bin/virtualenvwrapper.sh
