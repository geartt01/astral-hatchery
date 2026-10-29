# Astral Hatchery

> **Status:** prototype. Core systems are in place; art, monetization IDs and badges are not set up yet.
>
> **Stack:** Luau · Rojo · DataStoreService · server-authoritative remotes

An original Roblox creature-collection game. Players collect **Aether Eggs**, hatch procedurally varied companions, breed rare lineages, chase weather mutations, trade safely, and prestige their hatchery.

## Quick start

1. Install [Rojo](https://rojo.space/) and open a new Baseplate in Roblox Studio.
2. In this folder, run `rojo serve`, then connect the Rojo Studio plugin.
3. Publish the place before testing DataStores. Enable **Game Settings → Security → Enable Studio Access to API Services** only for Studio testing.
4. Set the product, gamepass, and badge IDs in `Shared/Config.lua`. IDs are intentionally `0` until you create the Roblox monetization items.

`ServerMain.server.lua` creates the entire playable lobby and egg stations at runtime. The data, economy, hatching, breeding, trading, weather, quest, prestige and receipt actions are server-authoritative; the client never gets permission to choose a rarity, value, mutation, or payout.

## Design notes

- Max active followers is capped at 3, avoiding expensive per-player swarms in 50-player servers.
- Weather is one server-wide state and hatching uses a compact table schema suitable for DataStore limits.
- Developer products only grant the configured **cosmetic** effects. No paid currency or stat boosts are included.
- Trade is a two-sided escrow confirmation process; items are only moved once the server validates ownership twice.

## Source map

- `Shared/Config.lua` — balancing/catalogue settings.
- `Server/*Service.lua` — server-side game systems.
- `ServerMain.server.lua` — remotes, world, lifecycle, validation routing.
- `ClientMain.client.lua` — responsive UI, tutorial, UI animation, follower visuals.
