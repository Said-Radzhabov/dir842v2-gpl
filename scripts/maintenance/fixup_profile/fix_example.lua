-- Реализуем интерфейс класса Fixer (см scripts/maintenance/fixup_profiles/fixer.tl)
local Fixer = require('fixer')

-- Все три метода опциональны
-- В каждом методе доступен self с полезными данными:
-- - name    - имя устройства
-- - profile - опции профиля


--- Метод для подготовки к обработке нового профиля.
--- В этом методе можно заранее посмотреть какие-то данные, рассчитать, сохранить локально.
--- Если этот метод задан и возвращает false, то профиль будет пропущен.
---
--- @retval true  - обработка продолжается
--- @retval false - обработка заканчивается, переход к следующему профилю
--function Fixer:pre()
    -- Пример - фильтруем все профили, содержащие WW в имени
    -- return self.name:match('_WW') and self.profile.BR2_TELNET_SSH_PROTECT == false

    -- Пример - фильтруем генерики
    -- return self.profile.BR2_DLINK_DEVICE_IS_GENERIC == true
--end




-- Метод для обновления конфига (${MODE}_config.default)
-- Запускается для каждого режима работы.
-- Конфиг выдается "как есть", с ним можно производить любые операции.
-- Затем измененный объект конфига будет записан обратно в файл.
--
-- @param mode:   режим работы (dir, dap, firewall, switch)
-- @param config: дефконфиг для этого режима работы

--function Fixer:reconfig(mode, config)
    -- Пример: удаляем из всех дефконфигов ветку Device.Network.Settings.SIP.Enable, попутно удаляя все получившиеся пустые объекты
    -- Fixer.remove_path(config, "Device.Network.Settings.SIP.Enable")

    -- Пример: включаем Telnet (TODO: сделать отдельную функцию create_path)
    -- config - объект JSON, документация по классу JSON: https://sphinx.rdlab.dlink.ru/lua/lua_confapi.html
    -- local function get_or_create(parent, key)
    --     local value = parent[key]
    --     if not value then
    --         value = {}
    --         parent[key] = value
    --     end
    --     return value
    -- end
    -- local device   = get_or_create(config, 'Device')
    -- local services = get_or_create(device, 'Services')
    -- local telnet   = get_or_create(services, 'Telnet')
    -- telnet.Enable = true
--end





--- Метод для обновления профиля
--- Метод может вернуть таблицу с парами "ключ-значение", которые будут дозаписаны в профиль устройства.
--- Чтобы убрать значение опции из профиля, нужно выставить ей значение `false`.
--- Пример: return {BR2_DAP_MODE = false, BR2_LAN_PORTS_COUNT = 5}
---
--- @retval набор изменений профиля
-- function Fixer:reprofile()
    -- Пример: включаем защиту telnet/ssh
    -- return {
    --     BR2_TELNET_SSH_PROTECT = true,
    -- }

    -- Пример: увеличиваем число разрешенных AccessPoint
    -- return {
    --     BR2_WIFI_HW_FIRST_AP_LIMIT  = self.profile.BR2_WIFI_HW_FIRST_AP_LIMIT + 1,
    --     BR2_WIFI_HW_SECOND_AP_LIMIT = self.profile.BR2_WIFI_HW_SECOND_AP_LIMIT + 1,
    -- }
-- end

return Fixer
