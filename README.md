<p align="center"><img src="https://raw.githubusercontent.com/rastating/wordpress-exploit-framework/gh-pages/static/wordpress-exploit-framework-200px.png" /></p>

<h1 align="center">WordPress Exploit Framework</h1>
<p align="center">
  <a href="https://travis-ci.org/rastating/wordpress-exploit-framework"><img src="https://travis-ci.org/rastating/wordpress-exploit-framework.svg?branch=development" alt="Build Status" height="20" /></a> <a href="https://codeclimate.com/github/rastating/wordpress-exploit-framework/maintainability"><img src="https://api.codeclimate.com/v1/badges/5414ccc4e7a1f5e38c79/maintainability" alt="Maintainability" height="20" /></a> <a href="https://coveralls.io/github/rastating/wordpress-exploit-framework?branch=development"><img src="https://coveralls.io/repos/github/rastating/wordpress-exploit-framework/badge.svg?branch=development" alt="Coverage Status" height="20" /></a> <a href="https://badge.fury.io/rb/wpxf"><img src="https://badge.fury.io/rb/wpxf@2x.png" alt="Gem Version" height="20"></a>
</p>

<p align="center">
  A Ruby framework designed to aid in the penetration testing of WordPress systems.
</p>

<hr>

### Installation
To install the latest stable build, run `gem install wpxf`.

After installation, you can launch the WordPress Exploit Framework console by running `wpxf`.

### What do I need to run it?
Ruby >= 2.4.4 is required to run WordPress Exploit Framework.

### Troubleshooting Installation
#### Debian Systems
If you have issues installing WPXF's dependencies (in particular, Nokogiri), first make sure you have all the tooling necessary to compile C extensions:

```
sudo apt-get install build-essential patch
```

It’s possible that you don’t have important development header files installed on your system. Here’s what you should do if you should find yourself in this situation:

```
sudo apt-get install ruby-dev zlib1g-dev liblzma-dev libsqlite3-dev
```

#### Windows Systems
If you are experiencing errors that indicate that `libcurl.dll` could not be loaded, you will need to ensure the latest libcurl binary is included in your Ruby bin folder, or any other folder that is in your environment's PATH variable.

The latest version can be downloaded from http://curl.haxx.se/download.html. As of 16/05/2016, the latest release is marked as `Win32 2000/XP zip	7.40.0 libcurl SSL`. After downloading the archive, extract the contents of the bin directory into your Ruby bin directory (if prompted, don't overwrite any existing DLLs).

### How do I use it?
Start the WordPress Exploit Framework console by running `wpxf`.

Once loaded, you'll be presented with the wpxf prompt, from here you can search for modules using the `search` command or load a module using the `use` command.

Loading a module into your environment will allow you to set options with the `set` command and view information about the module using `info`.

Below is an example of how one would load the symposium_shell_upload exploit module, set the module and payload options and run the exploit against the target.

```
wpxf > use exploit/shell/symposium_shell_upload

[+] Loaded module: #<Wpxf::Exploit::SymposiumShellUpload:0x3916f20>

wpxf [exploit/shell/symposium_shell_upload] > set host wp-sandbox

[+] Set host => wp-sandbox

wpxf [exploit/shell/symposium_shell_upload] > set target_uri /wordpress/

[+] Set target_uri => /wordpress/

wpxf [exploit/shell/symposium_shell_upload] > set payload exec

[+] Loaded payload: #<Wpxf::Payloads::Exec:0x434d078>

wpxf [exploit/shell/symposium_shell_upload] > set cmd echo "Hello, world!"

[+] Set cmd => echo "Hello, world!"

wpxf [exploit/shell/symposium_shell_upload] > run

[-] Preparing payload...
[-] Uploading the payload...
[-] Executing the payload...
[+] Result: Hello, world!
[+] Execution finished successfully
```
For a full list of supported commands, take a look at [This Wiki Page](https://github.com/rastating/wordpress-exploit-framework/wiki/Supported-Commands).

### What is the difference between auxiliary and exploit modules?
Auxiliary modules do not allow you to run payloads on the target machine, but instead allow you to extract information from the target, escalate privileges or provide denial of service functionality.

Exploit modules require you to specify a payload which subsequently gets executed on the target machine, allowing you to run arbitrary code to extract information from the machine, establish a remote shell or anything else that you want to do within the context of the web server.

### What payloads are available?
* **bind_php:** uploads a script that will bind to a specific port and allow WPXF to establish a remote shell.
* **custom:** uploads and executes a custom PHP script.
* **download_exec:** downloads and runs a remote executable file.
* **meterpreter_bind_tcp:** a Meterpreter bind TCP payload generated using msfvenom.
* **meterpreter_reverse_tcp:** a Meterpreter reverse  TCP payload generated using msfvenom.
* **exec:** runs a shell command on the remote server and returns the output to the WPXF session.
* **reverse_tcp:** uploads a script that will establish a reverse TCP shell.

All these payloads, with the exception of `custom` and the Meterpreter payloads, will delete themselves after they have been executed, to avoid leaving them lying around on the target machine after use or in the event that they are being used to establish a shell which fails.

### How can I write my own modules and payloads?
Guides on writing modules and payloads can be found on [The Wiki](https://github.com/rastating/wordpress-exploit-framework/wiki) and full documentation of the API can be found at https://rastating.github.io/wordpress-exploit-framework

## License
Copyright (C) 2015-2018 rastating

Running WordPress Exploit Framework against websites without prior mutual consent may be illegal in your country. The author and parties involved in its development accept no liability and are not responsible for any misuse or damage caused by WordPress Exploit Framework.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
