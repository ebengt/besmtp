# Besmtp

Once upon a time I had a CLI mail program that read the environment variables
'from' and 'smtp'. These values where used to set the from header and send to mail relay.
This is a substitute for sending with that mail program.

It will work with a GMail account, if that account has 'allow less security' on.
The lessening of security comes from giving my password to the application.
In this case that is exactly what I want to do. It is my application, and I trust it.
The password is read from the environment variable 'password'.

## Installation

mix deps.get
mix escript.build

Then move ./besmtp to a bin directory in your path.

