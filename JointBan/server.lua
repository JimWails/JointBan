local blacklist = ""

function isBlacklisted(id)
	blacklist = LoadResourceFile(GetCurrentResourceName(), "data/blacklist.txt") or ""
	i,j = string.find(blacklist, id)
	if i ~= nil and j ~= nil then
	    return true
	else 
	    return false
	end
end

AddEventHandler("playerConnecting", function(name, reject, def)
	local source	= source
	local steamID = GetSteamID(source)

	if not steamID then
		reject("检测到您未开启Steam，请先运行Steam然后重启FiveM (CitizenFX)后再次尝试加入本服务器.Detected that you did not started Steam, please run Steam first and restart FiveM (CitizenFX), then try to join this server .")
		CancelEvent()
		return
	end
	for k,v in ipairs(GetPlayerIdentifiers(source))do
	if isBlacklisted(GetPlayerIdentifiers(source)[1]) then
		reject("国服联合封禁：此Steam ID因违反规定已被本服务器或其他服务器永久封禁，禁止加入本服务器")
		CancelEvent()
		break
	end
	end
end)

function GetSteamID(src)
	local sid = GetPlayerIdentifiers(src)[1] or false

	if (sid == false or sid:sub(1,5) ~= "steam") then
		return false
	end

	return sid
end
