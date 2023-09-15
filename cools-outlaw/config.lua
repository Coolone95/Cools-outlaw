Config = {}

Config.Debug = false

--bank robbery--
Config.BankCooldown = 21600 -- amount of time in seconds until bank can be robbed again (3600 = 1hr)

--drug sale--
Config.Sellable = {
    ["applemoonshine"] = {
        label = "Apple Moonshine",
        price = 10,  -- Price for selling one unit
    },
    ["morphine"] = {
        label = "Morphine",
        price = 15,
    },
    ["joint"] = {
        label = "Joint",
        price = 5,
    },
    ["cocaine"] = {
        label = "Cocaine",
        price = 20,
    },
    ["shrooms"] = {
        label = "Shrooms",
        price = 5,
    },
    ["moonshine"] = {
        label = "Moonshine",
        price = 10,
    },
}


---ped settings--
Config.DistanceSpawn = 20.0 -- Distance before spawning/despawning the ped. (GTA Units.)
Config.FadeIn = true

--webhook---

Config.webhook = "https://discord.com/api/webhooks/1138670961529470976/T1vdJ9lY7FxYiJkfsYRbzmAQADooUIospBuYMuu361Y2H5ae0QN2rdWfHJ1HCRY8vkui"
Config.webhooktitle = "Illegal goods delivery in progress!"

--blip config
Config.Blip = {
    blipName = 'Moonsine Delivery', -- Config.Blip.blipName
    blipSprite = 'blip_business_moonshine', -- Config.Blip.blipSprite
    blipScale = 0.2 -- Config.Blip.blipScale
}


-- settings for lawmen amount to be on duty
Config.MinimumLawmen = 0  --how many law need to be on duty

--config for store robbery--
Config.SmallRewardAmount = 1
Config.MediumRewardAmount = 2
Config.LargeRewardAmount = 3
Config.MoneyRewardType = 'cash'
Config.MoneyRewardAmount = math.random(50, 200)
Config.movement = true --if set to true freezes player in animation for timer if false they can move around but cant get in inventory
Config.timer = 2 --time for robbery in mins
Config.progress = 'Robbing Store'  --progressbar--
Config.label1 = 'Rob Store' --label for register
Config.label2 = 'Rob Register' --label for register
Config.register1 = 'p_register03x'  --model for register 
Config.register2 = 'p_register05x'  --model for register

Config.register = {
    {   
      'p_register03x', 
	  'p_register05x'
    },
}	

--config for drug delivery--

Config.DeliveryLocations = {
    {   
        name        = 'Moonshine Delivery',
        deliveryid  = 'shinnedelivery1',
		model       = `a_m_o_btchillbilly_01`,
        coords       = vector4(1626.9874, 836.1160, 144.7745, 44.7835),
        cartspawn   = vector4(1623.4950, 840.5627, 144.2313, 17.8833), 
        cart        = 'cart01',
        cargo       = 'pg_re_moonshineCampgroupCart01x',
        light       = 'pg_teamster_cart01_lightupgrade1',
        startcoords = vector3(1626.1163, 836.6479, 144.8086),
        endcoords   = vector3(-1434.0763, -2315.4263, 43.0137),
        showgps     = true,
        showblip    = false,
		walktowagon = false,
		showtimer   = false,
		timerplacement = 'left',
		removeItemOnTimer = true,  -- set true if you want item removed if timer is up set false if you want item to not be removed
		showDropOffText = true,  -- Show "Drop off Point" text
        sellItem    = 'moonshine',  -- Item to sell at this delivery location
        itemamount = 20, -- Adjust the required amount of moonshine if needed
        price       = 300,   -- Adjust the price for this delivery location
        deliveryTime = 30,  -- Time in minutes for the delivery countdown
        notify      = 'The goods are loaded in wagon got 30 minutes the law has been alerted.',
        alert       = 'You need to have 20 moonshine!',
		deliveryfailalert  = 'Delivery failed! The wagon and goods have been confiscated.!',
        lawalert    = 'Someone is starting a Delivery of illegal goods!',
		lawalert1    = 'Delivery completed!',
		dropofftext = 'Sell location',
    },
    {   
        name        = 'Moonshine Delivery',
        deliveryid  = 'shinnedelivery2',
		model       = `mp_re_moonshinecamp_males_01`,
        coords      = vector4(-1857.6136, -1724.8650, 109.2261, 287.9733),
        cartspawn   = vector4(-1858.7897, -1712.2471, 107.4584, 339.3041), 
        cart        = 'cart01',
        cargo       = 'pg_re_moonshineCampgroupCart01x',
        light       = 'pg_teamster_cart01_lightupgrade1',
        startcoords = vector3(-1856.3446, -1724.2938, 109.2178),
        endcoords   = vector3(2543.4038, 774.3740, 75.8565),
        showgps     = true,
        showblip    = false,
		walktowagon = true,
		showtimer   = false,
		timerplacement = 'left',
		removeItemOnTimer = true,
		showDropOffText = true,  -- Show "Drop off Point" text
        sellItem    = 'moonshine',  -- Item to sell at this delivery location
        itemamount = 20, -- Adjust the required amount of moonshine if needed
        price       = 300,   -- Adjust the price for this delivery location
        deliveryTime = 30,  -- Time in minutes for the delivery countdown
        notify      = 'The goods are loaded in wagon got 30 minutes the law has been alerted.',
        alert       = 'You need to have 20 moonshine!',
		deliveryfailalert  = 'Delivery failed! The wagon and goods have been confiscated.!',
        lawalert    = 'Someone is starting a Delivery of illegal goods!',
		lawalert1    = 'Delivery completed!',
		dropofftext = 'Sell Location',
    },
    {   
        name        = 'Moonshine Delivery',
        deliveryid  = 'shinnedelivery3',
		model       = `cs_mp_moonshiner`,
        coords      = vector4(-1086.6731, 717.4090, 104.1237, 29.4455),
        cartspawn   = vector4(-1093.1027, 728.1072, 105.4001, 65.8961), 
        cart        = 'cart01',
        cargo       = 'pg_re_moonshineCampgroupCart01x',
        light       = 'pg_teamster_cart01_lightupgrade1',
        startcoords = vector3(-1087.0028, 718.3917, 104.1472),
        endcoords   = vector3(-2752.0034, -3048.8660, 9.6870),
        showgps     = true,
        showblip    = false,
		walktowagon = true,
		showtimer   = false,
		timerplacement = 'left',
		removeItemOnTimer = true,
		showDropOffText = true,  -- Show "Drop off Point" text
        sellItem    = 'moonshine',  -- Item to sell at this delivery location
        itemamount = 20, -- Adjust the required amount of moonshine if needed
        price       = 300,   -- Adjust the price for this delivery location
        deliveryTime = 30,  -- Time in minutes for the delivery countdown
        notify      = 'The goods are loaded in wagon got 30 minutes the law has been alerted.',
        alert       = 'You need to have 20 moonshine!',
		deliveryfailalert  = 'Delivery failed! The wagon and goods have been confiscated.!',
        lawalert    = 'Someone is starting a Delivery of illegal goods!',
		lawalert1    = 'Delivery completed!',
		dropofftext = 'Sell Location',
    },
    {   
        name        = 'Moonshine Delivery',
        deliveryid  = 'shinnedelivery4',
		model       = `cs_mp_moonshiner`,
        coords      = vector4(-2771.5801, -3053.5210, 11.2579, 207.8263),
        cartspawn   = vector4(-2757.4202, -3052.2117, 10.1190, 295.3713), 
        cart        = 'cart01',
        cargo       = 'pg_re_moonshineCampgroupCart01x',
        light       = 'pg_teamster_cart01_lightupgrade1',
        startcoords = vector3(-2770.2754, -3055.0854, 11.1683),
        endcoords   = vector3(1619.2731, 840.0795, 143.8127),
        showgps     = true,
        showblip    = false,
		walktowagon = true,
		showtimer   = false,
		timerplacement = 'left',
		removeItemOnTimer = true,
		showDropOffText = true,  -- Show "Drop off Point" text
        sellItem    = 'moonshine',  -- Item to sell at this delivery location
        itemamount = 20, -- Adjust the required amount of moonshine if needed
        price       = 300,   -- Adjust the price for this delivery location
        deliveryTime = 30,  -- Time in minutes for the delivery countdown
        notify      = 'The goods are loaded in wagon got 30 minutes the law has been alerted.',
        alert       = 'You need to have 20 moonshine!',
		deliveryfailalert  = 'Delivery failed! The wagon and goods have been confiscated.!',
        lawalert    = 'Someone is starting a Delivery of illegal goods!',
		lawalert1    = 'Delivery completed!',
		dropofftext = 'Sell Location',
    },
    {   
        name        = 'Moonshine Delivery',
        deliveryid  = 'shinnedelivery5',
        model       = `cs_mp_moonshiner`,
        coords      = vector4(1781.7476, -818.9604, 42.5985, 52.7948),
        cartspawn   = vector4(1775.9429, -829.2457, 41.7970, 180.9997), 
        cart        = 'cart01',
        cargo       = 'pg_re_moonshineCampgroupCart01x',
        light       = 'pg_teamster_cart01_lightupgrade1',
        startcoords = vector3(1780.8920, -818.0888, 42.6246),
        endcoords   = vector3(-1097.5355, 730.4246, 106.0459),
        showgps     = true,
        showblip    = false,
		walktowagon = true,
		showtimer   = false,
		timerplacement = 'left',
		removeItemOnTimer = true,
		showDropOffText = true,  -- Show "Drop off Point" text
        sellItem    = 'moonshine',  -- Item to sell at this delivery location
        itemamount = 20, -- Adjust the required amount of moonshine if needed
        price       = 300,   -- Adjust the price for this delivery location
        deliveryTime = 30,  -- Time in minutes for the delivery countdown
        notify      = 'The goods are loaded in wagon got 30 minutes the law has been alerted.',
        alert       = 'You need to have 20 moonshine!',
		deliveryfailalert  = 'Delivery failed! The wagon and goods have been confiscated.!',
        lawalert    = 'Someone is starting a Delivery of illegal goods!',
		lawalert1    = 'Delivery completed!',
		dropofftext = 'Sell Location',
    },
    {   
        name        = 'Cocaine Delivery',
        deliveryid  = 'cocainedelivery',
        model       = `a_m_o_btchillbilly_01`,
        coords      = vector4(-1449.0028, -2321.9231, 43.1364, 13.0765),
        cartspawn   = vector4(-1439.9094, -2311.9080, 43.4125, 238.3504), 
        cart        = 'cart01',
        cargo       = 'pg_re_moonshineCampgroupCart01x',
        light       = 'pg_teamster_cart01_lightupgrade1',
        startcoords = vector3(-1449.6276, -2320.5542, 43.2417),
        endcoords   = vector3(1419.0167, 367.8092, 89.2269),
        showgps     = true,
        showblip    = false,
		walktowagon = true,
		showtimer   = false,
		timerplacement = 'left',
		removeItemOnTimer = true,
		showDropOffText = true,  -- Show "Drop off Point" text
        sellItem    = 'cocaine',  -- Item to sell at this delivery location
        itemamount = 20, -- Adjust the required amount of moonshine if needed
        price       = 600,   -- Adjust the price for this delivery location
        deliveryTime = 30,  -- Time in minutes for the delivery countdown
        notify      = 'The goods are loaded in wagon got 30 minutes the law has been alerted.',
        alert       = 'You need to have 20 Cocaine!',
		deliveryfailalert  = 'Delivery failed! The wagon and goods have been confiscated.!',
        lawalert    = 'Someone is starting a Delivery of illegal goods!',
		lawalert1    = 'Delivery completed!',
		dropofftext = 'Sell Location',
    },
	{   
        name        = 'Morphine Delivery',
        deliveryid  = 'morphinedelivery',
        model       = `a_m_o_btchillbilly_01`,
        coords      = vector4(2539.1113, 774.7880, 75.6372, 318.9221),
        cartspawn   = vector4(2543.0112, 774.3387, 75.8408, 225.1071), 
        cart        = 'cart01',
        cargo       = 'pg_re_moonshineCampgroupCart01x',
        light       = 'pg_teamster_cart01_lightupgrade1',
        startcoords = vector3(2539.9622, 775.1318, 75.6572),
        endcoords   = vector3(2774.1680, -1110.6982, 47.1626),
        showgps     = true,
        showblip    = false,
		walktowagon = true,
		showtimer   = false,
		timerplacement = 'left',
		removeItemOnTimer = true,
		showDropOffText = true,  -- Show "Drop off Point" text
        sellItem    = 'morphine',  -- Item to sell at this delivery location
        itemamount = 20, -- Adjust the required amount of moonshine if needed
        price       = 600,   -- Adjust the price for this delivery location
        deliveryTime = 30,  -- Time in minutes for the delivery countdown
        notify      = 'The goods are loaded in wagon got 30 minutes the law has been alerted.',
        alert       = 'You need to have 20 Morphine!',
		deliveryfailalert  = 'Delivery failed! The wagon and goods have been confiscated.!',
        lawalert    = 'Someone is starting a Delivery of illegal goods!',
		lawalert1    = 'Delivery completed!',
		dropofftext = 'Sell Location',
    },
	{   
        name        = 'Opium Delivery',
        deliveryid  = 'opiumdelivery',
        model       = `a_m_o_btchillbilly_01`,
        coords      = vector4(2773.2437, -1115.7140, 47.4640, 336.9482),
        cartspawn   = vector4(2770.9487, -1110.1727, 47.4349, 88.0858), 
        cart        = 'cart01',
        cargo       = 'pg_re_moonshineCampgroupCart01x',
        light       = 'pg_teamster_cart01_lightupgrade1',
        startcoords = vector3(2774.0747, -1114.0297, 47.3500),
        endcoords   = vector3(2936.1658, 570.7473, 44.7215),
        showgps     = true,
        showblip    = false,
		walktowagon = true,
		showtimer   = false,
		timerplacement = 'left',
		removeItemOnTimer = true,
		showDropOffText = true,  -- Show "Drop off Point" text
        sellItem    = 'opium',  -- Item to sell at this delivery location
        itemamount = 20, -- Adjust the required amount of moonshine if needed
        price       = 600,   -- Adjust the price for this delivery location
        deliveryTime = 30,  -- Time in minutes for the delivery countdown
        notify      = 'The goods are loaded in wagon got 30 minutes the law has been alerted.',
        alert       = 'You need to have 20 opium!',
		deliveryfailalert  = 'Delivery failed! The wagon and goods have been confiscated.!',
        lawalert    = 'Someone is starting a Delivery of illegal goods!',
		lawalert1    = 'Delivery completed!',
		dropofftext = 'Sell Location',
    },	
}

-- items for the store robbery
Config.RewardItems = {
    'jerkybag', -- example
	'pipe', -- example
	'bagptobacco', -- example
	'cbeans', -- example
	'ctobacco', -- example
	'csmokes', -- example
	'lockpick', -- example
	
}

