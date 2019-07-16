# SNA - Social Network Automation

Social Network Authentication is an Elixir/Erlang project created to
make marketing and publishing on social network easy. The targeted
customers are the small and medium size companies who don't have
resources to have marketing team or don't have time with
communication.

## Purpose

The main objective of this project is to create an easy way to send
social network on different platform with only one entry-point.

The second objective is to create a platform where all Social Network
could be supported and added easily by the creators avec of the new SN
or the community.

The third objective is to give the opportunity to the user to take the
control of their data easily by offering an easy way to get all posted
information in one place and reuse them on other social network.

Finally, the last objective is to optimize the marketing on social
network without marketing team.

## How to run it

By default the service runs only on http://localhost:4000. If you want
to set another port or hostname you can alter global variables.

```
mix phx.server
```

```
PORT=8000 mix phx.server
```

## How to debug it

```
iex -S mix phx.server
```

## How to compile it

```
mix deps.get
mix compile
```

## How to test it

This project only support unit testing.

```
mix test
```

## How to build documentation

Documentation will be available in `doc`.

```
mix docs
```
