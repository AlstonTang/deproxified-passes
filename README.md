# deproxified-passes
Get user's gamepasses on Roblox without any proxies

## Why?
Normally, for one to get a user's gamepasses on Roblox, you would need to:

1. Fetch the user's games
2. Fetch the gamepasses associated with each game

Due to Roblox's lack of support for HTTPService to utilize most roblox.com APIs, developers have used workarounds in the form of proxies. However, use of such proxies can lead to malicious injections among other security concerns, and are still subject to potentially arbitrary rate limits.

To that end, deproxified-passes aims to use the limited APIs available to HTTPService through Open Cloud endpoints to fetch a user's gamepasses. While currently impractical for production use, this does serve as a proof of concept of what can be done.

## Prerequisites
A key to get the user's items (see [here](https://create.roblox.com/docs/cloud-services/http-service) to get started).
- Once making the API key load it into your game's secrets under the name of "test key" or whatever you wish (you may need to change the name of the key within the code).

## Limitations
1. It is required that the user for which you want to see their gamepasses has their inventory visibility to be public.
2. If someone has already bought a lot of gamepasses (presumably through donation games), you may hit rate limits with MarketPlaceService.
