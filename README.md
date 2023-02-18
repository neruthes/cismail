# Cismail

Cryptographically innovative-and-secure mail.

Temporary documentation:
[note-20230210-cismail.pdf](https://pub-714f8d634e8f451d9f2fe91a4debfa23.r2.dev/keep/ntexdb/note-20230210-cismail.pdf--9f1bb76e5b1938be3c8907311238dbc0.pdf).

Experimental implementation in shell script. Will migrate to Rust in future.





## Installation

```
./make.sh build
./make.sh local_install
```




## Usage


### Keygen

```shell
# Simple keygen
cismail keygen
# Specify a name
cismail keygen 'John Appleseed'
```

Keygen will add yourself to contacts list automatically.

### Encrypt

```shell
# Identify recipient by name
cismail e Neruthes <(echo "Hello world")
# Identify recipient by public key (or trailing chars)
cismail encrypt vst7mgpqskds8lg <(echo "Hello world")
```

### Decrypt

```shell
# Decrypt from clipboard
xclip -selection clipboard -o | cismail d
# Decrypt a file
cismail decrypt /path/to/encrypted/message.asc
```

### Test Case

Command:

```shell
$ cismail e $(ls ~/.config/cismail/self.age/* | head -n1) <(echo "Hello world") | cismail d
```

Output:

```
cismail: Valid: The message is sent to us: (Neruthes) kpid:age:age1s4zpwvrypemsn7ckn38uauedncy9m9yrn7dyak2trc7vst7mgpqskds8lg
cismail: Hint: Message was created at Sat Feb 18 21:57:40 UTC 2023 (0d 0hr ago)
cismail: Hint: Message was sent by 'Neruthes' (kpid:age:age1s4zpwvrypemsn7ckn38uauedncy9m9yrn7dyak2trc7vst7mgpqskds8lg)
cismail: Hint: Search result: Neruthes kpid:age:age1s4zpwvrypemsn7ckn38uauedncy9m9yrn7dyak2trc7vst7mgpqskds8lg
cismail: Below is raw message ---------------------------------------
Hello world
```




## Copyright

Copyright (c) 2023 Neruthes.

Published with [GNU GPL 2.0](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html).

