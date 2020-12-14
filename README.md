# Lanky-Framework for roblox
A very slim framework used to simplify Initiation, Datastores and Remotes.

_dont forget to report bugs or to provide feedback_

# Why use the lanky framework?

## Open source and flexible
* Server/Client modules are provided to aid readability, usability and to fine tune the initiation order.
* Developers can easily add extra functionality to the Server/Client modules without effecting the internal modules.
* Advanced Developers can use the internal modules to aid the development of their very own frameworks.
* Compatible with every type of game

## Datastore utilities and Automatic loading/saving
* Player Data Loading, Caching and Autosaving are handled automatically, you just provide Default Data for new players
* Player Data is replicated automatically to the client.
* SessionLocking is implemented and data cannot be overriden with old data and exploiters can't duplicate data. **[unfinished]**
* Optimized Backups
* Lanky doesn't use a network request everytime you want to get/update a value from datastores. (because it caches the players data)
* Reset data, add data or remove data. (Default data and players data will be reconciled upon joining)
* Add CORE leaderstats and CUSTOM leaderboards that automatically update when you change players data. **[unfinished]**

## Faster workflow with remotes and remote security
* Remotes more convenient to use
* Never have to worry about type errors
* Never have to worry about exploiters breaking your remotes/server.
* Never have to worry about adding debounces/cooldowns to every single remote.

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
