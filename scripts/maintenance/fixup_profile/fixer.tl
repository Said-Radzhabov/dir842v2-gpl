local JSON = require("dlink.jansson")

--- Класс для реализации логики обновления профиля/конфигов
--- На каждый существующий профиль создается новый экземпляр этого класса, заполняется информация о профиле.
--- В первую очередь вызывается метод `pre`. Если он задан И возвращает false или nil, то для этого профиля обработка прекращается.
--- Затем для каждого режима работы вызывается `reconfig` с указанием этого режима работы и соответствующего дефконфига.
--- Метод может изменять JSON как ему угодно, после завершения метода все изменения будут сохранены.
--- Затем вызывается метод `reprofile`, который может изменить конфигурацию профиля.
local record Fixer
    --- Режимы работы устройства
    enum DeviceMode
        'dir'
        'dap'
        'firewall'
        'switch'
    end


    --- Имя профиля
    name: string

    --- Данные профиля
    profile: {string: boolean|string|integer}

    --- Метод для подготовки к обработке нового профиля.
    --- В этом методе можно заранее посмотреть какие-то данные, рассчитать, сохранить локально.
    --- Если этот метод задан и возвращает false, то профиль будет пропущен.
    ---
    --- @retval true  - обработка продолжается
    --- @retval false - обработка заканчивается, переход к следующему профилю
    pre: function(self: Fixer): boolean

    --- Метод для обновления конфига (${MODE}_config.default)
    --- Запускается для каждого режима работы.
    --- Конфиг выдается "как есть", с ним можно производить любые операции.
    --- Затем измененный объект конфига будет записан обратно в файл.
    ---
    --- @param mode:   режим работы (dir, dap, firewall, switch)
    --- @param config: дефконфиг для этого режима работы
    reconfig: function(self: Fixer, mode: DeviceMode, config: JSON)

    --- Метод для обновления профиля
    --- Метод может вернуть таблицу с парами "ключ-значение", которые будут дозаписаны в профиль устройства.
    --- Чтобы убрать значение опции из профиля, нужно выставить ей значение `false`.
    --- Пример: return {BR2_DAP_MODE = false, BR2_LAN_PORTS_COUNT = 5}
    ---
    --- @retval набор изменений профиля
    reprofile: function(self: Fixer): {string: boolean|string|integer}
end

function Fixer:pre(): boolean
    -- дефолтное поведение - обработать все профили
    return true
end

function Fixer:reconfig(_mode: string, _config: JSON)
end

function Fixer:reprofile(): {string: boolean|string|integer}
end

-- Обертки для безопасного вызова
function Fixer:try_pre(): boolean, boolean
    return pcall(function(): boolean return self:pre() end)
end

function Fixer:try_reconfig(mode: string, config: JSON): boolean
    return pcall(function() self:reconfig(mode, config) end)
end

function Fixer:try_reprofile(): boolean, {string: boolean|string|integer}
    return pcall(function(): {string: boolean|string|integer} return self:reprofile() end)
end


-- API

--- Удаляет путь из конфига с удалением получившихся пустых объектов
function Fixer.remove_path(node: JSON, path: string)
    local record KV
        key: string
        parent: JSON
    end

    local subnodes: {KV} = {}

    for token in path:gmatch("[^.]+") do
        table.insert(subnodes, 1, {key = token, parent = node})
        node = node:get(token) as JSON

        if not JSON.typeof(node):match('json.')  then
            break
        end
    end

    for _, kv in ipairs(subnodes) do
        kv.parent:set(kv.key, nil) -- remove

        if kv.parent:size() > 0 then
            break
        end
    end
end

return Fixer
