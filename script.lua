local socket = require("socket")
local http = require("socket.http")
local ltn12 = require("ltn12")
local json = require("json")

-- Function to retrieve information about a domain
local function getDomainInformation(domain)
    -- Retrieve the IP address of the domain
    local ip = socket.dns.toip(domain)
    print("IP Address: " .. ip)

    -- Retrieve DNS records for the domain
    local records = socket.dns.getaddrinfo(domain)
    print("DNS Records:")
    for _, record in ipairs(records) do
        print("\t" .. record.ip)
    end

    -- Check for open ports
    print("Open Ports:")
    for port = 1, 65535 do
        local client = socket.tcp()
        client:settimeout(1000) -- Set timeout limit to 1 second

        -- If connection succeeds, the port is open
        if client:connect(ip, port) == 1 then
            print("\tPort " .. port .. " is open")
        end

        client:close()
    end

    -- Retrieve domain information from WHOIS service
    local whoisURL = "http://whois.jsonapi.pl/api/v1/whois?domain=" .. domain
    local response = {}
    local _, statusCode = http.request{
        url = whoisURL,
        method = "GET",
        sink = ltn12.sink.table(response)
    }
    if statusCode == 200 then
        local responseBody = table.concat(response)
        local whoisData = json.decode(responseBody)
        print("WHOIS:")
        print("\tRegistration Date: " .. whoisData.registered)
        print("\tExpiration Date: " .. whoisData.expires)
        print("\tOwner: " .. whoisData.owner)
        -- You can add other WHOIS information returned by the service
    else
        print("Unable to retrieve WHOIS information")
    end

    -- Retrieve the content of the domain's homepage
    local url = "http://" .. domain
    local body, statusCode, headers = http.request(url)
    if statusCode == 200 then
        print("Page Content:")
        print(body)
    else
        print("Unable to retrieve page content")
    end
end

-- Call the function with a sample domain
getDomainInformation("siteyoucantestthison.com")