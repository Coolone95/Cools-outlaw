local json = {}

function json.encode(data)
    local jsonString = ""
    if type(data) == "table" then
        jsonString = "{"
        local first = true
        for key, value in pairs(data) do
            if not first then
                jsonString = jsonString .. ","
            else
                first = false
            end
            jsonString = jsonString .. '"' .. key .. '":' .. json.encode(value)
        end
        jsonString = jsonString .. "}"
    elseif type(data) == "string" then
        jsonString = '"' .. data .. '"'
    else
        jsonString = tostring(data)
    end
    return jsonString
end

function json.decode(jsonString)
    return load("return " .. jsonString)()
end

return json