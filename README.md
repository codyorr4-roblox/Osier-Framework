# Lanky-Framework for roblox
A very slim framework used to simplify Initiation, Datastores and Remotes.

_Dont forget to report bugs or to provide feedback if something makes you cringe__

# Why use the lanky framework?

## Datastores
* Player Data Loading, Caching and Autosaving are handled automatically, you just provde Default Data for new players
* Player Data is replicated automatically to the client.
* SessionLocking is implemented and data cannot be overriden with old data and exploiters can't duplicate data. **[unfinished]**
* Lanky doesn't use a network request everytime you want to get/update a value from datastores. (because it caches the players data)
* Reset data, add data or remove data. (Default data and players data will be reconciled upon joining)
* Easily add CORE leaderstats and CUSTOM leaderboards that automatically update when you change players data.

## Remotes
* Remotes are way more convenient to use and have a faster workflow.
* Never have to worry about type errors
* Never have to worry about exploiters breaking your remotes/server.
* Never have to worry about adding debounces/cooldowns to every single remote.
just provide the cooldown argument in HandleEvent() and HandleRequest() function. (compatible with milliseconds)

***

# Getting Started


## Initiating the server
### Add a Server script into the _Server Module_

```lua

```

## Initiating the Client
### Add a Local Script into the _Client Module_

```lua

```
