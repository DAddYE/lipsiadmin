//  
//  Created by Davide D'Agostino on 2008-01-19.
//  Copyright 2008 Lipsiasoft s.r.l. All rights reserved.
// 

Ext.app.SearchField = Ext.extend(Ext.form.TwinTriggerField, {
	initComponent : function(){
		Ext.app.SearchField.superclass.initComponent.call(this);
		this.store.baseParams = this.store.baseParams || {};
    this.store.baseParams[this.paramName] = '';
		this.on('keypress', function(f, e){
			this.onTrigger2Click();
			}, this);
	},

	fireKey : function(e){
		Ext.app.SearchField.superclass.fireKey.call(this,e);
		if(!e.isSpecialKey()){
			this.fireEvent("keypress", this, e);
		}
	},

	//validationEvent:false,
	//validateOnBlur:false,
	trigger1Class:'x-form-clear-trigger',
	trigger2Class:'x-form-search-trigger',
	width:180,
	hasSearch : false,
	paramName : 'filter',
	items:[],


	onTrigger1Click : function(){
		if(this.hasSearch){
			this.el.dom.value = '';
			this.store.baseParams = this.store.baseParams || {};
      this.store.baseParams[this.paramName] = '';
			this.store.load(Ext.util.Pagination);
			this.hasSearch = false;
		}
	},

	onTrigger2Click : function(){
		var v = this.getRawValue();
		if(v.length < 1){
         this.onTrigger1Click();
         return;
     }
		this.store.baseParams = this.store.baseParams || {};
    this.store.baseParams[this.paramName] = v;
		this.store.baseParams['items'] = this.items;
		this.store.load(Ext.util.Pagination);
		this.hasSearch = true;	
	}
});