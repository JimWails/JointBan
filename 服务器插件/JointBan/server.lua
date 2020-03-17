local blacklist = ""
local APIRequest = "https://raw.githubusercontent.com/JimWails/JointBan/master/BanData"
local APTRetryTimes = 0
local ShowUpdataInfo = true

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
			reject("国服联合封禁：此Steam ID因违反规定已被本服务器或其他服务器永久封禁，禁止加入本服务器. 如有误封，请联系插件管理员：QQ1142247734")
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

function isBlacklisted(id)
	blacklist = LoadResourceFile(GetCurrentResourceName(), "data/blacklist.txt") or ""
	i,j = string.find(blacklist, id)
	if i ~= nil and j ~= nil then
	    return true
	else 
	    return false
	end
end

function CheckVersion()
	if ShowUpdataInfo then
		print("Checking version and blacklist...\n")
	end
	local localversion = LoadResourceFile(GetCurrentResourceName(), "data/version.txt") or "1.0.0.0"
	PerformHttpRequest(APIRequest .. "/version", function(err, rText, headers)
		if err == 200 then
			if rText ~= localversion then
				PerformHttpRequest(APIRequest .. "/data", function(err2, rText2, headers2)
					if err2 == 200 then
						SaveResourceFile(GetCurrentResourceName(), "data/version.txt", rText, -1)
						SaveResourceFile(GetCurrentResourceName(), "data/blacklist.txt", rText2, -1)
						APTRetryTimes = 0
						if ShowUpdataInfo then
							print("Successfully updated blacklist")
							print("New Database Version:" .. tostring(rText))
							print("Plugin will check it again after 120s")
						end
					else
						APTRetryTimes = APTRetryTimes + 1
						if ShowUpdataInfo then
							print("Failed to get blacklist")
							print("Plugin will retry after 120s")
						end
					end
				end)
			else
				APTRetryTimes = 0
				if ShowUpdataInfo then
					print("Local data is up to date")
					print("Plugin will check it again after 120s")
				end
			end
		else
			APTRetryTimes = APTRetryTimes + 1
			if APTRetryTimes >= 3 then
				APIRequest =  "https://www.kwfrb.club/BanData"
				APTRetryTimes = 0
				if ShowUpdataInfo then
					print("API changed")
				end
			end
			if ShowUpdataInfo then
				print("Failed to get version info")
				print("Plugin will retry after 120s")
			end
		end
	end)
end

Citizen.CreateThread(function()
	while true do
		CheckVersion()
		Citizen.Wait(120000)
	end
end)
