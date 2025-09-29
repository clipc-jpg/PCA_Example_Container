


ui <- fluidPage(

	useShinyjs(),

	titlePanel("PCA Config Builder for IRIS"),

	p("Dataset: IRIS (built-in)"),

	actionButton("add_plot", "Add Plot Configuration"),
	br(), br(),

	uiOutput("plot_selectors"),

	h4("Current Configurations"),
	tableOutput("config_table"),

	actionButton("save_config", "Save JSON Config"),
	
	# workaround: /terminate endpoint cannot be added to shiny apps
	# alternatives do not work or are quite verbose
	actionButton("terminate", "Terminate Server"),
	
	tags$script(HTML("
	  function sendConfigToActix(config) {
		fetch('http://127.0.0.1:20311/config/json', {
		  method: 'POST',
		  headers: { 'Content-Type': 'application/json' },
		  body: JSON.stringify(config)
		})
		.then(response => response.text())
		.then(txt => Shiny.setInputValue('interop_result', txt))
		.catch(err => Shiny.setInputValue('interop_result', 'Error: ' + err));
	  }
	"))
)
