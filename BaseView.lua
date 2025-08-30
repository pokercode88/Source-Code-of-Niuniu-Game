-- @Author: ZhuL
-- @Date:   2017-05-18 15:08:34
-- @Last Modified by:   ZhuL
-- @Last Modified time: 2017-06-01 14:57:03


local UIer = require_ex("ui.common.UIer")
local M = class("BaseView" , UIer)

function M:ctor()
    UIer.ctor(self)
end

function M:bindTitle(widget)
    if widget.bullTitle == nil then
        widget.bullTitle = createCsbNode("subgame/Niuniu/bullTitle.csb")
        self:addChild(widget.bullTitle)
    end

    -- 命名避免冲突
    local tab = {
        ["panelHead/cbPack"] = {key = "__cm_cbPack"},
        ["panelHead/cbPack/panel/child1"] = {key = "__cm_btnExit" , handle = handler(self , self.onClose)},
        ["panelHead/cbPack/panel/child2"] = {key = "__cm_btnTrans" , handle = handler(self , self.onTrans)},
        ["panelHead/cbPack/panel/child3"] = {key = "__cm_btnSetting" , handle = handler(self , self.onSetting)},
        ["panelHead/btn1"] = {key = "btnRcg" , handle = handler(self , self.onRecharge)},
        ["panelHead/btn2"] = {key = "btnRedPack" , handle = handler(self , self.onRedPack)},
        ["panelHead/btn3"] = {key = "btnRanking" , handle = handler(self , self.onRanking)},
        ["panelHead/btn4"] = {key = "btnHelp" , handle = handler(self , self.onHelp)},
        ["panelHead/btn5"] = {key = "btnChat" , handle = handler(self , self.onChat)},
    }
    bindWidgetList(widget.bullTitle , tab , widget)
    widget.__cm_cbPack:setAutoHideBg(true)
    widget.__cm_cbPack:addPackAttr()
    self:addChatView()
end

function M:addChatView()
    local chatView = require_ex("games.niuniu.views.ChatView").new()
    self:addChild(chatView)
    self.__chatView = chatView
end

function M:onTrans(sender , event)
    -- body
end

function M:onSetting(sender , event)
    Game.settingCom:openSettingUi()
end

function M:onRecharge(sender , event)
    Game.rechargeCom:openRechargeView()
end

function M:onRedPack(sender , event)
    -- body
end

function M:onRanking(sender , event)
    -- body
end

function M:onHelp(sender , event)
    -- body
end

function M:onChat(sender , event)
    self:openChatView()
end

return M