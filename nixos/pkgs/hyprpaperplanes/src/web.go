package main

import (
	"fmt"
	"net/http"
)

func api() {

	mux := http.NewServeMux()
	mux.HandleFunc("GET /{$}", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte(hyperText()))
	})

	handleConfig := func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte(configText()))
	}

	handleJSON := func(w http.ResponseWriter, r *http.Request) {

		w.Write([]byte(jsonText()))
	}

	mux.HandleFunc("GET /conf", handleConfig)
	mux.HandleFunc("GET /config", handleConfig)
	mux.HandleFunc("GET /configuration", handleConfig)
	mux.HandleFunc("GET /hyprpaper.conf", handleConfig)

	mux.HandleFunc("GET /json", handleJSON)

	server := http.Server{Addr: ":3000", Handler: mux}
	fmt.Println("Listening @ http://127.0.0.1:3000")
	server.ListenAndServe()
}
