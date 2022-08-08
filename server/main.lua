ESX             = nil
local RookeriItems = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

MySQL.ready(function()
	MySQL.Async.fetchAll('SELECT * FROM rookeri LEFT JOIN items ON items.name = rookeri.item', {}, function(rookeriResult)
		for i=1, #rookeriResult, 1 do
			if rookeriResult[i].name then
				if RookeriItems[rookeriResult[i].kauppa] == nil then
					RookeriItems[rookeriResult[i].kauppa] = {}
				end

				if rookeriResult[i].limit == -1 then
					rookeriResult[i].limit = 30
				end

				table.insert(RookeriItems[rookeriResult[i].kauppa], {
					label = rookeriResult[i].label,
					item  = rookeriResult[i].item,
					price = rookeriResult[i].price,
					limit = rookeriResult[i].limit
				})
			else
				print(('esx_rookeri: invalid item "%s" found!'):format(rookeriResult[i].item))
			end
		end
	end)
end)

ESX.RegisterServerCallback('esx_rookeri:requestDBItems', function(source, cb)
	cb(RookeriItems)
end)

RegisterServerEvent('esx_rookeri:buyItem')
AddEventHandler('esx_rookeri:buyItem', function(itemName, amount, zone)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	amount = ESX.Math.Round(amount)

	-- is the player trying to exploit?
	if amount < 0 then
		print('esx_rookeri: ' .. xPlayer.identifier .. ' attempted to exploit the rookeri!')
		return
	end

	-- get price
	local price = 0
	local itemLabel = ''

	for i=1, #RookeriItems[zone], 1 do
		if RookeriItems[zone][i].item == itemName then
			price = RookeriItems[zone][i].price
			itemLabel = RookeriItems[zone][i].label
			break
		end
	end

	price = price * amount

	-- can the player afford this item?
	if xPlayer.getMoney() >= price then
		-- can the player carry the said amount of x item?
		if sourceItem.limit ~= -1 and (sourceItem.count + amount) > sourceItem.limit then
			TriggerClientEvent('esx:showNotification', _source, _U('player_cannot_hold'))
		else
			xPlayer.removeMoney(price)
			xPlayer.addInventoryItem(itemName, amount)
			TriggerClientEvent('esx:showNotification', _source, _U('bought', amount, itemLabel, ESX.Math.GroupDigits(price)))
		end
	else
		local missingMoney = price - xPlayer.getMoney()
		TriggerClientEvent('esx:showNotification', _source, _U('not_enough', ESX.Math.GroupDigits(missingMoney)))
	end
end)
