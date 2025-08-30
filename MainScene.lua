-- @Author: ZhuL
-- @Date:   2017-05-02 10:17:07
-- @Last Modified by:   ZhuL
-- @Last Modified time: 2017-05-17 15:09:08

local MainScene = class("MainScene", cc.load("mvc").ViewBase)

function MainScene:onCreate()
    -- print(debug.traceback())
    Game.niuCom = require("games.niuniu.models.NiuCom")
    Game.niuDB = require_ex("games.niuniu.models.NiuDB")
    -- local params = {
    --     icon = "gameres/zhaociji/ZhaoCiJi_Button_05.png",
    --     gameid = 4,
    --     version = "1.60.00",
    --     onenter = function (callback)
    --         -- Game.rbDB = require_ex("games.redblack.models.RBDB")
    --         -- Game.rbCom = require_ex("games.redblack.models.RBCom")
    --         -- Game.rbCom:onEnter(callback)
    --     end,
    --     onexit = function ()
    --         -- if Game.rbCom then
    --         --     Game.rbCom:onExit()
    --         -- end
    --     end,
    -- }
    -- Game:addLayer(require("ui.common.GameEntryUI"):new(params))
    Game.niuCom:reqEnterGame()
    -- maskScene(self)
end

function MainScene:exitScene()
    if Game.rbCom and Game.rbCom:getBetUI() then
        Game.rbCom:getBetUI():onBackClicked()
    end
end

function MainScene:toString()
    print("RB Main scene")
end

return MainScene
