/*
    Mango - Open Source M2M - http://mango.serotoninsoftware.com
    Copyright (C) 2006-2011 Serotonin Software Technologies Inc.
    @author Matthew Lohbihler
    
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

mango.view = {};
mango.view.graphic = {};

mango.view.setEditing = false;
mango.view.setEditingContent = null;

mango.view.customCaernView = function()
{
    //MiscDwr.terminateLongPoll(mango.longPoll.pollSessionId);
    var array = "";
    var custom = false;
    jQuery('.custom').each(function(i, obj)
    {
        if(!jQuery(this).attr('var'))
        {
            var newClass = jQuery(this).attr("class").split(' ')[2].toString();
            if(newClass != 'custom' && newClass != 'null')
                array += newClass + ",";
            custom = true;    
        }
        else
        {
            if(jQuery(this).attr("var").split(' ')[0].toString() == "1")
            {
                var newClass = jQuery(this).attr("class").split(' ')[2].toString();
                if(newClass != 'custom' && newClass != 'null')
                    array += newClass + ",";
                custom = true;
            }
        }

        if(jQuery(this).attr("class").split(' ')[3] == "vazao-pressao")
        {
            array += jQuery(this).attr("class").split(' ')[4] + ",";
        }
        
    });    

    console.log(array);
    if(custom == true)
    {   
        mango.longPoll.pollRequest.arrayCustomCaern = array;
        mango.longPoll.pollRequest.customCaern = true;
    }
    else
    {
        mango.longPoll.pollRequest.customCaern = false;   
    }
    
    if (dojo.render.html.ie)
        mango.header.evtVisualizer = new IEBlinker($("__header__alarmLevelDiv"), 500, 200);
    else
        mango.header.evtVisualizer = new ImageFader($("__header__alarmLevelDiv"), 75, .2);

    mango.longPoll.start();
    //MiscDwr.initializeLongPoll(mango.longPoll.pollSessionId, mango.longPoll.pollRequest, mango.longPoll.pollCB);
}

function timeDifference(date1,date2) 
{
    var difference = (date1 - date2)-2000000;

    var secondsDifference = Math.floor(difference/1000);
    var minutesDifference = Math.floor(difference/1000/60);
    var hoursDifference = Math.floor(difference/1000/60/60);

    if(difference > (24*60*60*1000))
    {
        if (Math.floor(difference/(24*60*60*1000)) > 1)
            return "+ " + Math.floor(difference/(24*60*60*1000)) + " dias";
        else
            return "+ " + Math.floor(difference/(24*60*60*1000)) + " dia";
    }

    if(difference < 0)
    {
        return "0:00";
    }   
    else
    {
        var texto = "" + hoursDifference;
        if( (minutesDifference%60)<10 )
            texto += ":0" + minutesDifference%60;
        else
            texto += ":" + minutesDifference%60;

        if((secondsDifference%60)<10)
            return texto + ":0" + secondsDifference%60;
        else
            return texto + ":" + secondsDifference%60;
        

    }

}

mango.view.caernTimes = function(timesArr)
{
    for (var i=0; i<timesArr.length; i++) 
    {
        var id = timesArr[i].split(',')[0];
        var date = timesArr[i].split(',')[1];

        var date_now = Date.now();
        
        diferenca = date_now - date;

        //if(id == 'DP_026144')
        //    console.log(diferenca);

        if(jQuery('.'+id).attr("class").split(' ')[0].toString() == 'list-group-item' &&
            jQuery('.'+id).attr("class").split(' ')[3].toString() == 'status-link')
        {
            if(!(jQuery('.'+id).attr("class").split(' ')[4].toString() == 'verde'))
            {
                var texto = jQuery('.'+id).html().split("<br>")[0];
                texto += "<br>" + timeDifference(date_now, date);
                jQuery('.' + id).html(texto);   
            }
            else
            {
                var texto = jQuery('.'+id).html().split("<br>")[0];
                texto += "<br>" + "0:00";
                jQuery('.' + id).html(texto);   
            }
            
        }

    }
}

function acionamento(xid,tipoAcionamento,varElemento,valorElemento,xidAcionamento)
{
    var combinacoes = [0b00000000, 0b00000001, 0b00000010, 0b00000100, 0b00001000, 0b00010000,
                       0b00100000, 0b01000000, 0b10000000];

    //var valor = valorElemento;
    //LIGA BOMBA
    if(tipoAcionamento)
    {
        valorElemento = valorElemento | combinacoes[varElemento];
    }
    else
    {
        valorElemento = valorElemento & ~(combinacoes[varElemento]);
    }

    MiscDwr.setPointValue(xidAcionamento, valorElemento);
    jQuery('.botao_'+xid+"_"+varElemento).attr("onclick", "");
    //Timeout com nova função (5s)
    setTimeout(function() {MiscDwr.pointReadValue(xid);}, 20000);
    //setTimeout(function(){ alert("Hello"); }, 10000);
}

mango.view.setCaernView = function(stateArr)
{
    var srcLink = window.location.href;
    var ip = "http://"+srcLink.split('/')[2];

    var bombaDesligada = ip+"/scadalts/images/bomba-vermelha.png";
    var bombaLigada = ip+"/scadalts/images/bomba-azul.png";
    var motorVerticalLigado = ip+"/scadalts/images/motor-vertical-azul.png";
    var motorVerticalDesligado = ip+"/scadalts/images/motor-vertical-vermelho.png";
    var botaoLiga = ip+"/scadalts/images/botao_liga.svg";
    var botaoDesliga = ip+"/scadalts/images/botao_desliga.svg";

    var combinacoes = [0b00000000, 0b00000001, 0b00000010, 0b00000100, 0b00001000, 0b00010000,
                       0b00100000, 0b01000000, 0b10000000];

    var state;
    for (var i=0; i<stateArr.length; i++) 
    {
        state = stateArr[i];
        //Atualiza status de link
        if(jQuery('.'+state.id).attr("class").split(' ')[0].toString() == 'list-group-item' &&
            jQuery('.'+state.id).attr("class").split(' ')[3].toString() == 'status-link')
        {
            var texto = jQuery('.'+state.id).html().split("<br>")[0];
            jQuery('.'+state.id).removeClass("verde");
            jQuery('.'+state.id).removeClass("vermelho");

            if(state.value == "0")
                jQuery('.'+state.id).addClass("vermelho");
            if(state.value == "1")
                jQuery('.'+state.id).addClass("verde");

            var date = state.time;
            var date_now = Date.now();
            
            diferenca = date_now - date;

            if(jQuery('.'+state.id).attr("class").split(' ')[4].toString() == 'vermelho')
            {
                texto += "<br>" + timeDifference(date_now, date);
                jQuery('.'+state.id).html(texto);   
            }
            else
            {
                texto += "<br>0:00";
                jQuery('.'+state.id).html(texto);   
            }
            
        }

        //Atualiza status de LR
        if(jQuery('.'+state.id).attr("class").split(' ')[0].toString() == 'list-group-item' &&
            jQuery('.'+state.id).attr("class").split(' ')[3].toString() == 'status-LR')
        {
            jQuery('.'+state.id).removeClass("vermelho");
            jQuery('.'+state.id).removeClass("verde");

            if(state.value == "0")
                jQuery('.'+state.id).addClass("vermelho");
            if(state.value == "1")
                jQuery('.'+state.id).addClass("verde");

        }

        if(jQuery('.'+state.id).attr("class").split(' ')[0].toString() == 'LR')
        {
            jQuery('.'+state.id).removeClass("local");
            jQuery('.'+state.id).removeClass("remoto");

            if(state.value == "0")
            {
                jQuery('.'+state.id).addClass("local");
                jQuery('.'+state.id).html("|L|");
            }
            if(state.value == "1")
            {
                jQuery('.'+state.id).addClass("remoto");
                jQuery('.'+state.id).html("|R|");
            }
        }

        //Atualiza elementos de bombas e motor-vertical
        if(jQuery('.'+state.id).attr("class").split(' ')[0].toString() == 'elemento')
        {
            jQuery('.'+state.id).each(function(i, obj)
            {
                var aux = parseInt(jQuery(this).attr('var'));
                if(state.value & combinacoes[aux])
                {
                    if(jQuery(this).attr("class").split(' ')[3].toString() == 'bomba')
                        jQuery(this).attr("src", bombaLigada);

                    if(jQuery(this).attr("class").split(' ')[3].toString() == 'motor-vertical')
                        jQuery(this).attr("src", motorVerticalLigado);

                    jQuery('.botao_'+state.id+"_"+aux).attr("src", botaoDesliga);
                    var acionamento = jQuery('.botao_'+state.id+"_"+aux).attr("class").split(' ')[2].toString();
                    console.log('.botao_'+state.id+"_"+aux);
                    jQuery('.botao_'+state.id+"_"+aux).attr("onclick", "acionamento('"+state.id+"',false,'"+aux+"',"+state.value+",'" + acionamento + "')");
                }
                else
                {
                    
                    if(jQuery(this).attr("class").split(' ')[3].toString() == 'bomba')
                        jQuery(this).attr("src", bombaDesligada);

                    if(jQuery(this).attr("class").split(' ')[3].toString() == 'motor-vertical')
                        jQuery(this).attr("src", motorVerticalDesligado);

                    jQuery('.botao_'+state.id+"_"+aux).attr("src", botaoLiga);
                    console.log('.botao_'+state.id+"_"+aux);
                    var acionamento = jQuery('.botao_'+state.id+"_"+aux).attr("class").split(' ')[2].toString();
                    jQuery('.botao_'+state.id+"_"+aux).attr("onclick", "acionamento('"+state.id+"',true,'"+aux+"',"+state.value+",'" + acionamento + "')");
                }    
            });
        }
        
        //Atualiza os reservatórios
        if(jQuery('.'+state.id).attr("class").split(' ')[0].toString() == 'reservatorio')
        {
            //console.log(state.value);
            var valorState = state.value;

            if(valorState < 0)
                valorState = 0;
            if(valorState > 100)
                valorState = 100;

            var texto = "";
            var link = ip+"/scadalts";
            var setPoint = jQuery('.'+state.id).attr("class").split(' ')[1].toString();
            texto += "<div style='position:relative; top:0px; left:0px;'>";
            texto += "<img style='position:absolute; top:0px; left:0px;' src='"+link+"/images/tank"+
                        parseInt(valorState/10)+".png' border=0>";
            texto += "<div style='position:absolute; top:20px; left:148px;'><b>" + Math.floor(valorState) + "%</b></div>";
            //texto += "<div style='position:relative; top:0px; left:0px;'>";
            texto += "<img style='position:absolute; top:0px; left:0px;' src='"+link+"/images/setpoints/setpoint"+setPoint+".png'></div>";
            jQuery('.'+state.id).html("");
            jQuery('.'+state.id).html(texto);
        }

        //Atualiza os valores de pressão/vazão
        if(jQuery('.'+state.id).attr("class").split(' ')[0].toString() == 'list-group-item' &&
            jQuery('.'+state.id).attr("class").split(' ')[3].toString() == 'vazao-pressao')
        {
            var texto = jQuery('.'+state.id).html().split("<br>")[0];
            
            if(state.id == jQuery('.'+state.id).attr("class").split(' ')[2].toString())
            {
                texto += "<br>V: " + state.value;
                texto += "<br>P: " + jQuery('.'+state.id).html().split("<br>")[2];
            }

            if(state.id == jQuery('.'+state.id).attr("class").split(' ')[4].toString())
            {
                texto += "<br>V: " + jQuery('.'+state.id).html().split("<br>")[1];
                texto += "<br>P: " + state.value;
            }
        }

        //Atualiza os valores de Pressão / Vazão
        if(jQuery('.'+state.id).attr("class").split(' ')[0].toString() == 'vazao')
        {
            var texto = "";
            texto += "<b>Vazão: " + parseFloat(state.value).toFixed(2) + 
            jQuery('.'+state.id).attr("class").split(' ')[3].toString() + " </b>";
            
            jQuery('.'+state.id).html(texto);
        }
        if(jQuery('.'+state.id).attr("class").split(' ')[0].toString() == 'pressao')
        {
            var texto = "";
            texto += "<b>Pressão: " + parseFloat(state.value).toFixed(2) + 
            jQuery('.'+state.id).attr("class").split(' ')[3].toString() + " </b>";

            jQuery('.'+state.id).html(texto);
        }
        if(jQuery('.'+state.id).attr("class").split(' ')[0].toString() == 'vazao-exploracao')
        {
            var texto = "";
            texto += "<b>Pressão: " + parseFloat(state.value).toFixed(2) + 
            jQuery('.'+state.id).attr("class").split(' ')[3].toString() + " </b>";

            jQuery('.'+state.id).html(texto);
        }
    }
    
}

mango.view.setData = function(stateArr) {
    var state;
    for (var i=0; i<stateArr.length; i++) {
        state = stateArr[i];
        
        // Check that the point exists. Ignore if it doesn't.
        if (!$("c"+ state.id))
            throw "Can't find point view c"+ state.id;
        
        mango.view.setContent(state);
        
        if ($("c"+ state.id +"Controls")) {
            if (state.info != null)
                $set("c"+ state.id +"Info", state.info);
            if (state.change != null) {
                if (state.change) 
                    show("c"+ state.id +"ChangeMin");
                
                if (mango.view.setEditing)
                    // If the set value is being edited, save the content
                    mango.view.setEditingContent = state.change;
                else
                    $set("c"+ state.id +"Change", state.change);
            }
            if (state.chart != null) {
                 $set("c"+ state.id +"Chart", state.chart);
            }
         


        }
        
        mango.view.setMessages(state);
        mango.view.setChartData(state);
    }
};

mango.view.setMessages = function(state) {
    var warningNode = $("c"+ state.id +"Warning");
    if (warningNode && state.messages != null) {
        $set("c"+ state.id +"Messages", state.messages);
        if (state.messages)
            show(warningNode);
        else
            hide(warningNode);
    }
};

mango.view.setContent = function(state) {
    if (state.content != null) {
        var comp = $("c"+ state.id +"Content");
        //lastImage = comp.childNodes[0].src;
        
        //state.content = <img src="chart/1297885565049_60000_3_w500_h300.png" alt="Gráfico"/>
        //comp.innerHTML = state.content;   
        if(state.graph && comp.childNodes[0]) {
            newImageSrc = extractSrcAttribute(state.content);
            comp.childNodes[0].src = newImageSrc;
        } else {
            comp.innerHTML = state.content;
        }
        
        var dyn = $("dyn"+ state.id);
        if (dyn) {
            eval("var data = "+ dyn.value);
            if (data.graphic != '')
                eval("mango.view.graphic."+ data.graphic +".setValue("+ state.id +", "+ data.value +");");
        }
        
        // Look for scripts in the content.
        mango.view.runScripts(comp);
    }
};

function extractSrcAttribute(string) {
    string = string.replace("<img ","");
    string = string.replace(string.match("alt=.*"),"");
    string = string.replace("src=\"","");
    return string.replace("\"","");
}

mango.view.runScripts = function(node) { 
    var arr = [];
    mango.view.findScripts(node, arr);
    for (var i=0; i<arr.length; i++)
    {
        eval(arr[i]);
        console.log(arr[i]);
    }
}

mango.view.findScripts = function(node, arr) {
    for (var i=0; i<node.childNodes.length; i++) {
        var child = node.childNodes[i];
        if (child.tagName == "SCRIPT")
            arr.push(child.innerHTML);
        mango.view.findScripts(child, arr);
    }
}


mango.view.showChange = function(divId, xoffset, yoffset) {
    mango.view.setEditing = true;
    var theDiv = $(divId);
    showMenu(theDiv, xoffset, yoffset);
    
    // Automatically select the text in text boxes
    var inputElems = theDiv.getElementsByTagName("input");
    for (var i=0; i<inputElems.length; i++) {
        if (inputElems[i].id.startsWith("txtChange")) {
            var temp = inputElems[i].value;
            inputElems[i].value += " ";
            inputElems[i].value = temp;
            inputElems[i].select();
        }
    }
};

mango.view.hideChange = function(divId) {
    if ($(divId))
        hideLayer($(divId));
    mango.view.setEditing = false;
    if (mango.view.setEditingContent != null) {
        $set(divId, mango.view.setEditingContent);
        mango.view.setEditingContent = null;
    }
};

mango.view.showChart = function(componentId, event, source) {
    if (isMouseLeaveOrEnter(event, source)) {
        // Take the data in the chart textarea and put it into the chart layer div
        $set('c'+ componentId +'ChartLayer', $get('c'+ componentId +'Chart'));
        showMenu('c'+ componentId +'ChartLayer', 16, 0);
    }
}

mango.view.hideChart = function(componentId, event, source) {
    if (isMouseLeaveOrEnter(event, source))
        hideLayer('c'+ componentId +'ChartLayer');
}

function vcOver(base, amt) {
    if (!amt)
        amt = 10;
    setZIndex(base, amt);
    showLayer(base + 'Controls');
};

function vcOut(base) {
    setZIndex(base, 0);
    hideLayer(base +'Controls');
};


//
// Anonymous views
mango.view.initAnonymousView = function(viewId) {
    mango.view.setPoint = mango.view.anon.setPoint;
    // Tell the long poll request that we're interested in anonymous view data, and not max alarm.
    mango.longPoll.pollRequest.maxAlarm = false;
    mango.longPoll.pollRequest.anonViewId = viewId;
    mango.view.anon.viewId = viewId;
};

mango.view.anon = {};
mango.view.anon.setPoint = function(pointId, viewComponentId, value) {
    show("c"+ viewComponentId +"Changing");
    mango.view.hideChange("c"+ viewComponentId +"Change");
    ViewDwr.setViewPointAnon(mango.view.anon.viewId, viewComponentId, value, function(viewComponentId) {
        hide("c"+ viewComponentId +"Changing");
        MiscDwr.notifyLongPoll(mango.longPoll.pollSessionId);
    });
};


//
// Normal views
mango.view.initNormalView = function() 
{
    mango.view.setPoint = mango.view.norm.setPoint;
    // Tell the long poll request that we're interested in view data.
    mango.longPoll.pollRequest.view = true;
    
    //Chama a função modificada para caern para reconhecer os DS
    jQuery(document).ready(function()
    {
        //jQuery("#c1").addClass("col-md-12");
        mango.view.customCaernView();
    });



};

mango.view.norm = {};
mango.view.norm.setPoint = function(pointId, viewComponentId, value) {
    show("c"+ viewComponentId +"Changing");
    mango.view.hideChange("c"+ viewComponentId +"Change");
    ViewDwr.setViewPoint(viewComponentId, value, function(viewComponentId) {
        hide("c"+ viewComponentId +"Changing");
        MiscDwr.notifyLongPoll(mango.longPoll.pollSessionId);
    });
};


//
// View editing
mango.view.initEditView = function() {
    // Tell the long poll request that we're interested in view editing data.
    mango.longPoll.pollRequest.viewEdit = true;
    mango.view.setData = mango.view.edit.setData;
};

mango.view.edit = {};
mango.view.edit.iconize = false;
mango.view.edit.setData = function(stateArr) {
    var state, node;
    for (var i=0; i<stateArr.length; i++) {
        state = stateArr[i];
        
        // Check that the point exists. Ignore if it doesn't.
        if (!$("c"+ state.id))
            continue;
            //throw "Can't find point view c"+ state.id;
        
        if (state.content != null) {
            if (!state.content)
                state.content = "<img src='images/logo_icon.gif'/>";
            
            if (mango.view.edit.iconize)
                $("c"+ state.id).savedState = state;
            else
                mango.view.setContent(state);
        }
        
        if (state.info != null) {
            node = $("c"+ state.id +"Info");
            if (node)
                node.innerHTML = state.info;
        }
        mango.view.setMessages(state);
        mango.view.setChartData(state);
    }
};


//
// Watchlist
mango.view.initWatchlist = function() {
    mango.view.setPoint = mango.view.watchList.setPoint;
    // Tell the long poll request that we're interested in watchlist data.
    mango.longPoll.pollRequest.watchList = true;
};

mango.view.watchList = {};
mango.view.watchList.reset = function() {
    MiscDwr.resetWatchlistState(mango.longPoll.pollSessionId);
};

mango.view.watchList.setPoint = function(pointId, componentId, value) {
    startImageFader("p"+ pointId +"Changing");
    mango.view.hideChange("p"+ pointId +"Change");
    WatchListDwr.setPoint(pointId, componentId, value, function(pointId) {
        stopImageFader("p"+ pointId +"Changing");
        MiscDwr.notifyLongPoll(mango.longPoll.pollSessionId);
    });
};

mango.view.watchList.setData = function(stateArr) {
    for (var i=0; i<stateArr.length; i++)
        mango.view.watchList.setDataImpl(stateArr[i]);
};
    
mango.view.watchList.setDataImpl = function(state) {
    // Check that the point exists. Ignore if it doesn't.
    if (state && $("p"+ state.id)) {
        var node;
        if (state.value != null) {
            node = $("p"+ state.id +"Value");
            node.innerHTML = state.value;
            dojo.html.addClass(node, "viewChangeBkgd");
            setTimeout('mango.view.watchList.safeRemoveClass("'+ node.id +'", "viewChangeBkgd")', 2000);
        }
        
        if (state.time != null) {
            node = $("p"+ state.id +"Time");
            node.innerHTML = state.time;
            dojo.html.addClass(node, "viewChangeBkgd");
            setTimeout('mango.view.watchList.safeRemoveClass("'+ node.id +'", "viewChangeBkgd")', 2000);
        }
        
        if (state.change != null && document.getElementById("p"+ state.id +"ChangeMin") ) {
            show($("p"+ state.id +"ChangeMin"));
            if (!mango.view.setEditing)
                $set("p"+ state.id +"Change", state.change);
        }
        
        if (state.chart != null) {
            show($("p"+ state.id +"ChartMin"));
            $set("p"+ state.id +"Chart", state.chart);
        }
        
        if (state.messages != null)
            $("p"+ state.id +"Messages").innerHTML = state.messages;
        //else
        //    $("p"+ state.id +"Messages").innerHTML = "";
    }
};

mango.view.setChartData = function(state) {
    if(!isBlank(state.data) && typeof dygraphsCharts[state.id] != "undefined") {
            dygraphsCharts[state.id].updateData(state.data);
    }
};

mango.view.watchList.safeRemoveClass = function(nodeId, className) {
    var node = $(nodeId);
    if (node)
        dojo.html.removeClass(node, className);
};


mango.view.executeScript = function(scriptId) {
    ViewDwr.executeScript(scriptId, function(success) {
        if(!success) {
        } 
    });
};

//
// Point details
mango.view.initPointDetails = function() {
    mango.view.setPoint = mango.view.pointDetails.setPoint;
    // Tell the long poll request that we're interested in point details data.
    mango.longPoll.pollRequest.pointDetails = true;
};

mango.view.pointDetails = {};
mango.view.pointDetails.setPoint = function(pointId, componentId, value) {
    startImageFader("pointChanging");
    DataPointDetailsDwr.setPoint(pointId, componentId, value, function(componentId) {
        stopImageFader("pointChanging");
        MiscDwr.notifyLongPoll(mango.longPoll.pollSessionId);
    });
};

mango.view.pointDetails.setData = function(state) {
    if (state.value != null)
        $("pointValue").innerHTML = state.value;
    
    if (state.time != null)
        $("pointValueTime").innerHTML = state.time;
    
    //Apenas caso seja admin
    if (state.change != null && document.getElementById('pointChangeNode')) {
        show($("pointChangeNode"));
        $set("pointChange", state.change);
    }
    
    if (state.messages != null)
        $("pointMessages").innerHTML = state.messages;
};


//
// Custom views
mango.view.initCustomView = function() {
    mango.view.setData = mango.view.custom.setData;
    mango.view.setPoint = mango.view.custom.setPoint;
    // Tell the long poll request that we're interested in custom view data, and not max alarm.
    mango.longPoll.pollRequest.maxAlarm = false;
    mango.longPoll.pollRequest.customView = true;
};

mango.view.custom = {};
mango.view.custom.functions = {};
mango.view.custom.setData = function(stateArr) {
    var node;
    for (var i=0; i<stateArr.length; i++) {
        var func = mango.view.custom.functions["c"+ stateArr[i].id];
        if (func)
            func(stateArr[i].value, new Date(stateArr[i].time));
        else {
            node = $("c"+ stateArr[i].id);
            if (node)
                $set(node, stateArr[i].value);
        }
    }
}

mango.view.custom.setPoint = function(xid, value, callback) {
    CustomViewDwr.setCustomPoint(xid, value, function() {
        if (callback)
            callback();
        MiscDwr.notifyLongPoll(mango.longPoll.pollSessionId);
    });
};

mango.view.teste = function() {
    alert('oi');
    
};

//
// Graphics
mango.view.graphic.transform = function(xa, ya, fx, fy, mx, my, a) {
    for (var i=0; i<xa.length; i++) {
        // Scale
        xa[i] *= fx;
        ya[i] *= fy;
        
        // Rotate
        var point = mango.view.graphic.rotatePoint(xa[i], ya[i], a);
        xa[i] = point.x;
        ya[i] = point.y;
        
        // Translate
        xa[i] += mx;
        ya[i] += my;
    }
};

mango.view.graphic.rotatePoint = function(x, y, a) {
    var point = {};
    var cos = Math.cos(a)
    var sin = Math.sin(a);
    point.x = x*cos - y*sin;
    point.y = x*sin + y*cos;     
    return point;
};

mango.view.graphic.Dial = {};
mango.view.graphic.Dial.setValue = function(viewComponentId, value) {
    var g = new jsGraphics("c"+ viewComponentId +"Content");
    
    g.clear();
    
    var xCenter = 76;
    var yCenter = 77;
    
    var xa = new Array(-3, -1,  1,3,1,-1);
    var ya = new Array( 0,-52,-52,0,3, 3);
    var angle = (value * 2 - 1) * 2.1;
    
    mango.view.graphic.transform(xa, ya, 1, 1, xCenter, yCenter, angle);
    
    g.setColor("#A00000");
    g.fillPolygon(xa, ya);
    
    g.setColor("#202020");
    g.drawPolygon(xa, ya);
    g.drawLine(xCenter, yCenter, xCenter, yCenter);
    g.paint();
};

mango.view.graphic.SmallDial = {};
mango.view.graphic.SmallDial.setValue = function(viewComponentId, value) {
    var g = new jsGraphics("c"+ viewComponentId +"Content");
    
    g.clear();
    
    var xCenter = 38;
    var yCenter = 38;
    
    var xa = new Array(-2,  0,  0,2,1,-1);
    var ya = new Array( 0,-26,-26,0,2, 2);
    var angle = (value * 2 - 1) * 2.1;
    
    mango.view.graphic.transform(xa, ya, 1, 1, xCenter, yCenter, angle);
    
    g.setColor("#A00000");
    g.fillPolygon(xa, ya);
    
    g.setColor("#202020");
    g.drawPolygon(xa, ya);
    g.drawLine(xCenter, yCenter, xCenter, yCenter);
    g.paint();
};

mango.view.graphic.VerticalLevel = {};
mango.view.graphic.VerticalLevel.setValue = function(viewComponentId, value) {
    var g = new jsGraphics("c"+ viewComponentId +"Content");
    
    g.clear();
    
    var maxbars = 24;
    var bars = parseInt(maxbars * value + 0.5);
    var i, max;
    
    // Green
    max = bars > 18 ? 18 : bars;
    g.setColor("#008000");
    for (i=0; i<max; i++)
        g.fillRect(2, 94 - i*4, 16, 3);
    
    // Yellow
    max = bars > 22 ? 22 : bars;
    g.setColor("#E5E500");
    for (i=18; i<max; i++)
        g.fillRect(2, 94 - i*4, 16, 3);
    
    // Red
    max = bars > 24 ? 24 : bars;
    g.setColor("#E50000");
    for (i=22; i<max; i++)
        g.fillRect(2, 94 - i*4, 16, 3);
    
    g.paint();
};

mango.view.graphic.HorizontalLevel = {};
mango.view.graphic.HorizontalLevel.setValue = function(viewComponentId, value) {
    var g = new jsGraphics("c"+ viewComponentId +"Content");
    
    g.clear();
    
    var maxbars = 24;
    var bars = parseInt(maxbars * value + 0.5);
    var i, max;
    
    // Green
    max = bars > 18 ? 18 : bars;
    g.setColor("#008000");
    for (i=0; i<max; i++)
        g.fillRect(2 + i*4, 2, 3, 16);
    
    // Yellow
    max = bars > 22 ? 22 : bars;
    g.setColor("#E5E500");
    for (i=18; i<max; i++)
        g.fillRect(2 + i*4, 2, 3, 16);
    
    // Red
    max = bars > 24 ? 24 : bars;
    g.setColor("#E50000");
    for (i=22; i<max; i++)
        g.fillRect(2 + i*4, 2, 3, 16);
    
    g.paint();
};