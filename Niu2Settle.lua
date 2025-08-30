-- @Author: ZhuL
-- @Date:   2017-05-23 18:08:51
-- @Last Modified by:   ZhuL
-- @Last Modified time: 2017-06-16 11:17:08

local UIer = require_ex("ui.common.UIer")
local M = class("Niu2Settle" , UIer)

function M:ctor(ctrler , data , cb)
    UIer.ctor(self)

    self._ctrler = ctrler

    self._DB = ctrler:getDB()

    self._root = nil

    self._widget = {}

    self:init()

    execute(cb)

    self:runAction(cc.Sequence:create(cc.DelayTime:create(5) , cc.RemoveSelf:create()))
end

function M:init()
    self:initWidget()
    self:initView()
end

function M:onTouchEnded()
    self:destroy()
end

function M:initWidget()
    self._root = createCsbNode("subgame/Niu2/bullResult2.csb")
    local tab = {
        ["panel"] = {key = "panel"},
        ["panel/pointAnim1"] = {
            key = "pointAnim1",
            spine = {
                res = "subgame/Niu2/spine/result/win/nn_win",
                anim = {"1" , "2"},
                bLastLoop = true
            }
        },
        ["panel/pointAnim2"] = {
            key = "pointAnim2",
            spine = {
                res = "subgame/Niu2/spine/result/fail/nn_fail",
                anim = {"1" , "2"},
                bLastLoop = true
            }
        },
        ["panel/panel1"] = {key = "panel1"},
        ["panel/panel2"] = {key = "panel2"},
        ["panel/panel1/panelPoker"] = {key = "panelPoker1"},
        ["panel/panel2/panelPoker"] = {key = "panelPoker2"},
    }
    self:addChild(self._root)
    bindWidgetList(self._root , tab , self._widget)
    local widget = self._widget
    clonePoker(widget.panelPoker1)
    clonePoker(widget.panelPoker2)

    self:addTouchListener(true)
end

local RED = common_util.colorFromString("#F3603F")
local GREEN = common_util.colorFromString("#4CDD38")

function M:initSeat(panel , data)
    local panelPoker = panel:getChildByName("panelPoker")
    showPokerLst(panelPoker , data.cards)
    local txtCoin = panel:getChildByName("txtCoin")
    local factor = data.bWin and 1 or -1
    data.settleCoin = data.settleCoin or 0
    local banker = self._DB:getBanker()
    local num = factor * data.settleCoin
    dump(num)
    if num > 0 then
        txtCoin:setTextColor(RED)
    else
        txtCoin:setTextColor(GREEN)
    end
    num = num > 0 and "+" .. num or num
    txtCoin:setString(num)
    panel:getChildByName("txtName"):setString(data.name)
    panel:getChildByName("imgBanker"):setVisible(data.player_id == banker)
end

function M:initView()
    local widget = self._widget
    local myData = self._DB:getMyData()
    local cmpData = self._DB:getComptitorData()
    print("-------------sdb-------------------")
    dump(self._DB:getBanker())
    dump(myData)
    dump(cmpData)
    widget.pointAnim1:setVisible(myData.bWin)
    widget.pointAnim2:setVisible(not myData.bWin)
    playNiuSound(myData.bWin and "DoubleBullResultUI>win" or "DoubleBullResultUI>lose")
    self:initSeat(widget.panel1 , cmpData)
    self:initSeat(widget.panel2 , myData)
end

return M