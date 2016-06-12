These rc scripts provide a few things. First off, from the base install you need to do install bash and sudo:

- $ su -
- # pkg_add bash sdo
- # visudo
 - Add the following lines to it:
 - %wheel ALL=(ALL) SETENV: ALL
 - Defaults env_reset,timestamp_timeout=60
- # exit
- $ bash

You can now initialize the OpenBSD environment:

- $ initial_setup

This command will initialize the ports, as well as install some default packages.

That's it for setting up ports. I created wrappers to simplify using the ports structure. They're similar in nature to the pkg commands.

- port_add net/wget (compiles and adds wget for you)
- port_updateCVS (single command to grab updates from the CVS) 
- port_search <name/term> <search> (easy command to search for ports)

