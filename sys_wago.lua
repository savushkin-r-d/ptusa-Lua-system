modules_info = {}

modules_info[ 402 ] =
    {
    comment           = 'Дискретный вход',
    mtype             = 'DI',
    DI_channels_count = 4,
    channel_size      = 1 --Размер области отображения одного канала.
    }

modules_info[ 1420 ] =
    {
    comment           = 'Дискретный вход 24 VDC',
    mtype             = 'DI',
    DI_channels_count = 4,
    channel_size      = 1
    }

modules_info[ 1415 ] =
    {
    comment           = 'Дискретный вход 24 VDC',
    mtype             = 'DI',
    DI_channels_count = 8,
    channel_size      = 1
    }

modules_info[ 1405 ] =
    {
    comment           = 'Дискретный вход 24 VDC',
    mtype             = 'DI',
    DI_channels_count = 16,
    channel_size      = 1
    }

modules_info[ 1504 ] =
    {
    comment           = 'Дискретный выход 24 VDC',
    mtype             = 'DI',
    DI_channels_count = 16,
    channel_size      = 1
    }

modules_info[ 1515 ] =
    {
    comment           = 'Дискретный выход 24 VDC',
    mtype             = 'DI',
    DI_channels_count = 8,
    channel_size      = 1
    }

modules_info[ 638 ] =
    {
    comment           = 'Счетчик импульсов',
    mtype             = 'SPECIAL',
    AI_channels_count = 2,
    AO_channels_count = 2,
    channel_size      = 4
    }
modules_info[ 466 ] =
    {
    comment           = 'Температура',
    mtype             = 'AI',
    AI_channels_count = 2,
    channel_size      = 2
    }
modules_info[ 461 ] =
    {
    comment           = 'Текущий уровень',
    mtype             = 'AI',
    AI_channels_count = 2,
    channel_size      = 2
    }


--Спросить у Андрея характеристики модулей.
modules_info[ 504 ] =
    {
    comment           = '??',
    mtype             = 'DO',
    DO_channels_count = 4
    }
modules_info[ 512 ] =
    {
    comment           = '??',
    mtype             = 'DO',
    DO_channels_count = 4
    }
modules_info[ 554 ] =
    {
    comment           = '??',
    mtype             = 'AO',
    AO_channels_count = 2,
    channel_size      = 2
    }
modules_info[ 613 ] =
    {
    comment           = '??',
    mtype             = 'STUB'
    }
modules_info[ 612 ] =
    {
    comment           = '??',
    mtype             = 'STUB'
    }
modules_info[ 602 ] =
    {
    comment           = '??',
    mtype             = 'STUB'
    }
modules_info[ 600 ] =
    {
    comment           = '??',
    mtype             = 'STUB'
    }
modules_info[ 430 ] =
    {
    comment           = '??',
    mtype             = 'DI',
    DI_channels_count = 8
    }
modules_info[ 530 ] =
    {
    comment           = '??',
    mtype             = 'DO',
    DO_channels_count = 8
    }
modules_info[ 655 ] =
    {
    comment           = '??',
    mtype             = 'AIAO',
    AO_channels_count = 2,
    AI_channels_count = 2,
    channel_size      = 2
    }
modules_info[ 455 ] =
    {
    comment           = '??',
    mtype             = 'AI',
    AI_channels_count = 2,
    channel_size      = 2
    }
modules_info[ 460 ] =
    {
    comment           = '??',
    mtype             = 'AI',
    AI_channels_count = 2,
    channel_size      = 2
    }

function get_modules_info ( modules )
    local DO_cnt      = 0
    local AO_cnt      = 0
    local AO_local    = {}
    local DI_cnt      = 0
    local AI_cnt      = 0
    local AI_local    = {}
    local modules_cnt = 0

    if modules == nil or type( modules ) ~= "table" then
        return  { modules_count = 0 }
    end

    local AO_end_address = 0
    local AI_end_address = 0

    for fields, value in pairs( modules ) do
        if modules_info[ value[ 1 ] ] ~= nil then

            if modules_info[ value[ 1 ] ].DO_channels_count then
                DO_cnt = DO_cnt +
                    modules_info[ value[ 1 ] ].DO_channels_count
            end

            if modules_info[ value[ 1 ] ].AO_channels_count then

                for i = AO_cnt, AO_cnt +
                    modules_info[ value[ 1 ] ].AO_channels_count - 1 do

                    AO_local[ i + 1 ] = { value[ 1 ], AO_end_address }
                    AO_end_address = AO_end_address +
                        modules_info[ value[ 1 ] ].channel_size
                end
                AO_cnt = AO_cnt +
                    modules_info[ value[ 1 ] ].AO_channels_count
            end

            if modules_info[ value[ 1 ] ].DI_channels_count then
                DI_cnt = DI_cnt +
                    modules_info[ value[ 1 ] ].DI_channels_count
            end

            if modules_info[ value[ 1 ] ].AI_channels_count then
                for i = AI_cnt, AI_cnt +
                    modules_info[ value[ 1 ] ].AI_channels_count - 1 do

                    AI_local[ i + 1 ] = { value[ 1 ], AI_end_address }
                    AI_end_address = AI_end_address +
                        modules_info[ value[ 1 ] ].channel_size
                end
                AI_cnt = AI_cnt +
                    modules_info[ value[ 1 ] ].AI_channels_count
            end

            modules_cnt = modules_cnt + 1
        else
            print( "Unknown module №", fields, " - '", value[ 1 ], "'!")
        end

    end

    return
        {
        modules_count = modules_cnt,
        DO_count = DO_cnt,
        AO_count = AO_cnt,
        AO       = AO_local,
        DI_count = DI_cnt,
        AI_count = AI_cnt,
        AI       = AI_local
        }
end

system =
    {
    get_file_version = function()
        return file_version
    end,

    get_PAC_name = function()
        if PAC_name == nil then return 'Unknown project' end
        return PAC_name
    end,

    get_PAC_id = function()
        if PAC_id == nil then return 1 end
        return PAC_id
    end,

    get_editor_version = function()
        return editor_version
    end,

    init_wago = function()
        local nodes_count = #nodes
        G_WAGO_MANAGER():init( nodes_count )

        for i = 1, nodes_count do
            local node_info = get_modules_info( nodes[ i ].modules )

            G_WAGO_MANAGER():add_node( i - 1,
                nodes[ i ].ntype, nodes[ i ].address,
                nodes[ i ].IP,
                node_info.DO_count, node_info.DI_count,
                node_info.AO_count, node_info.AI_count )

            for j = 1, node_info.AO_count do
                G_WAGO_MANAGER():init_node_AO( i - 1, j - 1,
                    node_info.AO[ j ][ 1 ], node_info.AO[ j ][ 2 ] )
            end

            for j = 1, node_info.AI_count do
                G_WAGO_MANAGER():init_node_AI( i - 1, j - 1,
                    node_info.AI[ j ][ 1 ], node_info.AI[ j ][ 2 ] )
            end
        end
    end,

    init_devices = function()
        local devices_count = #devices

        for i = 1, devices_count do

            local device = devices[ i ]

            local wago_device = G_DEVICE_MANAGER():add_wago_device(
                device.dtype, device.subtype, device.number,
                device.descr )

            if wago_device ~= nil then --Устройство имеет модули Wago.

                local DI_channels = 0
                local DO_channels = 0
                local AI_channels = 0
                local AO_channels = 0
                local par_count   = 0

                if device.DI ~= nil then
                    DI_channels = #device.DI
                end
                if device.DO ~= nil then
                    DO_channels = #device.DO
                end
                if device.AI ~= nil then
                    AI_channels = #device.AI
                end
                if device.AO ~= nil then
                    AO_channels = #device.AO
                end
                if device.par ~= nil then
                    par_count = #device.par
                end

                wago_device:init( DO_channels, DI_channels,
                    AO_channels, AI_channels, par_count )

                for j = 1, DI_channels do
                    wago_device:init_channel( 1, j - 1,
                        device.DI[ j ].node, device.DI[ j ].offset )
                end
                for j = 1, DO_channels do
                    wago_device:init_channel( 2, j - 1,
                        device.DO[ j ].node, device.DO[ j ].offset )
                end
                for j = 1, AI_channels do
                    wago_device:init_channel( 3, j - 1,
                        device.AI[ j ].node, device.AI[ j ].offset )
                end
                for j = 1, AO_channels do
                    wago_device:init_channel( 4, j - 1,
                        device.AO[ j ].node, device.AO[ j ].offset )
                end

                for j = 1, par_count do
                    wago_device:init_par( j - 1, device.par[ j ] )
                end

            end --if wago_device ~= nil then --Устройство имеет модули Wago.
        end --for i = 1, devices_count do
    end,

	init_tech_dev_modes = function()

        local get_dev_type = function( dev_name )
            local dev_type = -1
            if     dev_name == 'V'   then dev_type = device.DT_V
            elseif dev_name == 'N'   then dev_type = device.DT_N
            elseif dev_name == 'FB'  then dev_type = device.DT_FB
            elseif dev_name == 'UPR' then dev_type = device.DT_UPR
            else print( "Error - unknown device type - ", dev_name  )
            end

            return dev_type
        end

		local add_seat_devices = function( v, mode, step, seat_state )

		    if v ~= nil then

                local DEV_TYPE = get_dev_type( 'V' )

                for field, value in pairs( v ) do

					--Добавляем группу.
                    local group = modes_manager:add_wash_seats_valves_group(
                        mode, step, seat_state )

                    for field, value in ipairs( value ) do

						local dev = G_DEVICE_MANAGER():get_device(
							DEV_TYPE, value )

                        modes_manager:add_wash_seat_valve( mode, step, group,
							dev )

                    end
                end
            end
		end

		for fields, value in ipairs( init_tech_objects_modes() ) do
			local object_n = value.n - 1
			local object   = G_TECH_OBJECT_MNGR():get_tech_objects( object_n )

			local modes_manager = object:get_modes_manager()

			for fields, value in ipairs( value.modes ) do

                local mode	  = fields - 1

                if value.opened_devices ~= nil then

                    for field, value in pairs( value.opened_devices ) do

                        local dev_type = get_dev_type( field )

                        for field, value in ipairs( value ) do
                            local dev = G_DEVICE_MANAGER():get_device(
                                dev_type, value )

                            modes_manager:add_mode_opened_dev(
                                mode, dev )
                        end
                    end
                end

                if value.closed_devices ~= nil then
                    for field, value in pairs( value.closed_devices ) do
                        local dev_type = get_dev_type( field )

                        for field, value in ipairs( value ) do
                            local dev = G_DEVICE_MANAGER():get_device(
                                dev_type, value )

                            modes_manager:add_mode_closed_dev(
                                mode, dev )
                        end
                    end
                end


                if value.opened_upper_seat_v ~= nil then
					add_seat_devices( opened_upper_seat_v, mode, 0,
						i_mix_proof.ST_UPPER_SEAT )
                end

                if value.opened_lower_seat_v ~= nil then
					add_seat_devices( opened_lower_seat_v, mode, 0,
						i_mix_proof.ST_LOWER_SEAT )
                end


                if value.required_FB ~= nil then
                    for field, value in pairs( value.required_FB ) do
                        local dev_type = get_dev_type( field )

                        for field, value in ipairs( value ) do
                            local dev = G_DEVICE_MANAGER():get_device(
                                dev_type, value )

                            modes_manager:add_mode_on_FB(
                                mode, dev )
                        end
                    end
                end

                if value.pair_dev ~= nil then
                    local fb_dev_type = get_dev_type( 'FB' )
                    local control_signal_dev_type = get_dev_type( 'UPR' )

                    for field, value in pairs( value.pair_dev ) do
                        local group = value

                        local fb_dev = G_DEVICE_MANAGER():get_device(
                            fb_dev_type, group[ 1 ] )

                        local n = modes_manager:add_mode_FB_group(
                                mode, fb_dev )

                        local upr_dev = G_DEVICE_MANAGER():get_device(
                            control_signal_dev_type, group[ 2 ] )

                        modes_manager:add_mode_pair_dev( mode, n, upr_dev )

                    end
                end

                if value.steps ~= nil then
                    local steps_count = #value.steps
                    modes_manager:set_mode_config( mode, steps_count )

                    for fields, value in ipairs( value.steps ) do
                        local step = fields - 1

                        if value.opened_devices ~= nil then
                            for field, value in pairs( value.opened_devices ) do

                                local dev_type = get_dev_type( field )

                                for field, value in ipairs( value ) do
                                    local dev = G_DEVICE_MANAGER():get_device(
                                        dev_type, value )

                                    modes_manager:add_opened_dev(
                                        mode, step, dev )
                                end
                            end
                        end

                        if value.closed_devices ~= nil then
                            for field, value in pairs( value.closed_devices ) do
                                local dev_type = get_dev_type( field )

                                for field, value in ipairs( value ) do
                                    local dev = G_DEVICE_MANAGER():get_device(
                                        dev_type, value )

                                    modes_manager:add_closed_dev(
                                        mode, step, dev )
                                end
                            end
                        end


						if value.opened_upper_seat_v ~= nil then
							add_seat_devices( value.opened_upper_seat_v, mode,
								step, i_mix_proof.ST_UPPER_SEAT )
						end

						if value.opened_lower_seat_v ~= nil then
							add_seat_devices( value.opened_lower_seat_v, mode,
								step, i_mix_proof.ST_LOWER_SEAT )
						end

                    end --for fields, value in ipairs( value.steps ) do
				end --if value.steps ~= nil then

                --print( 'end steps' )

			end --for fields, value in ipairs( value.modes ) do
		end --for fields, value in ipairs( tech_objects ) do

		return 0
	end,
    }
