--[[
Copyright 2025 Alston Tang.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

local HttpService = game:GetService("HttpService")
local mps = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local getPassesRemoteFunction = game.ReplicatedStorage.getPassesFromUserId
local updatePassStatus = game.ReplicatedStorage.UpdatePassStatus

local function onInvoke(player: Player, userId: number | nil): {any}
	userId = userId or player.UserId
	local allPassData = {}

	local success, items = pcall(function()
		local pageToken = nil
		local out = {}

		repeat
			local response = HttpService:RequestAsync({
				Url = `https://apis.roblox.com/cloud/v2/users/{userId}/inventory-items?maxPageSize=100&filter=badges=false;gamePasses=true;onlyCollectibles=false;privateServers=false` .. (pageToken and `&pageToken={pageToken}` or ""),
				Method = "GET",
				Headers = {
					["Content-Type"] = "application/json",
					["x-api-key"] = HttpService:GetSecret("test key"),
				}
			})

			local message = HttpService:JSONDecode(response.Body)

			if not message.inventoryItems then break end
			table.move(message.inventoryItems, 1, #message.inventoryItems, #out + 1, out)
			pageToken = message.nextPageToken
		until not pageToken or pageToken == ""
		
		return out
	end)

	if not success then return {} end

	local count = 0

	for _, entry in items do
		task.spawn(function() --TODO: Not rate limit mps/make the api call prefilter.
			local gamePassId = tonumber(entry.gamePassDetails.gamePassId)
			local productInfo = mps:GetProductInfo(gamePassId, Enum.InfoType.GamePass)

			if productInfo.Creator.CreatorTargetId == userId then
				table.insert(allPassData, productInfo)
			end
			count += 1
		end)
	end

	repeat
		RunService.Heartbeat:Wait()
	until count >= #items

	for _, pass in allPassData do
		local success, isOwned = pcall(function()
			return mps:UserOwnsGamePassAsync(player.UserId, pass.ProductId)
		end)

		if success then
			pass.RequestedPlayerOwnsIt = isOwned
		else
			pass.RequestedPlayerOwnsIt = false
		end
	end

	return allPassData
end

getPassesRemoteFunction.OnServerInvoke = function(player, userId)
	return pcall(onInvoke, player, userId)
end

mps.PromptGamePassPurchaseFinished:Connect(function(player: Instance, gamePassId: number, wasPurchased: boolean)
	updatePassStatus:FireClient(player, gamePassId, wasPurchased)
end)
