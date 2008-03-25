//  
//  Created by Davide D'Agostino on 2008-01-19.
//  Copyright 2008 Lipsiasoft s.r.l. All rights reserved.
// 

Ext.app.SearchField = Ext.extend(Ext.form.TwinTriggerField, {
	initComponent : function(){
		Ext.app.SearchField.superclass.initComponent.call(this);
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
		paramName : 'query',
		items:[],


		onTrigger1Click : function(){
			if(this.hasSearch){
				this.el.dom.value = '';
				this.store.clearFilter();
				this.hasSearch = false;
			}
		},

		onTrigger2Click : function(){
			var items = this.items;
			var v = this.getRawValue();
			var t;
			if(v.length < 1){
				this.onTrigger1Click();
				return;
			}
			this.store.filterBy(function(r) {
				valueArr = v.split(/\ +/);
				for (var j=0; j<valueArr.length; j++) {
					re = new RegExp(Ext.escapeRe(valueArr[j]), "i");
					keep = false;
					for (var i=0; i < items.length; i++) {
						if (re.test(r.data[items[i].name])==true){
							keep=true;
						}
					}
					if (!keep){
						return false;
					}
				}
				return true;
			});
			this.hasSearch = true;	
		}
	});