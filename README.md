# Lanky-Framework for roblox
A very slim framework used to simplify Initiation, Datastores and Remotes.

_dont forget to report bugs or to provide feedback_

# Why use the lanky framework?

## Open source and flexible
* Lanky is practically a base for your very own framework
* Server/Client modules are provided to aid readability, usability and to fine tune the initiation order.
* Developers can easily add extra functionality to the Server/Client modules.
* Compatible with every type of game

## Automatic loading/saving and Remote utilities
* Player Data Loading, Caching and Autosaving are handled automatically, you just provide Default Data for new players
* Player Data is replicated automatically to the client.
* SessionLocking is implemented and data cannot be overriden with old data and exploiters can't duplicate data.
* Optimized Backups
* Lanky doesn't use a network request everytime you want to get/update a value from datastores. (because it caches the players data)
* Reset data, add data or remove data. (Default data and players data will be reconciled upon joining)
* Add core leaderstats and/or custom leaderboards that automatically update when you change players data. **[unfinished]**
* Remotes are more convenient to use
* Setup remotes faster


***

# Getting Started


## Initiating the server
### Add a Server script into the _Server Module_ (or anywhere really)

```lua

```

## Initiating the Client
### Add a Local Script into the _Client Module_ (or anywhere really)

```lua

```
