



   
   
   
   
    




<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>

<head>
<title>Primate Life Histories Database</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">   
	
<link rel="stylesheet" type="text/css" href="../js/dijit/themes/tundra/tundra.css" />
<link rel="stylesheet" type="text/css" href="../css/plhdb.css" />
<script type="text/javascript" src="../js/dojo/dojo.js"  djConfig="parseOnLoad: false, isDebug: false, locale: 'en'"></script>
<script type="text/javascript" src="../js/dijit/dijit.js"></script>


</head><body class="tundra" id="container" style="margin-top:0;padding-top:0;">
<div class="pagewrapper" style="margin-top:0;padding-top:0;">
<div style="clear:both;height:44px;"></div>

   <div class="header">
       




<div id="logo"><img src="../images/plhdb_logo.jpg" width="172" height="45" alt="Primate Life Histories" /></div>
<div id="user_info">Version: 1.1.3&nbsp;&nbsp;Built: 06/06/2015 07:39 PM

    <br/>Logged in as: example@example.com  &nbsp;&nbsp;[ <a href="https://plhdb.org/jsp/changepassword.jsp">Change Password</a> | <a href="https://plhdb.org/jsp/logout.jsp">Logout</a> ] 

</div>
       <div id="nav">
   
    


    
    

    
    

    
      

     




<a href="https://plhdb.org/"><img src="../images/inactive_home.jpg" width="66" height="41" alt="Home"  onmouseover="this.src='/images/active_home.jpg'" onmouseout="this.src='/images/inactive_home.jpg'"/></a>






<a href="https://plhdb.org/edit.go"><img src="../images/inactive_edit.jpg" width="80" height="41" alt="Edit Data"  onmouseover="this.src='/images/active_edit.jpg'" onmouseout="this.src='/images/inactive_edit.jpg'"/></a>





<a href="https://plhdb.org/jsp/searchData.jsp"><img src="../images/inactive_biography.jpg" width="120" height="41" alt="Search Biography"   onmouseover="this.src='/images/active_biography.jpg'" onmouseout="this.src='/images/inactive_biography.jpg'" /></a>



	
<a href="searchFertility.jsp"><img src="../images/active_fertility.jpg" width="110" height="41" alt="Search Fertility" /></a>






<a href="https://plhdb.org/view/users.go"><img src="../images/inactive_users.jpg" width="70" height="41" alt="Users"  onmouseover="this.src='/images/active_users.jpg'" onmouseout="this.src='/images/inactive_users.jpg'"/></a>






<a href="https://plhdb.org/jsp/about.jsp"><img src="../images/inactive_about.jpg" width="77" height="41" alt="About"  onmouseover="this.src='/images/active_about.jpg'" onmouseout="this.src='/images/inactive_about.jpg'"/></a>


   </div>
   </div>
   <div style="clear:both;height:42px;"></div>
   <div class="content">


 

<script type="text/javascript">
function selectAll() {
	for (var i=0; i<document.selectform.elements.length; i++) {
		var e = document.selectform.elements[i];
		if (e.name.indexOf('show') == 0) e.checked = document.selectform.selectall.checked;
	}
}
function searchDistributionClicked() {
	for (var i=0; i<document.selectform.elements.length; i++) {
		var e = document.selectform.elements[i];
		if (e.name.indexOf('show') == 0) e.checked = !document.selectform.searchDistribution.checked;
	}
	document.selectform.selectall.checked=!document.selectform.searchDistribution.checked;
	document.selectform.selectall.disabled=document.selectform.searchDistribution.checked;
	var th=document.getElementById("thShow");
	var lbl="Show";
	if(document.selectform.searchDistribution.checked){
	    lbl="Group By";
	}
	var l=document.createTextNode(lbl);
	th.replaceChild(l,th.firstChild);
}
</script>
<h2>Search Fertility Interval</h2>
<form action="https://plhdb.org/search/fertility.go" method="post" name="selectform">
<table>
<tr><td colspan="5"><input type="checkbox" id="searchDistribution" name="searchDistribution" onClick="javascript:searchDistributionClicked()" /><label for="searchDistribution">Search Distribution</label><br/>
Check 'Search Distribution' to get a summary result of data records distribution according to the fields you choose below. For example, you can get a distribution of start type by ckecking the start type field. The distribution 
search can also be combined with filtering conditions, such as start type distribution for all animals from study 1.</td>
<tr><tr><th id="thShow" name="thShow">Show</th><th>Column</th><th>Operator</th><th>Value</th></tr><tr>
<td class="odd" nowrap="nowrap"><input type="checkbox" checked="true"  name="show_studyid" /></td>
<td class="odd" nowrap="nowrap">Study/Species</td><td class="odd" nowrap="nowrap">
<select name="op_studyid">
<option value="=">=</option>
<option value="!=">!=</option>
</select>
</td>
<td class="odd" nowrap="nowrap"><input type="text"  name="value_studyid" size="50">
</td></tr>
<tr>
<td class="even" nowrap="nowrap"><input type="checkbox" checked="true"  name="show_animid" /></td><td class="even" nowrap="nowrap">Animal Id</td><td class="even" nowrap="nowrap"><select name="op_animid">
<option value="=">=</option>
<option value="!=">!=</option>
<option value="LIKE">LIKE</option>
<option value="NOT LIKE">NOT LIKE</option>
<option value="ILIKE">ILIKE</option>
<option value="NOT ILIKE">NOT ILIKE</option>
<option value="IN">IN</option>
<option value="NOT IN">NOT IN</option>
</select></td>
<td class="even" nowrap="nowrap"><input type="text"  name="value_animid" size="50">&nbsp;&nbsp;(hint: BRIS, KUS, TMR)
</input>
</td></tr>
<tr>
<td class="odd" nowrap="nowrap"><input type="checkbox" checked="true"  name="show_startdate" /></td><td class="odd" nowrap="nowrap">Start Date</td><td class="odd" nowrap="nowrap">
<select name="op_startdate">
<option value="=">=</option>
<option value="!=">!=</option>
<option value="&lt;">&lt;</option>
<option value="&gt;">&gt;</option>
<option value="&lt;=">&lt;=</option>
<option value="&gt;=">&gt;=</option>
<option value="IS NULL">IS NULL</option>
<option value="IS NOT NULL">IS NOT NULL</option>
</select>
<td class="odd" nowrap="nowrap"><input name="value_startdate" value="" size="12"  />(dd-Mon-YYYY)
</td></tr>
<tr>
<td class="even" nowrap="nowrap"><input type="checkbox" checked="true"  name="show_starttype" /></td><td class="even" nowrap="nowrap">Start Type</td>
<td class="even" nowrap="nowrap"><select name="op_starttype">
<option value="=">=</option>
<option value="!=">!=</option>
<option value="IS NULL">IS NULL</option>
<option value="IS NOT NULL">IS NOT NULL</option>
<option value="IN">IN</option>
<option value="NOT IN">NOT IN</option>
</select></td>
<td class="even" nowrap="nowrap"><select name="value_starttype">
<option value=""></option>
<option value="O">beginning of observation</option>
<option value="B">birth</option>
<option value="C">confirmed identification</option>
<option value="I">immigration into population</option>
</select>
</td></tr>

<tr>
<td class="odd" nowrap="nowrap"><input type="checkbox" checked="true"  name="show_stopdate" /></td><td class="odd" nowrap="nowrap">Stop Date</td><td class="odd" nowrap="nowrap">
<select name="op_stopdate">
<option value="=">=</option>
<option value="!=">!=</option>
<option value="&lt;">&lt;</option>
<option value="&gt;">&gt;</option>
<option value="&lt;=">&lt;=</option>
<option value="&gt;=">&gt;=</option>
<option value="IS NULL">IS NULL</option>
<option value="IS NOT NULL">IS NOT NULL</option>
</select>
<td class="odd" nowrap="nowrap"><input name="value_stopdate" value="" size="12"  />(dd-Mon-YYYY)
</td></tr>

<tr>
<td class="even" nowrap="nowrap"><input type="checkbox" checked="true"  name="show_stoptype" /></td><td class="odd" nowrap="nowrap">Stop Type</td>
<td class="even" nowrap="nowrap"><select name="op_stoptype">
<option value="=">=</option>
<option value="!=">!=</option>
<option value="IN">IN</option>
<option value="NOT IN">NOT IN</option>
</select>
<td class="even" nowrap="nowrap"><select name="value_stoptype">
<option value=""></option>
<option value="D">death</option>
<option value="E">emigration from population</option>
<option value="O">end of observation</option>
<option value="P">permanent disappearance</option>
</select>
</td></tr>
<tr><td colspan="5"><input type="checkbox" checked="true"  id="selectall" name="selectall" onClick="javascript:selectAll()" /><label for="selectall">Select all fields</label></td></table></p>
<input type="submit" name="search" value="Search" />
<input type="reset" name="reset" value="Clear" /></p>
</form>
<p>All records will be returned if no searching conditions are specified.</p>
<div style="clear:both;"></div>


<h3>Available downloads</h3>


<hr/>
<img src="../images/photos/Campos-Fedigan-Cebus-capucinus-small.jpg" style="float:right;margin-left: 15px; margin-bottom:15px;" />

<h3>Column Definitions for Female Fertility Record Downloads</h3>
<ul>
<li>Study/Species: the ID of the study. Because animals in a study are from a single species, the study also identifies the species.</li>
<li>AnimID:  the ID of each animal (typically an abbreviated code),
  which unambiguously identifies individuals within a study. Animals in different studies might have the same ID. </li>
<li>Startdate and Stopdate: the start end end dates of an uninterrupted period of observation on a female during which no possible births would have been missed.</li>
<li>Starttype and Stoptype: see Entrytype and Departype in BIOGRAPHY; these correspond to Starttype and Stoptype in FERTILITY.</li>
</ul>
</div>

   </div>

<div class="footer">&copy;2010 National Evolutionary Synthesis Center. All rights reserved. 2024 W. Main Street<br/>Durham, NC 27705.
</div>

</body>

</html>


