![](/logo.png)

# RunAs.io - Social Network Hub

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

## Users
- **RunAs official documentation is present at [docs.runas.io](https://docs.runas.io).**
- For feature requests or questions, visit
  [https://help.runas.io/](https://help.runas.io/).
- Check out [the demo at runas.io](https://app.runas.io)
- Please see [releases tab](https://github.com/runasio/sna/releases) to
  find the latest release and corresponding release notes.
- [See the Roadmap](https://trello.com/b/NaEH5zt4/runas-product-roadmap) for list of
  working and planned features.
- Read about the latest updates from RunAs team [on our
  blog](https://www.runas.io/blog/).
- Watch tech talks on our [YouTube
  channel](https://www.youtube.com/runasio/featured).

## Developers
- See a list of issues [that we need help with](https://github.com/runasio/sna/issues).
- Please see [Contributing to RunAs](https://elixirforum.com/t/social-network-automation-project/24288) for guidelines on contributions.

## Client Libraries
The RunAs team maintain a number of [officially supported client libraries](https://github.com/runasio/sna_lib).

## Contact
- Please use [help.runas.io](https://help.runas.io) for documentation, questions, feature requests and discussions.
- Please use [Github issue tracker](https://github.com/runasio/sna/issues) for filling bugs or feature requests.
- Join [![Slack Status](http://slack.runas.io/badge.svg)](http://slack.runas.io).
- Follow us on Twitter [@runasio](https://twitter.com/runas_io).
