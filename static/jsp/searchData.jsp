



   
   
   
   
    




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

</div>
       <div id="nav">
   
    


    
    

    
    

    
      

     




<a href="/"><img src="/images/inactive_home.jpg" width="66" height="41" alt="Home"  onmouseover="this.src='/images/active_home.jpg'" onmouseout="this.src='/images/inactive_home.jpg'"/></a>



<a href="/adminer/"><img src="/images/inactive_login.jpg" width="66" height="41" alt="Login"  onmouseover="this.src='/images/active_login.jpg'" onmouseout="this.src='/images/inactive_login.jpg'"/></a>



	
<a href="searchData.jsp"><img src="../images/active_biography.jpg" width="120" height="41" alt="Search Biography" /></a>






<a href="/jsp/searchFertility.jsp"><img src="/images/inactive_fertility.jpg" width="110" height="41" alt="Search Fertility"   onmouseover="this.src='/images/active_fertility.jpg'" onmouseout="this.src='/images/inactive_fertility.jpg'" /></a>





<a href="/jsp/about.jsp"><img src="/images/inactive_about.jpg" width="77" height="41" alt="About"  onmouseover="this.src='/images/active_about.jpg'" onmouseout="this.src='/images/inactive_about.jpg'"/></a>


   </div>
   </div>
   <div style="clear:both;height:42px;"></div>
   <div class="content">


<h2>Search Biography</h2>
<p>This page no longer contains a search form.  Quick links to search
pages simlar to the old search pages are provided below.  Access to
all database content is provided through a generic user interface
supplied by <a href="http://adminer.org">Adminer.org</a>.

<p>The recommended download choice is via the BIOGRAPHIES view.
BIOGRAPHIES contains the mother's AnimId (and the mother's BId)
whereas BIOGRAPHY contains only the mother's BId.</p>

<div style="clear:both;"></div>



<h3>Available downloads</h3>

<ul>
  <li>Production Data
    <ul>
      <li><a href=/adminer/?pgsql=&username=&db=plhdb&ns=plhdb&select=biography>BIOGRAPHY</a></li>
      <li><a href=/adminer/?pgsql=&username=&db=plhdb&ns=plhdb&select=biographies>BIOGRAPHIES</a> (recommended)</li>
    </ul>
  </li>
  <li>Demo Data
    <ul>
      <li><a href=/adminer/?pgsql=&username=&db=plhdb_demo&ns=plhdb&select=biography>BIOGRAPHY</a></li>
      <li><a href=/adminer/?pgsql=&username=&db=plhdb_demo&ns=plhdb&select=biographies>BIOGRAPHIES</a> (recommended)</li>
    </ul>
  </li>
</ul


<hr/>
<img src="/images/photos/BMSR-Sifaka-F80-2001-5wks-infantBrockmanCredit-small.jpg" style="float:right;margin-left: 15px; margin-bottom:15px;" />
<h3>Column Definition for Biography Downloads</h3>
<ul>
<li>Study/Species: the ID of the study. Because animals in a study are
  from a single species, the study also identifies the species. </li>
<li>AnimID:  the ID of each animal (typically an abbreviated code),
  which unambiguously identifies individuals within a study. Animals in different studies might have the same ID. </li>
<li>BirthGroup and BGQual: the social group into which an animal was
  born (BirthGroup) and the researcher's confidence ((U)ncertain,
  (C)ertain, or missing) in this assignment (BGQual). </li>
<li>Sex: sex of each individual, possible values include (M)ale,
  (F)emale, and (U)nknown</li>
<li>MomID:  the AnimID of an individual's mother.</li>
<li>FirstBorn:  whether individuals were known to be their mother's first offspring.</li>
<li>Birthdate, BDMin, BDMax:  Birth date, and estimates of the minimum (BDMin)
  and maximum (BDMax) possible dates in which the birth could have occurred..</li>
<li>BDDist: distribution of birth date estimates to increase precision. More information can be found in the methid paper.
   <ul><li>N: Normal. the most likely birthdate to be closer to Birthdate than to BDMin or BDMax</li>
   <li>U: Uniform. any birthdate between BDMin and BDMax (including Birthdate) was equally likely.</li>
   </ul>
<li>Entrydate and Entrytype:  the date and type at which individuals entered their respective study populations. Possible Entrytypes include:
	<ul><li>B: birth</li>
	<li>I: immigration</li>
	<li>C: start of confirmed identification of the individual</li>
	<li>O: initiation of close observation</li>
	</ul>
</li>
<li>Departdate and DepartdateError:  the last date on which an animal was observed in the study population is the Departdate. DepartdateError reflects the time between Departdate 
(last date observed) and the first time that an animal was confirmed
  missing (e.g., when observations resumed and all individuals present
  could be expected to be re-encountered), and is expressed as a
  fraction of a year (number of days divided by number of days in a
  year). It is greater than 0 whenever the number of days between Departdate and retrospective 
confirmed missing date was more than 15 days. In some studies, members
  of the study population did not live in cohesive groups, making it
  difficult to specify an expected lag to re-sighting and a corresponding DepartdateError.  In cases when DepartdateError cannot be calculated, its value is missing.
</li>
<li>DepartType:  the type of departure of an individual from the population, including: 
	<ul><li>D: death</li>
	<li>E: emigration</li>
	<li>P: permanent disappearance</li>
	<li>O: the end of observation, which means that the individual was still present at the most recent census date. </li>
	</ul>
</li>
</ul>
</div>

   </div>

<div class="footer">&copy;2010 National Evolutionary Synthesis Center. All rights reserved. 2024 W. Main Street<br/>Durham, NC 27705.
</div>

</body>

</html>


