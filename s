ae=8

function numtoclr(n)

    local r = math.floor(n/ae^2) % ae

    local g = math.floor(n/ae) % ae

    local b = n%ae

    return Color.New(r/ae,g/ae,b/ae)

end

wait(2)

local inplabel = script.Parent["Input"]

local screen = script.Parent["Screen"]

local aborting = false

game["Hidden"]["SendAbortSignal"].InvokedClient:Connect(function()

    aborting = true

    for _,v in ipairs(screen:GetChildren()) do

        pcall(function() v:Destroy() end)

    end

    wait(1)

    aborting = false

end)

game["Hidden"]["SendPicture"].InvokedClient:Connect(function(_,msg)

    local inp = msg.GetString("data")

    local data = json.parse(inp)

    if data["clr"] then

        ae = data["clr"]

    end

    local ratio = data["h"]/data["w"]

    screen.SizeOffset = Vector2.New(300,300*ratio)

    local xunit = 1/data["w"]

    local yunit = 1/data["h"]

    local t = data["pixels"]

    local curpxls = screen:GetChildren()

    local pxlsscanned = 0

    for rowi,row in ipairs(t) do

        if aborting then

            break

        end

        wait(0)

        local ypos = (rowi-1)*yunit

        for k,v in pairs(row) do

            pxlsscanned = pxlsscanned + 1

            if pxlsscanned%20==0 then

                wait(0)

            end

            if type(v) == "number" then

                local i = tonumber(k)

                local p = script["Pixel"]:Clone()

                p.SizeRelative = Vector2.New(xunit,yunit)

                p.PositionRelative = Vector2.New((i-1)*xunit,1-ypos)

                p.Color = numtoclr(v)

                p.Visible = true

                p.Parent = screen

            else

                -- is an array in form of "0":[color,sizex,sizey]

                local i = tonumber(k)

                local p = script["Pixel"]:Clone()

                p.SizeRelative = Vector2.New(xunit*v[2],yunit*v[3])

                local ysize = yunit*(v[3]-1)

                p.PositionRelative = Vector2.New((i-1)*xunit,1-ypos+(ysize))

                p.Color = numtoclr(v[1])

                p.Visible = true

                p.Parent = screen

            end

        end

    end

    pxlsscanned = 0

    for _,v in ipairs(curpxls) do

        v:Destroy()

        pxlsscanned = pxlsscanned + 1

        if pxlsscanned%100==0 then

            wait(0)

        end

    end

    if aborting then

        for _,v in ipairs(screen:GetChildren()) do

            pcall(function() v:Destroy() end)

        end

    end

end)
