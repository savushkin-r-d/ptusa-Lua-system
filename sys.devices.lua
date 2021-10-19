--version = 2

system = system or {}
-- ----------------------------------------------------------------------------
--Инициализация свойств устройств.
system.init_devices_properties = function( self )
    local devices_count = #devices
    for i = 1, devices_count do
        local descr = devices[ i ]

        --Есть дополнительные свойства.
        if descr.prop then
            local device = G_DEVICE_MANAGER():get_device( descr.dtype, descr.name )

            if device then
                for field, value in pairs( descr.prop ) do
                    if field == "MT" then
                        if value ~= '' then
                            assert( loadstring( "dev = __"..value ) )( )
                            if not dev then
                                error( "init_devices_properties() - unknown device '"..value.."'." )
                            end
                            device:set_property( field, dev )
                        end
                    else
                        device:set_string_property( field, value )
                    end
                end
            end
        end
    end
end
-- ----------------------------------------------------------------------------
--Инициализация параметров устройств.
system.init_devices_params = function( self )
    local devices_count = #devices
    for i = 1, devices_count do
        local descr = devices[ i ]
        local device = G_DEVICE_MANAGER():get_device( descr.dtype, descr.name )

        if device and descr.par then
            local params_count = #descr.par
            for j = 1, params_count do
                device:set_par( j, 0, descr.par[ j ] )
            end

            for key, value in pairs( descr.par ) do
                if type( key ) == "string" then
                    device:set_cmd( key, 0, value )
                end
            end
        end
    end
end
-- ----------------------------------------------------------------------------
--Инициализация рабочих параметров устройств.
system.init_devices_rt_params = function( self )
    local devices_count = #devices
    for i = 1, devices_count do
        local descr = devices[ i ]
        local device = G_DEVICE_MANAGER():get_device( descr.dtype, descr.name )

        if device and descr.rt_par then
            local rt_par_count = #descr.rt_par
            for j = 1, rt_par_count do
                device:set_rt_par( j, descr.rt_par[ j ] )
            end
        end
    end
end
