ae=8

function numtoclr(n)
-- make the parts yourself okay i am lazy
    local r = math.floor(n/ae^2) % ae

    local g = math.floor(n/ae) % ae

    local b = n%ae

    return Color.New(r/ae,g/ae,b/ae)

end

wait(2)

local inplabel = script.Parent["Input"]

local fakescreen = game["Environment"]["FakeScreen"]

local screen = fakescreen["PixelHolder"]

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

    if not data["h"] or not data["w"] or not data["pixels"] then

        return

    end

    if data["clr"] then

        ae = data["clr"]

    end

    local ratio = data["w"]/data["h"]

    fakescreen.Size = Vector3.New(2,50,50*ratio)

    local xunit = 1/data["w"]

    local yunit = 1/data["h"]

    local t = data["pixels"]

    local curpxls = screen:GetChildren()

    for _,v in ipairs(curpxls) do

        local lpos = v.LocalPosition

        v.LocalPosition = Vector3.New(0.5005,lpos.y,lpos.z)

    end

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

                p.Color = numtoclr(v)

                p.Parent = screen

                p.LocalSize = Vector3.New(xunit,yunit,1)

                p.LocalPosition = Vector3.New(0.501,1-ypos - yunit/2,(i-1)*xunit + xunit/2)

            else

                -- is an array in form of "0":[color,sizex,sizey]

                local i = tonumber(k)

                local p = script["Pixel"]:Clone()

                p.Color = numtoclr(v[1])

                p.Parent = screen

                p.LocalSize = Vector3.New(xunit*v[2],yunit*v[3],1)

                local ysize = yunit*(v[3]-1)/2

                local xsize = xunit*(v[2]-1)/2

                p.LocalPosition = Vector3.New(0.501,1-ypos+(ysize) - yunit/2,((i-1)*xunit)+(xsize) + xunit/2)

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

game["Hidden"]["SendSound"].InvokedClient:Connect(function(_,msg)

    local inp = msg.GetString("data")

    local data = json.parse(inp)

    local sample = script.Parent["Samples"]:FindChild(data["sample"] or "Sine")

    for i,note in ipairs(data["data"]) do

        local hz = note["f"]

        if not hz then hz = 0 end

        local s = sample:Clone()

        s.Pitch = hz/440

        s.Parent = script

        local m = note["m"] or 1000

        s.Volume = (m/1000)*3

        s:Play()

        wait(note["t"]/1000)

        s:Stop()

        s:Destroy()

        if aborting then

            break

        end

    end

end)
