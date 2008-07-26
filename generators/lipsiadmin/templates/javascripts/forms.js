// 
//  bettingquiz
//  
//  Created by Davide D'Agostino on 2008-07-25.
//  Copyright 2008 LipsiaSoft s.r.l.. All rights reserved.
// 


//this function runs when the page is loaded so put all your other onload stuff in here too.
function styledForms() {
	hoverEffects();
	buttonHovers();
	formHovers();
}

function hoverEffects() {
	//get all elements (text inputs, passwords inputs, textareas)
	var elements = document.getElementsByTagName('input');
	var j = 0;
	var hovers = new Array();
	for (var i4 = 0; i4 < elements.length; i4++) {
		if( ((elements[i4].type=='text')||(elements[i4].type=='password'))&&(elements[i4].className=='text-input') ) {
			hovers[j] = elements[i4];
			++j;
		}
	}
	elements = document.getElementsByTagName('textarea');
	for (var i4 = 0; i4 < elements.length; i4++) {
		if (elements[i4].className=='text-area') {
		  hovers[j] = elements[i4];
		  ++j;
		};
	}
	//add focus effects
	for (var i4 = 0; i4 < hovers.length; i4++) {
		hovers[i4].onfocus = function() {this.className += "-hover";}
		hovers[i4].onblur = function() {this.className = this.className.replace(/-hover/g, "");}
	}
}

function formChilds() {
  var j = 0;
  var hovers = new Array();
  elements = document.getElementsByTagName('ul');
	for (var i4 = 0; i4 < elements.length; i4++) {
		if (elements[i4].className=='form') {
		  childs = elements[i4].getElementsByTagName('li');
		  for (var i5=0; i5 < childs.length; i5++) {
		    hovers[j] = childs[i5]
		    ++j;
		  };
		};
	}
	return hovers;
}

function formHovers() {
  var hovers = formChilds();
	for (var i4 = 0; i4 < hovers.length; i4++) {
		hovers[i4].onclick = function() { 
      var childs = formChilds();
      for (var i5=0; i5 < childs.length; i5++) {
        childs[i5].className = "";
      };
		  this.className = "hover";
		}
	}
}

function buttonHovers() {
	//get all buttons
	var elements = document.getElementsByTagName('input');
	var j = 0;
	var buttons = new Array();
	for (var i5 = 0; i5 < elements.length; i5++) {
		if((elements[i5].type=='submit')&&(elements[i5].className=='submit')) {
			buttons[j] = elements[i5];
			++j;
		}
	}
	
	//add hover effects
	for (var i5 = 0; i5 < buttons.length; i5++) {
		buttons[i5].onmouseover = function() {this.className += "-hover";}
		buttons[i5].onmouseout = function() {this.className = this.className.replace(/-hover/g, "");}
	}
}
window.onload = styledForms;