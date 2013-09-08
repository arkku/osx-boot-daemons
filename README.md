Here are a couple of daemons useful for netbooting old hardware such as
Sun and Silicon Graphics workstations from an OS X server. SGI machines
generally need bootparamd, and old Sun machines (e.g., SparcStations) need
rarpd. To actually boot them you'll need to set up tftp, DHCP/BOOTP and NFS,
but those do not need custom daemons (though I recommend dnsmasq).

- Kimmo Kulovesi, http://arkku.com/, 2013-09-08


    bootparamd
    ==========

Current versions of Mac OS X do not support bootparams anymore, so I
ported the FreeBSD bootparamd to OS X. It reads boot parameters from
a bootparams file only (i.e., not from OS X netinfo like Apple's bootparamd).
The daemon itself works just like the FreeBSD one.

http://www.unix.com/man-page/FreeBSD/8/bootparamd/
http://www.unix.com/man-page/freebsd/5/bootparams/

    Installing bootparamd
    ---------------------

    make bootparamd
    sudo mkdir -p /usr/local/sbin
    sudo cp rarpd /usr/local/sbin/bootparamd
    sudo cp com.arkku.bootparamd.plist /Library/LaunchDaemons/
    # place your boot parameters in /etc/bootparams

    # edit parameters in .plist as necessary, then:
    sudo launchctl load -w /Library/LaunchDaemons/com.arkku.rarpd.plist


    rarpd
    =====

Mac OS X does still ship with rarpd, but unfortunately the included
rarpd effectively needs to be run as root and it only serves requests
for hosts that have a bootfile matching their hexadecimal IP address
in /tftpboot on the system. So, I took the source code of Apple's
rarpd and modified it with the following changes:

* support argument -e to respond to every RARP request, i.e.,
  skip checking for /tftpboot for files named after the IP
  address of the machine requesting RARP (the original purpose
  of this check is to allow multiple RARP servers on the same
  network, each responding only to requests for hosts it has
  a netboot file for)

* add command-line option "-u user" to drop root privileges
  after setting up the daemon (e.g., rarpd -u nobody en0)

* add command-line option "-c /dir" to chroot to the directory
  after setting up the daemon - note that the new root must still
  contain /etc and the files required to resolve the requests,
  so the intended use is "-c /private" on OS X

* add command-line option "-t /dir" to specify a tftpboot
  directory other than /tftpboot (e.g., rarpd -a -t /private/tftpboot)

    Installing rarpd
    ----------------

    make rarpd
    sudo mkdir -p /usr/local/sbin
    sudo cp rarpd /usr/local/sbin/rarpd
    sudo cp com.arkku.rarpd.plist /Library/LaunchDaemons/
    # place your ethernet address mappings in /etc/ethers

    # edit parameters in .plist as necessary, then:
    sudo launchctl load -w /Library/LaunchDaemons/com.arkku.rarpd.plist
