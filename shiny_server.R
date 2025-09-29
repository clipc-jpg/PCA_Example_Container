
server <- function(input, output, session) {
        configs <- reactiveVal(list())

        observeEvent(input$add_plot, {
            new_config <- list(n_components = 2, plot_components = c(1,2))
            configs(append(configs(), list(new_config)))
        })

        output$plot_selectors <- renderUI({
            lapply(seq_along(configs()), function(i) {
                fluidRow(
                    column(3,
                        numericInput(paste0("ncomp_", i),
                        label = paste("Set", i, "– # PCs to keep"),
                        value = configs()[[i]]$n_components,
                        min = 2, max = 4, step = 1)
                    ),
                    column(3,
                        selectInput(paste0("pcx_", i),
                        label = paste("Set", i, "– X-axis PC"),
                        choices = 1:4,
                        selected = configs()[[i]]$plot_components[1])
                    ),
                    column(3,
                        selectInput(paste0("pcy_", i),
                        label = paste("Set", i, "– Y-axis PC"),
                        choices = 1:4,
                        selected = configs()[[i]]$plot_components[2])
                    )
                )
            })
        })

        observe({
            current <- configs()
            for (i in seq_along(current)) {
                ncomp <- input[[paste0("ncomp_", i)]]
                pcx   <- input[[paste0("pcx_", i)]]
                pcy   <- input[[paste0("pcy_", i)]]
                if (!is.null(ncomp) && !is.null(pcx) && !is.null(pcy)) {
                    current[[i]] <- list(
                        n_components = ncomp,
                        plot_components = c(as.integer(pcx), as.integer(pcy))
                    )
                }
            }
            configs(current)
        })

        output$config_table <- renderTable({
            do.call(rbind, lapply(seq_along(configs()), function(i) {
                c(Set = i,
                    n_components = configs()[[i]]$n_components,
                    PCx = configs()[[i]]$plot_components[1],
                    PCy = configs()[[i]]$plot_components[2])
            }))
        })

        output$download_json <- downloadHandler(
                        filename = function() { "hyperparams.json" },
                        content = function(file) {
                        confs <- configs()
                        write_json(confs, file, pretty = TRUE, auto_unbox = TRUE)
            }
        )

        observeEvent(input$terminate, {
            stopApp()
        })

        observeEvent(input$save_config, {
        confs <- configs()

        # validation
        for (i in seq_along(confs)) {
            ncomp <- confs[[i]]$n_components
            pcs   <- confs[[i]]$plot_components
            if (any(pcs > ncomp)) {
                showModal(modalDialog(
                    title = "Invalid configuration",
                    paste("In set", i,
                            "you selected PCs", paste(pcs, collapse = ","),
                            "but only", ncomp, "components are kept."),
                            easyClose = TRUE
                ))
                return(NULL)
            }
        }

            # interop mode: POST instead of download
            if (interop_mode) {
			  json_payload <- toJSON(confs, pretty = TRUE, auto_unbox = TRUE)
			  # pass configs to JS fetch
			  runjs(sprintf("sendConfigToActix(%s);", json_payload))

			  # wait for JS response
			  observeEvent(input$interop_result, {
				result <- input$interop_result
				if (startsWith(result, "Error:")) {
				  showModal(modalDialog(
					title = "Interop Failed",
					paste("Could not send config to Colony:", result),
					easyClose = TRUE
				  ))
				} else {
				  showModal(modalDialog(
					title = "Interop Success",
					"Configuration sent successfully to Colony.",
					easyClose = TRUE
				  ))
				}
			  })
			} else {
            # normal download mode
            showModal(modalDialog(
                title = "Download Ready",
                p("All configurations are valid. Click below to download:"),
                                        downloadButton("download_json", "Download JSON Config"),
                                        easyClose = TRUE
            ))
        }
		})
		
		# workaround: /terminate endpoint cannot be added to shiny apps
		# alternatives do not work or are quite verbose
		observeEvent(input$terminate, {
			stopApp()
		})
}