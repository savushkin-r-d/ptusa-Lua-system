--version = 1

system = system or {}

-- ----------------------------------------------------------------------------
--Инициализация свойств устройств.
system.init_devices_properties = function( self )

    local devices_count = #devices

    for i = 1, devices_count do

        local device_descr = devices[ i ]

        --Есть дополнительные свойства.
        if device_descr.prop ~= nil then

            local device = G_DEVICE_MANAGER():get_device(
                device_descr.dtype, device_descr.number )

            if device ~= nil then

                for field, value in pairs( device_descr.prop ) do
                    assert( loadstring( "dev = _"..value ) )( )
                    if dev == nil then
                        error( "Unknown device '"..value.."'." )
                    end

                    device:set_property( field, dev )
                end
            end
        end --if
    end --for i = 1, devices_count do
end
-- ----------------------------------------------------------------------------
--Инициализация параметров устройств.
system.init_devices_params = function( self )

    local devices_count = #devices

    for i = 1, devices_count do

        local device_descr = devices[ i ]

        local device = G_DEVICE_MANAGER():get_device(
            device_descr.dtype, device_descr.number )

        if device ~= nil then

            local par_count = 0
            if device_descr.par ~= nil then
                par_count = #device_descr.par
            end

            for j = 1, par_count do
                device:set_par( j - 1, 0, device_descr.par[ j ] )
            end

        end --if
    end --for i = 1, devices_count do
end
-- ----------------------------------------------------------------------------
--Получение описания устройства.
system.get_dev_descr = function( self, n )
    if devices[ n ] ~= nil then
        return devices[ n ].descr or ""
    end

    return ""
end
-- ----------------------------------------------------------------------------
--Получение описания устройства.
system.get_dev_name = function( self, n )
    if devices[ n ] ~= nil then
        return devices[ n ].name or ""
    end

    return ""
end