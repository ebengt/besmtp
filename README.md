# Besmtp

Once upon a time I had a CLI mail program that read the environment variables
'from' and 'smtp'. These values where used to set the from header and send to mail relay.
This is a substitute for sending with that mail program.

## Installation

mix deps.get
mix escript.build

Then move ./besmtp to a bin directory in your path.

