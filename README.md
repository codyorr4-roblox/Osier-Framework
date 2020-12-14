# SlimService for roblox
A very compact module used to simplify Initiation, Datastores and Remotes.

# Why use slim?

## Datastores
* Player Data Loading, Caching and Autosaving are handled automatically, you just provde Default Data for new players
* Player Data is replicated automatically to the client.
* SessionLocking is implemented and data cannot be overriden with old data and exploiters can't duplicate data. **[unfinished]**
* Slim doesn't use a network request everytime you want to get/update a value from datastores. (because it caches the players data)
* Easily reset data, add data or remove data using a reconcile method.
* Easily add CORE leaderstats that automatically update when you update players data.
* Easily add CUSTOM leaderboards that automatically update when you update players data. **[unfinished]**

## Remotes
* Remotes are way more convenient to use and have a faster workflow.
* Never have to worry about type errors
* Never have to worry about exploiters breaking your remotes/server.
* Never have to worry about adding debounces/cooldowns to every single remote.
  just provide the cooldown argument in HandleEvent() and HandleRequest() function. (compatible with milliseconds)


***

# Getting Started

***
## Initiating the server
### Add a Server script into the _Server Module_

```lua

```

## Initiating the Client
### Add a Local Script into the _Client Module_

```lua

```
