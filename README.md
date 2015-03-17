# MakeMarkov

A Markov chain generator generator in Haskell.

It exposes a RESTful JSON API for adding, updating, and removing corpuses
from its database.

It'll also generate a landing page for whatever quote generator you want.

## Initialization

This requires an active PostgreSQL database.

Run `psql <database> -f initdb.sql` to create the necessary table.
