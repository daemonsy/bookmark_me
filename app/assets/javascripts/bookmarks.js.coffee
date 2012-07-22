jQuery -> 
	$('#bookmark_tag_tokens').autoSuggest "/tags/search.json"
		selectedValuesProp: "name"
		searchObjProps: "name"
		selectedItemProp: "name"
		neverSubmit: true
		minChar: 2
		startText: "Enter tags here and hit <tab> or <comma>"
		emptyText: "No Results. Hit tab or comma to add this tag"
		preFill: $('#bookmark_tag_tokens').data("load")
		asHtmlID: "tag_tokens"