package main

import (
	"encoding/base64"
	"fmt"
	"log"
	"net/http"
	"os"
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
		active, err := listActive()

		if err != nil {
			log.Fatal(err)
		}

		jsonFu(active, func(a ...any) (n int, err error) {
			line := fmt.Sprint(a[0])
			w.Write([]byte(line))
			return 0, nil
		})
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

func hyperText() string {
	var hypertext string
	activeplanes, errListing := listActive()

	if errListing != nil {
		log.Fatal(errListing)
	}

	hypertext += fmt.Sprintf(`
	<!DOCTYPE html>
	<html>
	<head>
	<title>HyprPaperPlanes API %s</title>
	<style>
		* {
			background-color: black;
			color: white;
		}

		.formats {
			display: flex;
			justify-content: space-evenly;
		}
	</style>
	</head>
	<body>
		<div class="formats">
		<a href="/hyprpaper.conf">hyprpaper.conf</a>
		<a href="/json">JSON</a>
		</div>
	`, VERSION)

	for _, p := range activeplanes {
		bts, err := os.ReadFile(p.paper)

		if err != nil {
			log.Fatal(err)
		}

		data := fmt.Sprintf("data:%s;base64,%s",
			http.DetectContentType(bts),
			base64.StdEncoding.EncodeToString(bts))

		hypertext += fmt.Sprintf(`
		<div class="%s">%s</div>
		<style>
		.%s {
			line-height: 8rem; 
			text-align:center; 
			font-size: 4rem; 
			color: white; 
			width: 1280px; 
			height: 720px;
			margin-left: auto;
			margin-right: auto;
			margin-top: 80px;
			background-size: 1280px 720px; 
			background-image: url(%s);
			border: 4px solid white;
			border-radius: 12px;
		};
		</style>`, p.monitor, p.monitor, p.monitor, data)
	}

	hypertext += `</body></html>`
	return hypertext
}
