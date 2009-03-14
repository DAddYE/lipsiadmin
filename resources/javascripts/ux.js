//  
//  Created by Davide D'Agostino on 2008-01-19.
//  Copyright 2008 Lipsiasoft s.r.l. All rights reserved.
// 
Ext.util.Format.eurMoney = function(v){
  v = (Math.round((v-0)*100))/100;
  v = (v == Math.floor(v)) ? v + ".00" : ((v*10 == Math.floor(v*10)) ? v + "0" : v);
  return "€" + v ;
};

Ext.util.Format.boolRenderer = function(v, p, record){
  p.css += ' x-grid3-check-col-td'; 
  return '<div class="x-grid3-check-col'+(v?'-on':'')+' x-grid3-cc-'+this.id+'">&#160;</div>';
};

// Tree DropConfig to allow Drop on Leaf
var treeDropConfig = { getDropPoint : function(e, n, dd){ var tn = n.node; if(tn.isRoot){ return tn.allowChildren !== false ? "append" : false; } var dragEl = n.ddel; var t = Ext.lib.Dom.getY(dragEl), b = t + dragEl.offsetHeight; var y = Ext.lib.Event.getPageY(e); var noAppend = tn.allowChildren === false; if(this.appendOnly || tn.parentNode.allowChildren === false){ return noAppend ? false : "append"; } var noBelow = false; if(!this.allowParentInsert){ noBelow = tn.hasChildNodes() && tn.isExpanded(); } var q = (b - t) / (noAppend ? 2 : 3); if(y >= t && y < (t + q)){ return "above"; }else if(!noBelow && (noAppend || y >= b-q && y <= b)){ return "below"; }else{ return "append"; } }, completeDrop : function(de){ var ns = de.dropNode, p = de.point, t = de.target; if(!Ext.isArray(ns)){ ns = [ns]; } var n; for(var i = 0, len = ns.length; i < len; i++){ n = ns[i]; if(p == "above"){ t.parentNode.insertBefore(n, t); }else if(p == "below"){ t.parentNode.insertBefore(n, t.nextSibling); }else{ t.leaf = false; t.appendChild(n); } } n.ui.focus(); if(this.tree.hlDrop){ n.ui.highlight(); } t.ui.endDrop(); this.tree.fireEvent("nodedrop", de); } };

// Fix for Prototype Adapter
Ext.lib.Event.getTarget = function(e){ 
  var ee = e.browserEvent || e; 
  return ee.target ? Event.element(ee) : null;  
};

// CheckBox column
Ext.grid.CheckColumn = function(config){
  Ext.apply(this, config);
  if(!this.id){
    this.id = Ext.id();
  }
  this.renderer = this.renderer.createDelegate(this);
};

Ext.grid.CheckColumn.prototype ={
  init : function(grid){
    this.grid = grid;
    this.grid.on('render', function(){
      var view = this.grid.getView();
      view.mainBody.on('mousedown', this.onMouseDown, this);
      }, this);
  },

  onMouseDown : function(e, t){
    if(t.className && t.className.indexOf('x-grid3-cc-'+this.id) != -1){
      e.stopEvent();
      var index = this.grid.getView().findRowIndex(t);
      var record = this.grid.store.getAt(index);
      var editEvent = {
        grid: this.grid,
        record: this.grid.store.getAt(index),
        field: this.dataIndex,
        value: !record.data[this.dataIndex],
        originalValue: record.data[this.dataIndex],
        row: index,
        column: this.grid.getColumnModel().findColumnIndex(this.dataIndex)
      };
      record.set(this.dataIndex, editEvent.value);
      this.grid.getSelectionModel().selectRow(index);
      this.grid.fireEvent('afteredit', editEvent);
    }
  },

  renderer : function(v, p, record){
    p.css += ' x-grid3-check-col-td'; 
    return '<div class="x-grid3-check-col'+(v?'-on':'')+' x-grid3-cc-'+this.id+'">&#160;</div>';
  }
};

// DateTime Field
Ext.form.DateTimeField = Ext.extend(Ext.form.Field, {
    /**
     * @cfg {String/Object} defaultAutoCreate DomHelper element spec
     * Let superclass to create hidden field instead of textbox. Hidden will be submittend to server
     */
     defaultAutoCreate:{tag:'input', type:'hidden'}
    /**
     * @cfg {Number} timeWidth Width of time field in pixels (defaults to 100)
     */
    ,timeWidth:100
    /**
     * @cfg {Number} dateWidth Width of time field in pixels (defaults to 100)
     */
    ,dateWidth:100
    
    /**
     * @cfg {String} dtSeparator Date - Time separator. Used to split date and time (defaults to ' ' (space))
     */
    ,dtSeparator:' '
    /**
     * @cfg {String} hiddenFormat Format of datetime used to store value in hidden field
     * and submitted to server (defaults to 'Y-m-d H:i:s' that is mysql format)
     */
    ,hiddenFormat:'Y-m-d H:i:s'
    /**
     * @cfg {Boolean} otherToNow Set other field to now() if not explicly filled in (defaults to true)
     */
    ,otherToNow:true
    /**
     * @cfg {Boolean} emptyToNow Set field value to now on attempt to set empty value.
     * If it is true then setValue() sets value of field to current date and time (defaults to false)
     */
    /**
     * @cfg {String} dateFormat Format of DateField. Can be localized. (defaults to 'm/y/d')
     */
    ,dateFormat:'d/m/y'
    /**
     * @cfg {String} timeFormat Format of TimeField. Can be localized. (defaults to 'g:i A')
     */
    ,timeFormat:'H:i'
    /**
     * @cfg {Object} dateConfig Config for DateField constructor.
     */
    ,allowBlank: false
    /**
     * @cfg {Object} true to hide the time, default false.
     */    
    ,hideTime: false
    // {{{
    /**
     * private
     * creates DateField and TimeField and installs the necessary event handlers
     */
    ,initComponent:function() {
        // call parent initComponent
        Ext.form.DateTimeField.superclass.initComponent.call(this);

        // create DateField
        var dateConfig = Ext.apply({}, {
             id:this.id + '-date'
            ,format:this.dateFormat || Ext.form.DateField.prototype.format
            ,width:this.dateWidth
            ,allowBlank:this.allowBlank
            ,selectOnFocus:this.selectOnFocus
            ,listeners:{
                  blur:{scope:this, fn:this.onBlur}
                 ,focus:{scope:this, fn:this.onFocus}
            }
        }, this.dateConfig);
        this.df = new Ext.form.DateField(dateConfig);
        this.df.ownerCt = this;
        delete(this.dateFormat);


        // create TimeField
        var timeConfig = Ext.apply({}, {
             id:this.id + '-time'
            ,format:this.timeFormat || Ext.form.TimeField.prototype.format
            ,allowBlank:this.allowBlank
            ,width:this.timeWidth
            ,selectOnFocus:this.selectOnFocus
            ,listeners:{
                  blur:{scope:this, fn:this.onBlur}
                 ,focus:{scope:this, fn:this.onFocus}
            }
        }, this.timeConfig);
        this.tf = new Ext.form.TimeField(timeConfig);
        this.tf.ownerCt = this;
        delete(this.timeFormat);

        // relay events
        this.relayEvents(this.df, ['focus', 'specialkey', 'invalid', 'valid']);
        this.relayEvents(this.tf, ['focus', 'specialkey', 'invalid', 'valid']);

    } // eo function initComponent
    // }}}
    // {{{
    /**
     * private
     * Renders underlying DateField and TimeField and provides a workaround for side error icon bug
     */
    ,onRender:function(ct, position) {
        // don't run more than once
        if(this.isRendered) {
            return;
        }
        // render underlying hidden field
        Ext.form.DateTimeField.superclass.onRender.call(this, ct, position);

        // render DateField and TimeField
        // create bounding table
        var t;
        var timeStyle = this.hideTime ? 'display:none' : '';
        t = Ext.DomHelper.append(ct, {tag:'table',style:'border-collapse:collapse',children:[
            {tag:'tr',children:[
                {tag:'td',style:'padding-right:17px', cls:'datetime-date'},{tag:'td', cls:'datetime-time', style: timeStyle}
            ]}
        ]}, true);
        this.tableEl = t;

        this.wrap = t.wrap();
        this.wrap.on("mousedown", this.onMouseDown, this, {delay:10});
        // render DateField & TimeField
        this.df.render(t.child('td.datetime-date'));
        this.tf.render(t.child('td.datetime-time'));
        
        this.df.wrap.setStyle({width: this.dateWidth});
        this.tf.wrap.setStyle({width: this.timeWidth});
        
        // workaround for IE trigger misalignment bug
        if(Ext.isIE && Ext.isStrict) {
          t.select('input').applyStyles({top:0});
        }

        this.on('specialkey', this.onSpecialKey, this);
        this.df.el.swallowEvent(['keydown', 'keypress']);
        this.tf.el.swallowEvent(['keydown', 'keypress']);

        // create icon for side invalid errorIcon
        if('side' === this.msgTarget) {
            var elp = this.el.findParent('.x-form-element', 10, true);
            this.errorIcon = elp.createChild({cls:'x-form-invalid-icon'});

            this.df.errorIcon = this.errorIcon;
            this.tf.errorIcon = this.errorIcon;
        }

        // setup name for submit
        if (!this.el.dom.name){
          this.el.dom.name = this.hiddenName || this.name || this.id;
        }

        // prevent helper fields from being submitted
        this.df.el.dom.removeAttribute("name");
        this.tf.el.dom.removeAttribute("name");

        // we're rendered flag
        this.isRendered = true;
        if (this.el.dom.value){
          this.setValue(this.el.dom.value);
        } else {
          this.setValue(new Date());
          this.updateHidden();
        }
    } // eo function onRender
    // }}}
    // {{{
    /**
     * private
     */
    ,adjustSize:Ext.BoxComponent.prototype.adjustSize
    // }}}
    // {{{
    /**
     * private
     */
    ,alignErrorIcon:function() {
        this.errorIcon.alignTo(this.tableEl, 'tl-tr', [2, 0]);
    }
    // }}}
    // {{{
    /**
     * private initializes internal dateValue
     */
    ,initDateValue:function() {
        this.dateValue = this.otherToNow ? new Date() : new Date(1970, 0, 1, 0, 0, 0);
    }
    // }}}
    // {{{
    /**
     * Calls clearInvalid on the DateField and TimeField
     */
    ,clearInvalid:function(){
        this.df.clearInvalid();
        this.tf.clearInvalid();
    } // eo function clearInvalid
    // }}}

    /**
     * @private
     * called from Component::destroy. 
     * Destroys all elements and removes all listeners we've created.
     */
    ,beforeDestroy:function() {
        if(this.isRendered) {
//            this.removeAllListeners();
            this.wrap.removeAllListeners();
            this.wrap.remove();
            this.tableEl.remove();
            this.df.destroy();
            this.tf.destroy();
        }
    } // eo function beforeDestroy

    // {{{
    /**
     * Disable this component.
     * @return {Ext.Component} this
     */
    ,disable:function() {
        if(this.isRendered) {
            this.df.disabled = this.disabled;
            this.df.onDisable();
            this.tf.onDisable();
        }
        this.disabled = true;
        this.df.disabled = true;
        this.tf.disabled = true;
        this.fireEvent("disable", this);
        return this;
    } // eo function disable
    // }}}
    // {{{
    /**
     * Enable this component.
     * @return {Ext.Component} this
     */
    ,enable:function() {
        if(this.rendered){
            this.df.onEnable();
            this.tf.onEnable();
        }
        this.disabled = false;
        this.df.disabled = false;
        this.tf.disabled = false;
        this.fireEvent("enable", this);
        return this;
    } // eo function enable
    // }}}
    // {{{
    /**
     * private Focus date filed
     */
    ,focus:function() {
        this.df.focus();
    } // eo function focus
    // }}}
    // {{{
    /**
     * private
     */
    ,getPositionEl:function() {
        return this.wrap;
    }
    // }}}
    // {{{
    /**
     * private
     */
    ,getResizeEl:function() {
        return this.wrap;
    }
    // }}}
    // {{{
    /**
     * @return {Date/String} Returns value of this field
     */
    ,getValue:function() {
        // create new instance of date
        return this.dateValue ? new Date(this.dateValue) : '';
    } // eo function getValue
    // }}}
    // {{{
    /**
     * @return {Boolean} true = valid, false = invalid
     * private Calls isValid methods of underlying DateField and TimeField and returns the result
     */
    ,isValid:function() {
        return this.df.isValid() && this.tf.isValid();
    } // eo function isValid
    // }}}
    // {{{
    /**
     * Returns true if this component is visible
     * @return {boolean} 
     */
    ,isVisible : function(){
        return this.df.rendered && this.df.getActionEl().isVisible();
    } // eo function isVisible
    // }}}
    // {{{
    /** 
     * private Handles blur event
     */
    ,onBlur:function(f) {
        // called by both DateField and TimeField blur events

        // revert focus to previous field if clicked in between
        if(this.wrapClick) {
            f.focus();
            this.wrapClick = false;
        }

        // update underlying value
        this.updateDate();
        this.updateTime();
        this.updateHidden();

        // fire events later
        (function() {
            if(!this.df.hasFocus && !this.tf.hasFocus) {
                var v = this.getValue();
                if(String(v) !== String(this.startValue)) {
                    this.fireEvent("change", this, v, this.startValue);
                }
                this.hasFocus = false;
                this.fireEvent('blur', this);
            }
        }).defer(100, this);

    } // eo function onBlur
    // }}}
    // {{{
    /**
     * private Handles focus event
     */
    ,onFocus:function() {
        if(!this.hasFocus){
            this.hasFocus = true;
            this.startValue = this.getValue();
            this.fireEvent("focus", this);
        }
    }
    // }}}
    // {{{
    /**
     * private Just to prevent blur event when clicked in the middle of fields
     */
    ,onMouseDown:function(e) {
        if(!this.disabled) {
            this.wrapClick = 'td' === e.target.nodeName.toLowerCase();
        }
    }
    // }}}
    // {{{
    /**
     * private
     * Handles Tab and Shift-Tab events
     */
    ,onSpecialKey:function(t, e) {
        var key = e.getKey();
        if(key === e.TAB) {
            if(t === this.df && !e.shiftKey) {
                e.stopEvent();
                this.tf.focus();
            }
            if(t === this.tf && e.shiftKey) {
                e.stopEvent();
                this.df.focus();
            }
        }
        // otherwise it misbehaves in editor grid
        if(key === e.ENTER) {
            this.updateValue();
        }

    } // eo function onSpecialKey
    // }}}
    // {{{
    /**
     * private Sets the value of DateField
     */
    ,setDate:function(date) {
        this.df.setValue(date);
    } // eo function setDate
    // }}}
    // {{{
    /** 
     * private Sets the value of TimeField
     */
    ,setTime:function(date) {
        this.tf.setValue(date);
    } // eo function setTime
    // }}}
    // {{{
    /**
     * private
     * Sets correct sizes of underlying DateField and TimeField
     * With workarounds for IE bugs
     */
    ,setSize:function(w, h) {
        if(!w) {
            return;
        }
        if('below' === this.timePosition) {
            this.df.setSize(w, h);
            this.tf.setSize(w, h);
            if(Ext.isIE) {
                this.df.el.up('td').setWidth(w);
                this.tf.el.up('td').setWidth(w);
            }
        }
        else {
            this.df.setSize(w - this.timeWidth - 4, h);
            this.tf.setSize(this.timeWidth, h);

            if(Ext.isIE) {
                this.df.el.up('td').setWidth(w - this.timeWidth - 4);
                this.tf.el.up('td').setWidth(this.timeWidth);
            }
        }
    } // eo function setSize
    // }}}
    // {{{
    /**
     * @param {Mixed} val Value to set
     * Sets the value of this field
     */
    ,setValue:function(val) {
        if(!val && true === this.emptyToNow) {
            this.setValue(new Date());
            return;
        }
        else if(!val) {
            this.setDate('');
            this.setTime('');
            this.updateValue();
            return;
        }
        if ('number' === typeof val) {
          val = new Date(val);
        }
        val = val ? val : new Date(1970, 0 ,1, 0, 0, 0);
        var da, time;
        if(val instanceof Date) {
            this.setDate(val);
            this.setTime(val);
            this.dateValue = new Date(val);
        }
        else {
            da = val.split(this.dtSeparator);
            this.setDate(da[0]);
            if(da[1]) {
                if(da[2]) {
                    // add am/pm part back to time
                    da[1] += da[2];
                }
                var hh = da[1].split(":");
                this.setTime(hh[0]+":"+hh[1]);
            }
        }
    } // eo function setValue
    // }}}
    // {{{
    /**
     * Hide or show this component by boolean
     * @return {Ext.Component} this
     */
    ,setVisible: function(visible){
        if(visible) {
            this.df.show();
            this.tf.show();
        }else{
            this.df.hide();
            this.tf.hide();
        }
        return this;
    } // eo function setVisible
    // }}}
    //{{{
    ,show:function() {
        return this.setVisible(true);
    } // eo function show
    //}}}
    //{{{
    ,hide:function() {
        return this.setVisible(false);
    } // eo function hide
    //}}}
    // {{{
    /**
     * private Updates the date part
     */
    ,updateDate:function() {
        var d = this.df.getValue();
        if(d) {
            if(!(this.dateValue instanceof Date)) {
                this.initDateValue();
                if(!this.tf.getValue()) {
                    this.setTime(this.dateValue);
                }
            }
            this.dateValue.setMonth(0); // because of leap years
            this.dateValue.setFullYear(d.getFullYear());
            this.dateValue.setMonth(d.getMonth());
            this.dateValue.setDate(d.getDate());
        }
        else {
            this.dateValue = '';
            this.setTime('');
        }
    } // eo function updateDate
    // }}}
    // {{{
    /**
     * private
     * Updates the time part
     */
    ,updateTime:function() {
        var t = this.tf.getValue();
        if(t && !(t instanceof Date)) {
            t = Date.parseDate(t, this.tf.format);
        }
        if(t && !this.df.getValue()) {
            this.initDateValue();
            this.setDate(this.dateValue);
        }
        if(this.dateValue instanceof Date) {
            if(t) {
                this.dateValue.setHours(t.getHours());
                this.dateValue.setMinutes(t.getMinutes());
                this.dateValue.setSeconds(t.getSeconds());
            }
            else {
                this.dateValue.setHours(0);
                this.dateValue.setMinutes(0);
                this.dateValue.setSeconds(0);
            }
        }
    } // eo function updateTime
    // }}}
    // {{{
    /**
     * private Updates the underlying hidden field value
     */
    ,updateHidden:function() {
        if(this.isRendered) {
            var value = this.dateValue instanceof Date ? this.dateValue.format(this.hiddenFormat) : '';
            this.el.dom.value = value;
        }
    }
    // }}}
    // {{{
    /**
     * private Updates all of Date, Time and Hidden
     */
    ,updateValue:function() {

        this.updateDate();
        this.updateTime();
        this.updateHidden();
        return;
    } // eo function updateValue
    // }}}
    // {{{
    /**
     * @return {Boolean} true = valid, false = invalid
     * callse validate methods of DateField and TimeField
     */
    ,validate:function() {
        return this.df.validate() && this.tf.validate();
    } // eo function validate
    // }}}
    // {{{
    /**
     * Returns renderer suitable to render this field
     * @param {Object} Column model config
     */
    ,renderer: function(field) {
        var format = field.editor.dateFormat || Ext.form.DateTime.prototype.dateFormat;
        format += ' ' + (field.editor.timeFormat || Ext.form.DateTime.prototype.timeFormat);
        var renderer = function(val) {
            var retval = Ext.util.Format.date(val, format);
            return retval;
        };
        return renderer;
    } // eo function renderer
    // }}}

}); // eo extend

// register xtype
Ext.reg('datetimefield', Ext.form.DateTimeField);

/**
 * @class Ext.grid.Search
 * @extends Ext.util.Observable
 * @param {Object} config configuration object
 * @constructor
 */
Ext.grid.Search = function(config) {
  Ext.apply(this, config);
  Ext.grid.Search.superclass.constructor.call(this);
}; // eo constructor

Ext.extend(Ext.grid.Search, Ext.util.Observable, {
  /**
   * cfg {Boolean} autoFocus true to try to focus the input field on each store load (defaults to undefined)
   */
  autoFocus:true
  /**
   * @cfg {String} searchText Text to display on menu button
   */
   ,searchText:'Search'

  /**
   * @cfg {String} searchTipText Text to display as input tooltip. Set to '' for no tooltip
   */ 
  ,searchTipText:'Insert a word or press Search'

  /**
   * @cfg {String} selectAllText Text to display on menu item that selects all fields
   */
  ,selectAllText:'Select All'

  /**
   * @cfg {String} position Where to display the search controls. Valid values are top and bottom (defaults to top)
   * Corresponding toolbar has to exist at least with mimimum configuration tbar:[] for position:top or bbar:[]
   * for position bottom. Plugin does NOT create any toolbar.
   */
  ,position:'top'

  /**
   * @cfg {String} iconCls Icon class for menu button (defaults to check)
   */
  ,iconCls:'check'

  /**
   * @cfg {String/Array} checkIndexes Which indexes to check by default. Can be either 'all' for all indexes
   * or array of dataIndex names, e.g. ['persFirstName', 'persLastName']
   */
  ,checkIndexes:'all'

  /**
   * @cfg {Array} disableIndexes Array of index names to disable (not show in the menu), e.g. ['persTitle', 'persTitle2']
   */
  ,disableIndexes:[]

  /**
   * @cfg {String} dateFormat how to format date values. If undefined (the default) 
   * date is formatted as configured in colummn model
   */
  ,dateFormat:undefined

  /**
   * @cfg {Boolean} showSelectAll Select All item is shown in menu if true (defaults to true)
   */
  ,showSelectAll:true

  /**
   * @cfg {String} menuStyle Valid values are 'checkbox' and 'radio'. If menuStyle is radio
   * then only one field can be searched at a time and selectAll is automatically switched off.
   */
  ,menuStyle:'checkbox'

  /**
   * @cfg {Number} minChars minimum characters to type before the request is made. If undefined (the default)
   * the trigger field shows magnifier icon and you need to click it or press enter for search to start. If it
   * is defined and greater than 0 then maginfier is not shown and search starts after minChars are typed.
   */

  /**
   * @cfg {String} minCharsTipText Tooltip to display if minChars is > 0
   */
  ,minCharsTipText:'Insert at least {0} characters'

  /**
   * @cfg {String} mode Use 'remote' for remote stores or 'local' for local stores. If mode is local
   * no data requests are sent to server the grid's store is filtered instead (defaults to 'remote')
   */
  ,mode:'remote'

  /**
   * @cfg {Array} readonlyIndexes Array of index names to disable (show in menu disabled), e.g. ['persTitle', 'persTitle2']
   */

  /**
   * @cfg {Number} width Width of input field in pixels (defaults to 100)
   */
  ,width:200

  /**
   * @cfg {String} xtype xtype is usually not used to instantiate this plugin but you have a chance to identify it
   */
  ,xtype:'gridsearch'

  /**
   * @cfg {Object} paramNames Params name map (defaults to {fields:'fields', query:'query'}
   */
  ,paramNames: {
     fields:'fields'
    ,query:'query'
  }

  /**
   * @cfg {String} shortcutKey Key to fucus the input field (defaults to r = Sea_r_ch). Empty string disables shortcut
   */
  ,shortcutKey:'r'

  /**
   * @cfg {String} shortcutModifier Modifier for shortcutKey. Valid values: alt, ctrl, shift (defaults to alt)
   */
  ,shortcutModifier:'alt'

  /**
   * @cfg {String} align 'left' or 'right' (defaults to 'right')
   */
   ,align:'right'

  /**
   * @cfg {Number} minLength force user to type this many character before he can make a search
   */
   ,minLength:3

  /**
   * @cfg {Ext.Panel/String} toolbarContainer Panel (or id of the panel) which contains toolbar we want to render
   * search controls to (defaults to this.grid, the grid this plugin is plugged-in into)
   */
  // {{{
  /**
   * private
   * @param {Ext.grid.GridPanel/Ext.grid.EditorGrid} grid reference to grid this plugin is used for
   */
  ,init:function(grid) {
    this.grid = grid;

    // setup toolbar container if id was given
    if('string' === typeof this.toolbarContainer) {
      this.toolbarContainer = Ext.getCmp(this.toolbarContainer);
    }

    // do our processing after grid render and reconfigure
    grid.onRender = grid.onRender.createSequence(this.onRender, this);
    grid.reconfigure = grid.reconfigure.createSequence(this.reconfigure, this);
  } // eo function init
  // }}}
  // {{{
  /**
   * private add plugin controls to <b>existing</b> toolbar and calls reconfigure
   */
  ,onRender:function() {
    var panel = this.toolbarContainer || this.grid;
    var tb = 'bottom' === this.position ? panel.bottomToolbar : panel.topToolbar;

    // add menu
    this.menu = new Ext.menu.Menu();

    // handle position
    if('right' === this.align) {
      tb.addFill();
    }
    else {
      if(0 < tb.items.getCount()) {
        tb.addSeparator();
      }
    }

    // add menu button
    tb.add({
       text:this.searchText
      ,menu:this.menu
      //,iconCls:this.iconCls
    });

    // add input field (TwinTriggerField in fact)
    this.field = new Ext.form.TwinTriggerField({
       width:this.width
      ,selectOnFocus:undefined === this.selectOnFocus ? true : this.selectOnFocus
      ,trigger1Class:'x-form-clear-trigger'
      ,trigger2Class:this.minChars ? 'x-hidden' : 'x-form-search-trigger'
      ,onTrigger1Click:this.minChars ? Ext.emptyFn : this.onTriggerClear.createDelegate(this)
      ,onTrigger2Click:this.onTriggerSearch.createDelegate(this)
      ,minLength:this.minLength
    });

    // install event handlers on input field
    this.field.on('render', function() {
      this.field.el.dom.qtip = this.minChars ? String.format(this.minCharsTipText, this.minChars) : this.searchTipText;

      if(this.minChars) {
        this.field.el.on({scope:this, buffer:300, keyup:this.onKeyUp});
      }

      // install key map
      var map = new Ext.KeyMap(this.field.el, [{
         key:Ext.EventObject.ENTER
        ,scope:this
        ,fn:this.onTriggerSearch
      },{
         key:Ext.EventObject.ESC
        ,scope:this
        ,fn:this.onTriggerClear
      }]);
      map.stopEvent = true;
    }, this, {single:true});

    tb.add(this.field);

    // reconfigure
    this.reconfigure();

    // keyMap
    if(this.shortcutKey && this.shortcutModifier) {
      var shortcutEl = this.grid.getEl();
      var shortcutCfg = [{
         key:this.shortcutKey
        ,scope:this
        ,stopEvent:true
        ,fn:function() {
          this.field.focus();
        }
      }];
      shortcutCfg[0][this.shortcutModifier] = true;
      this.keymap = new Ext.KeyMap(shortcutEl, shortcutCfg);
    }

    if(true === this.autoFocus) {
      this.grid.store.on({scope:this, load:function(){this.field.focus();}});
    }
  } // eo function onRender
  // }}}
  // {{{
  /**
   * field el keypup event handler. Triggers the search
   * @private
   */
  ,onKeyUp:function() {
    var length = this.field.getValue().toString().length;
    if(0 === length || this.minChars <= length) {
      this.onTriggerSearch();
    }
  } // eo function onKeyUp
  // }}}
  // {{{
  /**
   * private Clear Trigger click handler
   */
  ,onTriggerClear:function() {
    if(this.field.getValue()) {
      this.field.setValue('');
      this.field.focus();
      this.onTriggerSearch();
    }
  } // eo function onTriggerClear
  // }}}
  // {{{
  /**
   * private Search Trigger click handler (executes the search, local or remote)
   */
  ,onTriggerSearch:function() {
    if(!this.field.isValid()) {
      return;
    }
    var val = this.field.getValue();
    var store = this.grid.store;

    // grid's store filter
    if('local' === this.mode) {
      store.clearFilter();
      if(val) {
        store.filterBy(function(r) {
          var retval = false;
          this.menu.items.each(function(item) {
            if(!item.checked || retval) {
              return;
            }
            var rv = r.get(item.dataIndex);
            rv = rv instanceof Date ? rv.format(this.dateFormat || r.fields.get(item.dataIndex).dateFormat) : rv;
            var re = new RegExp(val, 'gi');
            retval = re.test(rv);
          }, this);
          if(retval) {
            return true;
          }
          return retval;
        }, this);
      }
      else {
      }
    }
    // ask server to filter records
    else {
      // clear start (necessary if we have paging)
      if(store.lastOptions && store.lastOptions.params) {
        store.lastOptions.params[store.paramNames.start] = 0;
      }

      // get fields to search array
      var fields = [];
      this.menu.items.each(function(item) {
        if(item.checked && item.dataIndex) {
          fields.push(item.dataIndex);
        }
      });

      // add fields and query to baseParams of store
      delete(store.baseParams[this.paramNames.fields]);
      delete(store.baseParams[this.paramNames.query]);
      if (store.lastOptions && store.lastOptions.params) {
        delete(store.lastOptions.params[this.paramNames.fields]);
        delete(store.lastOptions.params[this.paramNames.query]);
      }
      if(fields.length) {
        store.baseParams[this.paramNames.fields] = fields.compact().join();
        store.baseParams[this.paramNames.query] = val;
      }
      // reload store
      store.reload();
    }

  } // eo function onTriggerSearch
  // }}}
  // {{{
  /**
   * @param {Boolean} true to disable search (TwinTriggerField), false to enable
   */
  ,setDisabled:function() {
    this.field.setDisabled.apply(this.field, arguments);
  } // eo function setDisabled
  // }}}
  // {{{
  /**
   * Enable search (TwinTriggerField)
   */
  ,enable:function() {
    this.setDisabled(false);
  } // eo function enable
  // }}}
  // {{{
  /**
   * Enable search (TwinTriggerField)
   */
  ,disable:function() {
    this.setDisabled(true);
  } // eo function disable
  // }}}
  // {{{
  /**
   * private (re)configures the plugin, creates menu items from column model
   */
  ,reconfigure:function() {

    // {{{
    // remove old items
    var menu = this.menu;
    menu.removeAll();

    // add Select All item plus separator
    if(this.showSelectAll && 'radio' !== this.menuStyle) {
      menu.add(new Ext.menu.CheckItem({
         text:this.selectAllText
        ,checked:!(this.checkIndexes instanceof Array)
        ,hideOnClick:false
        ,handler:function(item) {
          var checked = ! item.checked;
          item.parentMenu.items.each(function(i) {
            if(item !== i && i.setChecked && !i.disabled) {
              i.setChecked(checked);
            }
          });
        }
      }),'-');
    }

    // }}}
    // {{{
    // add new items
    var cm = this.grid.colModel;
    var group = undefined;
    if('radio' === this.menuStyle) {
      group = 'g' + (new Date).getTime(); 
    }
    Ext.each(cm.config, function(config) {
      var disable = false;
      if(config.header && config.dataIndex && config.sortable) {
        Ext.each(this.disableIndexes, function(item) {
          disable = disable ? disable : item === config.dataIndex;
        });
        if(!disable) {
          menu.add(new Ext.menu.CheckItem({
             text:config.header
            ,hideOnClick:false
            ,group:group
            ,checked:'all' === this.checkIndexes
            ,dataIndex:config.dataIndex
          }));
        }
      }
    }, this);
    // }}}
    // {{{
    // check items
    if(this.checkIndexes instanceof Array) {
      Ext.each(this.checkIndexes, function(di) {
        var item = menu.items.find(function(itm) {
          return itm.dataIndex === di;
        });
        if(item) {
          item.setChecked(true, true);
        }
      }, this);
    }
    // }}}
    // {{{
    // disable items
    if(this.readonlyIndexes instanceof Array) {
      Ext.each(this.readonlyIndexes, function(di) {
        var item = menu.items.find(function(itm) {
          return itm.dataIndex === di;
        });
        if(item) {
          item.disable();
        }
      }, this);
    }
    // }}}

  } // eo function reconfigure
  // }}}

}); // eo extend

// eof

/**
 * This class store state session of extjs in the database for the current account
 */
Ext.state.DataBaseProvider = function(config){
  Ext.state.DataBaseProvider.superclass.constructor.call(this);
  this.path = "/backend/state_sessions";
  Ext.apply(this, config);
  this.state = this.readCookies();
};

Ext.extend(Ext.state.DataBaseProvider, Ext.state.Provider, {
  // private
  set : function(name, value){
    if(typeof value == "undefined" || value === null){
      this.clear(name);
      return;
    }
    this.setCookie(name, value);
    Ext.state.DataBaseProvider.superclass.set.call(this, name, value);
  },

  // private
  clear : function(name){
    this.clearCookie(name);
    Ext.state.DataBaseProvider.superclass.clear.call(this, name);
  },

  // private
  readCookies : function(){
    var cookies = {};
    var values  = [];
    new Ajax.Request(this.path, {
      method: 'GET',
      asynchronous: false,
      onSuccess: function(response, request){
        values = Ext.decode(response.responseText);
      }
    });
    values.each(function(f){
      if(f.state_session && f.state_session.component && f.state_session.component.substring(0,3) == "ys-"){
        cookies[f.state_session.component.substr(3)] = this.decodeValue(f.state_session.data);
      }
    }, this);
    return cookies;
  },

  // private
  setCookie : function(name, value){
    Ext.Ajax.request({
      url: this.path,
      method: 'POST',
      params: { id: 'ys-'+name, data: this.encodeValue(value) }
    })
  },
  
  // private
  clearCookie : function(name){
    Ext.Ajax.request({
      url: this.path+'/ys-'+name,
      method: 'DELETE'
    })
  }
});