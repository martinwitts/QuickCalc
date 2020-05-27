/*!
 * Quickcalc Responsive Mobile v1.0 
 * (c) 2018 Martin Witts
 * licensed under MIT
 * 
 * 
 */

$(document).ready(function() {
  //alert("pageshow event fired");
	$.ajax({
    type: "POST",
    url: '/site_id',
    data: {'categoryID': $("#select_site").val(),'isAjax':true},
    dataType:'json',
    success: function(data) {
       var select = $("#ddlselect_site"), options = '';
       select.empty();      

       for(var i=0;i<data.length; i++)
       {
        options += "<option value='"+data[i].id+"'>"+ data[i].name +"</option>";              
       }
       select.append(options);
    }
});

	$("body").on('click', '.top', function() {
		$("nav.menu").toggleClass("menu_show");
		//$("nav.menu").show("menu_show");
	});
/*close navigator after click*/
$("nav a").click(function () {

	$("nav.menu").toggleClass("menu_show");
});
	

});
$( document ).on( "pagecreate", "#customers", function( event ) {
  //alert( "This page was just enhanced by jQuery Mobile!" );






		
});




		function circuitFilter() {
		
		var e = document.getElementById("ddlselect_site");
		var id = e.options[e.selectedIndex].value;

		document.getElementById("droptest").innerHTML = id;

  		var ids =jQuery("#circuit").jqGrid();
   		$.ajax({
     	type: "GET",
     	url: "/circuit?_search=true&rows=40&page=1&sidx=id&sord=asc&searchField=circuit_site&searchString=" + id + "&searchOper=eq&filters=",
     	data: JSON.stringify(ids), 
     	dataType: "json",
     	success: function(jsonData, textStatus, xhr) {
	 
       $('#circuit').setGridParam({ datastr: jsonData, datatype:'jsonstring', rowNum: jsonData.length }).trigger('reloadGrid');
	   $('#site').trigger( 'reloadGrid' );
	   
     }
  });
}
		 function fillddl(){
/*----------------------------------------ajax post to select dropdown option to current site on circuit table-----------------*/
          jQuery.ajax({
          url: '/ddl',
          type: "POST",
          data: {},
          dataType: "json",
          beforeSend: function(x) {
            if (x && x.overrideMimeType) {
              x.overrideMimeType("application/j-son;charset=UTF-8");
            }
          },
          success: function(result) {
 	     //Write your code here
		 //alert(result);
		 //document.getElementById("id").innerHTML = result;
		 $('#ddlselect_site').val(result);
		 $('#ddlselect_site').val(result);
		 var myselect = $("select#ddlselect_site"); 
		 myselect.selectmenu("refresh");
		 setTimeout(function(){ $('#ddlselect_site').val(result); }, 3000);
		 setTimeout(function(){ myselect.selectmenu("refresh"); }, 5000);
		 setTimeout(function(){ myselect.selectmenu("refresh"); }, 7000);
          }
});   
}


$( document ).delegate("#customers", "pageinit", function() {
  //jQuery("#customers").jqGrid('setGridParam',{datatype:'json'}).trigger('reloadGrid');
});
$( document ).delegate("#sites", "pageinit", function() {
  //jQuery("#sites").jqGrid('setGridParam',{datatype:'json'}).trigger('reloadGrid');
});
$( document ).delegate("#circuits", "pageinit", function() {
  //jQuery("#circuits").jqGrid('setGridParam',{datatype:'json'}).trigger('reloadGrid');
});








