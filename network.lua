HousingBotNetwork = {}

function HousingBotNetwork.SendDiscordMessage(message)
    local messageAsJson = json.encode({content = message})

    local function success(str, header, statuscode)
        d("HTTP Request: success.")
        d("HTTP Result Header: " .. tostring(header))
        d("HTTP Result StatusCode: " .. tostring(statuscode))
   
        local data = json.decode(str)
        if data then
           d("HTTP Request: data valid. Currency Coin info:")
           d(data)
        end
   
        -- local function HeadersTable(header)
        --    if type(header) == "string" and #header > 0 then
        --       header = string.match(header,".?%c(.*)") -- Removing the first entry
        --       local tbl = {}
        --       for w in header:gmatch("[^%c]+") do
        --          local k,v = string.match(w,"(.*): (.*)")
        --          tbl[k] = v
        --       end
        --       table.print(tbl)
        --       return tbl
        --    end
        -- end
   
        -- header = HeadersTable(header) -- if you want to convert the header string to a table
     end
   
     local function failed(error, header, statuscode)
        d("HTTP Failed Error: " .. error)
        d("HTTP Failed Header: " .. header)
        d("HTTP Failed StatusCode: " .. tostring(statuscode))
     end
   
     local params = {
        host = "discord.com",
        path = "/api/webhooks/841117198420148254/qWeFpIQiNGvBuzbcDPrrER29XhKe4y7aktazybRxG_AVSQAmGxkflrGf6ZEdSxCylTL-",
        port = 443,
        method = "POST", -- "GET","POST","PUT","DELETE"
        https = true,
        onsuccess = success,
        onfailure = failed,
        getheaders = true, --true will return the headers, if you dont need it you can leave this at nil
        body = messageAsJson, --optional, if not required for your call can be nil or ""
        headers = {
            ["Content-Type"] = "application/json"
        }, --optional, if not required for your call can be nil or ""
     }

     HttpRequest(params)


end


function HousingBotNetwork.AddHouse(totalHouseData) 
    local houseAsJson = json.encode(totalHouseData)

    local function success(str, header, statuscode)
        d("HTTP Request: success.")
        d("HTTP Result Header: " .. tostring(header))
        d("HTTP Result StatusCode: " .. tostring(statuscode))
   
        local data = json.decode(str)
        if data then
           d("HTTP Request: data valid. Currency Coin info:")
           d(data)
        end
        local function HeadersTable(header)
           if type(header) == "string" and #header > 0 then
              header = string.match(header,".?%c(.*)") -- Removing the first entry
              local tbl = {}
              for w in header:gmatch("[^%c]+") do
                 local k,v = string.match(w,"(.*): (.*)")
                 tbl[k] = v
              end
              table.print(tbl)
              return tbl
           end
        end
   
        header = HeadersTable(header) -- if you want to convert the header string to a table
     end
   
     local function failed(error, header, statuscode)
        d("HTTP Failed Error: " .. error)
        d("HTTP Failed Header: " .. header)
        d("HTTP Failed StatusCode: " .. tostring(statuscode))
     end
   
     local params = {
        host = "fbgclips.com",
        path = "/xiv/housing/add",
        port = 3000,
        method = "POST", -- "GET","POST","PUT","DELETE"
        https = false,
        onsuccess = success,
        onfailure = failed,
        getheaders = true, --true will return the headers, if you dont need it you can leave this at nil
        body = houseAsJson, --optional, if not required for your call can be nil or ""
        headers = {
            ["Content-Type"] = "application/json"
        }, --optional, if not required for your call can be nil or ""
     }

     HttpRequest(params)


end