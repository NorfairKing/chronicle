# Chronicle

A command-line future-proof journal with optional encryption.

## Installation

Put the `Chronicle` in your path:

```
$ sudo cp chronicle.sh /usr/bin/chronicle
```

or link to it:

```
$ sudo ln -s $PWD/chronicle.sh /usr/bin/chronicle
```


## Configuration

First, have `Chronicle` generate the default config file:

```
$ chronicle default-config $HOME/.chronicle.cfg
```

Now you can modify the options as you wish:


### Encryption

Encryption is disabled by default, you can enable it by setting the `ENCRYPTION` option to `TRUE`.
You can change the `ENCRYPTION_METHOD` as well, as `Chronicle` uses `openssl` for encryption.

```
ENCRYPTION="TRUE"
ENCRYPTION_METHOD="aes-256-cbc"
```



### Filename and path conventions
Journal entries are saved in the `CHRONICLE_DIR` directory in the subdirectory and file defined by the `DATE_FORMAT` option.

```
CHRONICLE_DIR=$HOME/.chronicle.cfg
DATE_FORMAT=%Y/%m/%d/%H:%M:%S
```

### Synchronisation

`Chronicle` does not handle synchronisation, but you can put your `CHRONICLE_DIR` directory in your Dropbox or something of that sort.


## Usage:

To write an entry:

```
$ chronicle enter
```


