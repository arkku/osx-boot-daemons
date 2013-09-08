Here are a couple of daemons useful for netbooting old hardware such as
Sun and Silicon Graphics workstations from a modern OS X server. SGI machines
generally need bootparamd, and old Sun machines (e.g., SparcStations) need
rarpd. To actually boot them you'll need to set up tftp, DHCP/BOOTP and NFS,
but those do not need custom daemons (though I recommend dnsmasq).

These programs have only been tested on my 10.8 Mountain Lion server so far,
but they do work for netbooting an SGI Indy and a Sun SparcStation 5. However,
as always, use at your own risk only.

~ [Kimmo Kulovesi](http://arkku.com/), 2013-09-08


bootparamd
==========

Current versions of Mac OS X do not support bootparams anymore, so I
ported the FreeBSD bootparamd to OS X. It reads boot parameters from
a bootparams file only (i.e., not from OS X netinfo like Apple's bootparamd).
The daemon itself works just like the
[FreeBSD bootparamd](http://www.unix.com/man-page/freebsd/8/bootparamd/) does.


Installing bootparamd
---------------------

To install bootparamd as a system daemon on OS X, follow these steps:

    make bootparamd
    sudo mkdir -p /usr/local/sbin
    sudo cp bootparamd /usr/local/sbin/bootparamd
    sudo cp com.arkku.bootparamd.plist /Library/LaunchDaemons/
    sudo launchctl load -w /Library/LaunchDaemons/com.arkku.bootparamd.plist

Edit the .plist to configure arguments, and place your boot parameters
file as `/etc/bootparams` (see
[bootparams(5)](http://www.unix.com/man-page/freebsd/5/bootparams/) for the
file format).

An example `/etc/bootparams` file for netbooting an SGI machine would be:

```
# SGI Indy
indy    root=server:/exports/indy/root \
        swap=server:/exports/indy/swap
```

Here `indy` is the hostname of the machine being booted, `server` is the
hostname of the NFS server, and `/exports/indy` is a path on the server
that is being exported via NFS. The directory `root` should contain the
filesystem for the client, while the directory `swap` should contain just
a file called `_swap` that is the size of the desired swap. A `bootparams`
entry may specify any number of other parameters as well, the meaning of
which depends on the system being booted.

The installation may be tested with the included program `callbootd`, e.g.,
`./callbootd 127.0.0.1 indy root` should print the root path when run on the
server with the above `/etc/bootparams`. (In my experience the `callbootd`
program is a bit unreliable, so try booting the actual client machine even
if the test doesn't work.)


rarpd
=====

Mac OS X does still ship with `rarpd`, but unfortunately the included
daemon effectively needs to be run as root and it only serves requests
for hosts that have a bootfile matching their hexadecimal IP address
in the `/tftpboot` directory on the system. So, I took the source code
of Apple's rarpd and modified it with the following changes:

* support argument `-e` to respond to every RARP request, i.e.,
  skip checking for `/tftpboot` for files named after the IP
  address of the machine requesting RARP (the original purpose
  of this check is to allow multiple RARP servers on the same
  network, each responding only to requests for hosts it has
  a netboot file for)

* add command-line option `-u user` to drop root privileges
  after setting up the daemon (e.g., `rarpd -u nobody en0`)

* add command-line option `-c /directory` to chroot to the directory
  after setting up the daemon - note that the new root must still
  contain `/etc` and the files required to resolve the requests,
  so the intended use is `-c /private` on OS X where `/etc` symlinks
  to `/private/etc`

* add command-line option `-t /directory` to specify a tftpboot
  directory other than the default `/tftpboot` where to search for
  netboot files (when `-e` is not specified), e.g.,
  `rarpd -t /private/tftpboot`

Installing rarpd
----------------

To install rarpd as a system daemon on OS X, follow these steps:

    make rarpd
    sudo mkdir -p /usr/local/sbin
    sudo cp rarpd /usr/local/sbin/rarpd
    sudo cp com.arkku.rarpd.plist /Library/LaunchDaemons/
    sudo launchctl load -w /Library/LaunchDaemons/com.arkku.rarpd.plist

Edit the .plist to configure arguments. For the daemon to actually serve any
requests, create `/etc/ethers` to specify mappings from ethernet addresses to
hostnames, and edit `/etc/hosts` to map those hostnames to IPv4 addresses.

To test `rarpd` before installation, I recommend running it in debug mode in
a terminal while booting the client machine, e.g., with the command line:

    sudo ./rarpd -d -e -c /private -u nobody en0

I added a bunch of debug messages to the program, so this should output all
requests and responses. If you intend to run without the argument `-e`, you
can also find out the names of the bootfiles `rarpd` looks for by looking
at the debug messages (in case you are lazy and don't want to convert the
client IP addresses to hexadecimal by hand).
