function show_help_msg() {
echo "cismail (version $APPVER)
Cryptographically innovative-and-secure mail.

Copyright (c) 2023 Neruthes.
This program is free software, released with GNU GPL 2.0.
The source code is available at <https://github.com/neruthes/cismail>.

USAGE:

    $  cismail  keygen  {Name}
            Generate a keypair and save it in '~/.config/cismail/self.age/{Name}'.

    $  cismail  e|encrypt  {Recipient}  message-content.txt
    $  cismail  e|encrypt  {Recipient}  message-content.txt  {Name}
    $  cismail  e|encrypt  {Recipient}  <(echo 'Hello Bob. This is Alice...')
            Write a message to {Recipient} from file.
            If Name is specified, use the corresponding identity as sender.

    $  cismail  d|decrypt  encrypted.asc
    $  cismail  d|decrypt  encrypted.asc  {Name}
            Try decrypting a message from a file.
            If Name is specified, a particular keypair will be used.

    $  cismail  ls
            List all contacts.

    $  cismail  add  {Name}  {KPID}
            Add new contact with Name and Keypair Identifier.
#
#    $  cismail  addfrom  encrypted.asc
#            Add message sender as new contact.


NOTES:

    -   Edit contacts info in '~/.config/cismail/contacts-v1.psv'.

" |  grep -v '^#'
}



function msg_stderr() {
    echo "cismail: $*" > /dev/stderr
}
