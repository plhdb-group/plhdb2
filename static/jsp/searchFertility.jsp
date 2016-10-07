



   
   
   
   
    




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
       




<div id="logo"><img src="/images/plhdb_logo.jpg" width="172" height="45" alt="Primate Life Histories" /></div>
<div id="user_info">Version: 1.1.3&nbsp;&nbsp;Built: 06/06/2015 07:39 PM

</div>
       <div id="nav">
   
    


    
    

    
    

    
      

     




<a href="/"><img src="/images/inactive_home.jpg" width="66" height="41" alt="Home"  onmouseover="this.src='/images/active_home.jpg'" onmouseout="this.src='/images/inactive_home.jpg'"/></a>



<a href="/adminer/"><img src="/images/inactive_login.jpg" width="66" height="41" alt="Login"  onmouseover="this.src='/images/active_login.jpg'" onmouseout="this.src='/images/inactive_login.jpg'"/></a>


<a href="/jsp/searchData.jsp"><img src="/images/inactive_biography.jpg" width="120" height="41" alt="Search Biography"   onmouseover="this.src='/images/active_biography.jpg'" onmouseout="this.src='/images/inactive_biography.jpg'" /></a>



	
<a href="searchFertility.jsp"><img src="../images/active_fertility.jpg" width="110" height="41" alt="Search Fertility" /></a>





<a href="/jsp/about.jsp"><img src="/images/inactive_about.jpg" width="77" height="41" alt="About"  onmouseover="this.src='/images/active_about.jpg'" onmouseout="this.src='/images/inactive_about.jpg'"/></a>


   </div>
   </div>
   <div style="clear:both;height:42px;"></div>
   <div class="content">

<h2>Search Fertility Interval</h2>
<p>This page no longer contains a search form.  Quick links to search
pages simlar to the old search pages are provided below.  Access to
all database content is provided through a generic user interface
supplied by <a href="http://adminer.org">Adminer.org</a>.

<p>The recommended download choice is via the FERTILITIES view.
FERTILITIES contains AnimId and StudyId columns (and another for BId)
whereas FERTILITY has only a BId column.</p>

<div style="clear:both;"></div>



<h3>Available downloads</h3>

<ul>
  <li>Production Data
    <ul>
      <li><a href="/adminer/?pgsql=&amp;username=&amp;db=plhdb&amp;ns=plhdb&amp;select=fertility>FERTILITY"</a></li>
      <li><a href="/adminer/?pgsql=&amp;username=&amp;db=plhdb&amp;ns=plhdb&amp;select=fertilities">FERTILITIES</a> (recommended)</li>
    </ul>
  </li>
  <li>Demo Data
    <ul>
      <li><a href="/demo/?pgsql=&amp;username=&amp;db=plhdb_demo&amp;ns=plhdb&amp;select=fertility">FERTILITY</a></li>
      <li><a href="/demo/?pgsql=&amp;username=&amp;db=plhdb_demo&amp;ns=plhdb&amp;select=fertilities">FERTILITIES</a> (recommended)</li>
    </ul>
  </li>
</ul

<hr/>
<img src="/images/photos/Campos-Fedigan-Cebus-capucinus-small.jpg" style="float:right;margin-left: 15px; margin-bottom:15px;" />

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


