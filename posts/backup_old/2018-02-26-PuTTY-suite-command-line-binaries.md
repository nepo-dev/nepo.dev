---
layout: post
title: "PuTTY: the (imitation) swiss knife of networking"
published: true
tags: ssh ftp PuTTY
---

Have you ever had to work in a network? If you're alive and working in the software industry now, chances are you have. 

### Copying files - from Russia, with SCP

I have to work with multiple computers and each one of them has their own VPNs. One of the actions I find myself repeating every day multiple times is compiling an application and uploading it to a server.

The thing is I have to log into a third computer (we call it 'bridge computer') so that I can copy the application to the one I want, and that means remembering IP addresses, credentials, paths, etc.

When it comes to handling this type of repetitive operations, there are two main ways of dealing with it:

* If you are lazy you will just use an SSH/FTP client to send the file you need to send and forget about it. When you're introduced to SSH, you usually use [PuTTY](https://www.putty.org/) first. It's the most used open source multi-platform SSH client of them all. But let's face it, PuTTY's interface is kind of outdated and it’s counter-intuitive sometimes. If you look for alternatives, you might find some good ones. Personally, I like [MobaXterm](https://mobaxterm.mobatek.net/). It's interface is more usable, integrates SSH and FTP clients and allows you to stores credentials easily. It even has games!

[imagen interfaz MobaXterm ¿con pinguinos?]

* If you're even lazier you will want to automate it. Don't worry, I'm right there with you. Why should I remember an IP address and the file's path in both computers? Can't somebody else do it? Well, yes, dummy, that's why we invented computers: so that we shouldn't have to work with _computers_, just with _abstractions_. In our case, that means the action of transfering the file, not the details of IP address, credentials and path.

This is where MobaXterm fails, in PuTTY's favor. You see, MobaXterm download includes just the GUI application (which you have to use manually!), but PuTTY comes with a suite of executables aimed for the terminal. And boy, does that suite suite our needs.

The two most important parts in my opinion are PSCP.exe, an SCP client, and PLINK.exe, an SSH client.

### man pscp

First of all, let me link you to the [PuTTY User Manual](https://the.earth.li/~sgtatham/putty/0.70/htmldoc/) in case you might need more information on the topic. I'm going to center this article on chapters 5 and 7, but I'll be covering very little of them. 

First of all, let's talk about PSCP. This program needs 2 parameters: the path to the source file and target directory.

```
PuTTY Secure Copy client
Release 0.70
Usage: pscp [options] [user@]host:source target
       pscp [options] source [source...] [user@]host:target
       pscp [options] -ls [user@]host:filespec
Options:
  -V        print version information and exit
  -pgpfp    print PGP key fingerprints and exit
  -p        preserve file attributes
  -q        quiet, don't show statistics
  -r        copy directories recursively
  -v        show verbose messages
  -load sessname  Load settings from saved session
  -P port   connect to specified port
  -l user   connect with specified username
  -pw passw login with specified password
  -1 -2     force use of particular SSH protocol version
  -4 -6     force use of IPv4 or IPv6
  -C        enable compression
  -i key    private key file for user authentication
  -noagent  disable use of Pageant
  -agent    enable use of Pageant
  -hostkey aa:bb:cc:...
            manually specify a host key (may be repeated)
  -batch    disable all interactive prompts
  -proxycmd command
            use 'command' as local proxy
  -unsafe   allow server-side wildcards (DANGEROUS)
  -sftp     force use of SFTP protocol
  -scp      force use of SCP protocol
  -sshlog file
  -sshrawlog file
            log protocol details to a file
```

The cool thing about PSCP is that these files can be in different computers, and we can specify that with the following notation:

```
xx.yy.zz.nn:/path/to/file
```

Where xyzn is the target computer's ip address.

And it takes care of authentication just with the help of some flags:

```
-l username
-pwd password
```

So, to put it all together, the following call would be used to copy a file from a password-protected computer to mine:

```
pscp.exe -l username -pw password xx.yy.zz.nn:/path/to/file /path/to/target/directory
```

#### Example

As an example, we will solve the case I presented earlier: I generate a file in my computer that needs to be sent to a another computer. 

|Computer | IP | File  |
|  --- | --- | --- |
| Source | localhost | C:\temp\source_file.csv |
| Target | 123.123.123.123 | /home/username/target_dir/ |

And these are the credentials we use to access the target computer:

| Username | Password |
| --- | --- |
| foo | b4r |

The command to do this would be:

```
pscp.exe -scp -l foo -pw b4r C:\tmp\source_file.csv 123.123.123.123:/home/username/target_dir/
```

Note that one computer is running Windows and the other a UNIX-like SO. PSCP doesn't care as long as the computer's SO can recognize the path.

If you get it just with that example, let me tell you it's really that simple. But if you don't, don't worry, let's go through it in detail:

* The executable really needs just 2 arguments: source file and target directory. These are both our paths 'C:\tmp\source_file.csv' for the source file and the one starting with the IP of the target machine, '123.123.123.123:/home/username/target_dir/', for the target directory.
* Since SSH is (hopefully) secure, we need to enter our credentials. '-l' takes care of the username while '-pw' does the same for the password.
* Finally, we use the flag '-scp' to force the program to use the SCP protocol instead of FTP, since transfering big files through FTP seems to be bugged right now.

Not so difficult, right? And it can be quite useful. I use it in a 2-line script to download a log from a server and open it in my text editor of choice.

```
pscp.exe -scp -l foo -pw b4r 123.123.123.123:/var/app/log/server.log C:\tmp\
sublime_text.exe C:\tmp\server.log
```

And just like that I can easily see what's wrong with the server.

Yeah, I know, the infrastructure could be better and I promise I had nothing to do with it. But when life gives you lemons... make lemon grenades. ¯\\\_(ツ)\_/¯

<br/>

___

<br/>

The last example was useful in case you need to send your data to another computer, but that's not the most common case, nor the most frustrating. For me it's worse when I need to access something from a computer behind a firewall. Imagine you need to access a server's web console that is being blocked by the firewall. If we can already access the other computer with SSH directly, isn't there a way to access it through HTTP too?

For that we will need to use Port Forwarding and, you guessed it, PuTTY also comes with a utility for that.

### Port for-what? Forwarding? Is that a place?

No, it's not a place.

Port forwarding is a fancy way of saying "redirect traffic going to an address and port to another address and port". The trick here is to use SSH to forward the traffic you need through a tunnel. They are the wormholes of networking and you're able to open and close them at your whim. How cool is that? To put this graphically, imagine the following case:

![PuTTY example that describes computer A, computer B and a firewall between both]({{ "/images/posts/2018-02-26/PuTTY-example-A-fw-B.png" }})

* Alice can't access Bob's computer because there's a firewall between them.
* Bob has an SSH server running on his computer and Alice has the credentials needed to access it. 
* Alice opens a tunnel redirecting HTTP traffic from her computer to Bob's.
* Alice can access the web as if she did so from Bob's computer (which she is technically doing).

So, how can you achieve this? Turns out PuTTY has a command-line tool for that to. Introducing...

### man plink

I link you again the [PuTTY User Manual](https://the.earth.li/~sgtatham/putty/0.70/htmldoc/) in case you might need more information.

Now, what can we say about PLINK? First of all, this program is a connection tool similar to SSH, so it's packed with possibilities. 

```
PuTTY Link: command-line connection utility
Release 0.53
Usage: plink [options] [user@]host [command]
       ("host" can also be a PuTTY saved session name)
Options:
  -v        show verbose messages
  -load sessname  Load settings from saved session
  -ssh -telnet -rlogin -raw
            force use of a particular protocol (default SSH)
  -P port   connect to specified port
  -l user   connect with specified username
  -m file   read remote command(s) from file
  -batch    disable all interactive prompts
The following options only apply to SSH connections:
  -pw passw login with specified password
  -L listen-port:host:port   Forward local port to remote address
  -R listen-port:host:port   Forward remote port to local address
  -X -x     enable / disable X11 forwarding
  -A -a     enable / disable agent forwarding
  -t -T     enable / disable pty allocation
  -1 -2     force use of particular protocol version
  -C        enable compression
  -i key    private key file for authentication
```

As you can see from the usage message, you have a plethora of options: from issuing a command to a remote computer to forwarding local/remote ports to another address and port.

We are going to use -L option to forward our traffic to the client's computer:

```
-L [xx.yy.zz.nn:]AAAA:xx.yy.zz.nn:BBBB
```

In this case, AAAA will be the port we will access from our computer and BBBB will be the target port. That means the exit of the tunnel, or where our packets will be sent. We could also specify both source and target IP addresses, but if omitted localhost will be assumed.

To put it all together:

```
pscp.exe -ssh -l username -pw password -L AAAA:xx.yy.zz.nn:BBBB
```

### Example

So, taking our example were we left it, we had just uploaded the application to the server. These were the credentials we used to access the target computer:

| Username | Password |
| --- | --- |
| foo | b4r |

Now we want to access the client's 8080 port so that we can see our application in action. We have chosen port 8501 for that.

|Computer | IP | Port |
|  --- | --- | --- |
| Source (mine) | localhost | 8501 |
| Target (client's) | 123.123.123.123 | 8080 |

So let's jump straight to the terminal. This is the command we want to use:

```
plink.exe -ssh -l foo -pw b4r -L localhost:8501:123.123.123:8080 123.123.123.123
```

As we can see, we use SSH protocol with our credentials and specify local port forwarding: from localhost:8501 to 123.123.123.123:8080. 

Note that we also need to specify the IP we're connecting to, the one with the SSH. This might seem redundant, but the IP you forward to and the one you're connect to with SSH are two different things. You could be connecting to SSH server in computer B but redirecting traffic to computer C.

After issuing that command in a terminal, you should be able to access your application at 123.123.123.123:8080 by typing localhost:8501 in your browser and hitting enter. Try it!

<br/>

___

<br/>


Following the example I've been using in this article, let's go back to the VPN setup I had to work with. We managed to automate downloading the log files from the server and then uploading the application. You now what we're missing now? Testing! So, what we need to do next is being able to access the webapp in our web browser directly (because testing over remote desktop is cumbersome and unpleasant). For that, we will need an HTTP proxy.

# HTTP Proxy

An HTTP proxy is a computer that lets you browse the web as if you were using that machine. It does so by sitting in the middle of your communication with the server. It re-sends everything you send to the web server and then it re-sends you the server's response.



# PLACEHOLDER

Aquí irá una explicación de porqué usar un proxy HTTP y se dirá que se puede hacer de esta manera:

```
plink.exe -ssh -T -l foo -pw b4r -D localhost:8501 xx.yy.zz.nn
```

Y podrás usar ese proxy configurando el navegador de esta manera:

![Firefox example configuration that defines SOCKS host as our -D parameter]({{ "/images/posts/2018-02-26/firefox-http-proxy-configuration.png" }})

# PLACEHOLDER

<br/>

___

<br/>

That is all for today. If found it interesting or useful invite me to a beer!
