<?php

// This script randomly redirects to a search engine in $searcharray, based on the "q" variable in the script's request.

$defaultsearchengine = "https://www.google.com/";

$searchterm = $_REQUEST['q'] ;
	
$searcharray = array(
		
		"https://www.google.com/search?q=" . $searchterm # Google
		, "http://www.bing.com/search?q=" . $searchterm # Bing
		, "http://search.yahoo.com/search?p=" . $searchterm # Yahoo

	) ;

$searchquery = $searcharray[array_rand($searcharray)] ;

//	print $searchquery;

header( 'Location: ' . $searchquery );

exit;

